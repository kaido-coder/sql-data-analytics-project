/*
===============================================================================
Magnitude Analysis (PostgreSQL Optimized)
===============================================================================
*/

-- 1. Revenue by Category (Joined Analysis)
-- Added COALESCE to handle any products that might not have a category mapping
SELECT
    COALESCE(p.category, 'Unknown') AS category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 2. Customer Ranking by Revenue
-- We use both names and the key to ensure uniqueness
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- 3. Geographic Distribution of Sales
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.country IS NOT NULL
GROUP BY c.country
ORDER BY total_sold_items DESC;
