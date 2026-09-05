# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

---

## DAY 15: END-TO-END ENTERPRISE ARCHITECTURE (CONTINUED)

================================================================================
PROJECT 23B: Enterprise Customer Analytics Engine — RFM, LTV & Churn (Hard)
================================================================================
Target Schedule: Week 3 — Day 15 (Topics M9–M10)

Target Topics: Multi-Channel Customer Event Stream Ingestion, Multi-Fact Schema Physical Modeling,
                RFM (Recency, Frequency, Monetary) Segmentation Calculation, Predictive LTV & Churn Scoring,
                Atomic MERGE State Synchronization, Anti-Pattern Architecture Auditing, 
                Point-in-Time RFM Time Travel, Multi-Column Clustering Optimization

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Multi-Channel Event Ingestion): Parse and stage web, mobile app, and in-store interaction streams (`STG_CUSTOMER_EVENTS`).
* Task 2 Requirements (Multi-Fact Dimensional Physical Modeling): Deploy facts (`FACT_TRANSACTIONS`, `FACT_WEB_SESSIONS`) with conformed `DIM_CUSTOMER`.
* Task 3 Requirements (RFM Segmentation Calculation): Evaluate Recency (days), Frequency (counts), and Monetary value to segment users into RFM groups.
* Task 4 Requirements (Predictive LTV Modeling): Compute historical customer lifetime value and predict 1-year forward LTV with churn risk scores.
* Task 5 Requirements (Analytics Warehouse MERGE Execution): Maintain continuous state updates using atomic `MERGE INTO` operations.
* Task 6 Requirements (Data Warehouse Anti-Pattern Audit): Identify and prevent architectural issues such as over-snowflaking or fan-out joins.
* Task 7 Requirements (Customer RFM Time Travel Audit): Audit historical transitions between RFM segments over time via point-in-time queries.
* Task 8 Requirements (Multi-Column Clustering Optimization): Apply Z-Ordering (`ZORDER BY (customer_sk, event_date)`) or micro-partition clustering keys.
* Task 9 Requirements (Cross-Channel Interaction Reconciliation): Reconcile identity resolution mapping web user sessions to physical customer IDs.
* Task 10 Requirements (N-Tile RFM Score Generation): Calculate N-Tile scores (1 to 5) for Recency, Frequency, and Monetary metrics using window functions.
* Task 11 Requirements (Churn Risk Score Categorization): Map churn probability values into actionable risk categories (Low, Medium, High, Critical).
* Task 12 Requirements (Fact-to-Fact Join Prevention Verification): Ensure no direct fact-to-fact joins exist in analytical views by routing via conformed dimensions.
* Task 13 Requirements (Incremental Event Deduplication): Detect and drop duplicate multi-channel event payloads using deterministic event hashes.
* Task 14 Requirements (Cross-Channel Conversion Funnel Analysis): Track conversion progression from web session view to store transaction.
* Task 15 Requirements (Enterprise Engine Pipeline Audit): Execute complete verification validating all 100 interaction events processed.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Raw Customer Multi-Channel Transactions (`raw_rfm_transactions_kv` - 100 Records):
----------------------------------------------------------------------------------
raw_rfm_transactions_kv = [
    {"event_id": "EVT-001", "customer_id": "CUST-A", "event_date": "2026-08-01", "amount": 150.00, "channel": "Web", "session_id": "SES-101"},
    {"event_id": "EVT-002", "customer_id": "CUST-B", "event_date": "2026-05-10", "amount": 50.00, "channel": "Mobile", "session_id": "SES-102"},
    {"event_id": "EVT-003", "customer_id": "CUST-C", "event_date": "2026-08-20", "amount": 500.00, "channel": "Store", "session_id": "SES-103"},
    {"event_id": "EVT-004", "customer_id": "CUST-A", "event_date": "2026-08-15", "amount": 300.00, "channel": "Web", "session_id": "SES-104"},
    {"event_id": "EVT-005", "customer_id": "CUST-D", "event_date": "2026-03-01", "amount": 20.00, "channel": "Mobile", "session_id": "SES-105"},
    {"event_id": "EVT-006", "customer_id": "CUST-B", "event_date": "2026-06-01", "amount": 120.00, "channel": "Web", "session_id": "SES-106"},
    {"event_id": "EVT-007", "customer_id": "CUST-E", "event_date": "2026-08-25", "amount": 1000.00, "channel": "Store", "session_id": "SES-107"},
    {"event_id": "EVT-008", "customer_id": "CUST-C", "event_date": "2026-08-22", "amount": 250.00, "channel": "Web", "session_id": "SES-108"},
    {"event_id": "EVT-009", "customer_id": "CUST-A", "event_date": "2026-08-26", "amount": 450.00, "channel": "Store", "session_id": "SES-109"},
    {"event_id": "EVT-010", "customer_id": "CUST-F", "event_date": "2026-01-15", "amount": 35.00, "channel": "Mobile", "session_id": "SES-110"},
    {"event_id": "EVT-011", "customer_id": "CUST-G", "event_date": "2026-08-10", "amount": 750.00, "channel": "Store", "session_id": "SES-111"},
    {"event_id": "EVT-012", "customer_id": "CUST-E", "event_date": "2026-08-27", "amount": 1200.00, "channel": "Web", "session_id": "SES-112"},
    {"event_id": "EVT-013", "customer_id": "CUST-H", "event_date": "2026-04-20", "amount": 90.00, "channel": "Web", "session_id": "SES-113"},
    {"event_id": "EVT-014", "customer_id": "CUST-C", "event_date": "2026-08-27", "amount": 300.00, "channel": "Mobile", "session_id": "SES-114"},
    {"event_id": "EVT-015", "customer_id": "CUST-A", "event_date": "2026-08-28", "amount": 600.00, "channel": "Web", "session_id": "SES-115"},
    {"event_id": "EVT-016", "customer_id": "CUST-I", "event_date": "2026-07-01", "amount": 200.00, "channel": "Store", "session_id": "SES-116"},
    {"event_id": "EVT-017", "customer_id": "CUST-J", "event_date": "2026-08-18", "amount": 850.00, "channel": "Web", "session_id": "SES-117"},
    {"event_id": "EVT-018", "customer_id": "CUST-G", "event_date": "2026-08-24", "amount": 400.00, "channel": "Mobile", "session_id": "SES-118"},
    {"event_id": "EVT-019", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 800.00, "channel": "Store", "session_id": "SES-119"},
    {"event_id": "EVT-020", "customer_id": "CUST-D", "event_date": "2026-04-10", "amount": 40.00, "channel": "Web", "session_id": "SES-120"},
    {"event_id": "EVT-021", "customer_id": "CUST-B", "event_date": "2026-07-15", "amount": 180.00, "channel": "Store", "session_id": "SES-121"},
    {"event_id": "EVT-022", "customer_id": "CUST-H", "event_date": "2026-05-11", "amount": 110.00, "channel": "Mobile", "session_id": "SES-122"},
    {"event_id": "EVT-023", "customer_id": "CUST-J", "event_date": "2026-08-25", "amount": 950.00, "channel": "Store", "session_id": "SES-123"},
    {"event_id": "EVT-024", "customer_id": "CUST-I", "event_date": "2026-08-05", "amount": 310.00, "channel": "Web", "session_id": "SES-124"},
    {"event_id": "EVT-025", "customer_id": "CUST-F", "event_date": "2026-02-20", "amount": 45.00, "channel": "Store", "session_id": "SES-125"},
    {"event_id": "EVT-026", "customer_id": "CUST-A", "event_date": "2026-08-28", "amount": 150.00, "channel": "Mobile", "session_id": "SES-126"},
    {"event_id": "EVT-027", "customer_id": "CUST-C", "event_date": "2026-08-28", "amount": 400.00, "channel": "Store", "session_id": "SES-127"},
    {"event_id": "EVT-028", "customer_id": "CUST-G", "event_date": "2026-08-27", "amount": 600.00, "channel": "Web", "session_id": "SES-128"},
    {"event_id": "EVT-029", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 350.00, "channel": "Mobile", "session_id": "SES-129"},
    {"event_id": "EVT-030", "customer_id": "CUST-J", "event_date": "2026-08-28", "amount": 1100.00, "channel": "Web", "session_id": "SES-130"},
    {"event_id": "EVT-031", "customer_id": "CUST-A", "event_date": "2026-08-02", "amount": 200.00, "channel": "Web", "session_id": "SES-131"},
    {"event_id": "EVT-032", "customer_id": "CUST-B", "event_date": "2026-07-20", "amount": 220.00, "channel": "Mobile", "session_id": "SES-132"},
    {"event_id": "EVT-033", "customer_id": "CUST-C", "event_date": "2026-08-21", "amount": 150.00, "channel": "Store", "session_id": "SES-133"},
    {"event_id": "EVT-034", "customer_id": "CUST-D", "event_date": "2026-05-01", "amount": 60.00, "channel": "Web", "session_id": "SES-134"},
    {"event_id": "EVT-035", "customer_id": "CUST-E", "event_date": "2026-08-26", "amount": 900.00, "channel": "Store", "session_id": "SES-135"},
    {"event_id": "EVT-036", "customer_id": "CUST-F", "event_date": "2026-03-10", "amount": 55.00, "channel": "Mobile", "session_id": "SES-136"},
    {"event_id": "EVT-037", "customer_id": "CUST-G", "event_date": "2026-08-15", "amount": 300.00, "channel": "Web", "session_id": "SES-137"},
    {"event_id": "EVT-038", "customer_id": "CUST-H", "event_date": "2026-06-01", "amount": 130.00, "channel": "Store", "session_id": "SES-138"},
    {"event_id": "EVT-039", "customer_id": "CUST-I", "event_date": "2026-08-10", "amount": 420.00, "channel": "Mobile", "session_id": "SES-139"},
    {"event_id": "EVT-040", "customer_id": "CUST-J", "event_date": "2026-08-20", "amount": 700.00, "channel": "Store", "session_id": "SES-140"},
    {"event_id": "EVT-041", "customer_id": "CUST-A", "event_date": "2026-08-10", "amount": 350.00, "channel": "Store", "session_id": "SES-141"},
    {"event_id": "EVT-042", "customer_id": "CUST-B", "event_date": "2026-08-01", "amount": 250.00, "channel": "Web", "session_id": "SES-142"},
    {"event_id": "EVT-043", "customer_id": "CUST-C", "event_date": "2026-08-25", "amount": 600.00, "channel": "Mobile", "session_id": "SES-143"},
    {"event_id": "EVT-044", "customer_id": "CUST-D", "event_date": "2026-06-15", "amount": 75.00, "channel": "Store", "session_id": "SES-144"},
    {"event_id": "EVT-045", "customer_id": "CUST-E", "event_date": "2026-08-27", "amount": 1100.00, "channel": "Web", "session_id": "SES-145"},
    {"event_id": "EVT-046", "customer_id": "CUST-F", "event_date": "2026-04-05", "amount": 80.00, "channel": "Web", "session_id": "SES-146"},
    {"event_id": "EVT-047", "customer_id": "CUST-G", "event_date": "2026-08-20", "amount": 500.00, "channel": "Store", "session_id": "SES-147"},
    {"event_id": "EVT-048", "customer_id": "CUST-H", "event_date": "2026-07-10", "amount": 160.00, "channel": "Mobile", "session_id": "SES-148"},
    {"event_id": "EVT-049", "customer_id": "CUST-I", "event_date": "2026-08-18", "amount": 550.00, "channel": "Store", "session_id": "SES-149"},
    {"event_id": "EVT-050", "customer_id": "CUST-J", "event_date": "2026-08-26", "amount": 1250.00, "channel": "Mobile", "session_id": "SES-150"},
    {"event_id": "EVT-051", "customer_id": "CUST-A", "event_date": "2026-08-20", "amount": 280.00, "channel": "Web", "session_id": "SES-151"},
    {"event_id": "EVT-052", "customer_id": "CUST-B", "event_date": "2026-08-10", "amount": 310.00, "channel": "Store", "session_id": "SES-152"},
    {"event_id": "EVT-053", "customer_id": "CUST-C", "event_date": "2026-08-26", "amount": 480.00, "channel": "Web", "session_id": "SES-153"},
    {"event_id": "EVT-054", "customer_id": "CUST-D", "event_date": "2026-07-01", "amount": 90.00, "channel": "Mobile", "session_id": "SES-154"},
    {"event_id": "EVT-055", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 1300.00, "channel": "Store", "session_id": "SES-155"},
    {"event_id": "EVT-056", "customer_id": "CUST-F", "event_date": "2026-05-12", "amount": 100.00, "channel": "Store", "session_id": "SES-156"},
    {"event_id": "EVT-057", "customer_id": "CUST-G", "event_date": "2026-08-22", "amount": 620.00, "channel": "Web", "session_id": "SES-157"},
    {"event_id": "EVT-058", "customer_id": "CUST-H", "event_date": "2026-08-01", "amount": 210.00, "channel": "Web", "session_id": "SES-158"},
    {"event_id": "EVT-059", "customer_id": "CUST-I", "event_date": "2026-08-22", "amount": 680.00, "channel": "Mobile", "session_id": "SES-159"},
    {"event_id": "EVT-060", "customer_id": "CUST-J", "event_date": "2026-08-27", "amount": 1400.00, "channel": "Store", "session_id": "SES-160"},
    {"event_id": "EVT-061", "customer_id": "CUST-A", "event_date": "2026-08-22", "amount": 190.00, "channel": "Mobile", "session_id": "SES-161"},
    {"event_id": "EVT-062", "customer_id": "CUST-B", "event_date": "2026-08-18", "amount": 140.00, "channel": "Web", "session_id": "SES-162"},
    {"event_id": "EVT-063", "customer_id": "CUST-C", "event_date": "2026-08-27", "amount": 520.00, "channel": "Store", "session_id": "SES-163"},
    {"event_id": "EVT-064", "customer_id": "CUST-D", "event_date": "2026-08-05", "amount": 110.00, "channel": "Web", "session_id": "SES-164"},
    {"event_id": "EVT-065", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 950.00, "channel": "Web", "session_id": "SES-165"},
    {"event_id": "EVT-066", "customer_id": "CUST-F", "event_date": "2026-06-20", "amount": 120.00, "channel": "Mobile", "session_id": "SES-166"},
    {"event_id": "EVT-067", "customer_id": "CUST-G", "event_date": "2026-08-25", "amount": 480.00, "channel": "Store", "session_id": "SES-167"},
    {"event_id": "EVT-068", "customer_id": "CUST-H", "event_date": "2026-08-15", "amount": 250.00, "channel": "Store", "session_id": "SES-168"},
    {"event_id": "EVT-069", "customer_id": "CUST-I", "event_date": "2026-08-25", "amount": 720.00, "channel": "Web", "session_id": "SES-169"},
    {"event_id": "EVT-070", "customer_id": "CUST-J", "event_date": "2026-08-28", "amount": 1600.00, "channel": "Web", "session_id": "SES-170"},
    {"event_id": "EVT-071", "customer_id": "CUST-A", "event_date": "2026-08-25", "amount": 320.00, "channel": "Store", "session_id": "SES-171"},
    {"event_id": "EVT-072", "customer_id": "CUST-B", "event_date": "2026-08-22", "amount": 290.00, "channel": "Mobile", "session_id": "SES-172"},
    {"event_id": "EVT-073", "customer_id": "CUST-C", "event_date": "2026-08-28", "amount": 380.00, "channel": "Web", "session_id": "SES-173"},
    {"event_id": "EVT-074", "customer_id": "CUST-D", "event_date": "2026-08-12", "amount": 130.00, "channel": "Store", "session_id": "SES-174"},
    {"event_id": "EVT-075", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 1400.00, "channel": "Mobile", "session_id": "SES-175"},
    {"event_id": "EVT-076", "customer_id": "CUST-F", "event_date": "2026-07-25", "amount": 150.00, "channel": "Web", "session_id": "SES-176"},
    {"event_id": "EVT-077", "customer_id": "CUST-G", "event_date": "2026-08-26", "amount": 530.00, "channel": "Mobile", "session_id": "SES-177"},
    {"event_id": "EVT-078", "customer_id": "CUST-H", "event_date": "2026-08-20", "amount": 280.00, "channel": "Web", "session_id": "SES-178"},
    {"event_id": "EVT-079", "customer_id": "CUST-I", "event_date": "2026-08-27", "amount": 810.00, "channel": "Store", "session_id": "SES-179"},
    {"event_id": "EVT-080", "customer_id": "CUST-J", "event_date": "2026-08-28", "amount": 1800.00, "channel": "Store", "session_id": "SES-180"},
    {"event_id": "EVT-081", "customer_id": "CUST-A", "event_date": "2026-08-27", "amount": 410.00, "channel": "Web", "session_id": "SES-181"},
    {"event_id": "EVT-082", "customer_id": "CUST-B", "event_date": "2026-08-25", "amount": 170.00, "channel": "Store", "session_id": "SES-182"},
    {"event_id": "EVT-083", "customer_id": "CUST-C", "event_date": "2026-08-28", "amount": 620.00, "channel": "Mobile", "session_id": "SES-183"},
    {"event_id": "EVT-084", "customer_id": "CUST-D", "event_date": "2026-08-20", "amount": 150.00, "channel": "Web", "session_id": "SES-184"},
    {"event_id": "EVT-085", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 1050.00, "channel": "Store", "session_id": "SES-185"},
    {"event_id": "EVT-086", "customer_id": "CUST-F", "event_date": "2026-08-10", "amount": 180.00, "channel": "Store", "session_id": "SES-186"},
    {"event_id": "EVT-087", "customer_id": "CUST-G", "event_date": "2026-08-28", "amount": 670.00, "channel": "Web", "session_id": "SES-187"},
    {"event_id": "EVT-088", "customer_id": "CUST-H", "event_date": "2026-08-25", "amount": 310.00, "channel": "Mobile", "session_id": "SES-188"},
    {"event_id": "EVT-089", "customer_id": "CUST-I", "event_date": "2026-08-28", "amount": 890.00, "channel": "Web", "session_id": "SES-189"},
    {"event_id": "EVT-090", "customer_id": "CUST-J", "event_date": "2026-08-28", "amount": 2100.00, "channel": "Mobile", "session_id": "SES-190"},
    {"event_id": "EVT-091", "customer_id": "CUST-A", "event_date": "2026-08-28", "amount": 500.00, "channel": "Store", "session_id": "SES-191"},
    {"event_id": "EVT-092", "customer_id": "CUST-B", "event_date": "2026-08-28", "amount": 350.00, "channel": "Web", "session_id": "SES-192"},
    {"event_id": "EVT-093", "customer_id": "CUST-C", "event_date": "2026-08-28", "amount": 700.00, "channel": "Store", "session_id": "SES-193"},
    {"event_id": "EVT-094", "customer_id": "CUST-D", "event_date": "2026-08-25", "amount": 180.00, "channel": "Mobile", "session_id": "SES-194"},
    {"event_id": "EVT-095", "customer_id": "CUST-E", "event_date": "2026-08-28", "amount": 1500.00, "channel": "Web", "session_id": "SES-195"},
    {"event_id": "EVT-096", "customer_id": "CUST-F", "event_date": "2026-08-22", "amount": 210.00, "channel": "Web", "session_id": "SES-196"},
    {"event_id": "EVT-097", "customer_id": "CUST-G", "event_date": "2026-08-28", "amount": 710.00, "channel": "Store", "session_id": "SES-197"},
    {"event_id": "EVT-098", "customer_id": "CUST-H", "event_date": "2026-08-28", "amount": 340.00, "channel": "Store", "session_id": "SES-198"},
    {"event_id": "EVT-099", "customer_id": "CUST-I", "event_date": "2026-08-28", "amount": 950.00, "channel": "Mobile", "session_id": "SES-199"},
    {"event_id": "EVT-100", "customer_id": "CUST-J", "event_date": "2026-08-28", "amount": 2500.00, "channel": "Store", "session_id": "SES-200"}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Multi-Channel Customer Event Ingestion
- Ingest 100 multi-channel interaction records into staging.

EXPECTED OUTPUT:
+-------------------+----------------+
| STAGING_PIPELINE  | LOADED_RECORDS |
+-------------------+----------------+
| STG_CUST_EVENTS   | 100            |
+-------------------+----------------+


TASK 2: Multi-Fact Dimensional Physical Modeling
- Verify physical schema creation across transaction facts and conformed dimensions.

EXPECTED OUTPUT:
+-------------------+-------------+-------------------+
| PHYSICAL_TABLE    | LAYER_TYPE  | KEY_STRUCTURE     |
+-------------------+-------------+-------------------+
| FACT_TRANSACTIONS | FACT        | TRANSACTION_SK    |
| DIM_CUSTOMER      | DIMENSION   | CUSTOMER_SK       |
+-------------------+-------------+-------------------+


TASK 3: RFM Segmentation Calculation
- Calculate Recency (days relative to 2026-08-28), Frequency, Monetary total, and RFM segment.

EXPECTED OUTPUT:
+-------------+---------+-----------+----------------+--------------+
| CUSTOMER_ID | RECENCY | FREQUENCY | MONETARY_TOTAL | RFM_SEGMENT  |
+-------------+---------+-----------+----------------+--------------+
| CUST-A      | 0 Days  | 10        | 3550.00        | Champions    |
| CUST-E      | 0 Days  | 10        | 11300.00       | Champions    |
| CUST-F      | 6 Days  | 10        | 1125.00        | At Risk      |
+-------------+---------+-----------+----------------+--------------+


TASK 4: Predictive LTV Modeling
- Compute historical LTV and extrapolate 1-year forward LTV with churn risk scores.

EXPECTED OUTPUT:
+-------------+----------------+-------------------+------------------+
| CUSTOMER_ID | HISTORICAL_LTV | PREDICTED_LTV_1YR | CHURN_RISK_SCORE |
+-------------+----------------+-------------------+------------------+
| CUST-A      | 3550.00        | 8500.00           | Low              |
| CUST-E      | 11300.00       | 24000.00          | Low              |
| CUST-F      | 1125.00        | 1300.00           | High             |
+-------------+----------------+-------------------+------------------+


TASK 5: Analytics Warehouse MERGE Execution
- Process incremental event stream updates via atomic `MERGE INTO`.

EXPECTED OUTPUT:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 0             | 10           |
+---------------+--------------+


TASK 6: Data Warehouse Anti-Pattern Audit
- Execute architectural validation checks to ensure zero fan-out joins or over-snowflaking.

EXPECTED OUTPUT:
+-------------------+----------+-------------+
| ANTI_PATTERN      | DETECTED | REMEDIATION |
+-------------------+----------+-------------+
| OVER_SNOWFLAKING  | NO       | PASSED      |
| FAN_OUT_JOIN      | NO       | PASSED      |
+-------------------+----------+-------------+


TASK 7: Customer RFM Time Travel Audit
- Perform point-in-time snapshot query to compare current vs past RFM segment assignments.

EXPECTED OUTPUT:
+-------------+--------------------+-----------------+
| CUSTOMER_ID | HISTORICAL_SEGMENT | CURRENT_SEGMENT |
+-------------+--------------------+-----------------+
| CUST-A      | Champions          | Champions       |
| CUST-F      | Potential Loyalist | At Risk         |
+-------------+--------------------+-----------------+


TASK 8: Multi-Column Clustering Optimization
- Execute cluster optimization on `FACT_TRANSACTIONS` using composite keys (`customer_sk`, `event_date`).

EXPECTED OUTPUT:
+-------------------+-------------------------+-----------+
| WAREHOUSE_FACT    | CLUSTERING_METRIC       | STATUS    |
+-------------------+-------------------------+-----------+
| FACT_TRANSACTIONS | ZORDER_CUST_SK_EVT_DATE | OPTIMIZED |
+-------------------+-------------------------+-----------+


TASK 9: Cross-Channel Interaction Reconciliation
- Reconcile multi-channel interaction identities to unified customer IDs.

EXPECTED OUTPUT:
+-------------------+-------------------+---------------+
| TOTAL_SESSIONS    | MATCHED_CUSTOMERS | UNMATCHED_SESS|
+-------------------+-------------------+---------------+
| 100               | 100               | 0             |
+-------------------+-------------------+---------------+


TASK 10: N-Tile RFM Score Generation
- Compute N-Tile scores (1–5) across Recency, Frequency, and Monetary metrics.

EXPECTED OUTPUT:
+-------------+-----------+-------------+----------------+----------------+
| CUSTOMER_ID | R_SCORE   | F_SCORE     | M_SCORE        | COMPOSITE_RFM  |
+-------------+-----------+-------------+----------------+----------------+
| CUST-A      | 5         | 5           | 4              | 554            |
| CUST-E      | 5         | 5           | 5              | 555            |
| CUST-F      | 2         | 5           | 1              | 251            |
+-------------+-----------+-------------+----------------+----------------+


TASK 11: Churn Risk Score Categorization
- Assign actionable risk categories based on churn probability scores.

EXPECTED OUTPUT:
+-------------------+---------------+
| RISK_CATEGORY     | CUSTOMER_COUNT|
+-------------------+---------------+
| Low Risk          | 7             |
| Medium Risk       | 2             |
| High Risk         | 1             |
+-------------------+---------------+


TASK 12: Fact-to-Fact Join Prevention Verification
- Audit view definitions to confirm zero direct joins between `FACT_TRANSACTIONS` and `FACT_WEB_SESSIONS`.

EXPECTED OUTPUT:
+----------------------+----------------------+--------+
| VIEW_AUDIT_CHECK     | DIRECT_FACT_JOINS    | STATUS |
+----------------------+----------------------+--------+
| FACT_JOIN_PREVENTION | 0                    | PASSED |
+----------------------+----------------------+--------+


TASK 13: Incremental Event Deduplication
- Detect and deduplicate incoming event streams using SHA256 hashes.

EXPECTED OUTPUT:
+--------------------+-------------------+---------------+
| PROCESSED_EVENTS   | DUPLICATES_DROPPED| CLEAN_RECORDS |
+--------------------+-------------------+---------------+
| 100                | 0                 | 100           |
+--------------------+-------------------+---------------+


TASK 14: Cross-Channel Conversion Funnel Analysis
- Calculate conversion progression rates from mobile/web sessions to completed purchases.

EXPECTED OUTPUT:
+---------------+-------------------+-------------------+-----------------+
| CHANNEL       | TOTAL_INTERACTION | COMPLETED_ORDERS  | CONVERSION_RATE |
+---------------+-------------------+-------------------+-----------------+
| Web           | 42                | 42                | 100.00%         |
| Mobile        | 25                | 25                | 100.00%         |
| Store         | 33                | 33                | 100.00%         |
+---------------+-------------------+-------------------+-----------------+


TASK 15: Enterprise Engine Pipeline Audit
- Run end-to-end audit verifying full processing of 100 multi-channel records across all facts and metrics.

EXPECTED OUTPUT:
+-------------------+----------------+-----------------+----------+
| ENGINE_COMPONENT  | EXPECTED_COUNT | PROCESSED_COUNT | STATUS   |
+-------------------+----------------+-----------------+----------+
| STG_EVENTS        | 100            | 100             | VERIFIED |
| FACT_TRANSACTIONS | 100            | 100             | VERIFIED |
| RFM_SUMMARY       | 10             | 10              | VERIFIED |
+-------------------+----------------+-----------------+----------+