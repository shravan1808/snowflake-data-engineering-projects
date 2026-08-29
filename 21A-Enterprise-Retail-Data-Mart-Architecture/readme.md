# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

## DAY 13: BUS MATRIX & DATA MARTS (PROJECT_ 21A)

================================================================================
PROJECT 21A: Enterprise Retail Data Mart Architecture (Medium)
================================================================================
Target Schedule: Week 3 — Day 13 (Topics M6–M8)

Target Topics: Enterprise Bus Matrix Mapping, Conformed Dimensions, Multi-Domain Data Mart Views, Atomic Upserts

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Multi-Domain Data Ingestion): Ingest POS sales and inventory snapshot datasets into raw staging layers.
* Task 2 Requirements (Bus Matrix Mapping Verification): Map business processes against conformed dimensions (`DIM_STORE`, `DIM_PRODUCT`).
* Task 3 Requirements (Sales Data Mart View Generation): Build dependent Sales Data Mart views using conformed keys.
* Task 4 Requirements (Inventory Data Mart View Generation): Construct Inventory Data Mart views reflecting stock snapshot levels.
* Task 5 Requirements (Conformed Dimension Atomic Upsert): Execute `MERGE INTO` updates on conformed dimensions.
* Task 6 Requirements (Referential Integrity Verification): Validate zero orphan foreign keys between fact tables and conformed dimensions.
* Task 7 Requirements (Time Travel Data Mart Audit): Query historical mart states using Delta time travel or Snowflake `AT()`.
* Task 8 Requirements (Conformed Dimension Storage Optimization): Cluster conformed dimension tables on primary key attributes.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Raw Sales Feed (`raw_sales_kv`):
--------------------------------
raw_sales_kv = [
    {"sale_id": "SL-301", "store_id": "STR-10", "product_id": "PRD-5", "amount": 120.00, "date_key": 20260801}
]

Raw Inventory Feed (`raw_inventory_kv`):
----------------------------------------
raw_inventory_kv = [
    {"snapshot_id": "INV-801", "store_id": "STR-10", "product_id": "PRD-5", "on_hand_qty": 45, "date_key": 20260801}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Multi-Domain Data Ingestion
- Ingest raw sales and inventory records into staging tables.

EXPECTED OUTPUT:
+---------------+-------------+
| DATASET       | LOADED_ROWS |
+---------------+-------------+
| POS_SALES     | 1           |
| INVENTORY     | 1           |
+---------------+-------------+


TASK 2: Bus Matrix Mapping Verification
- Verify conformed dimension mappings across business processes.

EXPECTED OUTPUT:
+--------------------+-------------------+---------------------+
| BUSINESS_PROCESS   | CONFORMED_STORE   | CONFORMED_PRODUCT   |
+--------------------+-------------------+---------------------+
| Sales Analysis     | YES               | YES                 |
| Inventory Snapshot | YES               | YES                 |
+--------------------+-------------------+---------------------+


TASK 3: Sales Data Mart View Generation
- Generate the downstream Sales Data Mart view.

EXPECTED OUTPUT:
+----------+----------+------------+--------+
| SALE_ID  | STORE_ID | PRODUCT_ID | AMOUNT |
+----------+----------+------------+--------+
| SL-301   | STR-10   | PRD-5      | 120.00 |
+----------+----------+------------+--------+


TASK 4: Inventory Data Mart View Generation
- Generate the downstream Inventory Data Mart view.

EXPECTED OUTPUT:
+-------------+----------+------------+-------------+
| SNAPSHOT_ID | STORE_ID | PRODUCT_ID | ON_HAND_QTY |
+-------------+----------+------------+-------------+
| INV-801     | STR-10   | PRD-5      | 45          |
+-------------+----------+------------+-------------+


TASK 5: Conformed Dimension Atomic Upsert
- Update conformed dimensions atomically via `MERGE`.

EXPECTED OUTPUT:
+---------------+----------------+
| ROWS_INSERTED | ROWS_UPDATED   |
+---------------+----------------+
| 0             | 1              |
+---------------+----------------+


TASK 6: Referential Integrity Verification
- Check foreign key validity across facts and dimensions.

EXPECTED OUTPUT:
+---------------------+------------------+
| INTEGRITY_CHECK     | FAILED_RECORDS   |
+---------------------+------------------+
| FACT_DIM_FK_MATCH   | 0                |
+---------------------+------------------+


TASK 7: Time Travel Data Mart Audit
- Audit historical sales records using point-in-time time travel queries.

EXPECTED OUTPUT:
+----------+--------+
| SALE_ID  | AMOUNT |
+----------+--------+
| SL-301   | 120.00 |
+----------+--------+


TASK 8: Conformed Dimension Storage Optimization
- Execute cluster maintenance on store and product keys.

EXPECTED OUTPUT:
+--------------------+--------------+
| CLUSTERING_TARGET  | STATUS       |
+--------------------+--------------+
| STORE_PRODUCT_KEYS | COMPLETED    |
+--------------------+--------------+


