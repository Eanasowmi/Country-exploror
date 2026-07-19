package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.Category;
import com.ecommerce.multivendor.domain.repositories.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CategoryRepositoryImpl implements CategoryRepository {

    private final JpaCategoryRepository jpaCategoryRepository;

    @Override
    public Optional<Category> findById(UUID id) {
        return jpaCategoryRepository.findById(id);
    }

    @Override
    public Optional<Category> findBySlug(String slug) {
        return jpaCategoryRepository.findBySlug(slug);
    }

    @Override
    public List<Category> findAll() {
        return jpaCategoryRepository.findAll();
    }

    @Override
    public List<Category> findByParentIdNull() {
        return jpaCategoryRepository.findByParentIdNull();
    }

    @Override
    public Category save(Category category) {
        return jpaCategoryRepository.save(category);
    }

    @Override
    public void delete(Category category) {
        jpaCategoryRepository.delete(category);
    }

    @Override
    public boolean existsBySlug(String slug) {
        return jpaCategoryRepository.existsBySlug(slug);
    }
}
