package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.WishlistItem;
import com.ecommerce.multivendor.domain.repositories.WishlistItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class WishlistItemRepositoryImpl implements WishlistItemRepository {

    private final JpaWishlistItemRepository jpaWishlistItemRepository;

    @Override
    public WishlistItem save(WishlistItem item) {
        return jpaWishlistItemRepository.save(item);
    }

    @Override
    public List<WishlistItem> findByUserId(UUID userId) {
        return jpaWishlistItemRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    public Optional<WishlistItem> findByUserIdAndProductId(UUID userId, UUID productId) {
        return jpaWishlistItemRepository.findByUserIdAndProductId(userId, productId);
    }

    @Override
    public void delete(WishlistItem item) {
        jpaWishlistItemRepository.delete(item);
    }
}
