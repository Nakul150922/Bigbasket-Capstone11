-- ==============================================================================
-- File: 02_aggregation_joins.sql
-- Project: BigBasket Category Performance Diagnostic
-- Purpose: Intermediate aggregation, INNER JOIN with HAVING filtering,
--          and LEFT JOIN preserving products with zero order history.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Task 4(a): INNER JOIN orders with products for Delivered orders only.
-- Compute order count, total revenue, and average revenue by category.
-- Filter for high-performing categories using HAVING total_revenue > 10000.
-- ------------------------------------------------------------------------------
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
HAVING total_revenue > 10000
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------------------------
-- Task 4(b): LEFT JOIN products to orders to surface total order count per product.
-- Uses COUNT(o.order_id) instead of COUNT(*) so products with zero orders 
-- correctly display a count of 0 rather than 1.
-- Ordered ascending by order count so the least-ordered products appear first.
-- In this dataset, 'Premium Face Cream 50g' has 0 orders and must appear with count 0.
-- ------------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price_inr,
    COUNT(o.order_id) AS total_orders
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category, p.unit_price_inr
ORDER BY total_orders ASC, p.product_id ASC;
