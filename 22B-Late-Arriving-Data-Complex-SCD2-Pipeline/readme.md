# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

---

## DAY 14: LATE-ARRIVING DATA & COMPLEX SCD TYPE 2 PIPELINE

================================================================================
PROJECT 22B: Late-Arriving Data & Complex SCD Type 2 Pipeline (Hard)
================================================================================
Target Schedule: Week 3 — Day 14 (Topics M9–M10)

Target Topics: Late-Arriving Data Handling, Inferred Member Pipeline, SCD Type 2 Merge,
                Automated Data Quality Pipelines, Micro-Partitioning & Clustering Optimization

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Late-Arriving Fact Ingestion): Ingest transactions arriving before the corresponding dimension record exists into staging.
* Task 2 Requirements (Inferred Member Generation): Generate inferred placeholder rows in `DIM_CUSTOMER_SCD2` (`is_inferred = true`, `customer_name = 'UNKNOWN_INFERRED'`).
* Task 3 Requirements (Surrogate Key Pipeline): Assign durable surrogate keys (`customer_sk`) to staging transactions using hashing or sequence generators.
* Task 4 Requirements (Inferred Member Resolution MERGE): Execute atomic MERGE updates to populate true customer attributes without creating duplicate records or breaking point-in-time facts.
* Task 5 Requirements (Historical Fact Alignment): Re-state historical facts to bind seamlessly to resolved surrogate keys across valid effective dates.
* Task 6 Requirements (Data Quality Check Pipeline): Build automated check pipelines enforcing referential integrity, null constraints, and value bounds.
* Task 7 Requirements (Retroactive Fix Time Travel Audit): Query pre-merge snapshots via Delta Time Travel (`VERSION AS OF`) or Snowflake `AT()` to audit inferred states.
* Task 8 Requirements (Key Clustering Optimization): Apply `ZORDER BY (customer_sk)` in Delta or `CLUSTER BY (customer_sk)` in Snowflake.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Late-Arriving Fact Transactions (`raw_late_facts_kv`):
-----------------------------------------------------
raw_late_facts_kv = [
    {"txn_id": "TXN-7001", "customer_id": "CUST-999", "amount": 850.00, "txn_date": "2026-08-01"},
    {"txn_id": "TXN-7002", "customer_id": "CUST-999", "amount": 1200.00, "txn_date": "2026-08-05"},
    {"txn_id": "TXN-7003", "customer_id": "CUST-888", "amount": 450.00, "txn_date": "2026-08-06"},
    {"txn_id": "TXN-7004", "customer_id": "CUST-777", "amount": 3100.00, "txn_date": "2026-08-07"},
    {"txn_id": "TXN-7005", "customer_id": "CUST-888", "amount": 920.00, "txn_date": "2026-08-10"}
]

