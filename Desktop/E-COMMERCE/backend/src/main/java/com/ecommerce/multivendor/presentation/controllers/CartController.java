package com.ecommerce.multivendor.presentation.controllers;

import com.ecommerce.multivendor.application.dto.CartItemDto;
import com.ecommerce.multivendor.application.dto.CartItemRequest;
import com.ecommerce.multivendor.application.usecases.CartService;
import com.ecommerce.multivendor.infrastructure.security.CustomUserDetails;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public ResponseEntity<List<CartItemDto>> getCart(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(cartService.getCart(userDetails.getUser().getId()));
    }

    @PostMapping
    public ResponseEntity<CartItemDto> addToCart(
            @Valid @RequestBody CartItemRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        return ResponseEntity.ok(cartService.addToCart(request, userDetails.getUser().getId()));
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<CartItemDto> updateCartItemQuantity(
            @PathVariable UUID itemId,
            @RequestParam int quantity,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        return ResponseEntity.ok(cartService.updateCartItemQuantity(itemId, quantity, userDetails.getUser().getId()));
    }

    @DeleteMapping("/{itemId}")
    public ResponseEntity<Void> removeFromCart(
            @PathVariable UUID itemId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        cartService.removeFromCart(itemId, userDetails.getUser().getId());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearCart(@AuthenticationPrincipal CustomUserDetails userDetails) {
        cartService.clearCart(userDetails.getUser().getId());
        return ResponseEntity.noContent().build();
    }
}
