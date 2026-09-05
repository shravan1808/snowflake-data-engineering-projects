


-- Create Architecture Context
CREATE DATABASE IF NOT EXISTS ENTERPRISE_DW;
USE DATABASE ENTERPRISE_DW;
CREATE SCHEMA IF NOT EXISTS RETAIL_MART;
USE SCHEMA RETAIL_MART;

-- 1. DIM_DATE (Role-Playing & Conformed Dimension)
CREATE OR REPLACE TABLE DIM_DATE (
    date_sk INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL
);

-- 2. DIM_CUSTOMER (SCD Type 2 Dimension)
CREATE OR REPLACE TABLE DIM_CUSTOMER (
    customer_sk INT PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    tier VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    effective_start_timestamp TIMESTAMP_NTZ NOT NULL,
    effective_end_timestamp TIMESTAMP_NTZ,
    is_current BOOLEAN NOT NULL
);

-- 3. DIM_PRODUCT (Conformed Hierarchy Dimension)
CREATE OR REPLACE TABLE DIM_PRODUCT (
    product_sk INT PRIMARY KEY,
    product_id VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    department_name VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL
);

-- 4. FACT_SALES (Transaction Fact Table with Degenerate & Role-Playing Dimensions)
CREATE OR REPLACE TABLE FACT_SALES (
    sales_sk INT PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL, -- Degenerate Dimension
    customer_sk INT REFERENCES DIM_CUSTOMER(customer_sk),
    product_sk INT REFERENCES DIM_PRODUCT(product_sk),
    order_date_sk INT REFERENCES DIM_DATE(date_sk), -- Role Playing 1
    ship_date_sk INT REFERENCES DIM_DATE(date_sk),  -- Role Playing 2
    quantity INT NOT NULL,                          -- Additive Measure
    revenue DECIMAL(12, 2) NOT NULL                 -- Additive Measure
);

-- 5. FACT_MONTHLY_INVENTORY (Periodic Snapshot Fact Table)

CREATE OR REPLACE TABLE FACT_MONTHLY_INVENTORY (
    snapshot_sk INT PRIMARY KEY,
    snapshot_date_sk INT REFERENCES DIM_DATE(date_sk),
    product_sk INT REFERENCES DIM_PRODUCT(product_sk),
    starting_stock_qty INT NOT NULL,               -- Semi-Additive
    ending_stock_qty INT NOT NULL,                 -- Semi-Additive
    restock_qty INT NOT NULL                       -- Additive
);

-- 6. FACT_PROMOTION_COVERAGE (Factless Fact Table)
CREATE OR REPLACE TABLE FACT_PROMOTION_COVERAGE (
    coverage_sk INT PRIMARY KEY,
    product_sk INT REFERENCES DIM_PRODUCT(product_sk),
    date_sk INT REFERENCES DIM_DATE(date_sk),
    promotion_code VARCHAR(30) NOT NULL
);



