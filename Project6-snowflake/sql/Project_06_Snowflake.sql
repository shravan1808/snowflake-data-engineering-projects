USE WAREHOUSE RETAIL_SALES_WH_STAR;
USE DATABASE RETAIL_SALES_DB_STAR;
USE SCHEMA RETAIL_SCHEMA_STAR;

CREATE TABLE DIM_STATE 
(
state_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
state_name VARCHAR 
);

CREATE TABLE DIM_CITY
(
city_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
city_name VARCHAR,
state_id NUMBER REFERENCES DIM_STATE(state_id)
);

INSERT INTO DIM_STATE(state_name) 
SELECT DISTINCT state FROM DIM_CUSTOMER;

INSERT INTO DIM_CITY(city_name,state_id)
SELECT DISTINCT dc.city,ds.state_id
FROM DIM_CUSTOMER dc
INNER JOIN DIM_STATE ds
ON dc.state=ds.state_name;

ALTER TABLE DIM_CUSTOMER
ADD COLUMN city_id NUMBER;

UPDATE DIM_CUSTOMER c
SET c.city_id = dc.city_id 
FROM DIM_CITY dc 
WHERE c.city=dc.city_name;

ALTER TABLE DIM_CUSTOMER
ADD CONSTRAINT fk_city_id 
FOREIGN KEY (city_id) REFERENCES DIM_CITY(city_id);

ALTER TABLE DIM_CUSTOMER
DROP COLUMN city,state;

CREATE TABLE DIM_CATEGORY
(
category_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
category VARCHAR
);

CREATE TABLE DIM_BRAND
(
brand_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
brand VARCHAR,
category_id NUMBER REFERENCES DIM_CATEGORY(category_id)
);

INSERT INTO DIM_CATEGORY(category)
SELECT DISTINCT category 
FROM DIM_PRODUCT;

INSERT INTO DIM_BRAND(brand,category_id)
SELECT DISTINCT p.brand,cat.category_id
FROM DIM_PRODUCT p
INNER JOIN DIM_CATEGORY cat
ON p.category=cat.category;

ALTER TABLE DIM_PRODUCT
ADD COLUMN brand_id NUMBER;

UPDATE DIM_PRODUCT dp
SET dp.brand_id= db.brand_id FROM DIM_BRAND db
WHERE dp.brand=db.brand;

ALTER TABLE DIM_PRODUCT
ADD CONSTRAINT fk_brand_id
FOREIGN KEY (brand_id) REFERENCES DIM_BRAND(brand_id);

ALTER TABLE DIM_PRODUCT
DROP COLUMN brand,category;

CREATE TABLE DIM_REGION
(
region_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
region_name VARCHAR
);

ALTER TABLE DIM_STATE
ADD COLUMN region_id NUMBER;

INSERT INTO DIM_REGION(region_name)
SELECT DISTINCT region 
FROM DIM_BRANCH;

UPDATE DIM_STATE ds
SET ds.region_id= dr.region_id
FROM DIM_REGION dr 
inner join dim_branch db
on dr.region_name=db.region
WHERE ds.state_name=db.state;

ALTER TABLE DIM_STATE
ADD CONSTRAINT fk_region_id
FOREIGN KEY (region_id)
REFERENCES DIM_REGION(region_id);

ALTER TABLE DIM_BRANCH
ADD COLUMN CITY_ID NUMBER;

UPDATE DIM_BRANCH db
SET db.city_id = dc.city_id
FROM DIM_CITY dc
WHERE db.city=dc.city_name;

ALTER TABLE DIM_BRANCH
ADD CONSTRAINT fk_city_id
FOREIGN KEY (city_id)
REFERENCES DIM_CITY(city_id);

ALTER TABLE DIM_BRANCH
DROP COLUMN city,region,state;

CREATE TABLE DIM_YEAR
(
year_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
cal_year NUMBER
);

CREATE TABLE DIM_QTR
(
qtr_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
cal_qtr VARCHAR,
year_id NUMBER REFERENCES DIM_YEAR(year_id)
);

CREATE TABLE DIM_MONTH
(
month_id NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
cal_month VARCHAR,
qtr_id NUMBER REFERENCES DIM_QTR(qtr_id)
);

ALTER TABLE DIM_CALENDAR
ADD COLUMN month_id NUMBER;

INSERT INTO DIM_YEAR(cal_year)
SELECT DISTINCT cal_year 
FROM DIM_CALENDAR;

