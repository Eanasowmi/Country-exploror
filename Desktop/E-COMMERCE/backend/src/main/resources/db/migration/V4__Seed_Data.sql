-- V4__Seed_Data.sql

-- 2. Seed Categories
INSERT INTO categories (id, name, slug, description) VALUES
('b1c2d3e4-f5a6-7b8c-9d0e-1f2a3b4c5d6e', 'Electronics', 'electronics', 'Gadgets, devices, and computing equipment'),
('c2d3e4f5-a6b7-8c9d-0e1f-2a3b4c5d6e7f', 'Fashion', 'fashion', 'Premium clothing, shoes, and lifestyle accessories'),
('d3e4f5a6-b7c8-9d0e-1f2a-3b4c5d6e7f8a', 'Home & Living', 'home-living', 'Furniture, decor, and premium home improvement products');

-- 3. Seed Brands
INSERT INTO brands (id, name, slug, description, logo_url) VALUES
('e4f5a6b7-c8d9-0e1f-2a3b-4c5d6e7f8a9b', 'Apple', 'apple', 'Think different. Premium consumer electronics.', 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=100'),
('f5a6b7c8-d9e0-1f2a-3b4c-5d6e7f8a9b0c', 'Nike', 'nike', 'Just do it. Premium athletic apparel and shoes.', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100'),
('a6b7c8d9-e0f1-2a3b-4c5d-6e7f8a9b0c1d', 'Sony', 'sony', 'Make believe. Innovative audio and display devices.', 'https://images.unsplash.com/photo-1598331668826-20cecc596b86?w=100');

-- 4. Seed Products
-- No products seeded so sellers can add inventory from scratch.

