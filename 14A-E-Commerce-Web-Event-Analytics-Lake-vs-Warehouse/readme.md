================================================================================

PROJECT 14A: E-Commerce Web Event Analytics — Data Lake vs. Warehouse Ingestion

================================================================================

Target Module: 4.4a (DW vs. Data Lake: Schema-on-Read vs. Schema-on-Write)

Environment: Snowflake SQL



\--------------------------------------------------------------------------------

1\. PROBLEM STATEMENT \& BUSINESS SCENARIO

\--------------------------------------------------------------------------------

You are a Data Engineer at an e-commerce platform. The system generates web 

clickstream events (page views, cart updates, and purchases). 



The platform architecture team is testing two storage paradigms:

1\. Data Lake Layer (Schema-on-Read): Raw JSON payloads are ingested directly 

&#x20;  into a Snowflake VARIANT column without pre-defining a strict schema.

2\. Data Warehouse Layer (Schema-on-Write): Data is extracted, transformed, 

&#x20;  and loaded into structured relational tables with strict data types.



During operation, the marketing team introduces a schema change (adding 

`promo\_code` and `discount\_amount`) in Batch 2 without notifying the data team, 

and a corrupted payload enters Batch 3. You must demonstrate how both layers 

handle schema evolution, error handling, analytics, and warehouse backfilling.



\--------------------------------------------------------------------------------

2\. INPUT DATASETS (JSON PAYLOADS TO INGEST)

\--------------------------------------------------------------------------------



Batch 1 Events (Standard Structure):

\----------------------------------

{"event\_id":"EVT-8001","timestamp":"2026-07-01T08:15:00Z","user\_id":1001,"page":"checkout","action":"purchase","order":{"total":12500.00,"shipping\_cost":250.00,"tax":625.00,"items":2}}

{"event\_id":"EVT-8002","timestamp":"2026-07-01T08:20:00Z","user\_id":1002,"page":"product\_detail","action":"view","order":null}

{"event\_id":"EVT-8003","timestamp":"2026-07-01T08:35:00Z","user\_id":1003,"page":"cart","action":"add\_to\_cart","order":null}

{"event\_id":"EVT-8004","timestamp":"2026-07-01T09:10:00Z","user\_id":1004,"page":"checkout","action":"purchase","order":{"total":45000.00,"shipping\_cost":500.00,"tax":2250.00,"items":5}}

{"event\_id":"EVT-8005","timestamp":"2026-07-01T09:45:00Z","user\_id":1001,"page":"product\_detail","action":"view","order":null}



Batch 2 Events (Schema Evolution — New Fields Added):

\--------------------------------------------------

{"event\_id":"EVT-8006","timestamp":"2026-07-02T10:00:00Z","user\_id":1005,"page":"checkout","action":"purchase","order":{"total":18000.00,"shipping\_cost":300.00,"tax":900.00,"items":3},"promo\_code":"SUMMER20","discount\_amount":3600.00}

{"event\_id":"EVT-8007","timestamp":"2026-07-02T10:15:00Z","user\_id":1002,"page":"checkout","action":"purchase","order":{"total":8500.00,"shipping\_cost":150.00,"tax":425.00,"items":1},"promo\_code":"WELCOME10","discount\_amount":850.00}

{"event\_id":"EVT-8008","timestamp":"2026-07-02T10:30:00Z","user\_id":1006,"page":"cart","action":"add\_to\_cart","order":null,"promo\_code":null,"discount\_amount":0.00}

{"event\_id":"EVT-8009","timestamp":"2026-07-02T11:00:00Z","user\_id":1003,"page":"checkout","action":"purchase","order":{"total":32000.00,"shipping\_cost":400.00,"tax":1600.00,"items":4},"promo\_code":"FESTIVE15","discount\_amount":4800.00}

{"event\_id":"EVT-8010","timestamp":"2026-07-02T11:20:00Z","user\_id":1007,"page":"product\_detail","action":"view","order":null,"promo\_code":null,"discount\_amount":0.00}



Batch 3 Events (Edge Cases \& Corrupted Records):

\------------------------------------------------

{"event\_id":"EVT-8011","timestamp":"2026-07-03T12:00:00Z","user\_id":1008,"page":"checkout","action":"purchase","order":{"total":0.00,"shipping\_cost":0.00,"tax":0.00,"items":0},"promo\_code":"FREEPASS","discount\_amount":0.00}

{"event\_id":"INVALID\_JSON\_PAYLOAD\_MALFORMED\_STRING"}



\--------------------------------------------------------------------------------

3\. STUDENT TASKS \& EXPECTED OUTPUTS

\--------------------------------------------------------------------------------



TASK 1: Data Lake Ingestion

\- Ingest valid JSON strings into table `LAKE\_RAW\_EVENTS`.



EXPECTED OUTPUT (SELECT COUNT(\*) FROM LAKE\_RAW\_EVENTS):

+---------------------+

