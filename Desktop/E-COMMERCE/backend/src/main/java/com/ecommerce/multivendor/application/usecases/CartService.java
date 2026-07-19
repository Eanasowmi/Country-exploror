package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.CartItemDto;
import com.ecommerce.multivendor.application.dto.CartItemRequest;
import com.ecommerce.multivendor.domain.entities.CartItem;
import com.ecommerce.multivendor.domain.entities.Product;
import com.ecommerce.multivendor.domain.entities.User;
import com.ecommerce.multivendor.domain.repositories.CartItemRepository;
import com.ecommerce.multivendor.domain.repositories.ProductRepository;
import com.ecommerce.multivendor.domain.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<CartItemDto> getCart(UUID userId) {
        return cartItemRepository.findByUserId(userId).stream()
                .map(this::mapToCartItemDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CartItemDto addToCart(CartItemRequest request, UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        if (product.getStockQuantity() < request.getQuantity()) {
            throw new IllegalArgumentException("Requested quantity exceeds available stock (" + product.getStockQuantity() + ")");
        }

        Optional<CartItem> existingItemOpt = cartItemRepository.findByUserIdAndProductId(userId, request.getProductId());
        CartItem cartItem;

        if (existingItemOpt.isPresent()) {
            cartItem = existingItemOpt.get();
            int newQty = cartItem.getQuantity() + request.getQuantity();
            if (product.getStockQuantity() < newQty) {
                throw new IllegalArgumentException("Requested total quantity exceeds available stock");
            }
            cartItem.setQuantity(newQty);
        } else {
            cartItem = CartItem.builder()
                    .user(user)
                    .product(product)
                    .quantity(request.getQuantity())
                    .build();
        }

        CartItem saved = cartItemRepository.save(cartItem);
        return mapToCartItemDto(saved);
    }

    @Transactional
    public CartItemDto updateCartItemQuantity(UUID cartItemId, int quantity, UUID userId) {
        CartItem cartItem = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));

        if (!cartItem.getUser().getId().equals(userId)) {
            throw new IllegalStateException("Unauthorized: you do not own this cart item");
        }

        if (cartItem.getProduct().getStockQuantity() < quantity) {
            throw new IllegalArgumentException("Requested quantity exceeds available stock (" + cartItem.getProduct().getStockQuantity() + ")");
        }

        cartItem.setQuantity(quantity);
        CartItem saved = cartItemRepository.save(cartItem);
        return mapToCartItemDto(saved);
    }

    @Transactional
    public void removeFromCart(UUID cartItemId, UUID userId) {
        CartItem cartItem = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));

        if (!cartItem.getUser().getId().equals(userId)) {
            throw new IllegalStateException("Unauthorized: you do not own this cart item");
        }

        cartItemRepository.delete(cartItem);
    }

    @Transactional
    public void clearCart(UUID userId) {
        cartItemRepository.deleteByUserId(userId);
    }

    private CartItemDto mapToCartItemDto(CartItem item) {
        String primaryImageUrl = item.getProduct().getImages().stream()
                .filter(img -> img.isPrimary())
                .map(img -> img.getUrl())
                .findFirst()
                .orElse(item.getProduct().getImages().isEmpty() ? "" : item.getProduct().getImages().get(0).getUrl());

        double price = item.getProduct().getDiscountPrice() != null
                ? item.getProduct().getDiscountPrice().doubleValue()
                : item.getProduct().getPrice().doubleValue();

        return CartItemDto.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .productName(item.getProduct().getName())
                .productSlug(item.getProduct().getSlug())
                .productImageUrl(primaryImageUrl)
                .price(price)
                .quantity(item.getQuantity())
                .build();
    }
}
