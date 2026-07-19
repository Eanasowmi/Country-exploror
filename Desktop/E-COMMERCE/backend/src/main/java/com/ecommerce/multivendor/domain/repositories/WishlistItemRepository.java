package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.WishlistItem;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WishlistItemRepository {
    WishlistItem save(WishlistItem item);
    List<WishlistItem> findByUserId(UUID userId);
    Optional<WishlistItem> findByUserIdAndProductId(UUID userId, UUID productId);
    void delete(WishlistItem item);
}