Step 2: Comprehensive Mock Data Seed (20+ Rows Per Table)
--------------------------------------------------------
-- Populate 1. DIM_DATE (20 Records)
INSERT INTO DIM_DATE VALUES
(20260101, '2026-01-01', 2026, 1, 1, 'January', 'Thursday', FALSE, TRUE),
(20260102, '2026-01-02', 2026, 1, 1, 'January', 'Friday', FALSE, FALSE),
(20260103, '2026-01-03', 2026, 1, 1, 'January', 'Saturday', TRUE, FALSE),
(20260104, '2026-01-04', 2026, 1, 1, 'January', 'Sunday', TRUE, FALSE),
(20260105, '2026-01-05', 2026, 1, 1, 'January', 'Monday', FALSE, FALSE),
(20260106, '2026-01-06', 2026, 1, 1, 'January', 'Tuesday', FALSE, FALSE),
(20260107, '2026-01-07', 2026, 1, 1, 'January', 'Wednesday', FALSE, FALSE),
(20260108, '2026-01-08', 2026, 1, 1, 'January', 'Thursday', FALSE, FALSE),
(20260109, '2026-01-09', 2026, 1, 1, 'January', 'Friday', FALSE, FALSE),
(20260110, '2026-01-10', 2026, 1, 1, 'January', 'Saturday', TRUE, FALSE),
(20260111, '2026-01-11', 2026, 1, 1, 'January', 'Sunday', TRUE, FALSE),
(20260112, '2026-01-12', 2026, 1, 1, 'January', 'Monday', FALSE, FALSE),
(20260113, '2026-01-13', 2026, 1, 1, 'January', 'Tuesday', FALSE, FALSE),
(20260114, '2026-01-14', 2026, 1, 1, 'January', 'Wednesday', FALSE, FALSE),
(20260115, '2026-01-15', 2026, 1, 1, 'January', 'Thursday', FALSE, FALSE),
(20260116, '2026-01-16', 2026, 1, 1, 'January', 'Friday', FALSE, FALSE),
(20260117, '2026-01-17', 2026, 1, 1, 'January', 'Saturday', TRUE, FALSE),
(20260118, '2026-01-18', 2026, 1, 1, 'January', 'Sunday', TRUE, FALSE),
(20260119, '2026-01-19', 2026, 1, 1, 'January', 'Monday', FALSE, FALSE),
(20260120, '2026-01-20', 2026, 1, 1, 'January', 'Tuesday', FALSE, FALSE);

-- Populate 2. DIM_CUSTOMER (20 Records - Includes Inferred Key -1 and SCD2 historical records)
INSERT INTO DIM_CUSTOMER VALUES
(-1, 'CUST-000', 'Inferred Member', 'unknown@domain.com', 'None', 'Unknown', '2020-01-01 00:00:00', NULL, TRUE),
(101, 'CUST-001', 'Alice Smith', 'alice@gmail.com', 'Gold', 'New York', '2025-01-01 00:00:00', '2026-01-05 00:00:00', FALSE),
(102, 'CUST-001', 'Alice Smith', 'alice_new@gmail.com', 'Platinum', 'New York', '2026-01-05 00:00:00', NULL, TRUE),
(103, 'CUST-002', 'Bob Jones', 'bob@yahoo.com', 'Silver', 'Chicago', '2025-06-01 00:00:00', NULL, TRUE),
(104, 'CUST-003', 'Charlie Brown', 'charlie@hotmail.com', 'Bronze', 'Houston', '2025-08-15 00:00:00', NULL, TRUE),
(105, 'CUST-004', 'Diana Prince', 'diana@amazon.com', 'Platinum', 'Seattle', '2025-02-10 00:00:00', NULL, TRUE),
(106, 'CUST-005', 'Evan Wright', 'evan@tech.com', 'Silver', 'Boston', '2025-11-20 00:00:00', NULL, TRUE),
(107, 'CUST-006', 'Fiona Gallagher', 'fiona@chicago.gov', 'Gold', 'Chicago', '2025-04-12 00:00:00', NULL, TRUE),
(108, 'CUST-007', 'George Clark', 'george@clark.org', 'Bronze', 'Denver', '2025-09-01 00:00:00', NULL, TRUE),
(109, 'CUST-008', 'Hannah Abbott', 'hannah@hogwarts.edu', 'Gold', 'Austin', '2025-03-30 00:00:00', NULL, TRUE),
(110, 'CUST-009', 'Ian Malcolm', 'ian@dino.com', 'Platinum', 'Dallas', '2025-07-07 00:00:00', NULL, TRUE),
(111, 'CUST-010', 'Julia Roberts', 'julia@cinema.com', 'Silver', 'Los Angeles', '2025-10-15 00:00:00', NULL, TRUE),
(112, 'CUST-011', 'Kevin Bacon', 'kevin@actor.com', 'Gold', 'Philadelphia', '2025-12-01 00:00:00', NULL, TRUE),
(113, 'CUST-012', 'Laura Croft', 'laura@tomb.org', 'Platinum', 'San Francisco', '2025-01-20 00:00:00', NULL, TRUE),
(114, 'CUST-013', 'Michael Scott', 'michael@paper.com', 'Bronze', 'Scranton', '2025-05-05 00:00:00', NULL, TRUE),
(115, 'CUST-014', 'Nancy Drew', 'nancy@detective.com', 'Silver', 'River Heights', '2025-06-18 00:00:00', NULL, TRUE),
(116, 'CUST-015', 'Oscar Martinez', 'oscar@accounting.com', 'Gold', 'Scranton', '2025-08-22 00:00:00', NULL, TRUE),
(117, 'CUST-016', 'Pam Beesly', 'pam@art.com', 'Silver', 'Scranton', '2025-09-14 00:00:00', NULL, TRUE),
(118, 'CUST-017', 'Quentin Tarantino', 'quentin@film.com', 'Platinum', 'Los Angeles', '2025-10-01 00:00:00', NULL, TRUE),
(119, 'CUST-018', 'Rachel Green', 'rachel@fashion.com', 'Gold', 'New York', '2025-11-11 00:00:00', NULL, TRUE),
(120, 'CUST-019', 'Steve Rogers', 'steve@shield.gov', 'Platinum', 'Brooklyn', '2025-01-01 00:00:00', NULL, TRUE);

