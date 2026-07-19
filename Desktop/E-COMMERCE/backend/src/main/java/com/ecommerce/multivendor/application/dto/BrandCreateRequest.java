package com.ecommerce.multivendor.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BrandCreateRequest {
    @NotBlank(message = "Brand name is required")
    private String name;
    private String description;
    private String logoUrl;
}
