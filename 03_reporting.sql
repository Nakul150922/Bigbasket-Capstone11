-- ==============================================================================
-- File: 03_reporting.sql
-- Project: BigBasket Category Performance Diagnostic
-- Purpose: Advanced reporting queries covering CASE WHEN revenue tiering,
--          monthly category breakdown, and target variance calculation with
--          floating-point-safe division.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Task 5(a): Product Revenue Tiering
-- Tier every product by its total Delivered revenue:
--   High   : total_revenue >= 3000
--   Medium : total_revenue >= 1000
--   Low    : otherwise
-- ------------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN o.amount_inr ELSE 0 END), 0) AS total_delivered_revenue,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN o.amount_inr ELSE 0 END), 0) >= 3000 THEN 'High'
        WHEN COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN o.amount_inr ELSE 0 END), 0) >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_tier
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_delivered_revenue DESC, p.product_id ASC;

-- ------------------------------------------------------------------------------
-- Task 5(b): Monthly Category Business Report
-- Columns: category, month, order_count, total_revenue, avg_revenue
-- Filtered for Delivered orders only.
-- Month extracted using SQLite strftime('%Y-%m', order_date).
-- Grouped by category and month; ordered by category then month.
-- (This exact result set is exported to monthly_category_revenue.csv)
-- ------------------------------------------------------------------------------
SELECT 
    p.category,
    strftime('%Y-%m', o.order_date) AS month,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue
FROM orders o
INNER JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category, strftime('%Y-%m', o.order_date)
ORDER BY p.category ASC, month ASC;

-- ------------------------------------------------------------------------------
-- Task 5(c): Target Comparison & Variance Diagnostic
-- Joins category-level Delivered revenue with category_targets.
-- Computes:
--   variance = target_revenue_inr - total_revenue
--   percentage_variance = ((total_revenue - target_revenue_inr) * 100.0) / target_revenue_inr
-- Classification:
--   'Above Target'           : total_revenue >= target_revenue_inr
--   'Below Target - Watch'   : shortfall within 15% (i.e. percentage_variance >= -15.0)
--   'Below Target - Critical': shortfall exceeding 15% (i.e. percentage_variance < -15.0)
-- Uses floating-point-safe division (* 100.0) to prevent SQLite integer truncation.
-- ------------------------------------------------------------------------------
WITH category_rev AS (
    SELECT 
        p.category,
        SUM(o.amount_inr) AS total_revenue
    FROM orders o
    INNER JOIN products p ON o.product_id = p.product_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category
)
SELECT 
    ct.category,
    ct.target_revenue_inr,
    cr.total_revenue,
    (ct.target_revenue_inr - cr.total_revenue) AS variance,
    ROUND(((cr.total_revenue - ct.target_revenue_inr) * 100.0) / ct.target_revenue_inr, 2) AS percentage_variance,
    CASE 
        WHEN cr.total_revenue >= ct.target_revenue_inr THEN 'Above Target'
        WHEN ((cr.total_revenue - ct.target_revenue_inr) * 100.0) / ct.target_revenue_inr >= -15.0 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS target_status
FROM category_targets ct
INNER JOIN category_rev cr ON ct.category = cr.category
ORDER BY cr.total_revenue DESC;
