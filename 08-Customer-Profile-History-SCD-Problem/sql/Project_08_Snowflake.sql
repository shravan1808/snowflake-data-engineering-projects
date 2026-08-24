USE WAREHOUSE SNOWFLAKE_LEARNING_WH;

CREATE DATABASE CUSTOMER_HISTORY_DB;

CREATE SCHEMA CUSTOMER_HISTORY_SCHEMA;

USE DATABASE CUSTOMER_HISTORY_DB;

USE SCHEMA CUSTOMER_HISTORY_SCHEMA;


-- CUSTOMER DIMENSION TABLE CREATION
CREATE TABLE DIM_CUSTOMER
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

COPY INTO DIM_CUSTOMER(customer_id,customer_name,city,state,membership,segment)
FROM @RAW_STAGE/customer_initials.csv;

SELECT * FROM DIM_CUSTOMER;

CREATE TABLE CUSTOMER_UPDATES
(
customer_id NUMBER primary key,
customer_name VARCHAR,
city VARCHAR,
state VARCHAR,
membership VARCHAR,
segment VARCHAR
);

COPY INTO CUSTOMER_UPDATES
FROM @RAW_STAGE/customer_updates.csv;

SELECT  dim.customer_id,
        dim.city AS old_city,
        upd.city AS new_city,
        dim.state AS old_state,
        upd.state AS new_state,
        dim.membership AS old_membership,
        upd.membership AS new_membership,
        dim.segment AS old_segment,
        upd.segment AS new_segment
FROM DIM_CUSTOMER dim
INNER JOIN CUSTOMER_UPDATES upd
ON dim.customer_id=upd.customer_id
WHERE    dim.city <> upd.city
      OR dim.state <> upd.state
      OR dim.membership <> upd.membership
      OR dim.segment <> upd.segment;


(SELECT  dim.customer_id,
        'CITY' AS attribute,
        dim.city AS old_value,
        upd.city AS new_value
FROM DIM_CUSTOMER dim
INNER JOIN CUSTOMER_UPDATES upd
ON dim.customer_id=upd.customer_id
WHERE dim.city<>upd.city
)
UNION ALL
(SELECT  dim.customer_id,
        'STATE' AS attribute,
        dim.state AS old_value,
        upd.state AS new_value
FROM DIM_CUSTOMER dim
INNER JOIN CUSTOMER_UPDATES upd
ON dim.customer_id=upd.customer_id
WHERE dim.state<>upd.state
)
UNION ALL
(SELECT  dim.customer_id,
        'MEMBERSHIP' AS attribute,
        dim.membership AS old_value,
        upd.membership AS new_value
FROM DIM_CUSTOMER dim
INNER JOIN CUSTOMER_UPDATES upd
ON dim.customer_id=upd.customer_id
WHERE dim.membership<>upd.membership
)
UNION ALL
(SELECT  dim.customer_id,
        'SEGMENT' AS attribute,
        dim.segment AS old_value,
        upd.segment AS new_value
FROM DIM_CUSTOMER dim
INNER JOIN CUSTOMER_UPDATES upd
ON dim.customer_id=upd.customer_id
WHERE dim.segment<>upd.segment
)
ORDER BY customer_id;


UPDATE DIM_CUSTOMER dim
SET dim.city = upd.city,
    dim.state=upd.state,
    dim.membership = upd.membership,
    dim.segment=upd.segment
FROM CUSTOMER_UPDATES upd
WHERE dim.customer_id=upd.customer_id;

SELECT * FROM DIM_CUSTOMER
ORDER BY CUSTOMER_KEY;

SELECT * FROM DIM_CUSTOMER
WHERE CUSTOMER_ID=101;