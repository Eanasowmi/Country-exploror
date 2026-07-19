package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.*;
import com.ecommerce.multivendor.domain.entities.Brand;
import com.ecommerce.multivendor.domain.entities.Category;
import com.ecommerce.multivendor.domain.repositories.BrandRepository;
import com.ecommerce.multivendor.domain.repositories.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryBrandService {

    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;

    private String toSlug(String input) {
        if (input == null) return "";
        return input.toLowerCase()
                .replaceAll("[^a-z0-9\\s]", "")
                .replaceAll("\\s+", "-");
    }

    // Categories
    @Transactional(readOnly = true)
    public List<CategoryDto> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToCategoryDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CategoryDto getCategoryById(UUID id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found with ID: " + id));
        return mapToCategoryDto(category);
    }

    @Transactional(readOnly = true)
    public CategoryDto getCategoryBySlug(String slug) {
        Category category = categoryRepository.findBySlug(slug)
                .orElseThrow(() -> new IllegalArgumentException("Category not found with slug: " + slug));
        return mapToCategoryDto(category);
    }

    @Transactional
    public CategoryDto createCategory(CategoryCreateRequest request) {
        String slug = toSlug(request.getName());
        if (categoryRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        Category parent = null;
        if (request.getParentId() != null) {
            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new IllegalArgumentException("Parent category not found with ID: " + request.getParentId()));
        }

        Category category = Category.builder()
                .name(request.getName())
                .slug(slug)
                .description(request.getDescription())
                .parent(parent)
                .build();

        Category saved = categoryRepository.save(category);
        return mapToCategoryDto(saved);
    }

    // Brands
    @Transactional(readOnly = true)
    public List<BrandDto> getAllBrands() {
        return brandRepository.findAll().stream()
                .map(this::mapToBrandDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public BrandDto getBrandById(UUID id) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Brand not found with ID: " + id));
        return mapToBrandDto(brand);
    }

    @Transactional(readOnly = true)
    public BrandDto getBrandBySlug(String slug) {
        Brand brand = brandRepository.findBySlug(slug)
                .orElseThrow(() -> new IllegalArgumentException("Brand not found with slug: " + slug));
        return mapToBrandDto(brand);
    }

    @Transactional
    public BrandDto createBrand(BrandCreateRequest request) {
        String slug = toSlug(request.getName());
        if (brandRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        Brand brand = Brand.builder()
                .name(request.getName())
                .slug(slug)
                .description(request.getDescription())
                .logoUrl(request.getLogoUrl())
                .build();

        Brand saved = brandRepository.save(brand);
        return mapToBrandDto(saved);
    }

    @Transactional
    public CategoryDto updateCategory(UUID id, CategoryCreateRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found with ID: " + id));

        String slug = toSlug(request.getName());
        if (!slug.equals(category.getSlug()) && categoryRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        Category parent = null;
        if (request.getParentId() != null) {
            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new IllegalArgumentException("Parent category not found with ID: " + request.getParentId()));
        }

        category.setName(request.getName());
        category.setSlug(slug);
        category.setDescription(request.getDescription());
        category.setParent(parent);

        return mapToCategoryDto(categoryRepository.save(category));
    }

    @Transactional
    public void deleteCategory(UUID id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found with ID: " + id));
        categoryRepository.delete(category);
    }

    @Transactional
    public BrandDto updateBrand(UUID id, BrandCreateRequest request) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Brand not found with ID: " + id));

        String slug = toSlug(request.getName());
        if (!slug.equals(brand.getSlug()) && brandRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        brand.setName(request.getName());
        brand.setSlug(slug);
        brand.setDescription(request.getDescription());
        brand.setLogoUrl(request.getLogoUrl());

        return mapToBrandDto(brandRepository.save(brand));
    }

    @Transactional
    public void deleteBrand(UUID id) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Brand not found with ID: " + id));
        brandRepository.delete(brand);
    }

    private CategoryDto mapToCategoryDto(Category category) {
        return CategoryDto.builder()
                .id(category.getId())
                .name(category.getName())
                .slug(category.getSlug())
                .description(category.getDescription())
                .parentId(category.getParent() != null ? category.getParent().getId() : null)
                .build();
    }

    private BrandDto mapToBrandDto(Brand brand) {
        return BrandDto.builder()
                .id(brand.getId())
                .name(brand.getName())
                .slug(brand.getSlug())
                .description(brand.getDescription())
                .logoUrl(brand.getLogoUrl())
                .build();
    }
}
