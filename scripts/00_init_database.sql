/*
=============================================================
Create Database and Schemas (PostgreSQL Version)
=============================================================
Script Purpose:
    This script drops the 'DataWarehouseAnalytics' database if it exists and 
    recreates it from scratch. It also initializes the 'gold' schema.
    
    Note: This script should be executed while connected to a maintenance 
    database (e.g., 'postgres') as you cannot drop the active database.

WARNING:
    Running this script will PERMANENTLY DELETE the 'DataWarehouseAnalytics' 
    database and all its associated schemas, tables, and data. 
    Proceed with caution and ensure you have valid backups.
=============================================================
*/

-- NOTE: Run these two lines separately if your IDE doesn't support multi-statement DB creation
DROP DATABASE IF EXISTS "DataWarehouseAnalytics";
CREATE DATABASE "DataWarehouseAnalytics";

-- Connect to DataWarehouseAnalytics before running the rest
-- In psql: \c DataWarehouseAnalytics

CREATE SCHEMA IF NOT EXISTS gold;

-- 1. Create Tables
CREATE TABLE gold.dim_customers(
    customer_key     INT,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);

CREATE TABLE gold.dim_products(
    product_key      INT,
    product_id       INT,
    product_number   VARCHAR(50),
    product_name     VARCHAR(50),
    category_id      VARCHAR(50),
    category         VARCHAR(50),
    subcategory      VARCHAR(50),
    maintenance      VARCHAR(50),
    cost             INT,
    product_line     VARCHAR(50),
    start_date       DATE
);

CREATE TABLE gold.fact_sales(
    order_number     VARCHAR(50),
    product_key      INT,
    customer_key     INT,
    order_date       DATE,
    shipping_date    DATE,
    due_date         DATE,
    sales_amount     INT,
    quantity         SMALLINT,
    price            INT
);

-- 2. Bulk Load Data
-- Ensure the PostgreSQL service account has permission to read these folders!

TRUNCATE TABLE gold.dim_customers;
COPY gold.dim_customers
FROM 'C:/my projects/sql-data-analytics-project-main/sql-data-analytics-project-main/datasets/csv-files/gold.dim_customers.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE gold.dim_products;
COPY gold.dim_products
FROM 'C:/my projects/sql-data-analytics-project-main/sql-data-analytics-project-main/datasets/csv-files/gold.dim_products.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

TRUNCATE TABLE gold.fact_sales;
COPY gold.fact_sales
FROM 'C:/my projects/sql-data-analytics-project-main/sql-data-analytics-project-main/datasets/csv-files/gold.fact_sales.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');
