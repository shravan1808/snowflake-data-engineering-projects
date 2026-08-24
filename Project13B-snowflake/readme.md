================================================================================

PROJECT 13B: Healthcare Analytics Warehouse — Star Schema vs. Snowflake Schema

================================================================================

Technology: Snowflake SQL

Target Modules Covered: 4.3a (Star Schema Architecture \& Flat Joins), 4.3b (Snowflake Schema \& Normalized Hierarchies)



================================================================================

1\. PROBLEM STATEMENT

================================================================================

A healthcare organization manages patient claims, hospital networks, and medical treatments.

The enterprise architecture team needs to evaluate two competing Data Warehouse designs:



1\. Star Schema (Module 4.3a):

&#x20;  - Flat, denormalized dimension tables directly connected to the central `FACT\_CLAIMS` table.

&#x20;  - Designed for fast dashboarding, simple BI query generation, and 1-hop join performance.



2\. Snowflake Schema (Module 4.3b):

&#x20;  - Fully normalized dimension hierarchies.

&#x20;  - Hospital hierarchy split across `DIM\_STATE` -> `DIM\_HOSPITAL\_NETWORK` -> `DIM\_HOSPITAL`.

&#x20;  - Treatment hierarchy split across `DIM\_DIAGNOSIS\_GROUP` -> `DIM\_TREATMENT`.

&#x20;  - Designed to eliminate attribute redundancy and streamline master data updates.



Students must build both schema architectures, populate them with incoming datasets, and run specialized analytics tasks to evaluate structural and operational differences.





================================================================================

2\. BUSINESS SCENARIO

================================================================================

Hospitals and Networks:

\- Network 10: Apollo Healthcare Group (Headquarters: Telangana, Manager: Dr. Ramesh)

&#x20; \* Hospital 1001: Apollo Jubilee Hills (Hyderabad, Telangana)

&#x20; \* Hospital 1002: Apollo Reach (Warangal, Telangana)

\- Network 20: Manipal Hospitals (Headquarters: Karnataka, Manager: Dr. Priya)

&#x20; \* Hospital 2001: Manipal Central (Bengaluru, Karnataka)



Medical Treatments:

\- Diagnosis Group: Cardiology

&#x20; \* Treatment 501: Coronary Angioplasty (Base Cost: 150,000.00)

\- Diagnosis Group: Orthopedics

&#x20; \* Treatment 502: Knee Replacement (Base Cost: 220,000.00)

\- Diagnosis Group: General Surgery

&#x20; \* Treatment 503: Appendectomy (Base Cost: 45,000.00)



Patient Claims:

\- Patients file medical insurance claims across various hospitals and treatments.





================================================================================

3\. INPUT DATASETS (4 SOURCE CSV FILES)

================================================================================



\--- FILE 1: hospital\_hierarchy.csv ---

hospital\_id,hospital\_name,city,state,network\_id,network\_name,network\_director

1001,Apollo Jubilee Hills,Hyderabad,Telangana,10,Apollo Healthcare Group,Dr. Ramesh

1002,Apollo Reach,Warangal,Telangana,10,Apollo Healthcare Group,Dr. Ramesh

2001,Manipal Central,Bengaluru,Karnataka,20,Manipal Hospitals,Dr. Priya



\--- FILE 2: treatment\_hierarchy.csv ---

treatment\_id,treatment\_name,diagnosis\_group\_id,diagnosis\_group\_name,standard\_cost

501,Coronary Angioplasty,DG-CARD,Cardiology,150000.00

502,Knee Replacement,DG-ORTH,Orthopedics,220000.00

503,Appendectomy,DG-SURG,General Surgery,45000.00



\--- FILE 3: patients.csv ---

patient\_id,patient\_name,gender,age,city

701,Suresh Kumar,Male,54,Hyderabad

702,Anitha Reddy,Female,42,Warangal

703,Venkatesh Rao,Male,61,Bengaluru



\--- FILE 4: insurance\_claims.csv ---