-- Populate 3. DIM_PRODUCT (20 Records)
INSERT INTO DIM_PRODUCT VALUES
(201, 'PRD-101', '4K Smart Monitor 27in', 'Monitors', 'Electronics', 250.00),
(202, 'PRD-102', 'Ergonomic Mechanical Keyboard', 'Accessories', 'Electronics', 75.00),
(203, 'PRD-103', 'Wireless Gaming Mouse', 'Accessories', 'Electronics', 40.00),
(204, 'PRD-104', 'USB-C Docking Station', 'Accessories', 'Electronics', 90.00),
(205, 'PRD-105', 'Noise-Canceling Headphones', 'Audio', 'Electronics', 180.00),
(206, 'PRD-106', 'Standing Desk Converter', 'Furniture', 'Office Supplies', 150.00),
(207, 'PRD-107', 'Mesh Office Chair', 'Furniture', 'Office Supplies', 200.00),
(208, 'PRD-108', 'LED Desk Lamp', 'Lighting', 'Office Supplies', 25.00),
(209, 'PRD-109', 'HD Web Camera 1080p', 'Audio & Video', 'Electronics', 50.00),
(210, 'PRD-110', 'External SSD 1TB', 'Storage', 'Electronics', 85.00),
(211, 'PRD-111', 'Bluetooth Soundbar', 'Audio', 'Electronics', 110.00),
(212, 'PRD-112', 'Paper Shredder Cross-Cut', 'Equipment', 'Office Supplies', 60.00),
(213, 'PRD-113', 'Laser Printer Monochrome', 'Printers', 'Office Supplies', 190.00),
(214, 'PRD-114', 'Surge Protector Tower', 'Power', 'Electronics', 30.00),
(215, 'PRD-115', 'Ergonomic Footrest', 'Furniture', 'Office Supplies', 35.00),
(216, 'PRD-116', 'Wireless Charger Pad', 'Accessories', 'Electronics', 20.00),
(217, 'PRD-117', 'Thermal Label Printer', 'Printers', 'Office Supplies', 130.00),
(218, 'PRD-118', 'Laptop Sleeve 15in', 'Accessories', 'Electronics', 18.00),
(219, 'PRD-119', 'Blue Light Glasses', 'Apparel', 'Personal', 22.00),
(220, 'PRD-120', 'Cable Management Box', 'Accessories', 'Office Supplies', 15.00);

