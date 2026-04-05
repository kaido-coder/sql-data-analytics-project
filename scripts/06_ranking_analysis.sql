/*
===============================================================================
Ranking Analysis (PostgreSQL Version)
===============================================================================
*/

-- 1. Top 5 Products by Revenue (Using LIMIT instead of TOP)
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 2. Ranking Using Window Functions (Postgres & SQL Server compatible)
-- This is better if you have "Ties" (two products with the exact same revenue)
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- 3. The 3 customers with the fewest orders
-- Using LIMIT 3 at the end
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC
LIMIT 3;
