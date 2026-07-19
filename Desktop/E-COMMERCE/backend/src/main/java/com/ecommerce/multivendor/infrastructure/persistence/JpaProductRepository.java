package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface JpaProductRepository extends JpaRepository<Product, UUID> {
    
    Optional<Product> findBySlug(String slug);
    
    boolean existsBySlug(String slug);
    
    boolean existsBySku(String sku);
    
    List<Product> findByVendorId(UUID vendorId);
    
    @Query("SELECT DISTINCT p FROM Product p WHERE p.active = true")
    Page<Product> findAllActive(Pageable pageable);

    @Query("SELECT DISTINCT p FROM Product p WHERE p.active = false")
    Page<Product> findPendingApproval(Pageable pageable);

    @Query("SELECT DISTINCT p FROM Product p JOIN p.category c WHERE c.slug = :categorySlug AND p.active = true")
    Page<Product> findByCategorySlug(@Param("categorySlug") String categorySlug, Pageable pageable);

    @Query("SELECT DISTINCT p FROM Product p JOIN p.brand b WHERE b.slug = :brandSlug AND p.active = true")
    Page<Product> findByBrandSlug(@Param("brandSlug") String brandSlug, Pageable pageable);

    @Query("SELECT DISTINCT p FROM Product p WHERE (LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :query, '%'))) AND p.active = true")
    Page<Product> searchProducts(@Param("query") String query, Pageable pageable);

    @Query("SELECT DISTINCT p FROM Product p WHERE (:categoryId IS NULL OR p.category.id = :categoryId) " +
           "AND (:brandId IS NULL OR p.brand.id = :brandId) " +
           "AND (:minPrice IS NULL OR p.price >= :minPrice) " +
           "AND (:maxPrice IS NULL OR p.price <= :maxPrice) " +
           "AND p.active = true")
    Page<Product> filterProducts(
            @Param("categoryId") UUID categoryId,
            @Param("brandId") UUID brandId,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice,
            Pageable pageable
    );
}
