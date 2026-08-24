-- PHASE-1 : Snowflake Environment

-- Create a Warehouse named RETAIL_WH.
CREATE WAREHOUSE RETAIL_WH
WITH 
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;


-- Create a Database named RETAIL_DB.
CREATE DATABASE RETAIL_DB;

-- Create a Schema named SALES_SCHEMA.
CREATE SCHEMA SALES_SCHEMA;

-- Create a CSV File Format.
CREATE FILE FORMAT CSV_FORMAT
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1;

-- Create an Internal Stage.
CREATE STAGE RAW_STAGE
FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT);

USE WAREHOUSE RETAIL_WH;
USE DATABASE RETAIL_DB;
USE SCHEMA SALES_SCHEMA;


-- PHASE-2 : Data Loading


-- Create the required tables.
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
city VARCHAR(30)
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


-- Load the data using COPY INTO.
COPY INTO CUSTOMERS
FROM @RAW_STAGE/customers.csv;

COPY INTO PRODUCTS
FROM @RAW_STAGE/products.csv;

COPY INTO BRANCHES
FROM @RAW_STAGE/branches.csv;

COPY INTO SALES
FROM @RAW_STAGE/sales.csv;


-- Verify the imported records.
SELECT * FROM CUSTOMERS;

SELECT * FROM PRODUCTS;

SELECT * FROM BRANCHES;

SELECT * FROM SALES;


-- PHASE-3 : SQL Analytics


-- Display all customers.
SELECT * FROM CUSTOMERS;

-- Display all products.
SELECT * FROM PRODUCTS;

-- Display all branches.
SELECT * FROM BRANCHES;

-- Display all sales transactions.
SELECT * FROM SALES;

-- Generate customer-wise sales.
SELECT c.customer_name,SUM(s.total_amount) as customer_sales
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_name;

-- Generate branch-wise sales.
SELECT b.branch_name,SUM(s.total_amount) as branch_sales
FROM BRANCHES b
INNER JOIN SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_name;

-- Generate product-wise sales.
SELECT p.product_name,SUM(s.total_amount) as product_sales
FROM PRODUCTS p
INNER JOIN SALES s
ON p.product_id=s.product_id
GROUP BY p.product_name;

-- Generate category-wise sales.
SELECT p.category,SUM(s.total_amount) as category_sales
FROM PRODUCTS p
INNER JOIN SALES s
ON p.product_id=s.product_id
GROUP BY p.category;


-- Display the highest revenue branch.
SELECT branch_name,max(total_revenue) AS max_revenue
FROM (SELECT b.branch_name,sum(s.total_amount) AS total_revenue
      FROM BRANCHES b
      INNER JOIN SALES s
      ON b.branch_id=s.branch_id
      GROUP BY b.branch_name) t1
GROUP BY branch_name
ORDER BY max_revenue DESC
LIMIT 1;

-- Display the highest spending customer.
SELECT customer_name
FROM (SELECT c.customer_name,SUM(s.total_amount) as customer_sales
      FROM CUSTOMERS c
      INNER JOIN SALES s
      ON c.customer_id=s.customer_id
      GROUP BY c.customer_name
      ) t2
ORDER BY customer_sales DESC
LIMIT 1;

-- another way
SELECT customer_name
FROM ( SELECT c.customer_name,
              SUM(s.total_amount) AS customer_sales
       FROM CUSTOMERS c
       INNER JOIN SALES s
       ON c.customer_id=s.customer_id
       GROUP BY c.customer_name
     ) t1
WHERE customer_sales= (SELECT MAX(customer_sales)
                       FROM ( SELECT c.customer_name,
                                     SUM(s.total_amount) AS customer_sales
                              FROM CUSTOMERS c
                              INNER JOIN SALES s
                              ON c.customer_id=s.customer_id
                              GROUP BY c.customer_name
                            ) t2 
                      ); 
                        

-- Display the top three products by revenue.
SELECT product_name,
       product_sales
