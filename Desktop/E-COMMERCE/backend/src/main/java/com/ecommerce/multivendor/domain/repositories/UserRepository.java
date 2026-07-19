package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.User;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository {
    Optional<User> findById(UUID id);
    Optional<User> findByEmail(String email);
    List<User> findAll();
    User save(User user);
    boolean existsByEmail(String email);
}
