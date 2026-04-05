/*
===============================================================================
Customer Report (PostgreSQL Version)
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors into a view.
    - It supports segmentation, age grouping, and lifetime value analysis.

Highlights:
    1. Consolidates names, ages, and transaction details.
    2. Segments customers by Tier (VIP, Regular, New) and Age Group.
    3. Aggregates totals (Sales, Orders, Quantity, Products, Lifespan).
    4. Calculates KPIs (Recency, Avg Order Value, Avg Monthly Spend).
===============================================================================
*/

-- Drop the view if it already exists
DROP VIEW IF EXISTS gold.report_customers;

-- Create the View
CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Joins Fact and Dimension tables
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        -- Using || for concatenation is standard SQL
        c.first_name || ' ' || c.last_name AS customer_name,
        -- Calculate Age in years
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.birthdate)) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes metrics at the customer level
---------------------------------------------------------------------------*/
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        -- Calculate Lifespan (Months between first and last order)
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
         EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

/*---------------------------------------------------------------------------
3) Final Logic: Apply Segments and KPI Calculations
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    -- Age Grouping
    CASE 
         WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,
    -- Customer Segmentation
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    -- Recency: Months since the last order
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12 +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date))) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute Average Order Value (AOV)
    -- Cast to NUMERIC to ensure decimal precision
    CASE WHEN total_orders = 0 THEN 0
         ELSE ROUND(total_sales::NUMERIC / total_orders, 2)
    END AS avg_order_value,
    -- Compute Average Monthly Spend
    CASE WHEN lifespan = 0 THEN total_sales::NUMERIC
         ELSE ROUND(total_sales::NUMERIC / lifespan, 2)
    END AS avg_monthly_spend
FROM customer_aggregation;