FROM ( SELECT p.product_name,
              SUM(s.total_amount) AS product_sales,
              DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS dns_rk
       FROM PRODUCTS p
       INNER JOIN SALES s
       ON p.product_id=s.product_id
       GROUP BY p.product_name) t
WHERE dns_rk<=3;


-- Display the top three customers by spending.
SELECT customer_name,
       customer_sales
FROM (SELECT c.customer_name,
             SUM(s.total_amount) as customer_sales,
             DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS dns_rnk
      FROM CUSTOMERS c
      INNER JOIN SALES s
      ON c.customer_id=s.customer_id
      GROUP BY c.customer_name
     ) dt
WHERE dns_rnk<=3;


-- PHASE-4 : Window Functions

-- Rank customers based on total spending.
SELECT c.customer_name,
       SUM(s.total_amount) AS Total_spending,
       DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS DENS_RNK
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_name;

-- Rank branches based on total sales.
SELECT b.branch_name,
       SUM(s.total_amount) AS Total_Sales,
       DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS Branch_rnk
FROM BRANCHES b
INNER JOIN SALES s
ON b.branch_id=s.branch_id
GROUP BY b.branch_name;

-- Display the top-selling product in each category using ROW_NUMBER().
SELECT category,
       product_name,
       product_Sales,
       ROW_NUMBER() OVER(PARTITION BY category ORDER BY product_sales DESC) AS Category_Wise_Sales_Rnk
FROM (SELECT p.category,
             p.product_name,
             SUM(s.total_amount) as product_sales
      FROM PRODUCTS p
      INNER JOIN SALES s
      ON p.product_id=s.product_id
      GROUP BY p.category,p.product_name) dt1
QUALIFY Category_Wise_Sales_Rnk=1;




-- Calculate cumulative sales using SUM() OVER().
SELECT sale_id,
       total_amount,
       SUM(total_amount) OVER(ORDER BY sale_id) AS Cummulative_Sales
FROM SALES ;

-- Calculate the average sale amount using AVG() OVER().
SELECT sale_id,total_amount,AVG(total_amount) OVER() AS Avg_sale_amount
FROM SALES;


-- PHASE-5 : CTE


-- Generate customer-wise revenue using a Common Table Expression (CTE).
-- Display customers whose spending is greater than the average spending.
WITH customer_wise_rev AS
(
SELECT c.customer_name,SUM(s.total_amount) AS Total_Revenue
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
GROUP BY c.customer_name
)
SELECT customer_name,Total_Revenue
FROM CUSTOMER_WISE_REV
WHERE Total_Revenue>(SELECT AVG(Total_Revenue) FROM CUSTOMER_WISE_REV)
ORDER BY Total_Revenue DESC;


-- PHASE-6 : Views

-- Create a View named SALES_REPORT.
CREATE VIEW SALES_REPORT AS
SELECT s.sale_id,c.customer_name,c.membership,p.product_name,p.category,b.branch_name,b.city as branch_city,s.quantity,s.sale_date,s.total_amount
FROM CUSTOMERS c
INNER JOIN SALES s
ON c.customer_id=s.customer_id
INNER JOIN PRODUCTS p
ON p.product_id=s.product_id
INNER JOIN BRANCHES b
ON b.branch_id=s.branch_id;

SELECT * FROM SALES_REPORT;


-- Create a Materialized View named TOP_CUSTOMERS.
CREATE MATERIALIZED VIEW TOP_CUSTOMERS AS
SELECT s.customer_id,
       SUM(s.total_amount) as customer_sales
FROM SALES s
GROUP BY s.customer_id;

SELECT customer_name,customer_id FROM TOP_CUSTOMERS
     

with cte_top_customers as
(
SELECT customer_name,
       customer_sales,
       DENSE_RANK() OVER(ORDER BY customer_sales DESC) AS dns_rnk
FROM CUSTOMERS c
INNER JOIN TOP_CUSTOMERS tc
on c.customer_id=tc.customer_id
)
SELECT * FROM cte_top_customers
WHERE dns_rnk<=3;