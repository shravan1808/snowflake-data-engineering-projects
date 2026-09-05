# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

---

## DAY 14: AUTOMATED SCD TYPE 2 PIPELINE ENGINE

================================================================================
PROJECT 22A: Automated SCD Type 2 Pipeline Engine (Medium)
================================================================================
Target Schedule: Week 3 — Day 14 (Topics M6–M8)

Target Topics: Slowly Changing Dimensions (SCD Type 2), Hash Key Generation, 
                Effective Date Windowing, MERGE INTO State Updates

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Staging Delta Ingestion): Ingest incoming customer profile updates into staging layers.
* Task 2 Requirements (Hash Key & Record Hash Generation): Compute deterministic row hash keys (`SHA256`) across tracked attributes to detect changes.
* Task 3 Requirements (SCD2 Tracked Field Change Identification): Compare incoming hash values against active dimension records (`is_current = true`) to identify updates versus new insertions.
* Task 4 Requirements (Atomic MERGE SCD2 Execution): Execute atomic `MERGE` statements to expire modified active records (`is_current = false`, `end_date`) and insert new active versions (`is_current = true`, `start_date`).
* Task 5 Requirements (SCD Type 1 Attribute Update Execution): Apply SCD Type 1 inline updates for non-tracked, non-historical attributes without creating new versions.
* Task 6 Requirements (Temporal Overlap Integrity Check): Enforce data quality checks validating that no customer surrogate key path contains overlapping date ranges.
* Task 7 Requirements (Point-in-Time Dimension Audit): Execute Time Travel queries (`VERSION AS OF` / `AT()`) to inspect dimension records prior to the SCD2 MERGE operation.
* Task 8 Requirements (Dimension Surrogate Key Clustering): Apply performance optimizations (`ZORDER BY (customer_sk)` or `CLUSTER BY (customer_sk)`).

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Incoming Customer Updates (`raw_customer_updates_kv`):
------------------------------------------------------
raw_customer_updates_kv = [
    {"customer_id": "CUST-101", "name": "Alice Smith", "address": "123 Main St, Austin, TX", "tier": "Gold", "phone": "512-555-0199", "effective_date": "2026-08-15"},
    {"customer_id": "CUST-102", "name": "Bob Jones", "address": "456 Oak Rd, Seattle, WA", "tier": "Silver", "phone": "206-555-0144", "effective_date": "2026-08-15"},
    {"customer_id": "CUST-103", "name": "Carol Danvers", "address": "789 Pine Ave, Chicago, IL", "tier": "Platinum", "phone": "312-555-0177", "effective_date": "2026-08-15"},
    {"customer_id": "CUST-104", "name": "David Miller", "address": "101 Maple Dr, Miami, FL", "tier": "Bronze", "phone": "305-555-0122", "effective_date": "2026-08-15"},
    {"customer_id": "CUST-105", "name": "Eva Green", "address": "202 Birch Ln, Denver, CO", "tier": "Gold", "phone": "303-555-0188", "effective_date": "2026-08-15"}
]

