
================================================================================
PROJECT 21B: Global E-Commerce Cross-Mart Lakehouse Engine (Hard)
================================================================================
Target Schedule: Week 3 — Day 13 (Topics M9–M10)

Target Topics: Multi-Source Stream Ingestion, Enterprise Bus Matrix Grain Balancing, 
                Shared Conformed Surrogate Keys, Multi-Table CDC Stream Processing

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Multi-Source Engine Ingestion): Ingest raw clickstream logs, order receipts, and return records.
* Task 2 Requirements (Bus Matrix Enterprise Mapping): Balance grain decisions across event-level clickstreams and line-item revenue marts.
* Task 3 Requirements (Customer Conformed Dimension SK Generation): Construct shared customer surrogate keys (`user_sk`) for cross-mart consistency.
* Task 4 Requirements (Cross-Mart Unified Return View): Build unified analytical views linking order receipts with return reasons.
* Task 5 Requirements (Multi-Stream CDC MERGE Execution): Execute synchronized multi-table CDC updates using SQL `MERGE`.
* Task 6 Requirements (Cross-Mart Completeness Audit): Audit cross-mart referential integrity to detect unmatched return transactions.
* Task 7 Requirements (Multi-Engine Snapshot Audit): Query point-in-time point states across historical versions.
* Task 8 Requirements (Non-Conformed Mart Clustering): Apply partition optimization and clustering across high-volume traffic facts.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Raw Clickstream Logs (`raw_clicks_kv`):
---------------------------------------
raw_clicks_kv = [{"click_id": "CLK-90", "user_id": "USR-1", "sku": "SKU-A", "action": "view"}]

Raw Orders Feed (`raw_orders_kv`):
----------------------------------
raw_orders_kv = [{"order_id": "ORD-50", "user_id": "USR-1", "sku": "SKU-A", "price": 49.99}]

Raw Returns Feed (`raw_returns_kv`):
-----------------------------------
raw_returns_kv = [{"return_id": "RET-10", "order_id": "ORD-50", "reason": "damaged"}]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Multi-Source Engine Ingestion
- Parse and load multi-channel streaming sources into staging.

EXPECTED OUTPUT:
+---------------+------------------+
| SOURCE_STREAM | RECORDS_PARSED   |
+---------------+------------------+
| CLICKSTREAM   | 1                |
| ORDERS        | 1                |
| RETURNS       | 1                |
+---------------+------------------+


TASK 2: Bus Matrix Enterprise Mapping
- Verify bus matrix grain alignment and domain ownership.

EXPECTED OUTPUT:
+-------------+-----------------+---------------+--------------+
| PROCESS     | CONFORMED_USR   | GRAIN_LEVEL   | MART_OWNER   |
+-------------+-----------------+---------------+--------------+
| Clickstream | YES             | Event-Level   | Traffic Mart |
| Orders      | YES             | Line-Item     | Revenue Mart |
+-------------+-----------------+---------------+--------------+


TASK 3: Customer Conformed Dimension SK Generation
- Generate unified surrogate keys for conformed customer entities.

EXPECTED OUTPUT:
+-------------+----------------+--------------------+
| USER_SK     | NATURAL_USR_ID | CONFORMED_STATUS   |
+-------------+----------------+--------------------+
| USR_SK_9001 | USR-1          | VERIFIED           |
+-------------+----------------+--------------------+


TASK 4: Cross-Mart Unified Return View
- Construct unified views combining order metrics and return metadata.

EXPECTED OUTPUT:
+----------+-------------+-------+----------+---------+
| ORDER_ID | USER_SK     | PRICE | RETURNED | REASON  |
+----------+-------------+-------+----------+---------+
| ORD-50   | USR_SK_9001 | 49.99 | YES      | damaged |
+----------+-------------+-------+----------+---------+


TASK 5: Multi-Stream CDC MERGE Execution
- Execute atomic CDC updates across interdependent streaming tables.

EXPECTED OUTPUT:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 1             | 1            |
+---------------+--------------+


TASK 6: Cross-Mart Completeness Audit
- Audit cross-mart joins to ensure zero unmatched return records.

EXPECTED OUTPUT:
+--------------------+-------------+
| AUDIT_CHECK        | PASS_STATUS |
+--------------------+-------------+
| UNMATCHED_RETURNS  | 0           |
+--------------------+-------------+


TASK 7: Multi-Engine Snapshot Audit
- Verify order records via historical time travel query execution.

EXPECTED OUTPUT:
+----------+-------+
| ORDER_ID | PRICE |
+----------+-------+
| ORD-50   | 49.99 |
+----------+-------+


TASK 8: Non-Conformed Mart Clustering
- Optimize physical table storage layout for high-throughput clickstream facts.

EXPECTED OUTPUT:
+------------------+---------------------+
| MART_TABLE       | OPTIMIZATION_RESULT |
+------------------+---------------------+
| FACT_CLICKSTREAM | SUCCESS             |
+------------------+---------------------+