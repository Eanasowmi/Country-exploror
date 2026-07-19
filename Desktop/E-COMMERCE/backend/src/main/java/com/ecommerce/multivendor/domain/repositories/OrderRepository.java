package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.Order;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository {
    Optional<Order> findById(UUID id);
    Optional<Order> findByOrderNumber(String orderNumber);
    List<Order> findByUserId(UUID userId);
    List<Order> findBySellerId(UUID vendorId);
    List<Order> findAll();
    Order save(Order order);
    void delete(Order order);
}