claim\_id,claim\_date,patient\_id,hospital\_id,treatment\_id,claimed\_amount,approved\_amount

CLM-9001,2026-06-01,701,1001,501,160000.00,150000.00

CLM-9002,2026-06-05,702,1002,503,50000.00,45000.00

CLM-9003,2026-06-10,703,2001,502,230000.00,22000.00

CLM-9004,2026-06-12,701,1001,503,48000.00,45000.00





================================================================================

4\. IMPLEMENTATION TASKS FOR STUDENTS \& EXPECTED OUTPUTS

================================================================================



\--------------------------------------------------------------------------------

TASK 1 — Create Environment Context

\--------------------------------------------------------------------------------

Task Instruction:

Write Snowflake SQL commands to create database `HEALTHCARE\_DW` and schema `SCHEMA\_COMPARE\_LAB`, then set context to this schema.



EXPECTED OUTPUT:

\-------------------------------------------------

Statement executed successfully.

Current database: HEALTHCARE\_DW

Current schema: SCHEMA\_COMPARE\_LAB

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 2 — Build Star Schema Denormalized Hospital Dimension (`STAR\_DIM\_HOSPITAL`)

\--------------------------------------------------------------------------------

Task Instruction:

Create `STAR\_DIM\_HOSPITAL` combining hospital details, network names, and network directors into one single table with a surrogate key.



| Column Name      | Data Type    | Constraint                 |

| :--------------- | :----------- | :------------------------- |

| HOSPITAL\_KEY     | NUMBER       | AUTOINCREMENT, PRIMARY KEY |

| HOSPITAL\_ID      | NUMBER       | Business Key               |

| HOSPITAL\_NAME    | VARCHAR(100) | Hospital Name              |

| CITY             | VARCHAR(50)  | City                       |

| STATE            | VARCHAR(50)  | State                      |

| NETWORK\_NAME     | VARCHAR(100) | Network Name               |

| NETWORK\_DIRECTOR | VARCHAR(100) | Regional Network Director  |



EXPECTED OUTPUT:

\-------------------------------------------------

Table STAR\_DIM\_HOSPITAL successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 3 — Build Star Schema Denormalized Treatment Dimension (`STAR\_DIM\_TREATMENT`)

\--------------------------------------------------------------------------------

Task Instruction:

Create `STAR\_DIM\_TREATMENT` flattening treatment information and medical diagnosis groups into one table.



| Column Name          | Data Type    | Constraint                 |

| :------------------- | :----------- | :------------------------- |

| TREATMENT\_KEY        | NUMBER       | AUTOINCREMENT, PRIMARY KEY |

| TREATMENT\_ID         | NUMBER       | Business Key               |

| TREATMENT\_NAME       | VARCHAR(100) | Procedure Name             |

| DIAGNOSIS\_GROUP\_NAME | VARCHAR(50)  | Medical Group Specialty    |

| STANDARD\_COST        | NUMBER(12,2) | Benchmark Cost             |



EXPECTED OUTPUT:

\-------------------------------------------------

Table STAR\_DIM\_TREATMENT successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 4 — Load Star Schema Dimension Data

\--------------------------------------------------------------------------------

Task Instruction:

Write INSERT statements to load records into `STAR\_DIM\_HOSPITAL` (from `hospital\_hierarchy.csv`) and `STAR\_DIM\_TREATMENT` (from `treatment\_hierarchy.csv`).



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 3 (STAR\_DIM\_HOSPITAL)

number of rows inserted: 3 (STAR\_DIM\_TREATMENT)

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 5 — Build \& Load Star Schema Claims Fact Table (`STAR\_FACT\_CLAIMS`)

\--------------------------------------------------------------------------------

Task Instruction:

Create `STAR\_FACT\_CLAIMS` linked via foreign keys to `STAR\_DIM\_HOSPITAL` and `STAR\_DIM\_TREATMENT`. Load all 4 records from `insurance\_claims.csv`.



| Column Name     | Data Type    | Reference                         |

