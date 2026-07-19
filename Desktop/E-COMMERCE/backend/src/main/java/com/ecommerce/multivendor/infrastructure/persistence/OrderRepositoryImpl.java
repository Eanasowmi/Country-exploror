package com.ecommerce.multivendor.infrastructure.persistence;

import com.ecommerce.multivendor.domain.entities.Order;
import com.ecommerce.multivendor.domain.repositories.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderRepositoryImpl implements OrderRepository {

    private final JpaOrderRepository jpaOrderRepository;

    @Override
    public Optional<Order> findById(UUID id) {
        return jpaOrderRepository.findById(id);
    }

    @Override
    public Optional<Order> findByOrderNumber(String orderNumber) {
        return jpaOrderRepository.findByOrderNumber(orderNumber);
    }

    @Override
    public List<Order> findByUserId(UUID userId) {
        return jpaOrderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    public List<Order> findBySellerId(UUID vendorId) {
        return jpaOrderRepository.findBySellerId(vendorId);
    }

    @Override
    public List<Order> findAll() {
        return jpaOrderRepository.findAll();
    }

    @Override
    public Order save(Order order) {
        return jpaOrderRepository.save(order);
    }

    @Override
    public void delete(Order order) {
        jpaOrderRepository.delete(order);
    }
}
