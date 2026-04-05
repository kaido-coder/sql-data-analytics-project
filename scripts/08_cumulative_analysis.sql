/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals and moving averages for key business metrics.
    - To analyze the long-term growth trajectory of the business.
    - To smooth out short-term fluctuations for trend identification.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Date Functions: DATE_TRUNC()
===============================================================================
*/

-- Calculate the total sales per year 
-- and the running total of sales to see lifetime growth
SELECT
    order_year,
    total_sales,
    -- Running Total: Adds current row sales to the sum of all previous rows
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    -- Moving Average: Calculates the average price from the start to the current year
    AVG(avg_price) OVER (ORDER BY order_year) AS moving_average_price
FROM
(
    -- Subquery to aggregate raw sales into yearly buckets
    SELECT 
        DATE_TRUNC('year', order_date)::DATE AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('year', order_date)
) AS yearly_metrics
ORDER BY order_year;
