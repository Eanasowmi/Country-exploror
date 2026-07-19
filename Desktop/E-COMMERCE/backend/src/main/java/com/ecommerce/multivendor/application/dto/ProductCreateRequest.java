package com.ecommerce.multivendor.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
public class ProductCreateRequest {
    @NotBlank(message = "Product name is required")
    private String name;
    
    private String description;
    
    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be greater than zero")
    private BigDecimal price;
    
    private BigDecimal discountPrice;
    
    @Min(value = 0, message = "Stock quantity cannot be negative")
    private int stockQuantity;
    
    @NotBlank(message = "SKU is required")
    private String sku;
    
    private UUID categoryId;
    private UUID brandId;
    
    private List<String> imageUrls;
}
