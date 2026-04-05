/*
===============================================================================
Dimensions Exploration
===============================================================================
*/

-- 1. Unique countries for customer distribution
-- Tip: In Postgres, nulls are sorted "LAST" by default in ascending order
SELECT DISTINCT 
    country 
FROM gold.dim_customers
WHERE country IS NOT NULL
ORDER BY country;

-- 2. Product Hierarchy Exploration
-- Checking the relationship between Category -> Subcategory -> Product
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
