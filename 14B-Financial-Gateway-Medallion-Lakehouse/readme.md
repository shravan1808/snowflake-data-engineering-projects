================================================================================

PROJECT 14B: Financial Gateway — Medallion Lakehouse \& Snapshot Auditing

================================================================================

Target Module: 4.4b (Lakehouse Architecture: Medallion Pattern \& Time-Travel)

Environment: Snowflake SQL



\--------------------------------------------------------------------------------

1\. PROBLEM STATEMENT \& BUSINESS SCENARIO

\--------------------------------------------------------------------------------

You are building a Lakehouse Architecture for a Fintech Payment Gateway using 

the \*\*Medallion Pattern (Bronze -> Silver -> Gold)\*\*:



1\. Bronze Layer (Raw Streaming Data Lake): Ingests raw JSON transaction payloads.

2\. Silver Layer (Cleaned Lakehouse Hub): Extracts, validates, and calculates 

&#x20;  gateway processing fees and net payouts.

3\. Gold Layer (Business Mart): Aggregates financial settlements per merchant.



During operation, an accidental SQL update corrupts transaction statuses in Silver. 

You must use Snowflake \*\*Time-Travel\*\* snapshot auditing to inspect past states, 

execute a recovery, mask sensitive user data, and reconcile metrics.



\--------------------------------------------------------------------------------

2\. INPUT DATASETS (BRONZE LAYER STREAM)

\--------------------------------------------------------------------------------



Raw Payment Gateway Payloads:

\----------------------------

{"txn\_id":"TXN-901","txn\_time":"2026-07-10T10:00:00Z","merchant\_id":301,"merchant\_name":"TechZone","card\_number":"4111222233334444","amount":50000.00,"fee\_pct":2.5,"status":"APPROVED"}

{"txn\_id":"TXN-902","txn\_time":"2026-07-10T10:15:00Z","merchant\_id":302,"merchant\_name":"StyleHub","card\_number":"5500111122223333","amount":12000.00,"fee\_pct":3.0,"status":"APPROVED"}

{"txn\_id":"TXN-903","txn\_time":"2026-07-10T11:00:00Z","merchant\_id":301,"merchant\_name":"TechZone","card\_number":"4111222233334444","amount":25000.00,"fee\_pct":2.5,"status":"PENDING"}

{"txn\_id":"TXN-904","txn\_time":"2026-07-10T11:30:00Z","merchant\_id":303,"merchant\_name":"FreshMart","card\_number":"4000111122223333","amount":8500.00,"fee\_pct":1.8,"status":"APPROVED"}

{"txn\_id":"TXN-905","txn\_time":"2026-07-10T12:00:00Z","merchant\_id":302,"merchant\_name":"StyleHub","card\_number":"5500111122223333","amount":45000.00,"fee\_pct":3.0,"status":"DECLINED"}

{"txn\_id":"TXN-906","txn\_time":"2026-07-10T12:30:00Z","merchant\_id":301,"merchant\_name":"TechZone","card\_number":"4111222233334444","amount":150000.00,"fee\_pct":2.5,"status":"APPROVED"}

{"txn\_id":"TXN-907","txn\_time":"2026-07-10T13:00:00Z","merchant\_id":303,"merchant\_name":"FreshMart","card\_number":"4000111122223333","amount":3200.00,"fee\_pct":1.8,"status":"APPROVED"}

{"txn\_id":"TXN-908","txn\_time":"2026-07-10T13:15:00Z","merchant\_id":302,"merchant\_name":"StyleHub","card\_number":"5500111122223333","amount":67000.00,"fee\_pct":3.0,"status":"PENDING"}



\--------------------------------------------------------------------------------

3\. STUDENT TASKS \& EXPECTED OUTPUTS

\--------------------------------------------------------------------------------



TASK 1: Bronze Layer Setup \& Ingestion

\- Create table `BRONZE\_PAYMENT\_PAYLOADS` and ingest all 8 raw JSON records.



EXPECTED OUTPUT (SELECT COUNT(\*) FROM BRONZE\_PAYMENT\_PAYLOADS):

+-------------------------+

| TOTAL\_BRONZE\_RECORDS\_CT |

+-------------------------+

| 8                       |

+-------------------------+





TASK 2: Silver Layer ETL \& Fee Computations

\- Populate `SILVER\_CLEANED\_TRANSACTIONS`.

\- Apply credit card masking: `XXXX-XXXX-XXXX-4444`.

\- Calculate `PROCESSING\_FEE = GROSS\_AMOUNT \* (FEE\_PCT / 100)`

