-- ==============================================================================
-- File: 01_foundations.sql
-- Project: BigBasket Category Performance Diagnostic
-- Purpose: Foundational SQL queries demonstrating key filtering, projection,
--          and sorting clauses on bigbasket_capstone.db.
-- ==============================================================================

-- 1. WHERE: Orders placed by customers residing in 'Bengaluru'
-- Filters orders by joining with the customers table to isolate Bengaluru transactions.
SELECT 
    o.order_id,
    o.order_date,
    c.name AS customer_name,
    c.city,
    o.amount_inr,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = 'Bengaluru';

-- 2. DISTINCT: List every unique product category available in the catalogue
SELECT DISTINCT category
FROM products
ORDER BY category ASC;

-- 3. ORDER BY + LIMIT: The 5 highest-value orders by amount_inr
SELECT 
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    amount_inr,
    payment_mode,
    status
FROM orders
ORDER BY amount_inr DESC
LIMIT 5;

-- 4. Alias (AS): Aggregate metrics with clear business column aliases
SELECT 
    status,
    COUNT(*) AS total_orders,
    SUM(amount_inr) AS total_order_value_inr,
    AVG(amount_inr) AS avg_order_value_inr
FROM orders
GROUP BY status;

-- 5. IN: Orders processed via specific digital payment modes ('UPI', 'Wallet')
SELECT 
    order_id,
    order_date,
    payment_mode,
    amount_inr,
    status
FROM orders
WHERE payment_mode IN ('UPI', 'Wallet');

-- 6. BETWEEN: Orders with transaction amount between 200 and 500 INR (inclusive)
SELECT 
    order_id,
    order_date,
    product_id,
    amount_inr,
    payment_mode,
    status
FROM orders
WHERE amount_inr BETWEEN 200 AND 500
ORDER BY amount_inr ASC;

-- 7. NOT BETWEEN: Orders with transaction amount outside the mid-tier range (outside 100 to 800 INR)
SELECT 
    order_id,
    order_date,
    product_id,
    amount_inr,
    payment_mode,
    status
FROM orders
WHERE amount_inr NOT BETWEEN 100 AND 800
ORDER BY amount_inr ASC;

-- 8. IS NULL: Orders with no customer rating recorded
-- These represent non-delivered orders (Cancelled or Pending) which never receive a rating.
SELECT 
    order_id,
    order_date,
    payment_mode,
    status,
    rating
FROM orders
WHERE rating IS NULL;
