package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.Category;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CategoryRepository {
    Optional<Category> findById(UUID id);
    Optional<Category> findBySlug(String slug);
    List<Category> findAll();
    List<Category> findByParentIdNull();
    Category save(Category category);
    void delete(Category category);
    boolean existsBySlug(String slug);
}
