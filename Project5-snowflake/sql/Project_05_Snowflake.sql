CREATE WAREHOUSE RETAIL_SALES_WH_STAR
WITH
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE DATABASE RETAIL_SALES_DB_STAR;

CREATE SCHEMA RETAIL_SCHEMA_STAR;

USE WAREHOUSE RETAIL_SALES_WH_STAR;
USE DATABASE RETAIL_SALES_DB_STAR;
USE SCHEMA RETAIL_SCHEMA_STAR;

CREATE FILE FORMAT CSV_FORMAT
TYPE='CSV'
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE STAGE RETAIL_SALES_STAGE_STAR
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

CREATE TABLE DIM_CUSTOMER
(
customer_id NUMBER PRIMARY KEY,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR
);

CREATE TABLE DIM_PRODUCT
(
product_id NUMBER PRIMARY KEY,
product_name VARCHAR,
category VARCHAR,
brand VARCHAR,
price NUMBER
);

CREATE TABLE DIM_BRANCH
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
customer_id NUMBER references DIM_CUSTOMER(customer_id),
product_id NUMBER references DIM_PRODUCT(product_id),
branch_id NUMBER references DIM_BRANCH(branch_id),
date_id NUMBER references DIM_CALENDAR(date_id),
quantity NUMBER,
total_amount NUMBER
);

COPY INTO DIM_CUSTOMER
FROM @RETAIL_SALES_STAGE_STAR/customers.csv;

COPY INTO DIM_PRODUCT
FROM @RETAIL_SALES_STAGE_STAR/products.csv;

COPY INTO DIM_BRANCH
FROM @RETAIL_SALES_STAGE_STAR/branches.csv;

COPY INTO DIM_CALENDAR
FROM @RETAIL_SALES_STAGE_STAR/calendar.csv;

COPY INTO FACT_SALES
FROM @RETAIL_SALES_STAGE_STAR/sales.csv;


-- Customer Revenue Report
CREATE VIEW VW_CUSTOMER_REVENUE AS
SELECT  c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS customer_revenue
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name;

SELECT * FROM VW_CUSTOMER_REVENUE
ORDER BY customer_revenue DESC;


-- Product-wise Revenue Report
CREATE VIEW VW_PRODUCT_REVENUE AS
SELECT  p.product_id,
        p.product_name,
        SUM(s.total_amount) AS product_revenue
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name;

SELECT * FROM VW_PRODUCT_REVENUE
ORDER BY product_revenue DESC;


-- Branch-wise Revenue Report
CREATE VIEW VW_BRANCH_REVENUE AS
SELECT  b.branch_id,
        b.branch_name,
        SUM(s.total_amount) AS branch_revenue
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name;

SELECT * FROM VW_BRANCH_REVENUE
ORDER BY branch_revenue DESC;


-- State-wise Revenue Report
CREATE VIEW VW_STATE_REVENUE AS
SELECT  b.state,
        SUM(s.total_amount) AS state_revenue
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.state;

SELECT * FROM VW_STATE_REVENUE
ORDER BY state_revenue DESC;


-- Monthly Revenue Report
CREATE VIEW VW_MONTHLY_REVENUE AS
SELECT  c.cal_month,
        SUM(s.total_amount) AS monthly_revenue
FROM DIM_CALENDAR c
INNER JOIN FACT_SALES s
ON c.date_id=s.date_id
GROUP BY c.cal_month;

SELECT * FROM VW_MONTHLY_REVENUE
ORDER BY monthly_revenue DESC;


-- Quarterly Revenue
CREATE VIEW VW_QUARTERLY_REVENUE AS
SELECT  c.cal_qtr,
        SUM(s.total_amount) AS quarterly_revenue
FROM DIM_CALENDAR c
INNER JOIN FACT_SALES s
ON c.date_id=s.date_id
GROUP BY c.cal_qtr;

SELECT * FROM VW_QUARTERLY_REVENUE
ORDER BY quarterly_revenue DESC;


-- Top 10 Customers
CREATE VIEW VW_TOP_10_CUSTOMERS AS
SELECT  c.customer_id,
        c.customer_name,
        SUM(s.total_amount) AS customer_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) as customer_ranking
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name;

SELECT * FROM VW_TOP_10_CUSTOMERS
WHERE customer_ranking<=10
ORDER BY customer_ranking;


-- Top 10 Products
CREATE VIEW VW_TOP_10_PRODUCTS AS
SELECT  p.product_id,
        p.product_name,
        SUM(s.total_amount) AS product_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) as product_ranking
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY  p.product_id,p.product_name;

SELECT * FROM VW_TOP_10_PRODUCTS
WHERE product_ranking<=10
ORDER BY product_ranking;


-- Top 10 Products
CREATE VIEW VW_TOP_10_BRANCHES AS
SELECT  b.branch_id,
        b.branch_name,
        SUM(s.total_amount) AS branch_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) as branch_performance
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name;

SELECT * FROM VW_TOP_10_BRANCHES
WHERE branch_performance<=10
ORDER BY branch_performance;


-- Category-wise Revenue
CREATE VIEW VW_CATEGORY_REVENUE AS 
SELECT  p.category,
        SUM(s.total_amount) AS category_revenue
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.category;

SELECT * FROM VW_CATEGORY_REVENUE
ORDER BY category_revenue DESC;


-- Customer Purchase Trend
CREATE VIEW VW_CUSTOMER_PURCHASE_TREND AS
SELECT  c.customer_id,
        dc.cal_month,
        COUNT(s.sale_id) AS order_frequency
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
INNER JOIN DIM_CALENDAR dc
ON dc.date_id=s.date_id
GROUP BY c.customer_id,dc.cal_month;

SELECT * FROM VW_CUSTOMER_PURCHASE_TREND
ORDER BY customer_id,cal_month;


-- Product Performance Dashboard
CREATE VIEW VW_PRODUCT_PERFORMANCE AS
SELECT  p.product_id,
        p.product_name,
        p.category,
        p.brand,
        SUM(s.quantity) AS qty_sold,
        SUM(s.total_amount) AS product_revenue
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name,p.category,p.brand;

SELECT * FROM VW_PRODUCT_PERFORMANCE
ORDER BY product_id;


-- Branch Performance Dashboard
CREATE VIEW VW_BRANCH_PERFORMANCE AS
SELECT  b.branch_id,
        b.branch_name,
        b.region,
        b.state,
        b.city,        
        SUM(s.quantity) AS qty_sold,
        SUM(s.total_amount) AS branch_revenue
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name,b.region,b.state,b.city;

SELECT * FROM VW_BRANCH_PERFORMANCE
ORDER BY qty_sold DESC,branch_revenue DESC;


-- Regional Sales Analysis
CREATE VIEW VW_REGIONAL_SALES AS
SELECT  b.region,
        SUM(s.total_amount) AS region_revenue
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
GROUP BY b.region;

SELECT * FROM VW_REGIONAL_SALES
ORDER BY region_revenue DESC;


-- Sales Trend Analysis
CREATE VIEW VW_SALES_TREND AS
SELECT  c.cal_date,
        SUM(s.total_amount) AS revenue,
        LAG(SUM(s.total_amount)) OVER(ORDER BY c.cal_date) AS previous_day_revenue
FROM DIM_CALENDAR c
INNER JOIN FACT_SALES s
ON c.date_id=s.date_id
GROUP BY c.cal_date;

SELECT cal_date,revenue,previous_day_revenue,ROUND(COALESCE((((revenue-previous_day_revenue)/previous_day_revenue)*100),0),2) AS percentage_change
FROM VW_SALES_TREND;

