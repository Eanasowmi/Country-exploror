package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.Brand;
import com.ecommerce.multivendor.domain.repositories.BrandRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class BrandRepositoryImpl implements BrandRepository {

    private final JpaBrandRepository jpaBrandRepository;

    @Override
    public Optional<Brand> findById(UUID id) {
        return jpaBrandRepository.findById(id);
    }

    @Override
    public Optional<Brand> findBySlug(String slug) {
        return jpaBrandRepository.findBySlug(slug);
    }

    @Override
    public List<Brand> findAll() {
        return jpaBrandRepository.findAll();
    }

    @Override
    public Brand save(Brand brand) {
        return jpaBrandRepository.save(brand);
    }

    @Override
    public void delete(Brand brand) {
        jpaBrandRepository.delete(brand);
    }

    @Override
    public boolean existsBySlug(String slug) {
        return jpaBrandRepository.existsBySlug(slug);
    }
}
