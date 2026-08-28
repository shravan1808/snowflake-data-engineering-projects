================================================================================

PROJECT 16: Healthcare Claims \& Billing — Real-Time CDC \& Dynamic Table Pipelines

================================================================================

This project focusing on Snowflake Dynamic Tables, Continuous CDC Pipelines, and Stream Processing.



Target Module: 4.5 (Declarative Data Pipelines: Dynamic Tables vs. Streams \& Tasks)

Environment: Snowflake SQL



\--------------------------------------------------------------------------------

1\. PROBLEM STATEMENT \& BUSINESS SCENARIO

\--------------------------------------------------------------------------------

You are a Senior Data Engineer at a healthcare claims network. The system processes 

medical claims submitted by providers (hospitals and clinics) in real-time.



The analytics infrastructure needs to move from legacy batch processing to a 

\*\*Continuous Declarative Lakehouse Pipeline\*\*:



1\. Staging / Ingestion Layer: Captures streaming JSON payloads of claims 

&#x20;  and status adjustments (Submitted, Approved, Denied, Paid).

2\. Dynamic Transformation Layer: Automatically updates downstream relational 

&#x20;  tables using Snowflake \*\*Dynamic Tables\*\* driven by specified `TARGET\_LAG`.

3\. Change Data Capture (CDC) Layer: Uses \*\*Streams\*\* to track updates/deletions 

&#x20;  and incremental adjustments across insurance coverage limits.



During operation, claims undergo real-time adjustments (e.g., status changes 

from PENDING to APPROVED or DENIED), requiring automated incremental downstream 

refreshing without full table scans.



\--------------------------------------------------------------------------------

2\. INPUT DATASETS (RAW MEDICAL CLAIMS PAYLOADS)

\--------------------------------------------------------------------------------



Batch 1 Payload Stream (Initial Claim Submissions):

\--------------------------------------------------

{"claim\_id":"CLM-301","submitted\_at":"2026-08-10T08:00:00Z","patient\_id":5001,"provider\_id":"PRV-10","diagnosis\_code":"ICD-10-A","billed\_amount":15000.00,"copay\_amount":500.00,"status":"PENDING"}

{"claim\_id":"CLM-302","submitted\_at":"2026-08-10T08:15:00Z","patient\_id":5002,"provider\_id":"PRV-11","diagnosis\_code":"ICD-10-B","billed\_amount":8500.00,"copay\_amount":300.00,"status":"APPROVED"}

{"claim\_id":"CLM-303","submitted\_at":"2026-08-10T08:30:00Z","patient\_id":5003,"provider\_id":"PRV-10","diagnosis\_code":"ICD-10-C","billed\_amount":45000.00,"copay\_amount":1500.00,"status":"PENDING"}

{"claim\_id":"CLM-304","submitted\_at":"2026-08-10T09:00:00Z","patient\_id":5004,"provider\_id":"PRV-12","diagnosis\_code":"ICD-10-A","billed\_amount":3200.00,"copay\_amount":100.00,"status":"APPROVED"}



Batch 2 Payload Stream (Claim Status Adjustments \& New Submissions):

\--------------------------------------------------------------------

{"claim\_id":"CLM-301","submitted\_at":"2026-08-10T08:00:00Z","patient\_id":5001,"provider\_id":"PRV-10","diagnosis\_code":"ICD-10-A","billed\_amount":15000.00,"copay\_amount":500.00,"status":"APPROVED"}

{"claim\_id":"CLM-303","submitted\_at":"2026-08-10T08:30:00Z","patient\_id":5003,"provider\_id":"PRV-10","diagnosis\_code":"ICD-10-C","billed\_amount":45000.00,"copay\_amount":1500.00,"status":"DENIED"}

{"claim\_id":"CLM-305","submitted\_at":"2026-08-10T10:00:00Z","patient\_id":5005,"provider\_id":"PRV-11","diagnosis\_code":"ICD-10-B","billed\_amount":120000.00,"copay\_amount":2500.00,"status":"APPROVED"}



Batch 3 Payload Stream (CDC Inserts \& Late Corrections):

\-------------------------------------------------------

{"claim\_id":"CLM-306","submitted\_at":"2026-08-10T10:30:00Z","patient\_id":5002,"provider\_id":"PRV-12","diagnosis\_code":"ICD-10-A","billed\_amount":6000.00,"copay\_amount":200.00,"status":"APPROVED"}

{"INVALID\_PAYLOAD\_UNPARSEABLE\_STRING"}



\--------------------------------------------------------------------------------

3\. STUDENT TASKS \& EXPECTED OUTPUTS

\--------------------------------------------------------------------------------



TASK 1: Bronze Streaming Staging \& Schema-on-Read Querying

\- Create Database: `HEALTHCARE\_PIPELINE\_DB`

\- Create Schema: `CLAIMS\_CORE`

\- Create Bronze table `BRONZE\_RAW\_CLAIMS` (`INGEST\_ID`, `PAYLOAD` VARIANT, `LOADED\_AT`).

\- Ingest valid JSON payloads from Batch 1, Batch 2, and Batch 3.



EXPECTED OUTPUT (SELECT COUNT(\*) FROM BRONZE\_RAW\_CLAIMS):

+-----------------------+

| TOTAL\_BRONZE\_RECORDS  |

+-----------------------+

| 8                     |

+-----------------------+





TASK 2: Error Handling \& Dead-Letter Isolation

\- Create table `QUARANTINE\_CLAIMS\_PAYLOADS` (`QUARANTINE\_ID`, `RAW\_RECORD\_TEXT`, `REASON`).

\- Use `TRY\_PARSE\_JSON` to isolate corrupt, non-JSON records.



