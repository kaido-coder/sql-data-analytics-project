/*
===============================================================================
Change Over Time Analysis (PostgreSQL Version)
===============================================================================
*/

-- 1. Using EXTRACT (Replacing YEAR/MONTH functions)
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 1, 2  -- Postgres allows grouping by column position
ORDER BY 1, 2;

-- 2. Using DATE_TRUNC (Standard for Time-Series)
-- This keeps the result as a DATE type (e.g., '2023-01-01') which is better for BI tools
SELECT
    DATE_TRUNC('month', order_date)::DATE AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date);

-- 3. Using TO_CHAR (Replacing FORMAT for pretty strings)
SELECT
    TO_CHAR(order_date, 'YYYY-Mon') AS order_period,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY TO_CHAR(order_date, 'YYYY-Mon'), DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date); -- We sort by the date trunc so months stay in order