-- Populate 4. FACT_SALES (20 Records)
INSERT INTO FACT_SALES VALUES
(1, 'ORD-9001', 102, 201, 20260101, 20260103, 1, 399.99),
(2, 'ORD-9001', 102, 202, 20260101, 20260103, 2, 240.00),
(3, 'ORD-9002', 103, 205, 20260102, 20260104, 1, 299.99),
(4, 'ORD-9003', 104, 203, 20260102, 20260105, 3, 180.00),
(5, 'ORD-9004', 105, 207, 20260103, 20260106, 1, 350.00),
(6, 'ORD-9005', 106, 210, 20260104, 20260107, 2, 260.00),
(7, 'ORD-9006', 107, 204, 20260105, 20260108, 1, 140.00),
(8, 'ORD-9007', 108, 208, 20260105, 20260107, 4, 160.00),
(9, 'ORD-9008', 109, 206, 20260106, 20260109, 1, 250.00),
(10, 'ORD-9009', 110, 213, 20260107, 20260110, 1, 299.00),
(11, 'ORD-9010', 111, 209, 20260108, 20260111, 2, 160.00),
(12, 'ORD-9011', 112, 211, 20260109, 20260112, 1, 180.00),
(13, 'ORD-9012', 113, 214, 20260110, 20260112, 5, 225.00),
(14, 'ORD-9013', 114, 212, 20260111, 20260114, 1, 95.00),
(15, 'ORD-9014', 115, 215, 20260112, 20260115, 2, 110.00),
(16, 'ORD-9015', 116, 216, 20260113, 20260116, 3, 90.00),
(17, 'ORD-9016', 117, 217, 20260114, 20260117, 1, 210.00),
(18, 'ORD-9017', 118, 218, 20260115, 20260118, 2, 50.00),
(19, 'ORD-9018', 119, 219, 20260116, 20260119, 2, 70.00),
(20, 'ORD-9019', 120, 220, 20260117, 20260120, 4, 100.00);

-- Populate 5. FACT_MONTHLY_INVENTORY (20 Records)
INSERT INTO FACT_MONTHLY_INVENTORY VALUES
(1, 20260101, 201, 50, 35, 0),
(2, 20260101, 202, 100, 80, 20),
(3, 20260101, 203, 120, 95, 0),
(4, 20260101, 204, 40, 22, 10),
(5, 20260101, 205, 30, 15, 0),
(6, 20260101, 206, 25, 10, 5),
(7, 20260101, 207, 15, 8, 0),
(8, 20260101, 208, 200, 150, 50),
(9, 20260101, 209, 80, 60, 0),
(10, 20260101, 210, 90, 70, 15),
(11, 20260101, 211, 45, 30, 0),
(12, 20260101, 212, 35, 25, 0),
(13, 20260101, 213, 20, 12, 10),
(14, 20260101, 214, 150, 110, 0),
(15, 20260101, 215, 60, 48, 0),
(16, 20260101, 216, 110, 85, 25),
(17, 20260101, 217, 25, 18, 0),
(18, 20260101, 218, 95, 80, 0),
(19, 20260101, 219, 70, 50, 10),
(20, 20260101, 220, 130, 100, 0);

-- Populate 6. FACT_PROMOTION_COVERAGE (20 Records)
INSERT INTO FACT_PROMOTION_COVERAGE VALUES
(1, 201, 20260101, 'NEWYEAR_2026'),
(2, 202, 20260101, 'NEWYEAR_2026'),
(3, 203, 20260102, 'TECH_DEALS'),
(4, 204, 20260102, 'TECH_DEALS'),
(5, 205, 20260103, 'AUDIO_MANIA'),
(6, 206, 20260104, 'OFFICE_REFRESH'),
(7, 207, 20260105, 'OFFICE_REFRESH'),
(8, 208, 20260105, 'LIGHTING_SALE'),
(9, 209, 20260106, 'WORK_FROM_HOME'),
(10, 210, 20260107, 'STORAGE_BLOWOUT'),
(11, 211, 20260108, 'AUDIO_MANIA'),
(12, 212, 20260109, 'OFFICE_REFRESH'),
(13, 213, 20260110, 'TECH_DEALS'),
(14, 214, 20260111, 'POWER_SAVINGS'),
(15, 215, 20260112, 'ERGONOMIC_COMFORT'),
(16, 216, 20260113, 'TECH_DEALS'),
(17, 217, 20260114, 'OFFICE_REFRESH'),
(18, 218, 20260115, 'ACCESSORY_SPECIAL'),
(19, 219, 20260116, 'HEALTH_WELLNESS'),
(20, 220, 20260117, 'ORGANIZATION_SALE');


