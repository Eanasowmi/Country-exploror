-- V5: Add demo customer and admin users
-- Password for both: 'password123' (BCrypt)

INSERT INTO users (id, email, password, first_name, last_name, is_email_verified, is_active)
VALUES (
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'customer@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWa',
    'Demo',
    'Customer',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, password, first_name, last_name, is_email_verified, is_active)
VALUES (
    'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
    'admin@luxeshop.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWa',
    'Admin',
    'User',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Assign CUSTOMER role to demo customer
INSERT INTO user_roles (user_id, role_id)
SELECT 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', id
FROM roles WHERE name = 'CUSTOMER'
ON CONFLICT DO NOTHING;

-- Assign ADMIN role to admin user
INSERT INTO user_roles (user_id, role_id)
SELECT 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f', id
FROM roles WHERE name = 'ADMIN'
ON CONFLICT DO NOTHING;
