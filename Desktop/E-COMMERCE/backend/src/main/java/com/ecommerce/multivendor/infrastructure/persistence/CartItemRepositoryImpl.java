package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.CartItem;
import com.ecommerce.multivendor.domain.repositories.CartItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CartItemRepositoryImpl implements CartItemRepository {

    private final JpaCartItemRepository jpaCartItemRepository;

    @Override
    public Optional<CartItem> findById(UUID id) {
        return jpaCartItemRepository.findById(id);
    }

    @Override
    public Optional<CartItem> findByUserIdAndProductId(UUID userId, UUID productId) {
        return jpaCartItemRepository.findByUserIdAndProductId(userId, productId);
    }

    @Override
    public List<CartItem> findByUserId(UUID userId) {
        return jpaCartItemRepository.findByUserId(userId);
    }

    @Override
    public CartItem save(CartItem cartItem) {
        return jpaCartItemRepository.save(cartItem);
    }

    @Override
    public void delete(CartItem cartItem) {
        jpaCartItemRepository.delete(cartItem);
    }

    @Override
    public void deleteByUserId(UUID userId) {
        jpaCartItemRepository.deleteByUserId(userId);
    }
}