Step 3: 15 Practical Capstone Tasks
--------------------------------------
Execute and verify each task directly in your Snowflake Worksheet.

Task 1: Role-Playing Dimensions Join

Query total sales revenue by connecting FACT_SALES to DIM_DATE twice (once as OrderDate and once as ShipDate).


Expected output
-----------------
ORDER_DATE,SHIP_DATE,DAILY_REVENUE
2026-01-01,2026-01-03,639.99
2026-01-02,2026-01-04,299.99
2026-01-02,2026-01-05,180.00
2026-01-03,2026-01-06,350.00
2026-01-04,2026-01-07,260.00
2026-01-05,2026-01-07,160.00
2026-01-05,2026-01-08,140.00
2026-01-06,2026-01-09,250.00
2026-01-07,2026-01-10,299.00
2026-01-08,2026-01-11,160.00
2026-01-09,2026-01-12,180.00
2026-01-10,2026-01-12,225.00
2026-01-11,2026-01-14,95.00
2026-01-12,2026-01-15,110.00
2026-01-13,2026-01-16,90.00
2026-01-14,2026-01-17,210.00
2026-01-15,2026-01-18,50.00
2026-01-16,2026-01-19,70.00
2026-01-17,2026-01-20,100.00


Task 2: Additive Measure Aggregation

Calculate total revenue, total items sold, and average revenue per line item from FACT_SALES.

Expected output
-----------------
TOTAL_UNITS_SOLD,TOTAL_REVENUE,AVG_LINE_REVENUE
37,3858.98,192.949000



Task 3: Semi-Additive Measure Processing

Calculate ending inventory balances without incorrectly summing across time dimensions (group by product across time).

Expected output
-----------------
PRODUCT_NAME,SNAPSHOT_DATE,ENDING_STOCK_QTY
4K Smart Monitor 27in,2026-01-01,35
Ergonomic Mechanical Keyboard,2026-01-01,80
Wireless Gaming Mouse,2026-01-01,95
USB-C Docking Station,2026-01-01,22
Noise-Canceling Headphones,2026-01-01,15
Standing Desk Converter,2026-01-01,10
Mesh Office Chair,2026-01-01,8
LED Desk Lamp,2026-01-01,150
HD Web Camera 1080p,2026-01-01,60
External SSD 1TB,2026-01-01,70
Bluetooth Soundbar,2026-01-01,30
Paper Shredder Cross-Cut,2026-01-01,25
Laser Printer Monochrome,2026-01-01,12
Surge Protector Tower,2026-01-01,110
Ergonomic Footrest,2026-01-01,48
Wireless Charger Pad,2026-01-01,85
Thermal Label Printer,2026-01-01,18
Laptop Sleeve 15in,2026-01-01,80
Blue Light Glasses,2026-01-01,50
Cable Management Box,2026-01-01,100

Task 4: Factless Fact Promotion Coverage Analysis

Find products that were listed under promotions but had no sales generated on that date.

