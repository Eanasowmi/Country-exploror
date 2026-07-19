package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.ProductCreateRequest;
import com.ecommerce.multivendor.application.dto.ProductDto;
import com.ecommerce.multivendor.application.dto.ProductImageDto;
import com.ecommerce.multivendor.domain.entities.*;
import com.ecommerce.multivendor.domain.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final UserRepository userRepository;

    private String toSlug(String input) {
        if (input == null) return "";
        return input.toLowerCase()
                .replaceAll("[^a-z0-9\\s]", "")
                .replaceAll("\\s+", "-");
    }

    @Transactional
    public ProductDto createProduct(ProductCreateRequest request, UUID vendorId) {
        String slug = toSlug(request.getName());
        if (productRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        if (productRepository.existsBySku(request.getSku())) {
            throw new IllegalArgumentException("SKU already exists: " + request.getSku());
        }

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        }

        Brand brand = null;
        if (request.getBrandId() != null) {
            brand = brandRepository.findById(request.getBrandId())
                    .orElseThrow(() -> new IllegalArgumentException("Brand not found"));
        }

        User vendor = userRepository.findById(vendorId)
                .orElseThrow(() -> new IllegalArgumentException("Vendor not found"));

        Product product = Product.builder()
                .name(request.getName())
                .slug(slug)
                .description(request.getDescription())
                .price(request.getPrice())
                .discountPrice(request.getDiscountPrice())
                .stockQuantity(request.getStockQuantity())
                .sku(request.getSku())
                .active(false)
                .category(category)
                .brand(brand)
                .vendor(vendor)
                .build();

        if (request.getImageUrls() != null) {
            boolean isFirst = true;
            for (String url : request.getImageUrls()) {
                product.addImage(ProductImage.builder()
                        .url(url)
                        .primary(isFirst)
                        .build());
                isFirst = false;
            }
        }

        Product saved = productRepository.save(product);
        return mapToProductDto(saved);
    }

    @Transactional(readOnly = true)
    public ProductDto getProductById(UUID id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with ID: " + id));
        return mapToProductDto(product);
    }

    @Transactional(readOnly = true)
    public ProductDto getProductBySlug(String slug) {
        Product product = productRepository.findBySlug(slug)
                .orElseThrow(() -> new IllegalArgumentException("Product not found with slug: " + slug));
        return mapToProductDto(product);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getAllProducts(Pageable pageable) {
        return productRepository.findAll(pageable).map(this::mapToProductDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProductsByCategory(String categorySlug, Pageable pageable) {
        return productRepository.findByCategorySlug(categorySlug, pageable).map(this::mapToProductDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getProductsByBrand(String brandSlug, Pageable pageable) {
        return productRepository.findByBrandSlug(brandSlug, pageable).map(this::mapToProductDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> searchProducts(String query, Pageable pageable) {
        return productRepository.searchProducts(query, pageable).map(this::mapToProductDto);
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> filterProducts(
            UUID categoryId,
            UUID brandId,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Pageable pageable
    ) {
        return productRepository.filterProducts(categoryId, brandId, minPrice, maxPrice, pageable)
                .map(this::mapToProductDto);
    }

    @Transactional(readOnly = true)
    public List<ProductDto> getProductsByVendor(UUID vendorId) {
        return productRepository.findByVendorId(vendorId).stream()
                .map(this::mapToProductDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<ProductDto> getPendingApproval(Pageable pageable) {
        return productRepository.findPendingApproval(pageable).map(this::mapToProductDto);
    }

    @Transactional
    public ProductDto updateProduct(UUID productId, ProductCreateRequest request, User currentUser) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        boolean isAdmin = currentUser.getRoles().stream()
                .map(Role::getName)
                .anyMatch(name -> name.equals("ADMIN") || name.equals("SUPER_ADMIN"));

        if (!isAdmin && (product.getVendor() == null || !product.getVendor().getId().equals(currentUser.getId()))) {
            throw new IllegalStateException("Unauthorized: you do not own this product");
        }

        if (!product.getSku().equals(request.getSku()) && productRepository.existsBySku(request.getSku())) {
            throw new IllegalArgumentException("SKU already exists: " + request.getSku());
        }

        String slug = toSlug(request.getName());
        if (!slug.equals(product.getSlug()) && productRepository.existsBySlug(slug)) {
            slug = slug + "-" + System.currentTimeMillis() % 1000;
        }

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("Category not found"));
        }

        Brand brand = null;
        if (request.getBrandId() != null) {
            brand = brandRepository.findById(request.getBrandId())
                    .orElseThrow(() -> new IllegalArgumentException("Brand not found"));
        }

        product.setName(request.getName());
        product.setSlug(slug);
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setDiscountPrice(request.getDiscountPrice());
        product.setStockQuantity(request.getStockQuantity());
        product.setSku(request.getSku());
        product.setCategory(category);
        product.setBrand(brand);

        if (request.getImageUrls() != null) {
            product.getImages().clear();
            boolean isFirst = true;
            for (String url : request.getImageUrls()) {
                product.addImage(ProductImage.builder()
                        .url(url)
                        .primary(isFirst)
                        .build());
                isFirst = false;
            }
        }

        return mapToProductDto(productRepository.save(product));
    }

    @Transactional
    public void deleteProduct(UUID productId, User currentUser) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        boolean isAdmin = currentUser.getRoles().stream()
                .map(Role::getName)
                .anyMatch(name -> name.equals("ADMIN") || name.equals("SUPER_ADMIN"));

        if (!isAdmin && (product.getVendor() == null || !product.getVendor().getId().equals(currentUser.getId()))) {
            throw new IllegalStateException("Unauthorized: you do not own this product");
        }
        productRepository.delete(product);
    }

    @Transactional
    public ProductDto approveProduct(UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        product.setActive(true);
        return mapToProductDto(productRepository.save(product));
    }

    private ProductDto mapToProductDto(Product product) {
        List<ProductImageDto> imageDtos = product.getImages().stream()
                .map(img -> ProductImageDto.builder()
                        .id(img.getId())
                        .url(img.getUrl())
                        .primary(img.isPrimary())
                        .build())
                .collect(Collectors.toList());

        return ProductDto.builder()
                .id(product.getId())
                .name(product.getName())
                .slug(product.getSlug())
                .description(product.getDescription())
                .price(product.getPrice())
                .discountPrice(product.getDiscountPrice())
                .stockQuantity(product.getStockQuantity())
                .sku(product.getSku())
                .active(product.isActive())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .categoryName(product.getCategory() != null ? product.getCategory().getName() : null)
                .brandId(product.getBrand() != null ? product.getBrand().getId() : null)
                .brandName(product.getBrand() != null ? product.getBrand().getName() : null)
                .vendorId(product.getVendor() != null ? product.getVendor().getId() : null)
                .vendorName(product.getVendor() != null ? (product.getVendor().getFirstName() + " " + product.getVendor().getLastName()) : null)
                .images(imageDtos)
                .build();
    }
}