INSERT INTO DIM_QTR(cal_qtr,year_id)
SELECT DISTINCT dc.cal_qtr,dy.year_id
FROM DIM_CALENDAR dc
INNER JOIN DIM_YEAR dy
ON dc.cal_year=dy.cal_year;

INSERT INTO DIM_MONTH(cal_month,qtr_id)
SELECT DISTINCT dc.cal_month,dq.qtr_id
FROM DIM_CALENDAR dc
INNER JOIN DIM_QTR dq
ON dc.cal_qtr=dq.cal_qtr
INNER JOIN DIM_YEAR dy
ON dc.cal_year=dy.cal_year AND dq.year_id=dy.year_id;

UPDATE DIM_CALENDAR dc
SET dc.month_id = dm.month_id
FROM DIM_MONTH dm
INNER JOIN DIM_QTR dq
ON dm.qtr_id=dq.qtr_id
INNER JOIN DIM_YEAR dy
ON dq.year_id=dy.year_id
WHERE dc.cal_month=dm.cal_month AND dc.cal_qtr=dq.cal_qtr AND dc.cal_year = dy.cal_year;

ALTER TABLE DIM_CALENDAR 
ADD CONSTRAINT fk_month_id
FOREIGN KEY (month_id)
REFERENCES DIM_MONTH(month_id);

ALTER TABLE DIM_CALENDAR
DROP COLUMN cal_month,cal_qtr,cal_year;


-- Customer-wise Sales Report
SELECT  c.customer_id,
        c.customer_name,
        dc.city_name,
        ds.state_name,
        SUM(s.total_amount) AS customer_revenue
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
INNER JOIN DIM_CITY dc
ON c.city_id=dc.city_id
INNER JOIN DIM_STATE ds
ON dc.state_id=ds.state_id
GROUP BY c.customer_id,c.customer_name,dc.city_name,ds.state_name
ORDER BY customer_revenue DESC;
        

-- Product-wise Revenue Report
SELECT  p.product_id,
        p.product_name,
        dc.category,
        db.brand,
        SUM(s.total_amount) AS product_revenue
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
INNER JOIN DIM_BRAND db
ON p.brand_id=db.brand_id
INNER JOIN DIM_CATEGORY dc
ON db.category_id=dc.category_id
GROUP BY p.product_id,p.product_name,dc.category,db.brand
ORDER BY product_revenue DESC;


-- Brand-wise Revenue Report
SELECT  db.brand,
        SUM(s.total_amount) AS brand_revenue
FROM DIM_BRAND db
INNER JOIN DIM_PRODUCT p
ON db.brand_id=p.brand_id
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY db.brand
ORDER BY brand_revenue DESC;


-- Category-wise Revenue Report
SELECT  dc.category,
        SUM(s.total_amount) AS category_revenue
FROM DIM_CATEGORY dc
INNER JOIN DIM_BRAND db
ON dc.category_id=db.category_id
INNER JOIN DIM_PRODUCT p
ON db.brand_id=p.brand_id
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY dc.category
ORDER BY category_revenue DESC;


-- City-wise Sales Report
SELECT  dc.city_name,
        SUM(s.total_amount) AS city_revenue
FROM DIM_CITY dc
INNER JOIN DIM_BRANCH db
ON dc.city_id=db.city_id
INNER JOIN FACT_SALES s
ON db.branch_id=s.branch_id
GROUP BY dc.city_name
ORDER BY city_revenue DESC;


-- State-wise Revenue Report
SELECT  ds.state_name,
        SUM(s.total_amount) AS state_revenue
FROM DIM_STATE ds
INNER JOIN DIM_CITY dc
ON ds.state_id=dc.state_id
INNER JOIN DIM_BRANCH db
ON dc.city_id=db.city_id
INNER JOIN FACT_SALES s
ON db.branch_id=s.branch_id
GROUP BY ds.state_name
ORDER BY state_revenue DESC;


-- Region-wise Revenue Report
SELECT  dr.region_name,
        SUM(s.total_amount) AS region_revenue
FROM DIM_REGION dr 
INNER JOIN DIM_STATE ds
ON dr.region_id=ds.region_id
INNER JOIN DIM_CITY dc
ON ds.state_id=dc.state_id
INNER JOIN DIM_BRANCH db
ON dc.city_id=db.city_id
INNER JOIN FACT_SALES s
ON db.branch_id=s.branch_id
GROUP BY dr.region_name
ORDER BY region_revenue DESC;


-- Monthly Revenue Report
SELECT  dm.cal_month,
        SUM(s.total_amount) AS monthly_revenue
