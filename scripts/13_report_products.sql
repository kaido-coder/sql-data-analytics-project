/*
===============================================================================
Product Report (PostgreSQL Version)
===============================================================================
Purpose:
    - Consolidates key product metrics including category, cost, and sales performance.
    - Segments products by revenue to identify performance tiers.
    - Calculates essential KPIs: Recency, AOR, and Monthly Revenue.

SQL Functions Used:
    - DATE_TRUNC(), AGE(), EXTRACT(): For timeline and recency logic.
    - CASE: For performance segmentation.
    - ROUND/CAST: For precise financial calculations.
===============================================================================
*/

-- Drop the view if it already exists
DROP VIEW IF EXISTS gold.report_products;

-- Create the View
CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Joins Fact and Dimension tables
---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes metrics at the product level
---------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        -- Lifespan calculation in months
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
         EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        -- Calculate average selling price using numeric casting for precision
        ROUND(AVG(sales_amount::NUMERIC / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

/*---------------------------------------------------------------------------
3) Final Logic: Apply Segments and KPI Calculations
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    -- Recency: Months since the last sale occurred
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_sale_date)) * 12 +
     EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_sale_date))) AS recency_in_months,
    -- Performance Segmentation logic
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales::NUMERIC / total_orders, 2)
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales::NUMERIC
        ELSE ROUND(total_sales::NUMERIC / lifespan, 2)
    END AS avg_monthly_revenue
FROM product_aggregations;
