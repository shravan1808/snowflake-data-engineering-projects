# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

## DAY 12: DIMENSIONAL DEEP DIVE

================================================================================
PROJECT 20B: Multi-Entity Financial Risk Lakehouse — Snowflaking & Complex Fact Types
================================================================================
Target Schedule: Week 3 — Day 12

Target Topics: Factless Fact Tables, Accumulating Snapshot Facts, Outrigger Dimensions,
                Normalized Snowflaking, Point-in-Time Risk Auditing

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Outrigger & Snowflaked Ingestion):
  - Databricks & Snowflake: Ingest risk profiles, branch structures, and credit rating outriggers into normalized dimension tables (`DIM_OUTRIGGER_RATING`, `DIM_BRANCH`).

* Task 2 Requirements (Factless Fact Table Creation):
  - Both Engines: Build a Factless Fact table (`FACT_CUSTOMER_FACILITY_ELIGIBILITY`) tracking coverage and eligibility relationships between customers and credit facilities without numeric metrics.

* Task 3 Requirements (Accumulating Snapshot Fact Pipeline):
  - Both Engines: Construct an Accumulating Snapshot fact table (`FACT_LOAN_APPLICATION_SNAPSHOT`) tracking multi-stage milestone timestamps (`submitted_date`, `underwritten_date`, `approved_date`, `disbursed_date`).

* Task 4 Requirements (Outrigger & Snowflaked Joins):
  - Both Engines: Query normalized dimensions by joining `DIM_CUSTOMER` to `DIM_BRANCH` and outrigger `DIM_OUTRIGGER_RATING` to analyze risk tier exposure.

* Task 5 Requirements (Milestone State MERGE Updates):
  - Databricks & Snowflake: Execute atomic `MERGE` statements to incrementally update lifecycle timestamps and duration metrics as loan applications transition across stages.

* Task 6 Requirements (Referential & Status Integrity Checks):
  - Both Engines: Enforce data quality constraints ensuring sequential milestone logic (`submitted_date <= underwritten_date <= approved_date`).

* Task 7 Requirements (Historical Lifecycle Time Travel Audit):
  - Databricks: Query Delta history using `VERSION AS OF` to review loan application statuses prior to final disbursement updates.
  - Snowflake: Perform `AT(TIMESTAMP => ...)` to evaluate application snapshot history.

* Task 8 Requirements (Storage Layout & Multi-Column Clustering):
  - Databricks: Optimize performance using `ZORDER BY (customer_id, facility_id)`.
  - Snowflake: Apply micro-partition clustering via `ALTER TABLE ... CLUSTER BY (customer_id, facility_id)`.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Credit Rating Outrigger Feed (`raw_ratings_kv`):
-----------------------------------------------
raw_ratings_kv = [
    {"rating_id": "RT-01", "agency": "S&P", "credit_score_band": "750-850", "risk_tier": "Low Risk"},
    {"rating_id": "RT-02", "agency": "Moody", "credit_score_band": "600-749", "risk_tier": "Medium Risk"}
]

Branch Master Feed (`raw_branches_kv`):
--------------------------------------
raw_branches_kv = [
    {"branch_id": "BR-10", "branch_name": "Downtown Commercial", "region": "North"},
    {"branch_id": "BR-12", "branch_name": "Uptown Corporate", "region": "East"}
]

Customer Master Feed (`raw_customers_kv`):
------------------------------------------
raw_customers_kv = [
    {"customer_id": "CUST-501", "customer_name": "Acme Corp", "rating_id": "RT-01", "branch_id": "BR-10"},
    {"customer_id": "CUST-502", "customer_name": "Apex Global", "rating_id": "RT-02", "branch_id": "BR-12"}
]

Facility Eligibility Feed (`raw_facilities_kv`):
-----------------------------------------------
raw_facilities_kv = [
    {"customer_id": "CUST-501", "facility_id": "FAC-100", "eligibility_flag": True},
    {"customer_id": "CUST-502", "facility_id": "FAC-200", "eligibility_flag": True}
]

Loan Application Pipeline Feed (`raw_loan_applications_kv`):
-----------------------------------------------------------
raw_loan_applications_kv = [
    {"app_id": "APP-9001", "customer_id": "CUST-501", "submitted_date": "2026-08-01", "underwritten_date": "2026-08-05", "approved_date": None, "disbursed_date": None, "loan_amount": 500000.00},
    {"app_id": "APP-9002", "customer_id": "CUST-502", "submitted_date": "2026-08-03", "underwritten_date": "2026-08-07", "approved_date": "2026-08-10", "disbursed_date": None, "loan_amount": 250000.00}
]