Expected output
-----------------;
PRODUCT_NAME,PROMOTION_CODE,FULL_DATE
4K Smart Monitor 27in,NEWYEAR_2026,2026-01-01
Ergonomic Mechanical Keyboard,NEWYEAR_2026,2026-01-01
Wireless Gaming Mouse,TECH_DEALS,2026-01-02
USB-C Docking Station,TECH_DEALS,2026-01-02
Noise-Canceling Headphones,AUDIO_MANIA,2026-01-03
Standing Desk Converter,OFFICE_REFRESH,2026-01-04
Mesh Office Chair,OFFICE_REFRESH,2026-01-05
LED Desk Lamp,LIGHTING_SALE,2026-01-05
HD Web Camera 1080p,WORK_FROM_HOME,2026-01-06
External SSD 1TB,STORAGE_BLOWOUT,2026-01-07
Bluetooth Soundbar,AUDIO_MANIA,2026-01-08
Paper Shredder Cross-Cut,OFFICE_REFRESH,2026-01-09
Laser Printer Monochrome,TECH_DEALS,2026-01-10
Surge Protector Tower,POWER_SAVINGS,2026-01-11
Ergonomic Footrest,ERGONOMIC_COMFORT,2026-01-12
Wireless Charger Pad,TECH_DEALS,2026-01-13
Thermal Label Printer,OFFICE_REFRESH,2026-01-14
Laptop Sleeve 15in,ACCESSORY_SPECIAL,2026-01-15
Blue Light Glasses,HEALTH_WELLNESS,2026-01-16
Cable Management Box,ORGANIZATION_SALE,2026-01-17

Task 5: Degenerate Dimension Analysis

Calculate total orders and revenue per order by grouping directly on the order_id in FACT_SALES.

Expected output
-----------------
ORDER_ID,LINE_ITEM_COUNT,ORDER_TOTAL_REVENUE
ORD-9001,2,639.99
ORD-9002,1,299.99
ORD-9003,1,180.00
ORD-9004,1,350.00
ORD-9005,1,260.00
ORD-9006,1,140.00
ORD-9007,1,160.00
ORD-9008,1,250.00
ORD-9009,1,299.00
ORD-9010,1,160.00
ORD-9011,1,180.00
ORD-9012,1,225.00
ORD-9013,1,95.00
ORD-9014,1,110.00
ORD-9015,1,90.00
ORD-9016,1,210.00
ORD-9017,1,50.00
ORD-9018,1,70.00
ORD-9019,1,100.00

Task 6: Hierarchical Rollup Query

Aggregate sales performance across Department, Category, and Product hierarchies.


Expected output
-----------------
DEPARTMENT_NAME,CATEGORY_NAME,PRODUCT_NAME,REVENUE
Electronics,Accessories,Ergonomic Mechanical Keyboard,240.00
Electronics,Accessories,Laptop Sleeve 15in,50.00
Electronics,Accessories,USB-C Docking Station,140.00
Electronics,Accessories,Wireless Charger Pad,90.00
Electronics,Accessories,Wireless Gaming Mouse,180.00
Electronics,Accessories,NULL,700.00
Electronics,Audio,Bluetooth Soundbar,180.00
Electronics,Audio,Noise-Canceling Headphones,299.99
Electronics,Audio,NULL,479.99
Electronics,Audio & Video,HD Web Camera 1080p,160.00
Electronics,Audio & Video,NULL,160.00
Electronics,Monitors,4K Smart Monitor 27in,399.99
Electronics,Monitors,NULL,399.99
Electronics,Power,Surge Protector Tower,225.00
Electronics,Power,NULL,225.00
Electronics,Storage,External SSD 1TB,260.00
Electronics,Storage,NULL,260.00
Electronics,NULL,NULL,2224.98
Office Supplies,Equipment,Paper Shredder Cross-Cut,95.00
Office Supplies,Equipment,NULL,95.00
Office Supplies,Furniture,Ergonomic Footrest,110.00
Office Supplies,Furniture,Mesh Office Chair,350.00
Office Supplies,Furniture,Standing Desk Converter,250.00
Office Supplies,Furniture,NULL,710.00
Office Supplies,Lighting,LED Desk Lamp,160.00
Office Supplies,Lighting,NULL,160.00
Office Supplies,Personal,Cable Management Box,100.00
Office Supplies,Personal,NULL,100.00
Office Supplies,Printers,Laser Printer Monochrome,299.00
Office Supplies,Printers,Thermal Label Printer,210.00
Office Supplies,Printers,NULL,509.00
Office Supplies,NULL,NULL,1564.00
Personal,Apparel,Blue Light Glasses,70.00
Personal,Apparel,NULL,70.00
Personal,NULL,NULL,70.00
NULL,NULL,NULL,3858.98

