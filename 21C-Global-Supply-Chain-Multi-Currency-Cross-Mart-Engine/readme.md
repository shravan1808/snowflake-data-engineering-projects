# WEEK 3: DATA MODELING DEEP DIVE & ENTERPRISE ARCHITECTURE

---

## DAY 13: BUS MATRIX & DATA MARTS (PROJECT 21C)

================================================================================
PROJECT 21C: Global Supply Chain & Multi-Currency Cross-Mart Engine (Hard)
================================================================================
Target Schedule: Week 3 — Day 13 (Topics M9–M10)

Target Topics: Multi-Currency Fact Normalization, Conformed Shared Dimensions, 
                Cross-Mart Supply Chain Reconciliation, Point-in-Time Foreign Exchange MERGE

Target Platforms: Dual-Engine (Databricks Delta Lake / PySpark & Snowflake SQL)

--------------------------------------------------------------------------------
1. ENGINE-SPECIFIC REQUIREMENTS & TECHNICAL ENVIRONMENT
--------------------------------------------------------------------------------
* Task 1 Requirements (Multi-Currency Supply Stream Ingestion): Ingest international purchase orders, customs tariffs, and foreign exchange (FX) rate feeds into raw staging layers.
* Task 2 Requirements (Bus Matrix Alignment & Currency Grain Mapping): Align supply chain procurement facts with conformed supplier and geography dimensions across transactional and base currencies.
* Task 3 Requirements (Conformed FX Rate Surrogate Key Mapping): Construct shared currency conversion keys (`currency_sk`) to standardize global valuations in base USD.
* Task 4 Requirements (Cross-Mart Supply Chain Reconciliation View): Build consolidated analytical views joining procurement, logistics, and landed cost data marts.
* Task 5 Requirements (Late-Arriving FX Rate MERGE Execution): Execute atomic `MERGE` updates to revalue pending open orders upon arrival of official effective FX rates.
* Task 6 Requirements (Cross-Mart Currency Imbalance Audit): Audit cross-mart financial reconciliations to detect variance between landed costs and PO line items (> 0.01% tolerance).
* Task 7 Requirements (Multi-Currency Historical Time Travel Audit): Query pre-conversion and post-conversion order states using Delta `VERSION AS OF` or Snowflake `AT()`.
* Task 8 Requirements (Cross-Mart Multi-Column Clustering): Apply clustering keys (`CLUSTER BY (currency_sk, supplier_id)` / `ZORDER`) across procurement fact tables.

--------------------------------------------------------------------------------
2. INPUT DATASETS (KEY-VALUE PAIR FORMAT)
--------------------------------------------------------------------------------

Raw Purchase Orders Feed (`raw_po_kv`):
--------------------------------------
raw_po_kv = [
    {"po_id": "PO-9001", "supplier_id": "SUP-77", "amount_local": 150000.00, "currency": "EUR", "po_date": "2026-08-10"},
    {"po_id": "PO-9002", "supplier_id": "SUP-88", "amount_local": 2500000.00, "currency": "JPY", "po_date": "2026-08-12"}
]

Raw Foreign Exchange Rates (`raw_fx_rates_kv`):
-----------------------------------------------
raw_fx_rates_kv = [
    {"currency": "EUR", "fx_to_usd": 1.0850, "effective_date": "2026-08-10"},
    {"currency": "JPY", "fx_to_usd": 0.0067, "effective_date": "2026-08-12"}
]

Late-Arriving FX Adjustments (`cdc_fx_updates_kv`):
---------------------------------------------------
cdc_fx_updates_kv = [
    {"currency": "EUR", "fx_to_usd": 1.0910, "effective_date": "2026-08-10"}
]

--------------------------------------------------------------------------------
3. TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Multi-Currency Supply Stream Ingestion
- Ingest international PO records and FX rate streams into raw staging tables.

