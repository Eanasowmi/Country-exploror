package com.ecommerce.multivendor.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminOverviewDto {
    private long totalUsers;
    private long totalCustomers;
    private long totalSellers;
    private long totalAdmins;
    private long totalProducts;
    private long totalOrders;
    private long totalCategories;
    private long totalBrands;
    private BigDecimal totalRevenue;
    private Map<String, Long> orderStatusCounts;
}