package com.ecommerce.multivendor.presentation.controllers;

import com.ecommerce.multivendor.application.dto.BrandCreateRequest;
import com.ecommerce.multivendor.application.dto.BrandDto;
import com.ecommerce.multivendor.application.usecases.CategoryBrandService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/brands")
@RequiredArgsConstructor
public class BrandController {

    private final CategoryBrandService categoryBrandService;

    @GetMapping
    public ResponseEntity<List<BrandDto>> getAllBrands() {
        return ResponseEntity.ok(categoryBrandService.getAllBrands());
    }

    @GetMapping("/{id}")
    public ResponseEntity<BrandDto> getBrandById(@PathVariable UUID id) {
        return ResponseEntity.ok(categoryBrandService.getBrandById(id));
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<BrandDto> getBrandBySlug(@PathVariable String slug) {
        return ResponseEntity.ok(categoryBrandService.getBrandBySlug(slug));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<BrandDto> createBrand(@Valid @RequestBody BrandCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(categoryBrandService.createBrand(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<BrandDto> updateBrand(@PathVariable UUID id, @Valid @RequestBody BrandCreateRequest request) {
        return ResponseEntity.ok(categoryBrandService.updateBrand(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<Void> deleteBrand(@PathVariable UUID id) {
        categoryBrandService.deleteBrand(id);
        return ResponseEntity.noContent().build();
    }
}
