-- V7: Seed the seller demo account for seller login
-- Password: 'password123' (BCrypt)

INSERT INTO users (id, email, password, first_name, last_name, is_email_verified, is_active)
VALUES (
    'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f90',
    'seller@luxeshop.com',
    '$2a$10$o6Gqte8bS1BkX09HWSIKSepkh049qFmDOuOdSTtKB/Ql2fwasYEZq',
    'Demo',
    'Seller',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = 'SELLER'
WHERE u.email = 'seller@luxeshop.com'
ON CONFLICT (user_id, role_id) DO NOTHING;