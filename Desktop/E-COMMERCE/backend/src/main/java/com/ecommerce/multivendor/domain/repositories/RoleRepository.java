package com.ecommerce.multivendor.domain.repositories;

import com.ecommerce.multivendor.domain.entities.Role;

import java.util.List;
import java.util.Optional;

public interface RoleRepository {
    Optional<Role> findByName(String name);
    List<Role> findAll();
}
