package com.ecommerce.multivendor.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String tokenType;
    private UUID userId;
    private String firstName;
    private String lastName;
    private String email;
    private String profilePictureUrl;
    private Set<String> roles;
}
