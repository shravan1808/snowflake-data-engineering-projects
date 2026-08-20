USE WAREHOUSE SNOWFLAKE_LEARNING_WH;


CREATE DATABASE CUSTOMER_MEMBERSHIP_DB;


USE DATABASE CUSTOMER_MEMBERSHIP_DB;


CREATE SCHEMA CUSTOMER_MEMBERSHIP_SCHEMA;


USE SCHEMA CUSTOMER_MEMBERSHIP_SCHEMA;


CREATE FILE FORMAT CSV_FORMAT
TYPE='CSV'
FIELD_DELIMITER = ','
SKIP_HEADER=1;


CREATE OR REPLACE STAGE RAW_STAGE
FILE_FORMAT=(FORMAT_NAME = CSV_FORMAT);


CREATE TABLE DIM_CUSTOMER_TYPE3
(
customer_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
customer_id NUMBER,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
current_membership VARCHAR,
previous_membership VARCHAR,
segment VARCHAR
);


INSERT INTO DIM_CUSTOMER_TYPE3(customer_id,customer_name,city,state,current_membership,previous_membership,segment)
SELECT  $1,
        $2,
        $3,
        $4,
        $5,
        NULL,
        $6
FROM @RAW_STAGE/customers_initial.csv;


SELECT  CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        CURRENT_MEMBERSHIP,
        PREVIOUS_MEMBERSHIP
FROM DIM_CUSTOMER_TYPE3;


UPDATE DIM_CUSTOMER_TYPE3 typ3
SET typ3.previous_membership=typ3.current_membership,
    typ3.current_membership=upd.$5 FROM @RAW_STAGE/customer_updates.csv AS upd
WHERE typ3.previous_membership IS NULL AND typ3.customer_id=upd.$1;


SELECT  CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        CURRENT_MEMBERSHIP,
        PREVIOUS_MEMBERSHIP
FROM DIM_CUSTOMER_TYPE3;


SELECT  CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        CURRENT_MEMBERSHIP,
        PREVIOUS_MEMBERSHIP
FROM DIM_CUSTOMER_TYPE3
WHERE CUSTOMER_ID=101;


CREATE TABLE DIM_CUSTOMER_TYPE6
(
customer_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
customer_id NUMBER,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
current_membership VARCHAR,
previous_membership VARCHAR,
historical_membership VARCHAR,
segment VARCHAR,
effective_date DATE,
expiry_date DATE,
is_current BOOLEAN
);


INSERT INTO DIM_CUSTOMER_TYPE6(customer_id,customer_name,city,state,current_membership,previous_membership,historical_membership,segment,effective_date,expiry_date,is_current)
SELECT  $1,
        $2,
        $3,
        $4,
        $5,
        NULL,
        $5,
        $6,
        TO_DATE('2026-01-01'),
        TO_DATE('9999-12-31'),
        TRUE
FROM @RAW_STAGE/customers_initial.csv;


UPDATE DIM_CUSTOMER_TYPE6 typ6
SET typ6.expiry_date=DATEADD(DAY,-1,upd.$7),
    typ6.is_current=FALSE
FROM @RAW_STAGE/customer_updates.csv AS upd
WHERE typ6.customer_id=upd.$1 AND typ6.is_current=TRUE;

INSERT INTO DIM_CUSTOMER_TYPE6(customer_id,customer_name,city,state,current_membership,previous_membership,historical_membership,segment,effective_date,expiry_date,is_current)
SELECT  upd.$1,
        upd.$2,
        upd.$3,
        upd.$4,
        upd.$5,
        typ6.current_membership,
        upd.$5,
        upd.$6,
        upd.$7,
        TO_DATE('9999-12-31'),
        TRUE
FROM @RAW_STAGE/customer_updates.csv upd
INNER JOIN DIM_CUSTOMER_TYPE6 typ6
ON upd.$1=typ6.customer_id AND typ6.is_current=FALSE;


SELECT  customer_id,
        customer_name,
        current_membership,
        previous_membership,
        effective_date,
        expiry_date,
        is_current
FROM dim_customer_type6
ORDER BY customer_id,effective_date;


SELECT  customer_id,
        customer_name,
        city,
        current_membership,
        previous_membership
FROM dim_customer_type6
WHERE is_current=TRUE
ORDER BY customer_id;


SELECT  customer_id,
        customer_name,
        current_membership,
        effective_date,
        expiry_date
FROM dim_customer_type6
WHERE (TO_DATE('2026-03-15') BETWEEN effective_date AND expiry_date) AND customer_id=101;


SELECT COUNT(*) 
FROM DIM_CUSTOMER_TYPE3;


SELECT COUNT(*) 
FROM DIM_CUSTOMER_TYPE6;


SELECT COUNT(*) 
FROM DIM_CUSTOMER_TYPE6
WHERE is_current=TRUE;


SELECT COUNT(*) 
FROM DIM_CUSTOMER_TYPE6
WHERE is_current=FALSE;