FROM DIM_MONTH dm
INNER JOIN DIM_CALENDAR dc
ON dm.month_id=dc.month_id
INNER JOIN FACT_SALES s
ON dc.date_id=s.date_id
GROUP BY dm.cal_month
ORDER BY monthly_revenue DESC;


-- Quarterly Revenue Report
SELECT  dq.cal_qtr,
        SUM(s.total_amount) AS quarterly_revenue
FROM DIM_YEAR dy
INNER JOIN DIM_QTR dq
ON dy.year_id=dq.year_id
INNER JOIN DIM_MONTH dm
ON dq.qtr_id=dm.qtr_id
INNER JOIN DIM_CALENDAR dc
ON dm.month_id=dc.month_id
INNER JOIN FACT_SALES s
ON dc.date_id=s.date_id
GROUP BY dq.cal_qtr,dy.cal_year
ORDER BY quarterly_revenue DESC;


-- Top 10 Customers
SELECT  c.customer_id,
        c.customer_name,
        dc.city_name,
        ds.state_name,
        SUM(s.total_amount) AS customer_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS customer_ranking
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
INNER JOIN DIM_CITY dc
ON c.city_id=dc.city_id
INNER JOIN DIM_STATE ds
ON dc.state_id=ds.state_id
GROUP BY c.customer_id,c.customer_name,dc.city_name,ds.state_name
QUALIFY customer_ranking<=10
ORDER BY customer_ranking;


-- Top 10 Products
SELECT  p.product_id,
        p.product_name,
        dc.category,
        db.brand,
        SUM(s.total_amount) AS product_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS product_ranking
FROM DIM_PRODUCT p
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
INNER JOIN DIM_BRAND db
ON p.brand_id=db.brand_id
INNER JOIN DIM_CATEGORY dc
ON db.category_id=dc.category_id
GROUP BY p.product_id,p.product_name,dc.category,db.brand
QUALIFY product_ranking<=10
ORDER BY product_ranking;


-- Top 10 Branches
SELECT  b.branch_id,
        b.branch_name,
        dc.city_name,
        ds.state_name,
        dr.region_name,
        SUM(s.total_amount) AS branch_revenue,
        DENSE_RANK() OVER(ORDER BY SUM(s.total_amount) DESC) AS branch_ranking
FROM DIM_BRANCH b
INNER JOIN FACT_SALES s
ON b.branch_id=s.branch_id
INNER JOIN DIM_CITY dc
ON b.city_id=dc.city_id
INNER JOIN DIM_STATE ds
ON dc.state_id=ds.state_id
INNER JOIN DIM_REGION dr
ON ds.region_id=dr.region_id
GROUP BY b.branch_id,b.branch_name,dc.city_name,ds.state_name,dr.region_name
QUALIFY branch_ranking<=10
ORDER BY branch_ranking;


-- Customer Purchase Trend
SELECT  c.customer_id,
        dm.cal_month,
        COUNT(s.sale_id) AS Order_Frequency
FROM DIM_CUSTOMER c
INNER JOIN FACT_SALES s
ON c.customer_id=s.customer_id
INNER JOIN DIM_CALENDAR dc
ON dc.date_id=s.date_id
INNER JOIN DIM_MONTH dm
ON dm.month_id=dc.month_id
GROUP BY c.customer_id,dm.cal_month
ORDER BY c.customer_id;

-- Product Performance Dashboard
SELECT  p.product_id,
        p.product_name,
        db.brand,
        cat.category,
        SUM(s.quantity) AS quantity_sold,
        SUM(s.total_amount) AS product_revenue
FROM DIM_PRODUCT p
INNER JOIN DIM_BRAND db
ON p.brand_id=db.brand_id
INNER JOIN DIM_CATEGORY cat
ON db.category_id=cat.category_id
INNER JOIN FACT_SALES s
ON p.product_id=s.product_id
GROUP BY p.product_id,p.product_name,db.brand,cat.category
ORDER BY quantity_sold DESC,product_revenue DESC;


-- Regional Sales Dashboard
SELECT  dr.region_name,
        SUM(s.quantity) AS quantity_sold,
        SUM(s.total_amount) AS regional_revenue
FROM DIM_BRANCH db
INNER JOIN DIM_CITY dc
ON db.city_id=dc.city_id
INNER JOIN DIM_STATE ds
ON dc.state_id=ds.state_id
INNER JOIN DIM_REGION dr
ON ds.region_id=dr.region_id
INNER JOIN FACT_SALES s
ON db.branch_id=s.branch_id
GROUP BY dr.region_name
ORDER BY quantity_sold DESC,regional_revenue DESC;