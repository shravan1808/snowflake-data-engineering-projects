PROJECT 11: Enterprise Customer Master Data Management using Hybrid SCD Strategies



Technology: Snowflake SQL

\------------------------------



1\. Problem Statement

\---------------------

An online retail company maintains customer information in a Snowflake Data Warehouse.

Customer attributes change over time, and management requires distinct tracking strategies depending on the attribute type\[cite: 129, 130, 214]:



1\. Operational Attributes (State): Overwritten directly when changes occur because prior state history is not required\[cite: 131].

2\. Tracked History Attributes (Segment): Retains complete historical row versions using effective date ranges and active record indicators\[cite: 133, 134, 135].

3\. Prior Value Attributes (City): Tracks current city and immediate prior city in a single row without creating extra versions\[cite: 215, 216].

4\. High-Value Hybrid Attributes (Membership): Combines current active value, immediate prior value, and historical point-in-time value across row versions\[cite: 217, 218].



Students must implement a unified Hybrid Dimension table in Snowflake SQL to handle all these requirements simultaneously\[cite: 130, 218].





2\. Business Scenario

\----------------------

Initially, the company has these customers:



101  Amit Sharma     Hyderabad   Telangana        Silver   Regular

102  Priya Reddy     Warangal    Telangana        Gold     Premium

103  Rahul Verma     Vijayawada  Andhra Pradesh   Silver   Regular

104  Neha Patel      Hyderabad   Telangana        Gold     Premium

105  Arjun Gupta     Nagpur      Maharashtra      Bronze   Regular



Later, the following updates arrive:



Customer 101:

City/State: Hyderabad, Telangana → Bengaluru, Karnataka

Membership: Silver → Gold

Segment: Regular → Premium

Effective Date: 2026-04-01



Customer 103:

City/State: Vijayawada, Andhra Pradesh → Chennai, Tamil Nadu

Membership: Silver → Gold

Segment: Regular → Premium

Effective Date: 2026-04-05



Customer 104:

Membership: Gold → Platinum

Effective Date: 2026-04-10





3\. Input Files

\--------------

customers\_initial.csv

\----------------------

customer\_id,customer\_name,city,state,membership,segment

101,Amit Sharma,Hyderabad,Telangana,Silver,Regular

102,Priya Reddy,Warangal,Telangana,Gold,Premium

103,Rahul Verma,Vijayawada,Andhra Pradesh,Silver,Regular

104,Neha Patel,Hyderabad,Telangana,Gold,Premium

105,Arjun Gupta,Nagpur,Maharashtra,Bronze,Regular





customer\_updates.csv

\---------------------

customer\_id,customer\_name,city,state,membership,segment,effective\_date

101,Amit Sharma,Bengaluru,Karnataka,Gold,Premium,2026-04-01

103,Rahul Verma,Chennai,Tamil Nadu,Gold,Premium,2026-04-05

104,Neha Patel,Hyderabad,Telangana,Platinum,Premium,2026-04-10





4\. Implementation Tasks

\------------------------



TASK 1 — Create Database and Schema

\------------------------------------





TASK 2 — Create Hybrid Dimension Table

\---------------------------------------

Required Columns:



| Column                | Purpose                                                    |

| --------------------- | ---------------------------------------------------------- |

| CUSTOMER\_KEY          | Surrogate key (Autoincrement)                              |

| CUSTOMER\_ID           | Business / Natural key                                     |

| CUSTOMER\_NAME         | Customer name                                              |

| CITY                  | Current city (Globally updated)                            |

| PREVIOUS\_CITY         | Immediate prior city                                       |

| STATE                 | Current state (Overwritten directly)                       |

| CURRENT\_MEMBERSHIP    | Current active membership (Globally updated across all rows)|

| PREVIOUS\_MEMBERSHIP   | Immediate prior membership                                 |

| HISTORICAL\_MEMBERSHIP | Slice membership value for this specific row version       |

| SEGMENT               | Historical customer segment                                |

| EFFECTIVE\_DATE        | Beginning date of record version                           |

| EXPIRY\_DATE           | Ending date of record version                              |

| IS\_CURRENT            | Active version indicator (TRUE / FALSE)                    |





TASK 3 — Load Initial Dimension Data

\------------------------------------



Expected Output:

\----------------

Initial Hybrid Dimension Data Loaded Successfully

Total Records = 5

Current Records = 5





TASK 4 — Display Initial Dimension State

\----------------------------------------



Expected Output:

\----------------

CUSTOMER\_ID  CUSTOMER\_NAME  CITY        PREVIOUS\_CITY  STATE           CURRENT\_MEMBERSHIP  PREVIOUS\_MEMBERSHIP  HISTORICAL\_MEMBERSHIP  SEGMENT  EFFECTIVE\_DATE  EXPIRY\_DATE  IS\_CURRENT

\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

