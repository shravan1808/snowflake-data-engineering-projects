USE WAREHOUSE SNOWFLAKE_LEARNING_WH;

CREATE DATABASE SCD;

CREATE SCHEMA SCD_SCHEMA;

USE DATABASE SCD;

USE SCHEMA SCD_SCHEMA;


-- CUSTOMER DIMENSION TABLE CREATION
CREATE TABLE DIM_CUSTOMER_TYPE1
(
customer_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
customer_id NUMBER,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR,
segment VARCHAR
);


CREATE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;


CREATE STAGE RAW_STAGE
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT');


COPY INTO DIM_CUSTOMER_TYPE1(customer_id,customer_name,city,state,membership,segment)
FROM @RAW_STAGE/customer_initials.csv;


CREATE TABLE CUSTOMER_UPDATES
(
customer_id NUMBER primary key,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR,
segment VARCHAR,
effective_date DATE
);


COPY INTO CUSTOMER_UPDATES
FROM @RAW_STAGE/customer_updates.csv;


UPDATE DIM_CUSTOMER_TYPE1 typ1
SET typ1.city = upd.city,
    typ1.state=upd.state,
    typ1.membership = upd.membership,
    typ1.segment=upd.segment
FROM CUSTOMER_UPDATES upd
WHERE typ1.customer_id=upd.customer_id;


SELECT * FROM DIM_CUSTOMER_TYPE1
ORDER BY CUSTOMER_ID;


SELECT * FROM DIM_CUSTOMER_TYPE1
WHERE CUSTOMER_ID=101;


CREATE TABLE DIM_CUSTOMER_TYPE2
(
customer_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
customer_id NUMBER,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR,
segment VARCHAR,
effective_date DATE,
expiry_date DATE,
is_current BOOLEAN
);


INSERT INTO DIM_CUSTOMER_TYPE2(customer_id,customer_name,city,state,membership,segment,effective_date,expiry_date,is_current)
SELECT  $1 AS customer_id,
        $2 AS customer_name,
        $3 AS city,
        $4 AS state,
        $5 AS membership,
        $6 AS segment,
        TO_DATE('2026-01-01') AS effective_date,
        TO_DATE('9999-12-31') AS expiry_date,
        TRUE AS is_current
FROM @RAW_STAGE/customer_initials.csv;


UPDATE DIM_CUSTOMER_TYPE2 typ2
SET typ2.is_current=FALSE,
    typ2.expiry_date=DATEADD(DAY,-1,upd.effective_date)
FROM CUSTOMER_UPDATES upd
WHERE typ2.is_current=TRUE AND typ2.customer_id = upd.customer_id; 


SELECT * FROM dim_customer_type2;


INSERT INTO DIM_CUSTOMER_TYPE2(customer_id,customer_name,city,state,membership,segment,effective_date,expiry_date,is_current)
SELECT  upd.customer_id,
        upd.customer_name,
        upd.city,
        upd.state,
        upd.membership,
        upd.segment,
        upd.effective_date,
        TO_DATE('9999-12-31'),
        TRUE
FROM CUSTOMER_UPDATES upd;


SELECT * FROM DIM_CUSTOMER_TYPE2
ORDER BY CUSTOMER_ID;


SELECT * FROM DIM_CUSTOMER_TYPE2
WHERE IS_CURRENT=TRUE
ORDER BY CUSTOMER_ID;


SELECT * FROM DIM_CUSTOMER_TYPE2
WHERE CUSTOMER_ID=101 AND '2026-03-15' BETWEEN EFFECTIVE_DATE AND EXPIRY_DATE;

SELECT COUNT(*) AS type1_records
FROM DIM_CUSTOMER_TYPE1;

SELECT COUNT(*) AS type2_records
FROM DIM_CUSTOMER_TYPE2;

SELECT COUNT(*) AS current_records
FROM DIM_CUSTOMER_TYPE2
WHERE IS_CURRENT = TRUE;

SELECT COUNT(*) AS historical_records
FROM DIM_CUSTOMER_TYPE2
WHERE IS_CURRENT = FALSE;