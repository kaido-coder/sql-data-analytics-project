/*
===============================================================================
Measures Exploration (PostgreSQL Optimized)
===============================================================================
*/

-- 1. High-Level Aggregations
SELECT 
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    -- AVG in Postgres returns a numeric type. 
    -- ROUND helps make the output readable.
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- 2. Customer Activity Insight
-- This helps identify "Ghost Customers" (customers in your dimension who haven't bought anything)
SELECT 
    (SELECT COUNT(*) FROM gold.dim_customers) AS total_customers,
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales;

-- 3. Unified Business Key Metrics Report
-- Tip: We cast values to NUMERIC so the UNION ALL works even if data types differ
SELECT 'Total Sales' AS measure_name, SUM(sales_amount)::NUMERIC AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity)::NUMERIC FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', ROUND(AVG(price), 2)::NUMERIC FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number)::NUMERIC FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name)::NUMERIC FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key)::NUMERIC FROM gold.dim_customers;
