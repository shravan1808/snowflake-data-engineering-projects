-- PHASE -1 SNOWFLAKE ENVIRONMENT

CREATE WAREHOUSE ENTERPRISE_WH
WITH 
WAREHOUSE_SIZE='XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE DATABASE ENTERPRISE_DB;

CREATE SCHEMA SALES_SCHEMA;

CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

USE WAREHOUSE ENTERPRISE_WH;
USE DATABASE ENTERPRISE_DB;
USE SCHEMA SALES_SCHEMA;

CREATE STAGE RAW_STAGE
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

SHOW STAGES;
SHOW FILE FORMATS;
LIST @RAW_STAGE;

-- PHASE - 2 : DATA LOADING

CREATE TABLE CUSTOMERS
(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(50),
city VARCHAR(30),
membership VARCHAR(30)
);

CREATE TABLE PRODUCTS
(
product_id INT  PRIMARY KEY,
product_name VARCHAR(50),
category VARCHAR(50),
price INT
);

CREATE TABLE BRANCHES
(
branch_id INT PRIMARY KEY,
branch_name VARCHAR(50),
state VARCHAR(30)
);

CREATE TABLE SALES
(
sale_id INT PRIMARY KEY,
customer_id INT REFERENCES CUSTOMERS(customer_id),
product_id INT REFERENCES PRODUCTS(product_id),
branch_id INT REFERENCES BRANCHES(branch_id),
quantity INT,
sale_date DATE,
total_amount INT
);


CREATE TABLE NEW_SALES
LIKE SALES;


COPY INTO CUSTOMERS
FROM @RAW_STAGE/customers.csv;

COPY INTO PRODUCTS
FROM @RAW_STAGE/products.csv;

COPY INTO BRANCHES
FROM @RAW_STAGE/branches.csv;

COPY INTO SALES
FROM @RAW_STAGE/sales_history.csv;

-- PHASE - 3 : INCREMENTAL LOADING

CREATE STREAM SALES_STREAM
ON TABLE SALES;

COPY INTO NEW_SALES
FROM @RAW_STAGE/new_sales.csv;

SELECT * FROM SALES_STREAM;

-- DROP STREAM SALES_STREAM;

MERGE INTO SALES AS S
USING NEW_SALES AS N
ON S.sale_id = N.sale_id

WHEN MATCHED THEN
UPDATE SET
    S.CUSTOMER_ID=N.CUSTOMER_ID,
    S.PRODUCT_ID=N.PRODUCT_ID,
    S.BRANCH_ID=N.BRANCH_ID,
    S.QUANTITY=N.QUANTITY,
    S.SALE_DATE=N.SALE_DATE,
    S.TOTAL_AMOUNT=N.TOTAL_AMOUNT

WHEN NOT MATCHED THEN
INSERT (
SALE_ID,
CUSTOMER_ID,
PRODUCT_ID,
BRANCH_ID,
QUANTITY,
SALE_DATE,
TOTAL_AMOUNT
)
VALUES (
N.SALE_ID,
N.CUSTOMER_ID,
N.PRODUCT_ID,
N.BRANCH_ID,
N.QUANTITY,
N.SALE_DATE,
N.TOTAL_AMOUNT
);


-- PHASE - 4 : DATA VALIDATION

SELECT sale_id,COUNT(*) AS duplicate_records_count
FROM SALES
GROUP BY sale_id
HAVING COUNT(*)>1;

SELECT s.sale_id,s.customer_id
FROM CUSTOMERS c
RIGHT JOIN SALES s
ON c.customer_id=s.customer_id
WHERE c.customer_id IS NULL;

SELECT s.sale_id,s.product_id
FROM SALES s
LEFT JOIN PRODUCTS p
ON s.product_id=p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS new_records
FROM NEW_SALES n;

-- PHASE -5 : TIME TRAVEL

DELETE FROM SALES
WHERE sale_id=10;

SELECT * FROM SALES;

INSERT INTO SALES
SELECT * 
FROM SALES
BEFORE(STATEMENT =>'01c62ff7-3203-1936-0017-d5ea000910f2')
WHERE sale_id=10;

SELECT * FROM SALES;

--  PHASE - 6 : ZERO COPY CLONE
CREATE TABLE SALES_TEST
CLONE SALES;

SELECT * FROM SALES_TEST;

INSERT INTO SALES_TEST
VALUES (11,2,104,2,3,'2026-07-11',2400);

SELECT * FROM SALES_TEST;

SELECT * FROM SALES;


LIST @RAW_STAGE;

CREATE TABLE STG_NEW_SALES 
LIKE SALES;

COPY INTO STG_NEW_SALES
FROM @RAW_STAGE
FILES=('new_sales_3.csv')
FILE_FORMAT=(FORMAT_NAME = 'CSV_FORMAT');

-- PHASE - 7 : TASK AUTOMATION

CREATE TASK DAILY_INCREMENTAL_LOAD
WAREHOUSE =  ENTERPRISE_WH
SCHEDULE = 'USING CRON 0 15 * * * UTC'
AS
MERGE INTO SALES s
USING STG_NEW_SALES sns
ON s.sale_id=sns.sale_id

WHEN MATCHED THEN