Late-Arriving Dimension Records (`late_arriving_dim_kv`):
--------------------------------------------------------
late_arriving_dim_kv = [
    {"customer_id": "CUST-999", "customer_name": "Robert Chen", "segment": "VIP", "effective_date": "2026-07-15"},
    {"customer_id": "CUST-888", "customer_name": "Sophia Patel", "segment": "Enterprise", "effective_date": "2026-07-20"},
    {"customer_id": "CUST-777", "customer_name": "Marcus Vance", "segment": "SMB", "effective_date": "2026-07-25"}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Late-Arriving Fact Ingestion
- Ingest raw transactions arriving before corresponding dimension records exist into staging.

EXPECTED OUTPUT:
+---------------+--------------+
| STAGING_TABLE | RECORD_COUNT |
+---------------+--------------+
| STG_LATE_FACTS| 5            |
+---------------+--------------+


TASK 2: Inferred Member Generation
- Generate inferred placeholder rows in `DIM_CUSTOMER_SCD2` (`is_inferred = true`, `customer_name = 'UNKNOWN_INFERRED'`).

EXPECTED OUTPUT:
+-------------+-------------+------------------+---------+--------------------+
| CUSTOMER_SK | CUSTOMER_ID | CUSTOMER_NAME    | SEGMENT | IS_INFERRED_MEMBER |
+-------------+-------------+------------------+---------+--------------------+
| CUST_SK_101 | CUST-999    | UNKNOWN_INFERRED | UNKNOWN | TRUE               |
| CUST_SK_102 | CUST-888    | UNKNOWN_INFERRED | UNKNOWN | TRUE               |
| CUST_SK_103 | CUST-777    | UNKNOWN_INFERRED | UNKNOWN | TRUE               |
+-------------+-------------+------------------+---------+--------------------+


TASK 3: Pipeline Surrogate Key Assignment
- Assign durable surrogate keys (`customer_sk`) to incoming facts using surrogate key mapping logic.

EXPECTED OUTPUT:
+----------+-------------+---------+------------+
| TXN_ID   | CUSTOMER_SK | AMOUNT  | TXN_DATE   |
+----------+-------------+---------+------------+
| TXN-7001 | CUST_SK_101 | 850.00  | 2026-08-01 |
| TXN-7002 | CUST_SK_101 | 1200.00 | 2026-08-05 |
| TXN-7003 | CUST_SK_102 | 450.00  | 2026-08-06 |
| TXN-7004 | CUST_SK_103 | 3100.00 | 2026-08-07 |
| TXN-7005 | CUST_SK_102 | 920.00  | 2026-08-10 |
+----------+-------------+---------+------------+


TASK 4: Inferred Member Resolution MERGE
- Execute atomic MERGE updates to resolve inferred member records when true dimension attributes arrive.

EXPECTED OUTPUT:
+-------------+-------------+---------------+------------+--------------------+
| CUSTOMER_SK | CUSTOMER_ID | CUSTOMER_NAME | SEGMENT    | IS_INFERRED_MEMBER |
+-------------+-------------+---------------+------------+--------------------+
| CUST_SK_101 | CUST-999    | Robert Chen   | VIP        | FALSE              |
| CUST_SK_102 | CUST-888    | Sophia Patel  | Enterprise | FALSE              |
| CUST_SK_103 | CUST-777    | Marcus Vance  | SMB        | FALSE              |
+-------------+-------------+---------------+------------+--------------------+


TASK 5: Historical Fact Key Alignment
- Restate historical transaction facts to bind seamlessly to resolved surrogate keys.

EXPECTED OUTPUT:
+----------+-------------+---------------+------------+---------+
| TXN_ID   | CUSTOMER_SK | CUSTOMER_NAME | SEGMENT    | AMOUNT  |
+----------+-------------+---------------+------------+---------+
| TXN-7001 | CUST_SK_101 | Robert Chen   | VIP        | 850.00  |
| TXN-7002 | CUST_SK_101 | Robert Chen   | VIP        | 1200.00 |
| TXN-7003 | CUST_SK_102 | Sophia Patel  | Enterprise | 450.00  |
| TXN-7004 | CUST_SK_103 | Marcus Vance  | SMB        | 3100.00 |
| TXN-7005 | CUST_SK_102 | Sophia Patel  | Enterprise | 920.00  |
+----------+-------------+---------------+------------+---------+


TASK 6: Comprehensive Data Quality Pipeline Verification
- Verify data quality rules (referential integrity, non-null surrogate keys, and valid ranges).

EXPECTED OUTPUT:
+-------------------+-------------+--------+
| RULE_NAME         | CHECK_TYPE  | STATUS |
+-------------------+-------------+--------+
| NULL_CUSTOMER_SK  | REFERENTIAL | PASSED |
| VALID_AMOUNT      | RANGE       | PASSED |
| UNRESOLVED_INFER  | INTEGRITY   | PASSED |
+-------------------+-------------+--------+


TASK 7: Retroactive Fix Time Travel Audit
- Perform Time Travel query across historical versions to verify the transition from inferred state to resolved state.

EXPECTED OUTPUT:
+-------------+------------------+-----------------------+
| CUSTOMER_ID | PREV_STATE       | CURRENT_STATE         |
+-------------+------------------+-----------------------+
| CUST-999    | UNKNOWN_INFERRED | Robert Chen (VIP)     |
| CUST-888    | UNKNOWN_INFERRED | Sophia Patel (Ent)    |
| CUST-777    | UNKNOWN_INFERRED | Marcus Vance (SMB)    |
+-------------+------------------+-----------------------+


TASK 8: Key Clustering Optimization
- Execute layout optimization on surrogate keys via engine maintenance features.

EXPECTED OUTPUT:
+-------------------+-------------------+
| TARGET_TABLE      | CLUSTERING_STATUS |
+-------------------+-------------------+
| DIM_CUSTOMER_SCD2 | OPTIMIZED         |
+-------------------+-------------------+