Task 7: Current vs Historical SCD Type 2 Query

Retrieve current customer attributes while ensuring historical dimension records are filtered out.

Expected output
-----------------
CUSTOMER_ID,CUSTOMER_NAME,EMAIL,TIER
CUST-001,Alice Smith,alice_new@gmail.com,Platinum
CUST-002,Bob Jones,bob@yahoo.com,Silver
CUST-003,Charlie Brown,charlie@hotmail.com,Bronze
CUST-004,Diana Prince,diana@amazon.com,Platinum
CUST-005,Evan Wright,evan@tech.com,Silver
CUST-006,Fiona Gallagher,fiona@chicago.gov,Gold
CUST-007,George Clark,george@clark.org,Bronze
CUST-008,Hannah Abbott,hannah@hogwarts.edu,Gold
CUST-009,Ian Malcolm,ian@dino.com,Platinum
CUST-010,Julia Roberts,julia@cinema.com,Silver
CUST-011,Kevin Bacon,kevin@actor.com,Gold
CUST-012,Laura Croft,laura@tomb.org,Platinum
CUST-013,Michael Scott,michael@paper.com,Bronze
CUST-014,Nancy Drew,nancy@detective.com,Silver
CUST-015,Oscar Martinez,oscar@accounting.com,Gold
CUST-016,Pam Beesly,pam@art.com,Silver
CUST-017,Quentin Tarantino,quentin@film.com,Platinum
CUST-018,Rachel Green,rachel@fashion.com,Gold
CUST-019,Steve Rogers,steve@shield.gov,Platinum

Task 8: SCD Type 2 Timeline Point-In-Time Join

Join historical sales to the exact version of the customer record active on the order date.

Expected output
-----------------
ORDER_ID,CUSTOMER_NAME,EMAIL_AT_PURCHASE_TIME,REVENUE
ORD-9001,Alice Smith,alice_new@gmail.com,399.99
ORD-9001,Alice Smith,alice_new@gmail.com,240.00
ORD-9002,Bob Jones,bob@yahoo.com,299.99
ORD-9003,Charlie Brown,charlie@hotmail.com,180.00
ORD-9004,Diana Prince,diana@amazon.com,350.00
ORD-9005,Evan Wright,evan@tech.com,260.00
ORD-9006,Fiona Gallagher,fiona@chicago.gov,140.00
ORD-9007,George Clark,george@clark.org,160.00
ORD-9008,Hannah Abbott,hannah@hogwarts.edu,250.00
ORD-9009,Ian Malcolm,ian@dino.com,299.00
ORD-9010,Julia Roberts,julia@cinema.com,160.00
ORD-9011,Kevin Bacon,kevin@actor.com,180.00
ORD-9012,Laura Croft,laura@tomb.org,225.00
ORD-9013,Michael Scott,michael@paper.com,95.00
ORD-9014,Nancy Drew,nancy@detective.com,110.00
ORD-9015,Oscar Martinez,oscar@accounting.com,90.00
ORD-9016,Pam Beesly,pam@art.com,210.00
ORD-9017,Quentin Tarantino,quentin@film.com,50.00
ORD-9018,Rachel Green,rachel@fashion.com,70.00
ORD-9019,Steve Rogers,steve@shield.gov,100.00

Task 9: Late-Arriving Dimension Key Routing

Simulate handling unknown/late-arriving records by querying facts assigned to key -1.

Expected output
-----------------
ORDER_ID,CUSTOMER_NAME,REVENUE
(0 rows returned - confirms all facts in the current seed resolve to active dimension keys),,



