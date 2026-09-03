-- =============================================================================
-- PROJECT 21A: ENTERPRISE RETAIL DATA MART ARCHITECTURE (DAY 13)
-- Target Engine: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. ENVIRONMENT SETUP & CONFORMED DIMENSIONS SEED
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw_sales_stg (
    sale_id VARCHAR(50),
    store_id VARCHAR(50),
    product_id VARCHAR(50),
    amount DECIMAL(10, 2),
    date_key INT
);

CREATE TABLE IF NOT EXISTS raw_inventory_stg (
    snapshot_id VARCHAR(50),
    store_id VARCHAR(50),
    product_id VARCHAR(50),
    on_hand_qty INT,
    date_key INT
);

CREATE TABLE IF NOT EXISTS DIM_STORE (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS DIM_PRODUCT (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

-- Seed Conformed Dimensions
INSERT INTO DIM_STORE VALUES ('STR-10', 'Downtown Store', 'East');
INSERT INTO DIM_PRODUCT VALUES ('PRD-5', 'Wireless Mouse', 'Electronics');

-- Seed Staging Raw Feed
INSERT INTO raw_sales_stg VALUES ('SL-301', 'STR-10', 'PRD-5', 120.00, 20260801);
INSERT INTO raw_inventory_stg VALUES ('INV-801', 'STR-10', 'PRD-5', 45, 20260801);


-- -----------------------------------------------------------------------------
-- TASK 1: Multi-Domain Data Ingestion
-- Ingest POS sales and inventory snapshot datasets into raw staging layers.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 1:
+---------------+-------------+
| DATASET       | LOADED_ROWS |
+---------------+-------------+
| POS_SALES     | 1           |
| INVENTORY     | 1           |
+---------------+-------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 2: Bus Matrix Mapping Verification
-- Verify conformed dimension mappings across business processes.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 2:
+--------------------+-------------------+---------------------+
| BUSINESS_PROCESS   | CONFORMED_STORE   | CONFORMED_PRODUCT   |
+--------------------+-------------------+---------------------+
| Sales Analysis     | YES               | YES                 |
| Inventory Snapshot | YES               | YES                 |
+--------------------+-------------------+---------------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 3: Sales Data Mart View Generation
-- Generate the downstream Sales Data Mart view (VIEW_SALES_MART).
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 3:
+----------+----------+------------+--------+
| SALE_ID  | STORE_ID | PRODUCT_ID | AMOUNT |
+----------+----------+------------+--------+
| SL-301   | STR-10   | PRD-5      | 120.00 |
+----------+----------+------------+--------+
*/


-- -----------------------------------------------------------------------------
-- TASK 4: Inventory Data Mart View Generation
-- Generate the downstream Inventory Data Mart view (VIEW_INVENTORY_MART).
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 4:
+-------------+----------+------------+-------------+
| SNAPSHOT_ID | STORE_ID | PRODUCT_ID | ON_HAND_QTY |
+-------------+----------+------------+-------------+
| INV-801     | STR-10   | PRD-5      | 45          |
+-------------+----------+------------+-------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 5: Conformed Dimension Atomic Upsert
-- STUDENT INSTRUCTION: Write an atomic MERGE statement on DIM_STORE for store_id = 'STR-10' 
-- to update its store_name to 'Downtown Store Flagship' and region to 'East'.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 5:
+---------------+----------------+
| ROWS_INSERTED | ROWS_UPDATED   |
+---------------+----------------+
| 0             | 1              |
+---------------+----------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 6: Referential Integrity Verification
-- Check foreign key validity across facts and conformed dimensions.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 6:
+---------------------+------------------+
| INTEGRITY_CHECK     | FAILED_RECORDS   |
+---------------------+------------------+
| FACT_DIM_FK_MATCH   | 0                |
+---------------------+------------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 7: Time Travel Data Mart Audit
-- Audit historical sales records using point-in-time time travel queries.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 7:
+----------+--------+
| SALE_ID  | AMOUNT |
+----------+--------+
| SL-301   | 120.00 |
+----------+--------+
*/


-- -----------------------------------------------------------------------------
-- TASK 8: Conformed Dimension Storage Optimization
-- Execute cluster maintenance on store and product keys.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 8:
+--------------------+--------------+
| CLUSTERING_TARGET  | STATUS       |
+--------------------+--------------+
| STORE_PRODUCT_KEYS | COMPLETED    |
+--------------------+--------------+
*/