\- Calculate `NET\_SETTLEMENT\_AMOUNT = GROSS\_AMOUNT - PROCESSING\_FEE`



EXPECTED OUTPUT:

+---------+--------------+---------------+--------------+----------+----------------+-----------------------+----------+

| TXN\_ID  | MERCHANT\_ID  | MERCHANT\_NAME | MASKED\_CARD  | GROSS    | PROCESSING\_FEE | NET\_SETTLEMENT\_AMOUNT | STATUS   |

+---------+--------------+---------------+--------------+----------+----------------+-----------------------+----------+

| TXN-901 | 301          | TechZone      | XXXX-XXXX-...| 50000.00 | 1250.00        | 48750.00              | APPROVED |

| TXN-902 | 302          | StyleHub      | XXXX-XXXX-...| 12000.00 | 360.00         | 11640.00              | APPROVED |

| TXN-903 | 301          | TechZone      | XXXX-XXXX-...| 25000.00 | 625.00         | 24375.00              | PENDING  |

| TXN-904 | 303          | FreshMart     | XXXX-XXXX-...| 8500.00  | 153.00         | 8347.00               | APPROVED |

| TXN-905 | 302          | StyleHub      | XXXX-XXXX-...| 45000.00 | 1350.00        | 43650.00              | DECLINED |

| TXN-906 | 301          | TechZone      | XXXX-XXXX-...| 150000.00| 3750.00        | 146250.00             | APPROVED |

| TXN-907 | 303          | FreshMart     | XXXX-XXXX-...| 3200.00  | 57.60          | 3142.40               | APPROVED |

| TXN-908 | 302          | StyleHub      | XXXX-XXXX-...| 67000.00 | 2010.00        | 64990.00              | PENDING  |

+---------+--------------+---------------+--------------+----------+----------------+-----------------------+----------+





TASK 3: Gold Layer Financial Aggregations

\- Create `GOLD\_MERCHANT\_SETTLEMENTS` containing aggregated metrics for `STATUS = 'APPROVED'` records.



EXPECTED OUTPUT:

+-------------+---------------+----------------------+---------------------+-------------------+----------------+

| MERCHANT\_ID | MERCHANT\_NAME | TOTAL\_APPROVED\_GROSS | TOTAL\_GATEWAY\_FEES  | TOTAL\_NET\_PAYOUT  | APPROVED\_COUNT |

+-------------+---------------+----------------------+---------------------+-------------------+----------------+

| 301         | TechZone      | 200000.00            | 5000.00             | 195000.00         | 2              |

| 302         | StyleHub      | 12000.00             | 360.00              | 11640.00          | 1              |

| 303         | FreshMart     | 11700.00             | 210.60              | 11489.40          | 2              |

+-------------+---------------+----------------------+---------------------+-------------------+----------------+





TASK 4: Data Corruption Simulation \& Time-Travel Inspection

1\. Run UPDATE setting `TechZone` approved records to `STATUS = 'REFUNDED'`.

2\. Execute Time-Travel query (`AT (OFFSET => ...)` or `BEFORE`) to view pre-corruption data.



EXPECTED OUTPUT (Time-Travel Inspection Query Result for TechZone):

+---------+---------------+----------+----------+

| TXN\_ID  | MERCHANT\_NAME | GROSS    | STATUS   |

+---------+---------------+----------+----------+

| TXN-901 | TechZone      | 50000.00 | APPROVED |

| TXN-906 | TechZone      | 150000.00| APPROVED |

+---------+---------------+----------+----------+





TASK 5: Time-Travel Recovery Execution

\- Revert corrupted statuses back to `APPROVED` using Time-Travel data.



EXPECTED OUTPUT (Post-Recovery Status Validation):

+---------------+-----------------+---------------+

| MERCHANT\_NAME | APPROVED\_COUNT  | REFUNDED\_COUNT|

+---------------+-----------------+---------------+

| TechZone      | 2               | 0             |

+---------------+-----------------+---------------+





TASK 6: End-to-End Pipeline Reconciliation Audit

\- Write a reconciliation audit query confirming gross totals across all three layers.



EXPECTED OUTPUT:

+-------------------+-------------------+-----------------+------------------+

| BRONZE\_GROSS\_SUM  | SILVER\_GROSS\_SUM  | GOLD\_GROSS\_SUM  | DATA\_MATCH\_FLAG  |

+-------------------+-------------------+-----------------+------------------+

| 360700.00         | 360700.00         | 223700.00\*      | TRUE             |

+-------------------+-------------------+-----------------+------------------+

(\*Note: Gold reflects APPROVED transactions only: 200000 + 12000 + 11700 = 223700.00)

