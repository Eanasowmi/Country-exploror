package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.CheckoutRequest;
import com.ecommerce.multivendor.application.dto.OrderDto;
import com.ecommerce.multivendor.application.dto.OrderItemDto;
import com.ecommerce.multivendor.domain.entities.*;
import com.ecommerce.multivendor.domain.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Transactional
    public OrderDto createOrder(CheckoutRequest request, UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        List<CartItem> cartItems = cartItemRepository.findByUserId(userId);
        if (cartItems.isEmpty()) {
            throw new IllegalStateException("Cannot checkout: Cart is empty");
        }

        // Validate stock and calculate total amount
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            Product product = item.getProduct();
            if (product.getStockQuantity() < item.getQuantity()) {
                throw new IllegalArgumentException("Insufficient stock for product: " + product.getName() + 
                        " (Available: " + product.getStockQuantity() + ")");
            }
            
            BigDecimal itemPrice = product.getDiscountPrice() != null ? product.getDiscountPrice() : product.getPrice();
            BigDecimal itemTotal = itemPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);
        }

        // Generate Order number
        String orderNumber = "ORD-" + System.currentTimeMillis() + "-" + (int)(Math.random() * 1000);

        Order order = Order.builder()
                .user(user)
                .orderNumber(orderNumber)
                .status(request.getPaymentMethod().equalsIgnoreCase("COD") ? "PROCESSING" : "PAYMENT_PENDING")
                .totalAmount(totalAmount)
                .paymentMethod(request.getPaymentMethod())
                .paymentStatus("PENDING")
                .shippingAddress(request.getShippingAddress())
                .build();

        // Create Order items and deduct inventory
        for (CartItem item : cartItems) {
            Product product = item.getProduct();
            // Deduct stock
            product.setStockQuantity(product.getStockQuantity() - item.getQuantity());
            productRepository.save(product);

            BigDecimal itemPrice = product.getDiscountPrice() != null ? product.getDiscountPrice() : product.getPrice();
            OrderItem orderItem = OrderItem.builder()
                    .product(product)
                    .quantity(item.getQuantity())
                    .price(itemPrice)
                    .build();
            
            order.addItem(orderItem);
        }

        // Save order and clear cart
        Order savedOrder = orderRepository.save(order);
        cartItemRepository.deleteByUserId(userId);

        return mapToOrderDto(savedOrder);
    }

    @Transactional(readOnly = true)
    public List<OrderDto> getMyOrders(UUID userId) {
        return orderRepository.findByUserId(userId).stream()
                .map(this::mapToOrderDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<OrderDto> getSellerOrders(UUID vendorId) {
        return orderRepository.findBySellerId(vendorId).stream()
                .map(order -> mapToOrderDtoForSeller(order, vendorId))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public OrderDto getOrderById(UUID id, User currentUser) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        boolean isAdmin = currentUser.getRoles().stream()
                .anyMatch(role -> role.getName().equals("ADMIN") || role.getName().equals("SUPER_ADMIN"));

        if (!isAdmin && !order.getUser().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("Unauthorized: you do not own this order");
        }

        return mapToOrderDto(order);
    }

    @Transactional(readOnly = true)
    public List<OrderDto> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::mapToOrderDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public OrderDto updateOrderStatus(UUID id, String status, Integer estimatedDeliveryDays) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        order.setStatus(status);
        if (status.equalsIgnoreCase("DELIVERED")) {
            order.setPaymentStatus("PAID");
        }
        if (status.equalsIgnoreCase("SHIPPED") && estimatedDeliveryDays != null) {
            order.setEstimatedDeliveryDays(estimatedDeliveryDays);
        }
        Order saved = orderRepository.save(order);
        return mapToOrderDto(saved);
    }

    @Transactional
    public OrderDto cancelOrder(UUID id, User currentUser) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        if (!order.getUser().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("Unauthorized: you do not own this order");
        }

        if (order.getStatus().equalsIgnoreCase("SHIPPED") || order.getStatus().equalsIgnoreCase("DELIVERED") || order.getStatus().equalsIgnoreCase("CANCELLED")) {
            throw new IllegalStateException("Cannot cancel order with status: " + order.getStatus());
        }

        order.setStatus("CANCELLED");
        
        // Restore stock quantity
        for (OrderItem item : order.getItems()) {
            Product product = item.getProduct();
            product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
            productRepository.save(product);
        }

        Order saved = orderRepository.save(order);
        return mapToOrderDto(saved);
    }

    @Transactional
    public void deleteOrder(UUID id, User currentUser) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        if (!order.getUser().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("Unauthorized: you do not own this order");
        }

        if (order.getStatus().equalsIgnoreCase("SHIPPED") || order.getStatus().equalsIgnoreCase("DELIVERED")) {
            throw new IllegalStateException("Cannot delete order with status: " + order.getStatus());
        }

        if (!order.getStatus().equalsIgnoreCase("CANCELLED")) {
            // Restore stock quantity before deleting if it hasn't been cancelled
            for (OrderItem item : order.getItems()) {
                Product product = item.getProduct();
                product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
                productRepository.save(product);
            }
        }

        orderRepository.delete(order);
    }

    private OrderDto mapToOrderDto(Order order) {
        List<OrderItemDto> itemDtos = order.getItems().stream()
                .map(item -> {
                    String primaryImageUrl = item.getProduct().getImages().stream()
                            .filter(ProductImage::isPrimary)
                            .map(ProductImage::getUrl)
                            .findFirst()
                            .orElse(item.getProduct().getImages().isEmpty() ? "" : item.getProduct().getImages().get(0).getUrl());

                    return OrderItemDto.builder()
                            .id(item.getId())
                            .productId(item.getProduct().getId())
                            .productName(item.getProduct().getName())
                            .productSlug(item.getProduct().getSlug())
                            .productImageUrl(primaryImageUrl)
                            .sellerPhone(item.getProduct().getVendor() != null ? item.getProduct().getVendor().getPhoneNumber() : null)
                            .quantity(item.getQuantity())
                            .price(item.getPrice())
                            .build();
                })
                .collect(Collectors.toList());

        return OrderDto.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .status(order.getStatus())
                .totalAmount(order.getTotalAmount())
                .paymentMethod(order.getPaymentMethod())
                .paymentStatus(order.getPaymentStatus())
                .shippingAddress(order.getShippingAddress())
                .customerName(order.getUser().getFirstName() + " " + order.getUser().getLastName())
                .customerEmail(order.getUser().getEmail())
                .customerPhone(order.getUser().getPhoneNumber())
                .estimatedDeliveryDays(order.getEstimatedDeliveryDays())
                .items(itemDtos)
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .build();
    }

    private OrderDto mapToOrderDtoForSeller(Order order, UUID vendorId) {
        List<OrderItemDto> itemDtos = order.getItems().stream()
                .filter(item -> item.getProduct().getVendor() != null && item.getProduct().getVendor().getId().equals(vendorId))
                .map(item -> {
                    String primaryImageUrl = item.getProduct().getImages().stream()
                            .filter(ProductImage::isPrimary)
                            .map(ProductImage::getUrl)
                            .findFirst()
                            .orElse(item.getProduct().getImages().isEmpty() ? "" : item.getProduct().getImages().get(0).getUrl());

                    return OrderItemDto.builder()
                            .id(item.getId())
                            .productId(item.getProduct().getId())
                            .productName(item.getProduct().getName())
                            .productSlug(item.getProduct().getSlug())
                            .productImageUrl(primaryImageUrl)
                            .sellerPhone(item.getProduct().getVendor() != null ? item.getProduct().getVendor().getPhoneNumber() : null)
                            .quantity(item.getQuantity())
                            .price(item.getPrice())
                            .build();
                })
                .collect(Collectors.toList());

        BigDecimal totalAmount = itemDtos.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return OrderDto.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .status(order.getStatus())
                .totalAmount(totalAmount)
                .paymentMethod(order.getPaymentMethod())
                .paymentStatus(order.getPaymentStatus())
                .shippingAddress(order.getShippingAddress())
                .customerName(order.getUser().getFirstName() + " " + order.getUser().getLastName())
                .customerEmail(order.getUser().getEmail())
                .customerPhone(order.getUser().getPhoneNumber())
                .estimatedDeliveryDays(order.getEstimatedDeliveryDays())
                .items(itemDtos)
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .build();
    }
}
