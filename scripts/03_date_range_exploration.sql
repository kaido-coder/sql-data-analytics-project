/*
===============================================================================
Date Range Exploration (PostgreSQL)
===============================================================================
*/

-- 1. Determine order date boundaries and duration
-- We use EXTRACT or AGE to handle month calculations
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    -- Subtracting dates returns days; we divide by 30 for an estimate
    -- Or use AGE() to get a precise interval
    (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
     EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS order_range_months
FROM gold.fact_sales;

-- 2. Find the youngest and oldest customer
-- AGE(date) calculates the difference between CURRENT_DATE and that date
SELECT
    MIN(birthdate) AS oldest_birthdate,
    EXTRACT(YEAR FROM AGE(MIN(birthdate))) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    EXTRACT(YEAR FROM AGE(MAX(birthdate))) AS youngest_age
FROM gold.dim_customers;
