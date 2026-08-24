================================================================================

PROJECT 15: Cross-Border Logistics \& Fleet Telematics Lakehouse Platform

================================================================================

Target Modules: 4.4a (Schema-on-Read vs. Schema-on-Write) \& 4.4b (Medallion \& Time-Travel)

Environment: Snowflake SQL



\--------------------------------------------------------------------------------

1\. PROBLEM STATEMENT \& BUSINESS SCENARIO

\--------------------------------------------------------------------------------

You are a Lead Data Platform Engineer at a global logistics firm operating an 

IoT fleet management system. 



The edge IoT telematics sensors on trucks stream two types of JSON payloads into Snowflake:

1\. Telematics Ping Events (Location, speed, fuel consumption, driver metrics).

2\. Freight Delivery Clearance Events (Shipment IDs, duties, customs fees, border status).



The data platform follows a \*\*Medallion Architecture\*\*:

\- Bronze Layer (Schema-on-Read Data Lake): Raw, dynamic IoT JSON streams stored in 

&#x20; VARIANT columns.

\- Silver Layer (Schema-on-Write Lakehouse Core): Extracted, cleaned, type-validated 

&#x20; relational tables with calculated metrics (fuel cost, duty calculations) and PII masking.

\- Gold Layer (Business Analytics Mart): Executive dashboards tracking fleet efficiency 

&#x20; and customs duty payouts.



During operations, an IoT firmware update silently alters the payload structure (adding 

`driver\_fatigue\_score` and `border\_clearance\_code`), an invalid non-JSON payload enters 

the raw queue, and a rogue automation script accidentally wipes customs payout records 

in the Silver layer. You must build an end-to-end pipeline handling semi-structured ETL, 

schema evolution, error quarantine, and disaster recovery via Snowflake Time-Travel.



\--------------------------------------------------------------------------------

2\. INPUT DATASETS (RAW IoT STREAMING PAYLOADS)

\--------------------------------------------------------------------------------



Batch 1 Payload Stream (Standard Telematics \& Delivery Payloads):

\------------------------------------------------------------------

{"payload\_id":"PL-801","payload\_type":"TELEMATICS","timestamp":"2026-08-01T06:00:00Z","data":{"trip\_id":"TRP-101","vehicle\_id":"TRK-9001","driver\_name":"John Doe","distance\_km":450.0,"fuel\_consumed\_liters":120.0,"speed\_avg":75.0}}

{"payload\_id":"PL-802","payload\_type":"CUSTOMS","timestamp":"2026-08-01T06:30:00Z","data":{"shipment\_id":"SHP-5001","vehicle\_id":"TRK-9001","destination\_country":"CAN","declared\_value":85000.00,"duty\_pct":5.0,"clearance\_status":"CLEARED"}}

{"payload\_id":"PL-803","payload\_type":"TELEMATICS","timestamp":"2026-08-01T07:00:00Z","data":{"trip\_id":"TRP-102","vehicle\_id":"TRK-9002","driver\_name":"Jane Smith","distance\_km":620.0,"fuel\_consumed\_liters":180.0,"speed\_avg":82.0}}

{"payload\_id":"PL-804","payload\_type":"CUSTOMS","timestamp":"2026-08-01T07:45:00Z","data":{"shipment\_id":"SHP-5002","vehicle\_id":"TRK-9002","destination\_country":"MEX","declared\_value":42000.00,"duty\_pct":7.5,"clearance\_status":"CLEARED"}}



Batch 2 Payload Stream (Schema Evolution — New Telematics \& Customs Fields):

\-----------------------------------------------------------------------------

{"payload\_id":"PL-805","payload\_type":"TELEMATICS","timestamp":"2026-08-01T08:15:00Z","data":{"trip\_id":"TRP-103","vehicle\_id":"TRK-9003","driver\_name":"Robert Brown","distance\_km":310.0,"fuel\_consumed\_liters":95.0,"speed\_avg":68.0,"driver\_fatigue\_score":1.2}}

