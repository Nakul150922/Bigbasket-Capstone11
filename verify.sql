-- ==============================================================================
-- File: verify.sql
-- Project: BigBasket Category Performance Diagnostic (Capstone)
-- Purpose: Verify row counts for all four tables and the orders status distribution.
--
-- VERIFICATION OUTPUT ON bigbasket_capstone.db:
-- Table counts:
--   products: 31
--   customers: 50
--   orders: 500
--   category_targets: 6
--
-- Orders status distribution:
--   Delivered: 434
--   Cancelled: 42
--   Pending:   24
-- ==============================================================================

-- 1. Products row count (Expected: 31)
SELECT 'products' AS table_name, COUNT(*) AS row_count FROM products;

-- 2. Customers row count (Expected: 50)
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers;

-- 3. Orders row count (Expected: 500)
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders;

-- 4. Category targets row count (Expected: 6)
SELECT 'category_targets' AS table_name, COUNT(*) AS row_count FROM category_targets;

-- 5. Orders status distribution (Expected: Delivered 434, Cancelled 42, Pending 24)
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;