| :-------------- | :----------- | :-------------------------------- |

| CLAIM\_KEY       | NUMBER       | AUTOINCREMENT, PRIMARY KEY        |

| CLAIM\_ID        | VARCHAR(50)  | Claim Business ID                 |

| CLAIM\_DATE      | DATE         | Date of Claim                     |

| PATIENT\_ID      | NUMBER       | Natural Patient Key               |

| HOSPITAL\_KEY    | NUMBER       | Foreign Key -> STAR\_DIM\_HOSPITAL  |

| TREATMENT\_KEY   | NUMBER       | Foreign Key -> STAR\_DIM\_TREATMENT |

| CLAIMED\_AMOUNT  | NUMBER(12,2) | Total Billed                      |

| APPROVED\_AMOUNT | NUMBER(12,2) | Total Approved                    |



EXPECTED OUTPUT:

\-------------------------------------------------

Table STAR\_FACT\_CLAIMS successfully created.

number of rows inserted: 4

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 6 — Build Normalized Snowflake Schema Hospital Hierarchy

\--------------------------------------------------------------------------------

Task Instruction:

Decompose the hospital domain into two normalized tables to eliminate network director repetition:

1\. `SNOW\_DIM\_NETWORK`: `NETWORK\_KEY` (PK), `NETWORK\_ID`, `NETWORK\_NAME`, `NETWORK\_DIRECTOR`

2\. `SNOW\_DIM\_HOSPITAL`: `HOSPITAL\_KEY` (PK), `HOSPITAL\_ID`, `HOSPITAL\_NAME`, `CITY`, `STATE`, `NETWORK\_KEY` (FK -> SNOW\_DIM\_NETWORK)



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_DIM\_NETWORK successfully created.

Table SNOW\_DIM\_HOSPITAL successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 7 — Build Normalized Snowflake Schema Treatment Hierarchy

\--------------------------------------------------------------------------------

Task Instruction:

Decompose the medical procedure domain into two normalized tables:

1\. `SNOW\_DIM\_DIAGNOSIS\_GROUP`: `DIAGNOSIS\_GROUP\_KEY` (PK), `DIAGNOSIS\_GROUP\_ID`, `DIAGNOSIS\_GROUP\_NAME`

2\. `SNOW\_DIM\_TREATMENT`: `TREATMENT\_KEY` (PK), `TREATMENT\_ID`, `TREATMENT\_NAME`, `STANDARD\_COST`, `DIAGNOSIS\_GROUP\_KEY` (FK -> SNOW\_DIM\_DIAGNOSIS\_GROUP)



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_DIM\_DIAGNOSIS\_GROUP successfully created.

Table SNOW\_DIM\_TREATMENT successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 8 — Populate Snowflake Schema Normalized Hierarchies

\--------------------------------------------------------------------------------

Task Instruction:

Write INSERT queries to populate `SNOW\_DIM\_NETWORK`, `SNOW\_DIM\_HOSPITAL`, `SNOW\_DIM\_DIAGNOSIS\_GROUP`, and `SNOW\_DIM\_TREATMENT` while linking appropriate foreign keys.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 2 (SNOW\_DIM\_NETWORK)

number of rows inserted: 3 (SNOW\_DIM\_HOSPITAL)

number of rows inserted: 3 (SNOW\_DIM\_DIAGNOSIS\_GROUP)

number of rows inserted: 3 (SNOW\_DIM\_TREATMENT)

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 9 — Build \& Load Snowflake Schema Claims Fact Table (`SNOW\_FACT\_CLAIMS`)

\--------------------------------------------------------------------------------

Task Instruction:

Create `SNOW\_FACT\_CLAIMS` with foreign key constraints referencing `SNOW\_DIM\_HOSPITAL` and `SNOW\_DIM\_TREATMENT`. Load the 4 claim records into the table.



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_FACT\_CLAIMS successfully created.

number of rows inserted: 4

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 10 — Star Schema Specialty Claims Analysis (Flat 1-Hop Query)

\--------------------------------------------------------------------------------