EXPECTED OUTPUT:
+---------------+------------------+
| SOURCE_STREAM | RECORDS_PARSED   |
+---------------+------------------+
| RAW_PO        | 2                |
| RAW_FX        | 2                |
+---------------+------------------+


TASK 2: Bus Matrix Alignment & Currency Grain Mapping
- Map international supply chain procurement events to conformed dimensions.

EXPECTED OUTPUT:
+---------------------+-------------------+---------------------+--------------------+
| BUSINESS_PROCESS    | CONFORMED_SUPPLIER| CONFORMED_CURRENCY  | BASE_CURRENCY_GRAIN|
+---------------------+-------------------+---------------------+--------------------+
| Global Procurement  | YES               | YES                 | USD Equivalent     |
| Customs & Tariffs   | YES               | YES                 | USD Equivalent     |
+---------------------+-------------------+---------------------+--------------------+


TASK 3: Conformed FX Rate Surrogate Key Mapping
- Standardize local currency amounts into USD using conformed `currency_sk` mappings.

EXPECTED OUTPUT:
+---------+--------------+----------+--------------+------------------+
| PO_ID   | CURRENCY_SK  | CURRENCY | AMOUNT_LOCAL | AMOUNT_USD       |
+---------+--------------+----------+--------------+------------------+
| PO-9001 | CURR_EUR_01  | EUR      | 150000.00    | 162750.00        |
| PO-9002 | CURR_JPY_01  | JPY      | 2500000.00   | 16750.00         |
+---------+--------------+----------+--------------+------------------+


TASK 4: Cross-Mart Supply Chain Reconciliation View
- Construct a unified view joining Procurement and Financial Reconciliation Data Marts.

EXPECTED OUTPUT:
+---------+---------------+----------+--------------+------------------+------------------+
| PO_ID   | SUPPLIER_ID   | CURRENCY | AMOUNT_LOCAL | AMOUNT_USD       | RECON_STATUS     |
+---------+---------------+----------+--------------+------------------+------------------+
| PO-9001 | SUP-77        | EUR      | 150000.00    | 162750.00        | MATCHED          |
| PO-9002 | SUP-88        | JPY      | 2500000.00   | 16750.00         | MATCHED          |
+---------+---------------+----------+--------------+------------------+------------------+


TASK 5: Late-Arriving FX Rate MERGE Execution
- Execute an atomic `MERGE` statement to recalculate USD valuation for PO-9001 after EUR FX rate adjustment.

EXPECTED OUTPUT:
+---------------+--------------+
| ROWS_INSERTED | ROWS_UPDATED |
+---------------+--------------+
| 0             | 1            |
+---------------+--------------+


TASK 6: Cross-Mart Currency Imbalance Audit
- Audit landed cost calculations across data marts to flag currency conversion variances.

EXPECTED OUTPUT:
+-----------------------+--------------------+-------------+
| AUDIT_CHECK           | VARIANCE_DETECTED  | STATUS      |
+-----------------------+--------------------+-------------+
| FX_VARIANCE_TOLERANCE | 0.00%              | PASSED      |
+-----------------------+--------------------+-------------+


TASK 7: Multi-Currency Historical Time Travel Audit
- Perform point-in-time time travel queries to inspect PO-9001 USD value before FX adjustment.

EXPECTED OUTPUT:
+---------+--------------------+-------------------+
| PO_ID   | PRE_MERGE_USD      | POST_MERGE_USD    |
+---------+--------------------+-------------------+
| PO-9001 | 162750.00          | 163650.00         |
+---------+--------------------+-------------------+


TASK 8: Cross-Mart Multi-Column Clustering
- Optimize multi-currency procurement facts via composite clustering on `currency_sk` and `supplier_id`.

EXPECTED OUTPUT:
+-----------------------+---------------------+
| MART_TABLE            | OPTIMIZATION_RESULT |
+-----------------------+---------------------+
| FACT_GLOBAL_PROCURE   | OPTIMIZED           |
+-----------------------+---------------------+