package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.CartItem;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CartItemRepository {
    Optional<CartItem> findById(UUID id);
    Optional<CartItem> findByUserIdAndProductId(UUID userId, UUID productId);
    List<CartItem> findByUserId(UUID userId);
    CartItem save(CartItem cartItem);
    void delete(CartItem cartItem);
    void deleteByUserId(UUID userId);
}