| TOTAL\_RAW\_RECORD\_CT |

+---------------------+

| 11                  |

+---------------------+





TASK 2: Schema-on-Read Ingestion \& Extraction

\- Query `LAKE\_RAW\_EVENTS` extracting semi-structured JSON attributes.



EXPECTED OUTPUT:

+----------+----------------------+---------+-------------+-------------+------------+

| EVENT\_ID | EVENT\_TIME           | USER\_ID | ACTION      | ORDER\_TOTAL | PROMO\_CODE |

+----------+----------------------+---------+-------------+-------------+------------+

| EVT-8001 | 2026-07-01 08:15:00  | 1001    | purchase    | 12500.00    | NULL       |

| EVT-8002 | 2026-07-01 08:20:00  | 1002    | view        | NULL        | NULL       |

| EVT-8003 | 2026-07-01 08:35:00  | 1003    | add\_to\_cart | NULL        | NULL       |

| EVT-8004 | 2026-07-01 09:10:00  | 1004    | purchase    | 45000.00    | NULL       |

| EVT-8005 | 2026-07-01 09:45:00  | 1001    | view        | NULL        | NULL       |

| EVT-8006 | 2026-07-02 10:00:00  | 1005    | purchase    | 18000.00    | SUMMER20   |

| EVT-8007 | 2026-07-02 10:15:00  | 1002    | purchase    | 8500.00     | WELCOME10  |

| EVT-8008 | 2026-07-02 10:30:00  | 1006    | add\_to\_cart | NULL        | NULL       |

| EVT-8009 | 2026-07-02 11:00:00  | 1003    | purchase    | 32000.00    | FESTIVE15  |

| EVT-8010 | 2026-07-02 11:20:00  | 1007    | view        | NULL        | NULL       |

| EVT-8011 | 2026-07-03 12:00:00  | 1008    | purchase    | 0.00        | FREEPASS   |

+----------+----------------------+---------+-------------+-------------+------------+





TASK 3: Schema-on-Read Financial Analysis

\- Calculate `NET\_REVENUE` for orders where `total > 0`.

\- Formula: `NET\_REVENUE = ORDER\_TOTAL - SHIPPING\_COST - TAX - COALESCE(DISCOUNT\_AMOUNT, 0)`



EXPECTED OUTPUT:

+----------+-------------+---------------+---------+-----------------+-------------+

| EVENT\_ID | ORDER\_TOTAL | SHIPPING\_COST | TAX     | DISCOUNT\_AMOUNT | NET\_REVENUE |

+----------+-------------+---------------+---------+-----------------+-------------+

| EVT-8001 | 12500.00    | 250.00        | 625.00  | 0.00            | 11625.00    |

| EVT-8004 | 45000.00    | 500.00        | 2250.00 | 0.00            | 42250.00    |

| EVT-8006 | 18000.00    | 300.00        | 900.00  | 3600.00         | 13200.00    |

| EVT-8007 | 8500.00     | 150.00        | 425.00  | 850.00          | 7075.00     |

| EVT-8009 | 32000.00    | 400.00        | 1600.00 | 4800.00         | 25200.00    |

+----------+-------------+---------------+---------+-----------------+-------------+





TASK 4: Funnel \& Conversion Key Metrics

\- Compute high-level business KPIs across valid non-zero events.



EXPECTED OUTPUT:

+--------------+-----------------+--------------------+---------------------+---------------------+

| TOTAL\_EVENTS | TOTAL\_PURCHASES | CONVERSION\_RATE\_PCT| TOTAL\_GROSS\_REVENUE | AVERAGE\_ORDER\_VALUE |

+--------------+-----------------+--------------------+---------------------+---------------------+

| 11           | 5               | 45.45              | 116000.00           | 23200.00            |

+--------------+-----------------+--------------------+---------------------+---------------------+





TASK 5: Data Warehouse Backfill (Schema-on-Write)

\- Insert valid extracted payloads into `DW\_STRUCTURED\_EVENTS`.



EXPECTED OUTPUT (SELECT COUNT(\*), SUM(NET\_REVENUE) FROM DW\_STRUCTURED\_EVENTS):

+--------------------+-------------------+

| STORED\_RECORDS\_QTY | TOTAL\_NET\_REVENUE |

+--------------------+-------------------+

| 11                 | 99350.00          |

+--------------------+-------------------+





TASK 6: Data Integrity \& Error Quarantine Strategy

\- Identify and move corrupt non-JSON records into `QUARANTINE\_RAW\_EVENTS`.



EXPECTED OUTPUT:

+-------------------+---------------------------------------------+---------------------+

| QUARANTINE\_ID     | RAW\_RECORD\_TEXT                             | REASON              |

+-------------------+---------------------------------------------+---------------------+

| 1                 | INVALID\_JSON\_PAYLOAD\_MALFORMED\_STRING       | MALFORMED\_JSON\_BODY |

+-------------------+---------------------------------------------+---------------------+

