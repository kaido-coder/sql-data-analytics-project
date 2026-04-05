/*
===============================================================================
Data Segmentation Analysis (PostgreSQL Version)
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - To perform customer tiering (VIP, Regular, New) based on spending and loyalty.
    - To analyze product distribution across cost brackets.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - DATE_TRUNC(), AGE(), EXTRACT(): For calculating customer lifespan.
    - CTEs (WITH clause): To organize complex multi-step logic.
===============================================================================
*/

-- 1. Product Segmentation by Cost Range
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        -- Custom buckets to analyze product price distribution
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- 2. Customer Segmentation (VIP, Regular, New)
-- Calculated based on lifespan (months between first and last order) and total spend
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        -- Calculate lifespan in months using PostgreSQL AGE logic
        (EXTRACT(YEAR FROM AGE(MAX(f.order_date), MIN(f.order_date))) * 12 +
         EXTRACT(MONTH FROM AGE(MAX(f.order_date), MIN(f.order_date)))) AS lifespan_months
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        -- Applying business logic to define segments
        CASE 
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