{"payload\_id":"PL-806","payload\_type":"CUSTOMS","timestamp":"2026-08-01T08:30:00Z","data":{"shipment\_id":"SHP-5003","vehicle\_id":"TRK-9003","destination\_country":"CAN","declared\_value":120000.00,"duty\_pct":4.0,"clearance\_status":"CLEARED","border\_clearance\_code":"FAST\_PASS\_01"}}

{"payload\_id":"PL-807","payload\_type":"CUSTOMS","timestamp":"2026-08-01T09:00:00Z","data":{"shipment\_id":"SHP-5004","vehicle\_id":"TRK-9001","destination\_country":"MEX","declared\_value":15000.00,"duty\_pct":7.5,"clearance\_status":"HELD\_INSPECTION","border\_clearance\_code":null}}



Batch 3 Payload Stream (Corrupted Payload \& Faulty Readings):

\--------------------------------------------------------------

{"payload\_id":"PL-808","payload\_type":"TELEMATICS","timestamp":"2026-08-01T09:30:00Z","data":{"trip\_id":"TRP-104","vehicle\_id":"TRK-9004","driver\_name":"Alice Green","distance\_km":0.0,"fuel\_consumed\_liters":0.0,"speed\_avg":0.0,"driver\_fatigue\_score":0.0}}

{"MALFORMED\_IOT\_SENSOR\_BINARY\_BURST\_DATA\_ERR"}



\--------------------------------------------------------------------------------

3\. STUDENT TASKS \& EXPECTED OUTPUTS

\--------------------------------------------------------------------------------



TASK 1: Bronze Data Lake Ingestion \& Schema-on-Read Exploration

\- Create Database: `LOGISTICS\_LAKEHOUSE\_DB`

\- Create Schema: `FLEET\_CORE`

\- Create Bronze table `BRONZE\_IOT\_STREAMS` (`INGEST\_ID`, `RAW\_PAYLOAD` VARIANT, `RECORDED\_AT`).

\- Ingest valid JSON records into `BRONZE\_IOT\_STREAMS`.

\- Write a Schema-on-Read query extracting `payload\_id`, `payload\_type`, `timestamp`, 

&#x20; vehicle identifiers, and shipment declared values.



EXPECTED OUTPUT (SELECT COUNT(\*) FROM BRONZE\_IOT\_STREAMS):

+-----------------------+

| TOTAL\_BRONZE\_RECORDS  |

+-----------------------+

| 8                     |

+-----------------------+





TASK 2: Dead-Letter Queue Quarantine Strategy

\- Create table `QUARANTINE\_IOT\_PAYLOADS` (`QUARANTINE\_ID`, `RAW\_RECORD\_TEXT`, `REASON`).

\- Use `TRY\_PARSE\_JSON` to intercept malformed binary/string entries and populate the quarantine table.



EXPECTED OUTPUT:

+---------------+----------------------------------------------+---------------------+

| QUARANTINE\_ID | RAW\_RECORD\_TEXT                              | REASON              |

+---------------+----------------------------------------------+---------------------+

| 1             | MALFORMED\_IOT\_SENSOR\_BINARY\_BURST\_DATA\_ERR  | MALFORMED\_JSON\_BODY |

+---------------+----------------------------------------------+---------------------+





TASK 3: Silver Layer ETL — Schema-on-Write Modeling \& Computations

\- Create Silver table `SILVER\_CUSTOMS\_CLEARANCE`:

&#x20; \* Columns: `SHIPMENT\_ID`, `PAYLOAD\_ID`, `VEHICLE\_ID`, `DESTINATION\_COUNTRY`, 

&#x20;   `DECLARED\_VALUE`, `DUTY\_PCT`, `DUTY\_AMOUNT\_DUE`, `BORDER\_CODE`, `CLEARANCE\_STATUS`

\- Build an ETL query targeting `payload\_type = 'CUSTOMS'`:

&#x20; \* Calculate `DUTY\_AMOUNT\_DUE = DECLARED\_VALUE \* (DUTY\_PCT / 100)`

&#x20; \* Extract `border\_clearance\_code` into `BORDER\_CODE` (handling missing schema fields as NULL).



EXPECTED OUTPUT:

+-------------+------------+---------------+-------------------+---------------+-----------------+---------------+------------------+

| SHIPMENT\_ID | VEHICLE\_ID | DEST\_COUNTRY  | DECLARED\_VALUE    | DUTY\_PCT      | DUTY\_AMOUNT\_DUE | BORDER\_CODE   | CLEARANCE\_STATUS |

+-------------+------------+---------------+-------------------+---------------+-----------------+---------------+------------------+

| SHP-5001    | TRK-9001   | CAN           | 85000.00          | 5.0           | 4250.00         | NULL          | CLEARED          |

| SHP-5002    | TRK-9002   | MEX           | 42000.00          | 7.5           | 3150.00         | NULL          | CLEARED          |

| SHP-5003    | TRK-9003   | CAN           | 120000.00         | 4.0           | 4800.00         | FAST\_PASS\_01  | CLEARED          |

| SHP-5004    | TRK-9001   | MEX           | 15000.00          | 7.5           | 1125.00         | NULL          | HELD\_INSPECTION  |

+-------------+------------+---------------+-------------------+---------------+-----------------+---------------+------------------+





TASK 4: Gold Layer Strategic Aggregations

\- Create Gold table `GOLD\_COUNTRY\_DUTY\_SUMMARY` summarizing metrics strictly for 

&#x20; shipments where `CLEARANCE\_STATUS = 'CLEARED'`.



EXPECTED OUTPUT:

+--------------+-----------------------+---------------------+-------------------+-------------------+

| DEST\_COUNTRY | TOTAL\_CLEARED\_VAL     | TOTAL\_DUTIES\_COLLECTED | AVG\_DUTY\_RATE\_PCT | CLEARED\_SHIPMENTS |

+--------------+-----------------------+---------------------+-------------------+-------------------+

| CAN          | 205000.00             | 9050.00             | 4.41              | 2                 |

| MEX          | 42000.00              | 3150.00             | 7.50              | 1                 |

+--------------+-----------------------+---------------------+-------------------+-------------------+





TASK 5: Disaster Recovery via Snowflake Time-Travel Auditing

1\. Simulate corruption: Run an unauthorized SQL command setting all `CAN` shipments 

&#x20;  in `SILVER\_CUSTOMS\_CLEARANCE` to `CLEARANCE\_STATUS = 'REJECTED'`.

2\. Write a Time-Travel query using `AT (OFFSET => ...)` or `BEFORE` to view the original values.

3\. Write a SQL recovery query restoring `SILVER\_CUSTOMS\_CLEARANCE` back to its 

&#x20;  uncorrupted state.



EXPECTED OUTPUT (Post-Recovery Audit Query):

+--------------+---------------------+----------------------+

| DEST\_COUNTRY | CLEARED\_COUNT       | REJECTED\_COUNT       |

+--------------+---------------------+----------------------+

| CAN          | 2                   | 0                    |

| MEX          | 1                   | 0                    |

+--------------+---------------------+----------------------+





TASK 6: End-to-End Pipeline Lineage \& Reconciliation Audit

Write a cross-layer audit query comparing declared values across Bronze, Silver, and Gold layers 

to verify pipeline completeness.



EXPECTED OUTPUT:

+-------------------+-------------------+-----------------+-------------------+

| BRONZE\_GROSS\_TOTAL| SILVER\_GROSS\_TOTAL| GOLD\_GROSS\_TOTAL| RECONCILED\_FLAG   |

+-------------------+-------------------+-----------------+-------------------+

| 262000.00         | 262000.00         | 247000.00\*      | TRUE              |

+-------------------+-------------------+-----------------+-------------------+

(\*Note: Gold totals include CLEARED shipments only: 205000 + 42000 = 247000.00)