UPDATE SET
    s.customer_id=sns.customer_id,
    s.product_id=sns.product_id,
    s.branch_id=sns.branch_id,
    s.quantity=sns.quantity,
    s.sale_date=sns.sale_date,
    s.total_amount=sns.total_amount

WHEN NOT MATCHED THEN
INSERT
(
sale_id,
customer_id,
product_id,
branch_id,
quantity,
sale_date,
total_amount
)
VALUES (
sns.sale_id,
sns.customer_id,
sns.product_id,
sns.branch_id,
sns.quantity,
sns.sale_date,
sns.total_amount
);

ALTER TASK DAILY_INCREMENTAL_LOAD
RESUME;

EXECUTE TASK DAILY_INCREMENTAL_LOAD;

SELECT * FROM SALES;

SELECT *
FROM TABLE(
INFORMATION_SCHEMA.TASK_HISTORY(
TASK_NAME => 'DAILY_INCREMENTAL_LOAD'
)
);

ALTER TASK DAILY_INCREMENTAL_LOAD
SUSPEND;

TRUNCATE TABLE STG_NEW_SALES;

-- PHASE - 8 : BUSINESS ANALYTICS

-- Customer Revenue Report
SELECT c.customer_id,c.customer_name,SUM(s.total_amount) AS customer_revenue
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY customer_revenue DESC;


-- Branch Revenue Report
SELECT b.branch_id,b.branch_name,SUM(s.total_amount) AS branch_revenue
FROM BRANCHES b
INNER JOIN SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_id,b.branch_name
ORDER BY branch_revenue DESC;


-- Product Revenue Report
SELECT p.product_id,p.product_name,SUM(s.total_amount) AS product_revenue
FROM PRODUCTS p
INNER JOIN SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name
ORDER BY product_revenue DESC;

-- Monthly Revenue Report
SELECT MONTHNAME(sale_date) as month_name,SUM(total_amount) AS monthly_revenue
FROM SALES 
GROUP BY MONTHNAME(sale_date)
ORDER BY monthly_revenue DESC;

-- Highest Revenue Customer
SELECT customer_name
FROM (SELECT customer_name,
             customer_revenue,
             DENSE_RANK() OVER(ORDER BY customer_revenue DESC) as customer_rank
      FROM (SELECT c.customer_name,
             SUM(s.total_amount) AS customer_revenue
             FROM CUSTOMERS c
             INNER JOIN SALES s
             ON c.customer_id=s.customer_id
             GROUP BY c.customer_name
           ) t1
     ) t2
WHERE customer_rank=1;

-- Highest Revenue Branch
SELECT branch_name
FROM (SELECT branch_name,
             branch_revenue,
             DENSE_RANK() OVER(ORDER BY branch_revenue DESC) as branch_rank
      FROM (SELECT b.branch_name,
             SUM(s.total_amount) AS branch_revenue
             FROM BRANCHES b
             INNER JOIN SALES s
             ON b.branch_id=s.branch_id
             GROUP BY b.branch_name
           ) t1
     ) t2
WHERE branch_rank=1;

-- TOP  FIVE PRODUCTS
SELECT product_id,
       product_name
FROM (SELECT product_id,
             product_name,
             product_revenue,
             DENSE_RANK() OVER(ORDER BY product_revenue) as product_rank
      FROM (SELECT p.product_id,
                   p.product_name,
                   sum(s.total_amount) as product_revenue
            FROM PRODUCTS p
            INNER JOIN SALES s
            ON p.product_id=s.product_id
            GROUP BY p.product_id,p.product_name
            ) t1
      ) t2
WHERE product_rank<=5
ORDER BY product_rank DESC;

-- Customer Purchase Frequency
SELECT c.customer_id,c.customer_name,count(s.sale_id) as customer_purchase_freq
FROM CUSTOMERS c
LEFT JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name;

-- Running Revenue
SELECT sale_id,
       customer_id,
       product_id,
       branch_id,
       quantity,
       sale_date,
       total_amount,
       SUM(total_amount) OVER(ORDER BY sale_id) AS running_revenue
FROM SALES;

-- Customer Ranking
SELECT customer_name,
       customer_revenue,
       DENSE_RANK() OVER(ORDER BY customer_revenue DESC) as customer_rank
FROM (SELECT c.customer_name,
             SUM(s.total_amount) AS customer_revenue
             FROM CUSTOMERS c
             INNER JOIN SALES s
             ON c.customer_id=s.customer_id
             GROUP BY c.customer_name
    ) t1;


-- PHASE - 9 : VIEWS

-- Create View: CUSTOMER_REVENUE
CREATE VIEW CUSTOMER_REVENUE AS
SELECT c.customer_id,c.customer_name,SUM(s.total_amount) AS customer_revenue
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY customer_revenue DESC;

SELECT * FROM CUSTOMER_REVENUE;

-- Create Materialized View: BRANCH_REVENUE
CREATE MATERIALIZED VIEW BRANCH_REVENUE AS
SELECT branch_id,sum(total_amount) AS branch_revenue
FROM SALES
GROUP BY branch_id;

SELECT b.branch_name,br.branch_id,br.branch_revenue
FROM BRANCHES b
INNER JOIN BRANCH_REVENUE br
ON b.branch_id=br.branch_id
ORDER BY br.branch_revenue DESC;