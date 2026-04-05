/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products over time.
    - To benchmark current sales against historical averages.
    - To track Yearly Growth (YoY) using the LAG() function.

SQL Functions Used:
    - Window Functions: LAG(), AVG() OVER()
    - CTEs (WITH clause)
    - CASE statements
    - Date Functions: EXTRACT()
===============================================================================
*/

-- Step 1: Create a CTE to aggregate sales by year and product
WITH yearly_product_sales AS (
    SELECT
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM f.order_date),
        p.product_name
)

-- Step 2: Compare performance to average and previous years
SELECT
    order_year,
    product_name,
    current_sales,
    -- Calculate the lifetime average sales for each specific product
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 2) AS avg_sales,
    -- Difference from the lifetime average
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    -- Categorize performance against the average
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_status,
    
    -- Year-over-Year (YoY) Analysis
    -- LAG() pulls the 'current_sales' from the previous year's row for the same product
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    
    -- Categorize the Year-over-Year trend
    CASE 
        WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) > 0 THEN 'Increase'
        WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_trend
FROM yearly_product_sales
ORDER BY product_name, order_year;