Task Instruction:

Write a query against the \*\*Star Schema\*\* summarizing Total Claimed Amount and Total Approved Amount by `DIAGNOSIS\_GROUP\_NAME`.



EXPECTED OUTPUT:

\------------------------------------------------------------------------

DIAGNOSIS\_GROUP\_NAME  TOTAL\_CLAIMED\_AMOUNT  TOTAL\_APPROVED\_AMOUNT

\------------------------------------------------------------------------

Cardiology            160000.00             150000.00

General Surgery       98000.00              90000.00

Orthopedics           230000.00             220000.00

\------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 11 — Snowflake Schema Specialty Claims Analysis (Multi-Hop Join Query)

\--------------------------------------------------------------------------------

Task Instruction:

Write a query against the \*\*Snowflake Schema\*\* returning the exact same financial summary by traversing from `SNOW\_FACT\_CLAIMS` -> `SNOW\_DIM\_TREATMENT` -> `SNOW\_DIM\_DIAGNOSIS\_GROUP`.



EXPECTED OUTPUT:

\------------------------------------------------------------------------

DIAGNOSIS\_GROUP\_NAME  TOTAL\_CLAIMED\_AMOUNT  TOTAL\_APPROVED\_AMOUNT

\------------------------------------------------------------------------

Cardiology            160000.00             150000.00

General Surgery       98000.00              90000.00

Orthopedics           230000.00             220000.00

\------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 12 — Hospital Network Director Performance Report

\--------------------------------------------------------------------------------

Task Instruction:

Write a query against both schemas to evaluate total claims handled under each `NETWORK\_DIRECTOR`.



EXPECTED OUTPUT:

\-------------------------------------------------------------------

NETWORK\_DIRECTOR  TOTAL\_CLAIMS\_HANDLED  TOTAL\_APPROVED\_AMOUNT

\-------------------------------------------------------------------

Dr. Ramesh        3                     285000.00

Dr. Priya         1                     220000.00

\-------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 13 — Data Anomaly Analysis: Master Data Update Test (Network Director Update)

\--------------------------------------------------------------------------------

Task Instruction:

Assume Dr. Ramesh is replaced by `'Dr. Anand'` for Apollo Healthcare Group (Network 10).

\- In the Star Schema, how many rows in `STAR\_DIM\_HOSPITAL` must be updated?

\- In the Snowflake Schema, how many rows in `SNOW\_DIM\_NETWORK` must be updated?

Students must write a brief verification SQL script proving the update effort difference.



EXPECTED OUTPUT:

\-----------------------------------------------------------------------------

SCHEMA\_TYPE       UPDATED\_TABLE      ROWS\_UPDATED  MAINTENANCE\_EFFORT

\-----------------------------------------------------------------------------

Star Schema       STAR\_DIM\_HOSPITAL  2             Higher (Multiple rows)

Snowflake Schema  SNOW\_DIM\_NETWORK   1             Lower (Single row)

\-----------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 14 — Full Architecture Record Audit \& Schema Comparison

\--------------------------------------------------------------------------------

Task Instruction:

Write a single SQL query using `UNION ALL` to verify record counts across all Star Schema and Snowflake Schema dimension and fact tables.



EXPECTED OUTPUT:

\-------------------------------------------------------

SCHEMA\_TYPE       TABLE\_NAME                 RECORD\_COUNT

\-------------------------------------------------------

Star Schema       STAR\_DIM\_HOSPITAL          3

Star Schema       STAR\_DIM\_TREATMENT         3

Star Schema       STAR\_FACT\_CLAIMS           4

Snowflake Schema  SNOW\_DIM\_NETWORK           2

Snowflake Schema  SNOW\_DIM\_HOSPITAL          3

Snowflake Schema  SNOW\_DIM\_DIAGNOSIS\_GROUP   3

Snowflake Schema  SNOW\_DIM\_TREATMENT         3

Snowflake Schema  SNOW\_FACT\_CLAIMS           4

\-------------------------------------------------------

