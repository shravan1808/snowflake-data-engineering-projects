# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

---

## DAY 15: END-TO-END ENTERPRISE ARCHITECTURE

================================================================================
PROJECT 23A: Enterprise Sales Analytics & Multi-Tier Cohort Warehouse (Hard)
================================================================================
Target Schedule: Week 3 — Day 15 (Topics M9–M10)

Target Topics: Star Schema Physical Modeling, Customer LTV & Retention Aggregation, 
                Cohort Revenue Trend Analysis, Multi-Stage MERGE Execution, Grain Alignment Audit,
                Late-Arriving Fact Adjustments, Multi-Column Clustering Optimization

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Staging Raw Sales Ingestion): Parse and load multi-region transactional sales streams into raw staging layers (`STG_SALES_EVENTS`).
* Task 2 Requirements (Star Schema Physical Modeling): Build `FACT_SALES` linked to `DIM_CUSTOMER`, `DIM_STORE`, and `DIM_PRODUCT` via surrogate keys.
* Task 3 Requirements (Customer LTV & Retention Aggregation): Compute cumulative order counts, overall spend, and initial cohort assignment per customer.
* Task 4 Requirements (Cohort Revenue Trend Analysis): Build monthly acquisition cohorts and evaluate revenue progression across subsequent months (M0, M1, M2+).
* Task 5 Requirements (Sales Warehouse MERGE Execution): Process late sales adjustments, returns, and incremental order revisions atomically via `MERGE INTO`.
* Task 6 Requirements (Header-vs-Line-Item Grain Alignment Audit): Execute data validation queries enforcing header-level and line-item total parity.
* Task 7 Requirements (Warehouse Time Travel Audit): Query historical order states prior to adjustments using Delta `VERSION AS OF` or Snowflake `AT()`.
* Task 8 Requirements (Star Schema Storage Layout Optimization): Optimize multi-table joins using `ZORDER BY (customer_sk, order_date)` or `CLUSTER BY (customer_sk, order_date)`.
* Task 9 Requirements (Orphan Foreign Key Integrity Pipeline): Identify and log foreign keys in `FACT_SALES` that do not exist in dimension tables.
* Task 10 Requirements (Cumulative Monthly Spend Windowing): Compute running total spend using window functions partition-by customer.
* Task 11 Requirements (Multi-Store Sales Performance Aggregation): Roll up store performance metrics across regional and store type hierarchies.
* Task 12 Requirements (High-Value Order Threshold Analysis): Classify sales transactions into dynamic revenue bands (Low, Medium, High, VIP).
* Task 13 Requirements (Historical Order Revision Tracking): Track order status transitions (Placed, Shipped, Delivered, Returned, Adjusted).
* Task 14 Requirements (Cross-Dimensional Aggregation Rollup): Construct cube views combining Customer, Store, and Date hierarchies.
* Task 15 Requirements (Full Pipeline Execution & Warehouse Audit): Execute end-to-end pipeline verification and validate final record counts across the star schema.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Raw Warehouse Sales Feed (`raw_sales_warehouse_kv` - 50 Records):
-----------------------------------------------------------------
raw_sales_warehouse_kv = [
    {"order_id": "ORD-1001", "customer_id": "CUST-01", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-01-10", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1002", "customer_id": "CUST-02", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-01-12", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1003", "customer_id": "CUST-03", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-01-15", "quantity": 5, "revenue": 250.00},
    {"order_id": "ORD-1004", "customer_id": "CUST-01", "store_id": "STR-10", "product_id": "PRD-C", "order_date": "2026-02-01", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1005", "customer_id": "CUST-04", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-02-05", "quantity": 2, "revenue": 500.00},
    {"order_id": "ORD-1006", "customer_id": "CUST-02", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-02-10", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1007", "customer_id": "CUST-05", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-02-14", "quantity": 3, "revenue": 150.00},
    {"order_id": "ORD-1008", "customer_id": "CUST-03", "store_id": "STR-12", "product_id": "PRD-C", "order_date": "2026-02-20", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1009", "customer_id": "CUST-06", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-03-01", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1010", "customer_id": "CUST-01", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-03-05", "quantity": 4, "revenue": 200.00},
    {"order_id": "ORD-1011", "customer_id": "CUST-07", "store_id": "STR-12", "product_id": "PRD-C", "order_date": "2026-03-10", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1012", "customer_id": "CUST-04", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-03-12", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1013", "customer_id": "CUST-02", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-03-15", "quantity": 3, "revenue": 750.00},
    {"order_id": "ORD-1014", "customer_id": "CUST-08", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-03-18", "quantity": 1, "revenue": 50.00},
    {"order_id": "ORD-1015", "customer_id": "CUST-05", "store_id": "STR-10", "product_id": "PRD-C", "order_date": "2026-03-22", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1016", "customer_id": "CUST-09", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-04-01", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1017", "customer_id": "CUST-03", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-04-05", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1018", "customer_id": "CUST-10", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-04-08", "quantity": 3, "revenue": 900.00},
    {"order_id": "ORD-1019", "customer_id": "CUST-06", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-04-12", "quantity": 1, "revenue": 50.00},
    {"order_id": "ORD-1020", "customer_id": "CUST-07", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-04-15", "quantity": 2, "revenue": 500.00},
    {"order_id": "ORD-1021", "customer_id": "CUST-01", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-04-18", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1022", "customer_id": "CUST-08", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-04-22", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1023", "customer_id": "CUST-04", "store_id": "STR-12", "product_id": "PRD-C", "order_date": "2026-04-25", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1024", "customer_id": "CUST-05", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-04-28", "quantity": 3, "revenue": 150.00},
    {"order_id": "ORD-1025", "customer_id": "CUST-02", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-05-01", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1026", "customer_id": "CUST-09", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-05-04", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1027", "customer_id": "CUST-10", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-05-08", "quantity": 2, "revenue": 500.00},
    {"order_id": "ORD-1028", "customer_id": "CUST-03", "store_id": "STR-10", "product_id": "PRD-C", "order_date": "2026-05-12", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1029", "customer_id": "CUST-06", "store_id": "STR-12", "product_id": "PRD-A", "order_date": "2026-05-15", "quantity": 5, "revenue": 250.00},
    {"order_id": "ORD-1030", "customer_id": "CUST-07", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-05-18", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1031", "customer_id": "CUST-08", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-05-22", "quantity": 1, "revenue": 50.00},
    {"order_id": "ORD-1032", "customer_id": "CUST-01", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-05-25", "quantity": 3, "revenue": 750.00},
    {"order_id": "ORD-1033", "customer_id": "CUST-04", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-05-28", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1034", "customer_id": "CUST-05", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-06-01", "quantity": 2, "revenue": 500.00},
    {"order_id": "ORD-1035", "customer_id": "CUST-09", "store_id": "STR-12", "product_id": "PRD-C", "order_date": "2026-06-05", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1036", "customer_id": "CUST-10", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-06-08", "quantity": 3, "revenue": 150.00},
    {"order_id": "ORD-1037", "customer_id": "CUST-02", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-06-12", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1038", "customer_id": "CUST-06", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-06-15", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1039", "customer_id": "CUST-07", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-06-18", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1040", "customer_id": "CUST-03", "store_id": "STR-11", "product_id": "PRD-B", "order_date": "2026-06-22", "quantity": 2, "revenue": 500.00},
    {"order_id": "ORD-1041", "customer_id": "CUST-08", "store_id": "STR-12", "product_id": "PRD-C", "order_date": "2026-06-25", "quantity": 3, "revenue": 900.00},
    {"order_id": "ORD-1042", "customer_id": "CUST-04", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-07-01", "quantity": 1, "revenue": 50.00},
    {"order_id": "ORD-1043", "customer_id": "CUST-05", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-07-05", "quantity": 1, "revenue": 250.00},
    {"order_id": "ORD-1044", "customer_id": "CUST-01", "store_id": "STR-11", "product_id": "PRD-A", "order_date": "2026-07-10", "quantity": 2, "revenue": 100.00},
    {"order_id": "ORD-1045", "customer_id": "CUST-09", "store_id": "STR-10", "product_id": "PRD-C", "order_date": "2026-07-15", "quantity": 1, "revenue": 300.00},
    {"order_id": "ORD-1046", "customer_id": "CUST-10", "store_id": "STR-12", "product_id": "PRD-B", "order_date": "2026-07-20", "quantity": 3, "revenue": 750.00},
    {"order_id": "ORD-1047", "customer_id": "CUST-02", "store_id": "STR-10", "product_id": "PRD-A", "order_date": "2026-07-22", "quantity": 1, "revenue": 50.00},
    {"order_id": "ORD-1048", "customer_id": "CUST-06", "store_id": "STR-11", "product_id": "PRD-C", "order_date": "2026-07-25", "quantity": 2, "revenue": 600.00},
    {"order_id": "ORD-1049", "customer_id": "CUST-07", "store_id": "STR-12", "product_id": "PRD-A", "order_date": "2026-07-28", "quantity": 4, "revenue": 200.00},
    {"order_id": "ORD-1050", "customer_id": "CUST-03", "store_id": "STR-10", "product_id": "PRD-B", "order_date": "2026-07-31", "quantity": 1, "revenue": 250.00}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Staging Raw Sales Ingestion
- Ingest raw sales transactions into staging tables.

EXPECTED OUTPUT:
+---------------+--------------+
| STAGING_TABLE | LOADED_ROWS  |
+---------------+--------------+
| STG_SALES_EVT | 50           |
+---------------+--------------+


TASK 2: Star Schema Physical Model Verification
- Verify table creation for `FACT_SALES`, `DIM_CUSTOMER`, `DIM_STORE`, and `DIM_PRODUCT`.

EXPECTED OUTPUT:
+-------------+------------+-------------+
| TABLE_NAME  | TABLE_TYPE | PRIMARY_KEY |
+-------------+------------+-------------+
| FACT_SALES  | FACT       | ORDER_ID    |
| DIM_CUST    | DIMENSION  | CUST_SK     |
| DIM_STORE   | DIMENSION  | STORE_SK    |
| DIM_PRODUCT | DIMENSION  | PROD_SK     |
+-------------+------------+-------------+


TASK 3: Customer LTV & Retention Aggregation
- Aggregate customer order metrics across total spend and total order counts.

EXPECTED OUTPUT:
+-------------+--------------+--------------+---------------+
| CUSTOMER_ID | TOTAL_ORDERS | TOTAL_SPEND  | COHORT_MONTH  |
+-------------+--------------+--------------+---------------+
| CUST-01     | 6            | 1150.00      | 2026-01       |
| CUST-02     | 6            | 1900.00      | 2026-01       |
| CUST-03     | 7            | 2150.00      | 2026-01       |
+-------------+--------------+--------------+---------------+


TASK 4: Cohort Revenue Trend Analysis
- Evaluate revenue progression across initial acquisition cohort months.

EXPECTED OUTPUT:
+--------------+------------+------------+------------+
| COHORT_MONTH | REVENUE_M0 | REVENUE_M1 | REVENUE_M2 |
+--------------+------------+------------+------------+
| 2026-01      | 600.00     | 1400.00    | 1000.00    |
+--------------+------------+------------+------------+


TASK 5: Sales Warehouse MERGE Execution
- Execute atomic `MERGE` statement for late adjustments on sales records.

EXPECTED OUTPUT:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 0             | 5            |
+---------------+--------------+


TASK 6: Header-vs-Line-Item Grain Alignment Audit
- Enforce check ensuring no line-item total mismatch exists against sales headers.

EXPECTED OUTPUT:
+-------------------+--------------------+--------+
| CHECK_NAME        | MISMATCHES_DETECTED| STATUS |
+-------------------+--------------------+--------+
| GRAIN_PARITY_CHK  | 0                  | PASSED |
+-------------------+--------------------+--------+


TASK 7: Warehouse Time Travel Audit
- Query sales records prior to late adjustments using Time Travel.

EXPECTED OUTPUT:
+----------+-------------+------------------+
| ORDER_ID | CUSTOMER_ID | PRE_MERGE_AMOUNT |
+----------+-------------+------------------+
| ORD-1001 | CUST-01     | 100.00           |
+----------+-------------+------------------+


TASK 8: Star Schema Storage Layout Optimization
- Perform clustering layout optimization on surrogate join keys.

EXPECTED OUTPUT:
+---------------+---------------------+
| TARGET_TABLE  | CLUSTERING_STATUS   |
+---------------+---------------------+
| FACT_SALES    | OPTIMIZED           |
+---------------+---------------------+


TASK 9: Orphan Foreign Key Integrity Pipeline
- Execute check for orphan foreign keys in `FACT_SALES`.

EXPECTED OUTPUT:
+--------------------+---------------+--------+
| REFERENTIAL_CHECK  | ORPHAN_COUNT  | STATUS |
+--------------------+---------------+--------+
| FK_CUST_SK_CHECK   | 0             | PASSED |
+--------------------+---------------+--------+


TASK 10: Cumulative Monthly Spend Windowing
- Calculate running cumulative spend per customer across order dates.

EXPECTED OUTPUT:
+-------------+------------+---------+-------------------+
| CUSTOMER_ID | ORDER_DATE | REVENUE | CUMULATIVE_SPEND  |
+-------------+------------+---------+-------------------+
| CUST-01     | 2026-01-10 | 100.00  | 100.00            |
| CUST-01     | 2026-02-01 | 300.00  | 400.00            |
+-------------+------------+---------+-------------------+


TASK 11: Multi-Store Sales Performance Aggregation
- Aggregate sales volume and total revenue by store location.

EXPECTED OUTPUT:
+----------+---------------+---------------+
| STORE_ID | TOTAL_ORDERS  | TOTAL_REVENUE |
+----------+---------------+---------------+
| STR-10   | 18            | 4200.00       |
| STR-11   | 14            | 4450.00       |
| STR-12   | 18            | 8350.00       |
+----------+---------------+---------------+


TASK 12: High-Value Order Threshold Analysis
- Categorize orders into revenue tiers (Low: <200, Medium: 200-500, High: >500).

EXPECTED OUTPUT:
+---------------+-------------+
| REVENUE_TIER  | ORDER_COUNT |
+---------------+-------------+
| Low           | 19          |
| Medium        | 21          |
| High          | 10          |
+---------------+-------------+


TASK 13: Historical Order Revision Tracking
- Log order state revisions across historical pipeline executions.

EXPECTED OUTPUT:
+---------------+---------------------+
| REVISION_TYPE | RECORDS_TRANSITIONED|
+---------------+---------------------+
| STATUS_UPDATE | 5                   |
+---------------+---------------------+


TASK 14: Cross-Dimensional Aggregation Rollup
- Generate aggregate summaries across store and product dimensions using rollup/cube.

EXPECTED OUTPUT:
+----------+------------+---------------+
| STORE_ID | PRODUCT_ID | TOTAL_REVENUE |
+----------+------------+---------------+
| STR-10   | PRD-A      | 1050.00       |
| STR-10   | ALL        | 4200.00       |
+----------+------------+---------------+


TASK 15: Full Pipeline Execution & Warehouse Audit
- Final verification of full warehouse model population.

EXPECTED OUTPUT:
+-------------------+---------------+---------------+
| PHYSICAL_TABLE    | TOTAL_RECORDS | STATUS        |
+-------------------+---------------+---------------+
| FACT_SALES        | 50            | VERIFIED      |
| DIM_CUSTOMER      | 10            | VERIFIED      |
| DIM_STORE         | 3             | VERIFIED      |
| DIM_PRODUCT       | 3             | VERIFIED      |
+-------------------+---------------+---------------+