101          Amit Sharma    Hyderabad   NULL           Telangana       Silver              NULL                 Silver                 Regular  2026-01-01      9999-12-31   TRUE

102          Priya Reddy    Warangal    NULL           Telangana       Gold                NULL                 Gold                   Premium  2026-01-01      9999-12-31   TRUE

103          Rahul Verma    Vijayawada  NULL           Andhra Pradesh  Silver              NULL                 Silver                 Regular  2026-01-01      9999-12-31   TRUE

104          Neha Patel     Hyderabad   NULL           Telangana       Gold                NULL                 Gold                   Premium  2026-01-01      9999-12-31   TRUE

105          Arjun Gupta    Nagpur      NULL           Maharashtra     Bronze              NULL                 Bronze                 Regular  2026-01-01      9999-12-31   TRUE





TASK 5 — Apply Hybrid Updates for Customers 101, 103, and 104

\-------------------------------------------------------------

Step 1: Expire active versions of updated customers.

Step 2: Insert new active versions.

Step 3: Synchronize global current \& prior attributes across all records.



Expected Output:

\----------------

number of rows updated: 1

number of rows updated: 1

number of rows updated: 1

number of rows inserted: 3

number of rows updated: 2

number of rows updated: 2

number of rows updated: 2



Hybrid SCD Updates Applied Successfully.

Total Records = 8

Current Records = 5

Historical Records = 3





TASK 6 — Display Complete Dimension History

\--------------------------------------------

Expected Output:

\----------------

CUSTOMER\_ID  CUSTOMER\_NAME  CITY       PREVIOUS\_CITY  STATE       CURRENT\_MEMBERSHIP  PREVIOUS\_MEMBERSHIP  HISTORICAL\_MEMBERSHIP  SEGMENT  EFFECTIVE\_DATE  EXPIRY\_DATE  IS\_CURRENT

\------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

101          Amit Sharma    Bengaluru  Hyderabad      Karnataka   Gold                Silver               Silver                 Regular  2026-01-01      2026-03-31   FALSE

101          Amit Sharma    Bengaluru  Hyderabad      Karnataka   Gold                Silver               Gold                   Premium  2026-04-01      9999-12-31   TRUE

102          Priya Reddy    Warangal   NULL           Telangana   Gold                NULL                 Gold                   Premium  2026-01-01      9999-12-31   TRUE

103          Rahul Verma    Chennai    Vijayawada     Tamil Nadu  Gold                Silver               Silver                 Regular  2026-01-01      2026-04-04   FALSE

103          Rahul Verma    Chennai    Vijayawada     Tamil Nadu  Gold                Silver               Gold                   Premium  2026-04-05      9999-12-31   TRUE

104          Neha Patel     Hyderabad  NULL           Telangana   Platinum            Gold                 Gold                   Premium  2026-01-01      2026-04-09   FALSE

104          Neha Patel     Hyderabad  NULL           Telangana   Platinum            Gold                 Platinum               Premium  2026-04-10      9999-12-31   TRUE

105          Arjun Gupta    Nagpur     NULL           Maharashtra Bronze              NULL                 Bronze                 Regular  2026-01-01      9999-12-31   TRUE





TASK 7 — Display Active Customer Report

\----------------------------------------

Expected Output:

\----------------

CUSTOMER\_ID  CUSTOMER\_NAME  CITY       PREVIOUS\_CITY  STATE       CURRENT\_MEMBERSHIP  PREVIOUS\_MEMBERSHIP  SEGMENT

\------------------------------------------------------------------------------------------------------------------

101          Amit Sharma    Bengaluru  Hyderabad      Karnataka   Gold                Silver               Premium

102          Priya Reddy    Warangal   NULL           Telangana   Gold                NULL                 Premium

103          Rahul Verma    Chennai    Vijayawada     Tamil Nadu  Gold                Silver               Premium

104          Neha Patel     Hyderabad  NULL           Telangana   Platinum            Gold                 Premium

105          Arjun Gupta    Nagpur     NULL           Maharashtra Bronze              NULL                 Regular





TASK 8 — Point-in-Time Historical Query

\----------------------------------------

Management asks:

"What was Customer 101's historical membership, segment, and city on March 15, 2026?"



Expected Output:

\----------------

CUSTOMER\_ID  CUSTOMER\_NAME  CITY       HISTORICAL\_MEMBERSHIP  SEGMENT  EFFECTIVE\_DATE  EXPIRY\_DATE

\----------------------------------------------------------------------------------------------------

101          Amit Sharma    Bengaluru  Silver                 Regular  2026-01-01      2026-03-31











TASK 9 — Metric Validation and Record Counts

\--------------------------------------------

Expected Output:

\----------------

METRIC                   VALUE

\------------------------------

TOTAL RECORD COUNT       8

CURRENT RECORD COUNT     5

HISTORICAL RECORD COUNT  3

