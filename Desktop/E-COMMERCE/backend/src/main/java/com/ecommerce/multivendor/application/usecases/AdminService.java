package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.AdminOverviewDto;
import com.ecommerce.multivendor.application.dto.RoleDto;
import com.ecommerce.multivendor.application.dto.UpdateUserRolesRequest;
import com.ecommerce.multivendor.application.dto.UpdateUserStatusRequest;
import com.ecommerce.multivendor.application.dto.UserDto;
import com.ecommerce.multivendor.domain.entities.Order;
import com.ecommerce.multivendor.domain.entities.Role;
import com.ecommerce.multivendor.domain.entities.User;
import com.ecommerce.multivendor.domain.repositories.BrandRepository;
import com.ecommerce.multivendor.domain.repositories.CategoryRepository;
import com.ecommerce.multivendor.domain.repositories.OrderRepository;
import com.ecommerce.multivendor.domain.repositories.ProductRepository;
import com.ecommerce.multivendor.domain.repositories.RoleRepository;
import com.ecommerce.multivendor.domain.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;

    @Transactional(readOnly = true)
    public AdminOverviewDto getOverview() {
        List<User> users = userRepository.findAll();
        List<Order> orders = orderRepository.findAll();

        BigDecimal totalRevenue = orders.stream()
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return AdminOverviewDto.builder()
                .totalUsers(users.size())
                .totalCustomers(countUsersWithRole(users, "CUSTOMER"))
                .totalSellers(countUsersWithRole(users, "SELLER"))
                .totalAdmins(countUsersWithAnyRole(users, "ADMIN", "SUPER_ADMIN"))
                .totalProducts(productRepository.findAll(Pageable.unpaged()).getTotalElements())
                .totalOrders(orders.size())
                .totalCategories(categoryRepository.findAll().size())
                .totalBrands(brandRepository.findAll().size())
                .totalRevenue(totalRevenue)
                .orderStatusCounts(orders.stream().collect(Collectors.groupingBy(
                        order -> order.getStatus().toUpperCase(),
                        Collectors.counting()
                )))
                .build();
    }

    @Transactional(readOnly = true)
    public List<UserDto> getUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToUserDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RoleDto> getRoles() {
        return roleRepository.findAll().stream()
                .map(this::mapToRoleDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserDto updateUserRoles(UUID userId, UpdateUserRolesRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));

        Set<Role> roles = request.getRoles().stream()
                .map(roleName -> roleRepository.findByName(roleName)
                        .orElseThrow(() -> new IllegalArgumentException("Role not found: " + roleName)))
                .collect(Collectors.toSet());

        user.setRoles(roles);
        return mapToUserDto(userRepository.save(user));
    }

    @Transactional
    public UserDto updateUserStatus(UUID userId, UpdateUserStatusRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with ID: " + userId));

        user.setEnabled(request.isEnabled());
        return mapToUserDto(userRepository.save(user));
    }

    private long countUsersWithRole(List<User> users, String roleName) {
        return users.stream()
                .filter(user -> user.getRoles().stream().anyMatch(role -> role.getName().equals(roleName)))
                .count();
    }

    private long countUsersWithAnyRole(List<User> users, String... roleNames) {
        return users.stream()
                .filter(user -> user.getRoles().stream()
                        .map(Role::getName)
                        .anyMatch(roleName -> java.util.Arrays.asList(roleNames).contains(roleName)))
                .count();
    }

    private UserDto mapToUserDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .enabled(user.isEnabled())
                .emailVerified(user.isEmailVerified())
                .roles(user.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    private RoleDto mapToRoleDto(Role role) {
        return RoleDto.builder()
                .id(role.getId())
                .name(role.getName())
                .build();
    }
}