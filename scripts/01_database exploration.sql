/*
===============================================================================
Database Exploration (PostgreSQL)
===============================================================================
*/

-- 1. Retrieve all user-defined tables
-- Filter by 'gold' schema to avoid seeing internal Postgres system tables
SELECT 
    table_catalog, 
    table_schema, 
    table_name, 
    table_type
FROM information_schema.tables
WHERE table_schema = 'gold';

-- 2. Retrieve all columns for 'dim_customers'
-- Note: PostgreSQL is case-sensitive for strings; use lowercase 'dim_customers'
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    character_maximum_length,
    column_default
FROM information_schema.columns
WHERE table_name = 'dim_customers'
  AND table_schema = 'gold'
ORDER BY ordinal_position;
