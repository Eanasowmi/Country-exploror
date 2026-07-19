package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.ProductDto;
import com.ecommerce.multivendor.application.dto.ProductImageDto;
import com.ecommerce.multivendor.application.dto.WishlistItemDto;
import com.ecommerce.multivendor.domain.entities.Product;
import com.ecommerce.multivendor.domain.entities.User;
import com.ecommerce.multivendor.domain.entities.WishlistItem;
import com.ecommerce.multivendor.domain.repositories.ProductRepository;
import com.ecommerce.multivendor.domain.repositories.UserRepository;
import com.ecommerce.multivendor.domain.repositories.WishlistItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WishlistService {

    private final WishlistItemRepository wishlistItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<WishlistItemDto> getWishlist(UUID userId) {
        return wishlistItemRepository.findByUserId(userId).stream()
                .map(this::mapToWishlistItemDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public WishlistItemDto addProductToWishlist(UUID userId, UUID productId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        Optional<WishlistItem> existing = wishlistItemRepository.findByUserIdAndProductId(userId, productId);
        if (existing.isPresent()) {
            return mapToWishlistItemDto(existing.get());
        }

        WishlistItem item = WishlistItem.builder()
                .user(user)
                .product(product)
                .build();

        WishlistItem saved = wishlistItemRepository.save(item);
        return mapToWishlistItemDto(saved);
    }

    @Transactional
    public void removeProductFromWishlist(UUID userId, UUID productId) {
        Optional<WishlistItem> existing = wishlistItemRepository.findByUserIdAndProductId(userId, productId);
        existing.ifPresent(wishlistItemRepository::delete);
    }

    private WishlistItemDto mapToWishlistItemDto(WishlistItem item) {
        return WishlistItemDto.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .product(mapToProductDto(item.getProduct()))
                .createdAt(item.getCreatedAt())
                .build();
    }

    private ProductDto mapToProductDto(Product product) {
        List<ProductImageDto> imageDtos = product.getImages().stream()
                .map(img -> ProductImageDto.builder()
                        .id(img.getId())
                        .url(img.getUrl())
                        .primary(img.isPrimary())
                        .build())
                .collect(Collectors.toList());

        return ProductDto.builder()
                .id(product.getId())
                .name(product.getName())
                .slug(product.getSlug())
                .description(product.getDescription())
                .price(product.getPrice())
                .discountPrice(product.getDiscountPrice())
                .stockQuantity(product.getStockQuantity())
                .sku(product.getSku())
                .active(product.isActive())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .categoryName(product.getCategory() != null ? product.getCategory().getName() : null)
                .brandId(product.getBrand() != null ? product.getBrand().getId() : null)
                .brandName(product.getBrand() != null ? product.getBrand().getName() : null)
                .vendorId(product.getVendor() != null ? product.getVendor().getId() : null)
                .vendorName(product.getVendor() != null ? (product.getVendor().getFirstName() + " " + product.getVendor().getLastName()) : null)
                .images(imageDtos)
                .build();
    }
}
