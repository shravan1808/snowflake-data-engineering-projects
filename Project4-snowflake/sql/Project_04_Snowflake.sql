CREATE WAREHOUSE RETAIL_SALES_WH
WITH
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE DATABASE RETAIL_SALES_DB;

CREATE SCHEMA RETAIL_SCHEMA;

USE WAREHOUSE RETAIL_SALES_WH;
USE DATABASE RETAIL_SALES_DB;
USE SCHEMA RETAIL_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE='CSV'
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE STAGE RETAIL_SALES_STAGE
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

CREATE TABLE DIM_CUSTOMERS
(
customer_id NUMBER PRIMARY KEY,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR
);

CREATE TABLE DIM_PRODUCTS
(
product_id NUMBER PRIMARY KEY,
product_name VARCHAR,
category VARCHAR,
brand VARCHAR,
price NUMBER
);

CREATE TABLE DIM_BRANCHES
(
branch_id NUMBER PRIMARY KEY,
branch_name VARCHAR,
city VARCHAR,
state VARCHAR,
region VARCHAR,
manager_name VARCHAR
);

CREATE TABLE DIM_CALENDAR
(
date_id NUMBER PRIMARY KEY,
cal_date DATE,
cal_day NUMBER,
cal_day_name VARCHAR,
cal_week_no NUMBER,
cal_month VARCHAR,
cal_qtr VARCHAR,
cal_year NUMBER,
is_weekend VARCHAR
);

CREATE TABLE FACT_SALES
(
sale_id NUMBER PRIMARY KEY,
customer_id NUMBER references DIM_CUSTOMERS(customer_id),
product_id NUMBER references DIM_PRODUCTS(product_id),
branch_id NUMBER references DIM_BRANCHES(branch_id),
date_id NUMBER references DIM_CALENDAR(date_id),
quantity NUMBER,
total_amount NUMBER
);

COPY INTO DIM_CUSTOMERS
FROM @RETAIL_SALES_STAGE/customers.csv;

COPY INTO DIM_PRODUCTS
FROM @RETAIL_SALES_STAGE/products.csv;

COPY INTO DIM_BRANCHES
FROM @RETAIL_SALES_STAGE/branches.csv;

COPY INTO DIM_CALENDAR
FROM @RETAIL_SALES_STAGE/calendar.csv;

COPY INTO FACT_SALES
FROM @RETAIL_SALES_STAGE/sales.csv;


-- Customer Revenue Report
SELECT  c.customer_id,
        c.customer_name,
        COALESCE(SUM(s.total_amount),0) AS customer_revenue
FROM DIM_CUSTOMERS c
LEFT JOIN FACT_SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY customer_revenue DESC;


-- Product Revenue Report
SELECT  p.product_id,
        p.product_name,
        COALESCE(SUM(s.total_amount),0) AS product_revenue
FROM DIM_PRODUCTS p
LEFT JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name
ORDER BY product_revenue DESC;


-- Branch Performance Report
SELECT  b.branch_id,
        b.branch_name,
        COALESCE(SUM(s.total_amount),0) AS branch_revenue
FROM DIM_BRANCHES b
LEFT JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name
ORDER BY branch_revenue DESC;


-- Monthly Revenue Report
SELECT  c.cal_month,
        COALESCE(SUM(s.total_amount),0) AS monthly_revenue
FROM DIM_CALENDAR c
LEFT JOIN FACT_SALES s
ON c.date_id=s.date_id
GROUP BY c.cal_month,c.cal_year
ORDER BY monthly_revenue DESC;


-- State Wise Sales Report
SELECT  b.state,
        COALESCE(SUM(s.total_amount),0) AS state_wise_sales
FROM DIM_BRANCHES b
LEFT JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.state
ORDER BY state_wise_sales DESC;


-- Category-wise Revenue Report
SELECT  p.category,
        COALESCE(SUM(s.total_amount),0) AS category_wise_revenue
FROM DIM_PRODUCTS p
LEFT JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.category
ORDER BY category_wise_revenue DESC;


-- Top Customers
SELECT  c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS customer_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS Customer_Ranking
FROM DIM_CUSTOMERS c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,customer_name
QUALIFY Customer_Ranking<=10;


-- Top Products
SELECT  p.product_id,
        p.product_name,
        SUM(s.total_amount) AS product_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS product_ranking
FROM DIM_PRODUCTS p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name
QUALIFY product_ranking<=10;


-- Sales Trend Analysis
SELECT  c.cal_date,
        SUM(s.total_amount) AS daily_sales
FROM DIM_CALENDAR c
INNER JOIN FACT_SALES s
ON c.date_id=s.date_id
GROUP BY c.cal_date
ORDER BY c.cal_date;