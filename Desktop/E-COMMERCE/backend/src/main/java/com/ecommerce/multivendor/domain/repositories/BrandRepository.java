package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.Brand;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BrandRepository {
    Optional<Brand> findById(UUID id);
    Optional<Brand> findBySlug(String slug);
    List<Brand> findAll();
    Brand save(Brand brand);
    void delete(Brand brand);
    boolean existsBySlug(String slug);
}