Loan Pipeline Updates Feed (`cdc_loan_updates_kv`):
--------------------------------------------------
cdc_loan_updates_kv = [
    {"app_id": "APP-9001", "approved_date": "2026-08-12", "disbursed_date": "2026-08-15"}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Outrigger & Snowflaked Dimension Staging
- Ingest credit ratings and branch structures into normalized staging structures.

EXPECTED OUTPUT:
+---------------+--------------+
| STAGING_TABLE | RECORD_COUNT |
+---------------+--------------+
| STG_RATINGS   | 2            |
| STG_BRANCHES  | 2            |
+---------------+--------------+


TASK 2: Factless Fact Table Construction
- Build `FACT_CUSTOMER_FACILITY_ELIGIBILITY` using `raw_facilities_kv` to capture multi-entity relationship coverage without numeric metrics.

EXPECTED OUTPUT:
+-------------+-------------+------------------+
| CUSTOMER_ID | FACILITY_ID | ELIGIBILITY_FLAG |
+-------------+-------------+------------------+
| CUST-501    | FAC-100     | TRUE             |
| CUST-502    | FAC-200     | TRUE             |
+-------------+-------------+------------------+


TASK 3: Accumulating Snapshot Fact Initialization
- Initialize `FACT_LOAN_APPLICATION_SNAPSHOT` capturing stage completion timestamps and active loan amounts.

EXPECTED OUTPUT:
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+
| APP_ID   | CUSTOMER_ID | SUBMITTED_DATE | UNDERWRITTEN_DATE | APPROVED_DATE | DISBURSED_DATE | LOAN_AMOUNT |
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+
| APP-9001 | CUST-501    | 2026-08-01     | 2026-08-05        | NULL          | NULL           | 500000.00   |
| APP-9002 | CUST-502    | 2026-08-03     | 2026-08-07        | 2026-08-10    | NULL           | 250000.00   |
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+


TASK 4: Outrigger & Snowflaked Dimension Join Query
- Execute join queries traversing `FACT_LOAN_APPLICATION_SNAPSHOT` -> `DIM_CUSTOMER` -> `DIM_BRANCH` and outrigger `DIM_OUTRIGGER_RATING`.

EXPECTED OUTPUT:
+----------+---------------+---------------------+-------------------+-----------+-------------+
| APP_ID   | CUSTOMER_NAME | BRANCH_NAME         | CREDIT_SCORE_BAND | RISK_TIER | LOAN_AMOUNT |
+----------+---------------+---------------------+-------------------+-----------+-------------+
| APP-9001 | Acme Corp     | Downtown Commercial | 750-850           | Low Risk  | 500000.00   |
| APP-9002 | Apex Global   | Uptown Corporate    | 600-749           | Med Risk  | 250000.00   |
+----------+---------------+---------------------+-------------------+-----------+-------------+


TASK 5: Accumulating Snapshot Lifecycle MERGE
- Process `cdc_loan_updates_kv` to update lifecycle dates (`approved_date`, `disbursed_date`) for APP-9001.

EXPECTED OUTPUT:
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+
| APP_ID   | CUSTOMER_ID | SUBMITTED_DATE | UNDERWRITTEN_DATE | APPROVED_DATE | DISBURSED_DATE | LOAN_AMOUNT |
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+
| APP-9001 | CUST-501    | 2026-08-01     | 2026-08-05        | 2026-08-12    | 2026-08-15     | 500000.00   |
+----------+-------------+----------------+-------------------+---------------+----------------+-------------+


TASK 6: Milestone Sequence Check Enforcement
- Validate data quality checks ensuring milestone dates follow accurate time progression sequences.

EXPECTED OUTPUT:
+-------------------+--------------------+------------------+
| CHECK_NAME        | INVALID_SEQUENCES  | STATUS           |
+-------------------+--------------------+------------------+
| DATE_SEQUENCE_CHK | 0                  | PASSED           |
+-------------------+--------------------+------------------+


TASK 7: Lifecycle Historical State Audit
- Query previous versions of `FACT_LOAN_APPLICATION_SNAPSHOT` prior to disbursement updates using Time Travel.

EXPECTED OUTPUT:
+----------+---------------+----------------+
| APP_ID   | APPROVED_DATE | DISBURSED_DATE |
+----------+---------------+----------------+
| APP-9001 | NULL          | NULL           |
+----------+---------------+----------------+


TASK 8: Multi-Column Storage Layout Optimization
- Optimize multi-entity join query layout via multi-column clustering execution.

EXPECTED OUTPUT:
+--------------------------------+-------------------+
| TARGET_TABLE                   | CLUSTERING_STATUS |
+--------------------------------+-------------------+
| FACT_CUSTOMER_FACILITY_ELIGIB  | OPTIMIZED         |
+--------------------------------+-------------------+