Task 10: Dependent Data Mart Extraction (Sales Mart)

Create a dedicated business data mart view for the Finance department focusing on net profit metrics

Expected output
-----------------
YEAR,MONTH_NAME,DEPARTMENT_NAME,GROSS_REVENUE,TOTAL_COST,NET_PROFIT
2026,January,Electronics,2224.98,1295.00,929.98
2026,January,Office Supplies,1564.00,1120.00,444.00
2026,January,Personal,70.00,44.00,26.00



Task 11: Enterprise Bus Matrix Verification Query

Query conformed dimensions (DIM_PRODUCT and DIM_DATE) across both FACT_SALES and FACT_MONTHLY_INVENTORY.


Expected output
-----------------
PRODUCT_NAME,TOTAL_SALES_REVENUE,LATEST_STOCK_LEVEL
4K Smart Monitor 27in,399.99,35
Ergonomic Mechanical Keyboard,240.00,80
Wireless Gaming Mouse,180.00,95
USB-C Docking Station,140.00,22
Noise-Canceling Headphones,299.99,15
Standing Desk Converter,250.00,10
Mesh Office Chair,350.00,8
LED Desk Lamp,160.00,150
HD Web Camera 1080p,160.00,60
External SSD 1TB,260.00,70
Bluetooth Soundbar,180.00,30
Paper Shredder Cross-Cut,95.00,25
Laser Printer Monochrome,299.00,12
Surge Protector Tower,225.00,110
Ergonomic Footrest,110.00,48
Wireless Charger Pad,90.00,85
Thermal Label Printer,210.00,18
Laptop Sleeve 15in,50.00,80
Blue Light Glasses,70.00,50
Cable Management Box,100.00,100


Task 12: Customer RFM Segmentation Analysis

Calculate Recency, Frequency, and Monetary scores for all active customers.


Expected output
-----------------
CUSTOMER_ID,CUSTOMER_NAME,FREQUENCY,MONETARY_VALUE
CUST-001,Alice Smith,1,639.99
CUST-002,Bob Jones,1,299.99
CUST-003,Charlie Brown,1,180.00
CUST-004,Diana Prince,1,350.00
CUST-005,Evan Wright,1,260.00
CUST-006,Fiona Gallagher,1,140.00
CUST-007,George Clark,1,160.00
CUST-008,Hannah Abbott,1,250.00
CUST-009,Ian Malcolm,1,299.00
CUST-010,Julia Roberts,1,160.00
CUST-011,Kevin Bacon,1,180.00
CUST-012,Laura Croft,1,225.00
CUST-013,Michael Scott,1,95.00
CUST-014,Nancy Drew,1,110.00
CUST-015,Oscar Martinez,1,90.00
CUST-016,Pam Beesly,1,210.00
CUST-017,Quentin Tarantino,1,50.00
CUST-018,Rachel Green,1,70.00
CUST-019,Steve Rogers,1,100.00


Task 13: Data Quality & Referential Integrity Check

Check for orphan facts in FACT_SALES that do not resolve to valid primary keys in DIM_PRODUCT.


Expected output
-----------------
SALES_SK,PRODUCT_SK
(0 rows returned - indicates zero referential integrity violations),


Task 14: SCD Type 2 MERGE Pipeline Update

Execute a Snowflake MERGE statement to update a customer's tier, expiring their old record and inserting a new current record.


Expected output
-----------------
CUSTOMER_ID,TIER,IS_CURRENT,EFFECTIVE_END_TIMESTAMP
CUST-002,Silver,FALSE,2026-09-01 12:42:19.000


Task 15: Automated Audit Tracking
-------
Query table freshness and record counts across all core data warehouse tables.

Expected output
-----------------
TABLE_NAME,ROW_COUNT
DIM_DATE,20
DIM_CUSTOMER,21
DIM_PRODUCT,20
FACT_SALES,20
FACT_MONTHLY_INVENTORY,20
FACT_PROMOTION_COVERAGE,20