Existing Active Dimension Table (`dim_customer_scd2_active_kv`):
---------------------------------------------------------------
dim_customer_scd2_active_kv = [
    {"customer_sk": "SK-1001", "customer_id": "CUST-101", "name": "Alice Smith", "address": "789 Pine St, Dallas, TX", "tier": "Bronze", "phone": "512-555-0100", "start_date": "2026-01-01", "end_date": "9999-12-31", "is_current": True},
    {"customer_sk": "SK-1002", "customer_id": "CUST-102", "name": "Bob Jones", "address": "456 Oak Rd, Seattle, WA", "tier": "Silver", "phone": "206-555-0144", "start_date": "2026-02-10", "end_date": "9999-12-31", "is_current": True},
    {"customer_sk": "SK-1004", "customer_id": "CUST-104", "name": "David Miller", "address": "101 Maple Dr, Miami, FL", "tier": "Bronze", "phone": "305-555-0111", "start_date": "2026-03-15", "end_date": "9999-12-31", "is_current": True}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Staging Delta Ingestion
- Ingest customer update records into the staging layer.

EXPECTED OUTPUT:
+---------------+--------------+
| STAGING_TABLE | LOADED_ROWS  |
+---------------+--------------+
| STG_CUST_UPD  | 5            |
+---------------+--------------+


TASK 2: Hash Key & Record Hash Generation
- Compute SHA256 record hashes across tracked historical attributes.

EXPECTED OUTPUT:
+-------------+------------------------------------------------------------------+
| CUSTOMER_ID | RECORD_HASH                                                      |
+-------------+------------------------------------------------------------------+
| CUST-101    | 8f4e2a3b1c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f |
| CUST-102    | 3a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b |
| CUST-103    | 5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d |
| CUST-104    | 9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f |
| CUST-105    | 1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a |
+-------------+------------------------------------------------------------------+


TASK 3: SCD2 Tracked Field Change Identification
- Identify record state changes to categorize actions (SCD2 insert/expire, SCD1 update, or brand new customer insert).

EXPECTED OUTPUT:
+-------------+-------------------+--------------------+------------------------+
| CUSTOMER_ID | CHANGE_DETECTED   | SCD1_ONLY_UPDATE   | ACTION_REQUIRED        |
+-------------+-------------------+--------------------+------------------------+
| CUST-101    | YES               | NO                 | EXPIRE_AND_INSERT_SCD2 |
| CUST-102    | NO                | NO                 | NO_ACTION              |
| CUST-103    | NO (NEW)          | NO                 | INSERT_NEW_CUSTOMER    |
| CUST-104    | YES               | YES (PHONE ONLY)   | UPDATE_SCD1_INLINE     |
| CUST-105    | NO (NEW)          | NO                 | INSERT_NEW_CUSTOMER    |
+-------------+-------------------+--------------------+------------------------+


TASK 4: Atomic MERGE SCD2 Execution
- Execute atomic `MERGE` to update active flags, close effective dates, and insert new version rows.

EXPECTED OUTPUT:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 3             | 1            |
+---------------+--------------+


TASK 5: SCD Type 1 Attribute Update Execution
- Perform inline SCD1 updates for non-historical attribute fields (e.g., phone numbers).

EXPECTED OUTPUT:
+---------------+---------------------+
| UPDATE_TYPE   | RECORDS_MODIFIED    |
+---------------+---------------------+
| SCD1_INLINE   | 1                   |
+---------------+---------------------+


TASK 6: Temporal Overlap Integrity Check
- Ensure continuous, non-overlapping date ranges across all customer versions.

EXPECTED OUTPUT:
+------------------------+------------------+--------+
| CHECK_NAME             | OVERLAPS_FOUND   | STATUS |
+------------------------+------------------+--------+
| TEMPORAL_RANGE_CHECK   | 0                | PASSED |
+------------------------+------------------+--------+


TASK 7: Point-in-Time Dimension Audit
- Query dimension state prior to MERGE execution using engine Time Travel.

EXPECTED OUTPUT:
+-------------+---------------+------------+------------+------------+
| CUSTOMER_ID | ADDRESS       | TIER       | START_DATE | IS_CURRENT |
+-------------+---------------+------------+------------+------------+
| CUST-101    | 789 Pine St   | Bronze     | 2026-01-01 | TRUE       |
+-------------+---------------+------------+------------+------------+


TASK 8: Dimension Surrogate Key Clustering
- Optimize physical table layout on surrogate keys via engine maintenance features.

EXPECTED OUTPUT:
+-------------------+---------------------+
| TARGET_TABLE      | CLUSTERING_STATUS   |
+-------------------+---------------------+
| DIM_CUSTOMER_SCD2 | OPTIMIZED           |
+-------------------+---------------------+