-- =============================================================================
-- PROJECT 21B: GLOBAL E-COMMERCE CROSS-MART LAKEHOUSE ENGINE (DAY 13)
-- Target Engine: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. ENVIRONMENT SETUP & CONFORMED DIMENSIONS SEED
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS raw_clicks_stg (
    click_id VARCHAR(50),
    user_id VARCHAR(50),
    sku VARCHAR(50),
    action VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS raw_orders_stg (
    order_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    sku VARCHAR(50),
    price DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS raw_returns_stg (
    return_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    reason VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS DIM_CUSTOMER_CONFORMED (
    user_sk VARCHAR(50) PRIMARY KEY,
    natural_usr_id VARCHAR(50),
    conformed_status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS FACT_ORDERS_CDC (
    order_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    price DECIMAL(10, 2)
);

-- Seed Conformed Customer Key
INSERT INTO DIM_CUSTOMER_CONFORMED VALUES ('USR_SK_9001', 'USR-1', 'VERIFIED');

-- Seed Staging Raw Feed
INSERT INTO raw_clicks_stg VALUES ('CLK-90', 'USR-1', 'SKU-A', 'view');
INSERT INTO raw_orders_stg VALUES ('ORD-50', 'USR-1', 'SKU-A', 49.99);
INSERT INTO raw_returns_stg VALUES ('RET-10', 'ORD-50', 'damaged');


-- -----------------------------------------------------------------------------
-- TASK 1: Multi-Source Engine Ingestion
-- Parse and load multi-channel streaming sources into staging.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 1:
+---------------+------------------+
| SOURCE_STREAM | RECORDS_PARSED   |
+---------------+------------------+
| CLICKSTREAM   | 1                |
| ORDERS        | 1                |
| RETURNS       | 1                |
+---------------+------------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 2: Bus Matrix Enterprise Mapping
-- Verify bus matrix grain alignment and domain ownership.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 2:
+-------------+-----------------+---------------+--------------+
| PROCESS     | CONFORMED_USR   | GRAIN_LEVEL   | MART_OWNER   |
+-------------+-----------------+---------------+--------------+
| Clickstream | YES             | Event-Level   | Traffic Mart |
| Orders      | YES             | Line-Item     | Revenue Mart |
+-------------+-----------------+---------------+--------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 3: Customer Conformed Dimension SK Generation
-- Generate unified surrogate keys for conformed customer entities.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 3:
+-------------+----------------+--------------------+
| USER_SK     | NATURAL_USR_ID | CONFORMED_STATUS   |
+-------------+----------------+--------------------+
| USR_SK_9001 | USR-1          | VERIFIED           |
+-------------+----------------+--------------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 4: Cross-Mart Unified Return View
-- Construct unified views combining order metrics and return metadata.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 4:
+----------+-------------+-------+----------+---------+
| ORDER_ID | USER_SK     | PRICE | RETURNED | REASON  |
+----------+-------------+-------+----------+---------+
| ORD-50   | USR_SK_9001 | 49.99 | YES      | damaged |
+----------+-------------+-------+----------+---------+
*/


-- -----------------------------------------------------------------------------
-- TASK 5: Multi-Stream CDC MERGE Execution
-- STUDENT INSTRUCTION: Execute an atomic MERGE to upsert incoming CDC order records 
-- from raw_orders_stg into FACT_ORDERS_CDC for order_id = 'ORD-50'.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 5:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 1             | 0            |
+---------------+--------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 6: Cross-Mart Completeness Audit
-- Audit cross-mart joins to ensure zero unmatched return records.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 6:
+--------------------+-------------+
| AUDIT_CHECK        | PASS_STATUS |
+--------------------+-------------+
| UNMATCHED_RETURNS  | 0           |
+--------------------+-------------+
*/


-- -----------------------------------------------------------------------------
-- TASK 7: Multi-Engine Snapshot Audit
-- Verify order records via historical time travel query execution.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 7:
+----------+-------+
| ORDER_ID | PRICE |
+----------+-------+
| ORD-50   | 49.99 |
+----------+-------+
*/


-- -----------------------------------------------------------------------------
-- TASK 8: Non-Conformed Mart Clustering
-- Optimize physical table storage layout for high-throughput clickstream facts.
-- -----------------------------------------------------------------------------
-- TODO: WRITE YOUR QUERY HERE



/* EXPECTED OUTPUT TASK 8:
+------------------+---------------------+
| MART_TABLE       | OPTIMIZATION_RESULT |
+------------------+---------------------+
| FACT_CLICKSTREAM | SUCCESS             |
+------------------+---------------------+
*/