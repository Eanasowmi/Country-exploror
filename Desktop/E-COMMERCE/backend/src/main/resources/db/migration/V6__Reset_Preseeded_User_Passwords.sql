-- V6: Update passwords of seeded/demo users to verified BCrypt hashes
-- All passwords will be reset to: 'password123'
-- Hashed value: '$2a$10$o6Gqte8bS1BkX09HWSIKSepkh049qFmDOuOdSTtKB/Ql2fwasYEZq'

UPDATE users
SET password = '$2a$10$o6Gqte8bS1BkX09HWSIKSepkh049qFmDOuOdSTtKB/Ql2fwasYEZq'
WHERE email IN ('customer@example.com', 'admin@luxeshop.com', 'seller@luxeshop.com');
