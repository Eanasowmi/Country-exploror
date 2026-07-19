package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository {
    Optional<Product> findById(UUID id);
    Optional<Product> findBySlug(String slug);
    Page<Product> findAll(Pageable pageable);
    Page<Product> findByCategorySlug(String categorySlug, Pageable pageable);
    Page<Product> findByBrandSlug(String brandSlug, Pageable pageable);
    Page<Product> searchProducts(String query, Pageable pageable);
    Page<Product> filterProducts(
            UUID categoryId,
            UUID brandId,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Pageable pageable
    );
    Product save(Product product);
    void delete(Product product);
    boolean existsBySlug(String slug);
    boolean existsBySku(String sku);
    List<Product> findByVendorId(UUID vendorId);
    Page<Product> findPendingApproval(Pageable pageable);
}
