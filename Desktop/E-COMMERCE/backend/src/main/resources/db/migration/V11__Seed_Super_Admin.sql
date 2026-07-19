-- V11: Seed default Super Admin user
-- Email:    superadmin@shopverse.com
-- Password: password123
-- Change the password immediately after first login via the profile settings.

INSERT INTO users (id, email, password, first_name, last_name, is_email_verified, is_active)
VALUES (
    'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a',
    'superadmin@shopverse.com',
    '$2a$10$o6Gqte8bS1BkX09HWSIKSepkh049qFmDOuOdSTtKB/Ql2fwasYEZq',
    'Super',
    'Admin',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Assign SUPER_ADMIN role
INSERT INTO user_roles (user_id, role_id)
SELECT 'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a', id
FROM roles WHERE name = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;
