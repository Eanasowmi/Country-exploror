package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.Product;
import com.ecommerce.multivendor.domain.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class ProductRepositoryImpl implements ProductRepository {

    private final JpaProductRepository jpaProductRepository;

    @Override
    public Optional<Product> findById(UUID id) {
        return jpaProductRepository.findById(id);
    }

    @Override
    public Optional<Product> findBySlug(String slug) {
        return jpaProductRepository.findBySlug(slug);
    }

    @Override
    public Page<Product> findAll(Pageable pageable) {
        return jpaProductRepository.findAllActive(pageable);
    }

    @Override
    public Page<Product> findByCategorySlug(String categorySlug, Pageable pageable) {
        return jpaProductRepository.findByCategorySlug(categorySlug, pageable);
    }

    @Override
    public Page<Product> findByBrandSlug(String brandSlug, Pageable pageable) {
        return jpaProductRepository.findByBrandSlug(brandSlug, pageable);
    }

    @Override
    public Page<Product> searchProducts(String query, Pageable pageable) {
        return jpaProductRepository.searchProducts(query, pageable);
    }

    @Override
    public Page<Product> filterProducts(UUID categoryId, UUID brandId, BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable) {
        return jpaProductRepository.filterProducts(categoryId, brandId, minPrice, maxPrice, pageable);
    }

    @Override
    public Product save(Product product) {
        return jpaProductRepository.save(product);
    }

    @Override
    public void delete(Product product) {
        jpaProductRepository.delete(product);
    }

    @Override
    public boolean existsBySlug(String slug) {
        return jpaProductRepository.existsBySlug(slug);
    }

    @Override
    public boolean existsBySku(String sku) {
        return jpaProductRepository.existsBySku(sku);
    }

    @Override
    public List<Product> findByVendorId(UUID vendorId) {
        return jpaProductRepository.findByVendorId(vendorId);
    }

    @Override
    public Page<Product> findPendingApproval(Pageable pageable) {
        return jpaProductRepository.findPendingApproval(pageable);
    }
}