EXPECTED OUTPUT:

+---------------+-------------------------------------+---------------------+

| QUARANTINE\_ID | RAW\_RECORD\_TEXT                     | REASON              |

+---------------+-------------------------------------+---------------------+

| 1             | INVALID\_PAYLOAD\_UNPARSEABLE\_STRING  | MALFORMED\_JSON\_BODY |

+---------------+-------------------------------------+---------------------+





TASK 3: Silver Layer — Real-Time CDC via Stream Tracking

\- Create a Snowflake Stream `STRM\_BRONZE\_CLAIMS` on `BRONZE\_RAW\_CLAIMS`.

\- Create Silver base table `SILVER\_CLAIMS\_TRANSACTIONS` with columns:

&#x20; \* `CLAIM\_ID`, `SUBMITTED\_AT`, `PATIENT\_ID`, `PROVIDER\_ID`, `DIAGNOSIS\_CODE`, 

&#x20;   `BILLED\_AMOUNT`, `COPAY\_AMOUNT`, `NET\_PAYABLE\_AMOUNT`, `STATUS`

\- Calculate `NET\_PAYABLE\_AMOUNT = BILLED\_AMOUNT - COPAY\_AMOUNT`.

\- Merge/Deduplicate records based on `CLAIM\_ID`, picking the latest status update.



EXPECTED OUTPUT:

+----------+------------+-------------+----------------+---------------+--------------+--------------------+----------+

| CLAIM\_ID | PATIENT\_ID | PROVIDER\_ID | DIAGNOSIS\_CODE | BILLED\_AMOUNT | COPAY\_AMOUNT | NET\_PAYABLE\_AMOUNT | STATUS   |

+----------+------------+-------------+----------------+---------------+--------------+--------------------+----------+

| CLM-301  | 5001       | PRV-10      | ICD-10-A       | 15000.00      | 500.00       | 14500.00           | APPROVED |

| CLM-302  | 5002       | PRV-11      | ICD-10-B       | 8500.00       | 300.00       | 8200.00            | APPROVED |

| CLM-303  | 5003       | PRV-10      | ICD-10-C       | 45000.00      | 1500.00      | 43500.00           | DENIED   |

| CLM-304  | 5004       | PRV-12      | ICD-10-A       | 3200.00       | 100.00       | 3100.00            | APPROVED |

| CLM-305  | 5005       | PRV-11      | ICD-10-B       | 120000.00     | 2500.00      | 117500.00          | APPROVED |

| CLM-306  | 5002       | PRV-12      | ICD-10-A       | 6000.00       | 200.00       | 5800.00            | APPROVED |

+----------+------------+-------------+----------------+---------------+--------------+--------------------+----------+





TASK 4: Declarative Pipeline Automation — Dynamic Table Setup

\- Create a Dynamic Table `DT\_PROVIDER\_FINANCIAL\_SUMMARY` with `TARGET\_LAG = '1 minute'` 

&#x20; and `WAREHOUSE = COMPUTE\_WH`.

\- Compute financial summaries strictly for `STATUS = 'APPROVED'` claims grouped by `PROVIDER\_ID`.



EXPECTED OUTPUT:

+-------------+----------------------+--------------------+--------------------+-----------------+

| PROVIDER\_ID | TOTAL\_BILLED\_AMOUNT  | TOTAL\_COPAY\_COLLECT| TOTAL\_NET\_PAYABLE  | APPROVED\_CLAIMS |

+-------------+----------------------+--------------------+--------------------+-----------------+

| PRV-10      | 15000.00             | 500.00             | 14500.00           | 1               |

| PRV-11      | 128500.00            | 2800.00            | 125700.00          | 2               |

| PRV-12      | 9200.00              | 300.00             | 8900.00            | 2               |

+-------------+----------------------+--------------------+--------------------+-----------------+





TASK 5: Dynamic Table Refresh Monitoring \& DAG Audit

\- Query `INFORMATION\_SCHEMA.DYNAMIC\_TABLE\_GRAPH\_HISTORY` / `DYNAMIC\_TABLE\_REFRESH\_HISTORY` 

&#x20; to verify that `DT\_PROVIDER\_FINANCIAL\_SUMMARY` executed incremental refreshes.



EXPECTED OUTPUT:

+------------------------------+-------------------+---------------+--------------------+

| DYNAMIC\_TABLE\_NAME           | REFRESH\_ACTION    | REFRESH\_MODE  | QUALIFIED\_STATUS   |

+------------------------------+-------------------+---------------+--------------------+

| DT\_PROVIDER\_FINANCIAL\_SUMMARY| REFRESH           | INCREMENTAL   | SUCCESS            |

+------------------------------+-------------------+---------------+--------------------+





TASK 6: End-to-End Pipeline Lineage \& Reconciliation Audit

\- Write an audit query confirming total billed values across Bronze, Silver, and Gold (Dynamic Table) 

&#x20; layers to ensure complete data integrity across transformations.



EXPECTED OUTPUT:

+-------------------+-------------------+-----------------+-------------------+

| BRONZE\_GROSS\_TOTAL| SILVER\_GROSS\_TOTAL| GOLD\_GROSS\_TOTAL| RECONCILED\_FLAG   |

+-------------------+-------------------+-----------------+-------------------+

| 250700.00         | 197700.00\*        | 152700.00\*\*     | TRUE              |

+-------------------+-------------------+-----------------+-------------------+

(\*Note: Silver reflects latest deduplicated states: 15000 + 8500 + 45000 + 3200 + 120000 + 6000 = 197700.00)

(\*\*Note: Gold reflects APPROVED claims only: 15000 + 8500 + 3200 + 120000 + 6000 = 152700.00)

