package com.ecommerce.multivendor.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDto {
    private UUID id;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private BigDecimal discountPrice;
    private int stockQuantity;
    private String sku;
    private boolean active;
    
    private UUID categoryId;
    private String categoryName;
    
    private UUID brandId;
    private String brandName;
    
    private UUID vendorId;
    private String vendorName;
    
    private List<ProductImageDto> images;
}
