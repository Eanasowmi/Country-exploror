package com.ecommerce.multivendor.presentation.controllers;

import com.ecommerce.multivendor.application.dto.WishlistItemDto;
import com.ecommerce.multivendor.application.usecases.WishlistService;
import com.ecommerce.multivendor.infrastructure.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/wishlist")
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;

    @GetMapping
    public ResponseEntity<List<WishlistItemDto>> getWishlist(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(wishlistService.getWishlist(userDetails.getUser().getId()));
    }

    @PostMapping("/{productId}")
    public ResponseEntity<WishlistItemDto> addToWishlist(
            @PathVariable UUID productId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        return ResponseEntity.ok(wishlistService.addProductToWishlist(userDetails.getUser().getId(), productId));
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFromWishlist(
            @PathVariable UUID productId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        wishlistService.removeProductFromWishlist(userDetails.getUser().getId(), productId);
        return ResponseEntity.noContent().build();
    }
}
