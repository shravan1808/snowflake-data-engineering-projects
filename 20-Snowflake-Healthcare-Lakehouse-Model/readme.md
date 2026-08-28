================================================================================
PROJECT 20A: Healthcare Lakehouse Engine — Role-Playing, Hierarchies & Delta Lake
================================================================================
Target Schedule: Week 3 — Day 12 (Topics M6–M10)
Target Topics: Role-Playing Dimensions, Bridge Tables, Parent-Child Hierarchies,Delta Lake Table Operations, Time Travel & Schema Evolution

Environment: PySpark SQL / Databricks Delta Lake / Snowflake SQL
--------------------------------------------------------------------------------
1. PROBLEM STATEMENT & BUSINESS SCENARIO
--------------------------------------------------------------------------------
You are a Senior Data Engineer constructing a Healthcare Lakehouse platform. The hospital 
network requires tracking patient visits, diagnosis trees (parent-child disease hierarchies), 
multi-specialty doctor assignments (multi-valued bridge attributes), and multiple date 
perspectives (Admit Date, Discharge Date, Billing Date) off a single Date Dimension.

You are tasked with implementing Delta Lake / Lakehouse tables, handling schema 
evolution, writing MERGE statements, and modeling complex relational hierarchies.

--------------------------------------------------------------------------------
2. INPUT DATASETS (20–30 RECORDS EACH)
--------------------------------------------------------------------------------

Dim Date Master (`dim_date.csv`):
---------------------------------
date_key,full_date,year,quarter,month_name,is_weekend
20260801,2026-08-01,2026,Q3,August,Y
20260802,2026-08-02,2026,Q3,August,Y
20260803,2026-08-03,2026,Q3,August,N
20260804,2026-08-04,2026,Q3,August,N
20260805,2026-08-05,2026,Q3,August,N
20260806,2026-08-06,2026,Q3,August,N
20260807,2026-08-07,2026,Q3,August,N
20260808,2026-08-08,2026,Q3,August,Y
20260809,2026-08-09,2026,Q3,August,Y
20260810,2026-08-10,2026,Q3,August,N
20260811,2026-08-11,2026,Q3,August,N
20260812,2026-08-12,2026,Q3,August,N
20260813,2026-08-13,2026,Q3,August,N
20260814,2026-08-14,2026,Q3,August,N
20260815,2026-08-15,2026,Q3,August,Y
20260816,2026-08-16,2026,Q3,August,Y
20260817,2026-08-17,2026,Q3,August,N
20260818,2026-08-18,2026,Q3,August,N
20260819,2026-08-19,2026,Q3,August,N
20260820,2026-08-20,2026,Q3,August,N
20260821,2026-08-21,2026,Q3,August,N
20260822,2026-08-22,2026,Q3,August,Y
20260823,2026-08-23,2026,Q3,August,Y
20260824,2026-08-24,2026,Q3,August,N
20260825,2026-08-25,2026,Q3,August,N

ICD Diagnosis Parent-Child Hierarchy (`dim_diagnosis_hierarchy.csv`):
--------------------------------------------------------------------
diagnosis_id,diagnosis_name,parent_diagnosis_id,category_level
ICD-1000,Respiratory System,NULL,1
ICD-1100,Infectious Respiratory,ICD-1000,2
ICD-1110,Acute Bronchitis,ICD-1100,3
ICD-1120,Pneumonia,ICD-1100,3
ICD-1200,Chronic Respiratory,ICD-1000,2
ICD-1210,Asthma,ICD-1200,3
ICD-1220,COPD,ICD-1200,3
ICD-2000,Cardiovascular System,NULL,1
ICD-2100,Ischemic Heart Disease,ICD-2000,2
ICD-2110,Acute Myocardial Infarction,ICD-2100,3
ICD-2120,Angina Pectoris,ICD-2100,3
ICD-2200,Hypertensive Disease,ICD-2000,2
ICD-2210,Essential Hypertension,ICD-2200,3
ICD-3000,Digestive System,NULL,1
ICD-3100,Gastrointestinal,ICD-3000,2
ICD-3110,Gastritis,ICD-3100,3
ICD-3120,Gastroenteritis,ICD-3100,3
ICD-4000,Nervous System,NULL,1
ICD-4100,Central Nervous System,ICD-4000,2
ICD-4110,Migraine,ICD-4100,3
ICD-4120,Epilepsy,ICD-4100,3

Patient Encounters (`raw_encounters.csv`):
------------------------------------------
encounter_id,patient_id,admit_date_key,discharge_date_key,billing_date_key,primary_diag_id,total_cost
ENC-801,PAT-10,20260801,20260804,20260806,ICD-1110,4500.00
ENC-802,PAT-11,20260801,20260805,20260808,ICD-2110,12000.00
ENC-803,PAT-12,20260802,20260806,20260809,ICD-1120,3200.00
ENC-804,PAT-13,20260802,20260803,20260805,ICD-2210,1800.00
ENC-805,PAT-14,20260803,20260807,20260810,ICD-3110,2900.00
ENC-806,PAT-15,20260803,20260808,20260812,ICD-1210,5100.00
ENC-807,PAT-16,20260804,20260809,20260811,ICD-2120,8400.00
ENC-808,PAT-17,20260805,20260807,20260810,ICD-4110,1500.00
ENC-809,PAT-18,20260805,20260810,20260814,ICD-1220,9500.00
ENC-810,PAT-19,20260806,20260811,20260815,ICD-3120,3800.00
ENC-811,PAT-20,20260807,20260812,20260816,ICD-4120,6200.00
ENC-812,PAT-21,20260808,20260811,20260813,ICD-1110,2200.00
ENC-813,PAT-22,20260809,20260815,20260818,ICD-2110,14500.00
ENC-814,PAT-23,20260810,20260814,20260817,ICD-1120,4100.00
ENC-815,PAT-24,20260810,20260812,20260815,ICD-2210,1950.00
ENC-816,PAT-25,20260811,20260816,20260820,ICD-3110,3100.00
ENC-817,PAT-26,20260812,20260817,20260821,ICD-1210,4800.00
ENC-818,PAT-27,20260813,20260818,20260822,ICD-2120,7900.00
ENC-819,PAT-28,20260814,20260816,20260819,ICD-4110,1650.00
ENC-820,PAT-29,20260815,20260820,20260824,ICD-1220,10200.00

Bridge Encounter Doctors (`bridge_encounter_doctors.csv`):
------------------------------------------------------------
encounter_id,doctor_id,weight_factor
ENC-801,DOC-1,0.60
ENC-801,DOC-2,0.40
ENC-802,DOC-2,0.70
ENC-802,DOC-3,0.30
ENC-803,DOC-1,0.50
ENC-803,DOC-3,0.50
ENC-804,DOC-4,1.00
ENC-805,DOC-5,0.80
ENC-805,DOC-1,0.20
ENC-806,DOC-2,0.50
ENC-806,DOC-4,0.50
ENC-807,DOC-3,0.60
ENC-807,DOC-5,0.40
ENC-808,DOC-1,1.00
ENC-809,DOC-2,0.80
ENC-809,DOC-3,0.20
ENC-810,DOC-4,0.50
ENC-810,DOC-5,0.50
ENC-811,DOC-1,0.70
ENC-811,DOC-2,0.30
ENC-812,DOC-3,1.00
ENC-813,DOC-2,0.60
ENC-813,DOC-4,0.40
ENC-814,DOC-5,0.50
ENC-814,DOC-1,0.50
ENC-815,DOC-3,1.00

--------------------------------------------------------------------------------
3. STUDENT TASKS & EXPECTED OUTPUTS
--------------------------------------------------------------------------------

TASK 1: Delta Lake Table Creation & Lakehouse Storage Setup
- Create Delta Lake table `FACT_PATIENT_ENCOUNTERS` partitioned by `admit_date_key`.

EXPECTED OUTPUT:
+------------------------+-------------------+
| TABLE_NAME             | STORAGE_FORMAT    |
+------------------------+-------------------+
| FACT_PATIENT_ENCOUNTERS| DELTA             |
+------------------------+-------------------+


TASK 2: Role-Playing Dimension Views Implementation
- Create 3 SQL views referencing `dim_date.csv` for role-playing roles:
  * `VIEW_ADMIT_DATE`
  * `VIEW_DISCHARGE_DATE`
  * `VIEW_BILLING_DATE`

EXPECTED OUTPUT (SELECT encounter_id, admit_date, discharge_date FROM FACT_PATIENT_ENCOUNTERS joined with Views LIMIT 3):
+--------------+------------+----------------+
| ENCOUNTER_ID | ADMIT_DATE | DISCHARGE_DATE |
+--------------+------------+----------------+
| ENC-801      | 2026-08-01 | 2026-08-04     |
| ENC-802      | 2026-08-01 | 2026-08-05     |
| ENC-803      | 2026-08-02 | 2026-08-06     |
+--------------+------------+----------------+


TASK 3: Multi-Valued Attribute Weighting via Bridge Table
- Join `FACT_PATIENT_ENCOUNTERS` with `bridge_encounter_doctors.csv` to calculate attributed cost per doctor (`total_cost * weight_factor`).

EXPECTED OUTPUT (Sample for ENC-801 and ENC-802):
+--------------+-----------+---------------+-----------------+
| ENCOUNTER_ID | DOCTOR_ID | WEIGHT_FACTOR | ATTRIBUTED_COST |
+--------------+-----------+---------------+-----------------+
| ENC-801      | DOC-1     | 0.60          | 2700.00         |
| ENC-801      | DOC-2     | 0.40          | 1800.00         |
| ENC-802      | DOC-2     | 0.70          | 8400.00         |
| ENC-802      | DOC-3     | 0.30          | 3600.00         |
+--------------+-----------+---------------+-----------------+


TASK 4: Recursive Parent-Child Hierarchy Flattening
- Write a CTE query to flatten `dim_diagnosis_hierarchy.csv`, displaying child diagnosis alongside its top-level root category.

EXPECTED OUTPUT (Sample rows):
+--------------+--------------------------+--------------------+
| DIAGNOSIS_ID | DIAGNOSIS_NAME           | ROOT_CATEGORY_NAME |
+--------------+--------------------------+--------------------+
| ICD-1110     | Acute Bronchitis         | Respiratory System |
| ICD-2110     | Acute Myocardial Inf...  | Cardiovascular Sys |
| ICD-3110     | Gastritis                | Digestive System   |
+--------------+--------------------------+--------------------+


TASK 5: Delta Lake Incremental MERGE (UPSERT)
- Perform a Delta `MERGE INTO` operation updating `total_cost` for `ENC-801` to `5000.00` and inserting a new encounter `ENC-821`.

EXPECTED OUTPUT:
+-------------------+-------------------+
| ROWS_INSERTED     | ROWS_UPDATED      |
+-------------------+-------------------+
| 1                 | 1                 |
+-------------------+-------------------+


TASK 6: Delta Time Travel Audit Query
- Query `FACT_PATIENT_ENCOUNTERS` using `VERSION AS OF 0` to retrieve original cost before MERGE execution.

EXPECTED OUTPUT:
+--------------+------------+
| ENCOUNTER_ID | TOTAL_COST |
+--------------+------------+
| ENC-801      | 4500.00    |
+--------------+------------+


TASK 7: Lakehouse Schema Evolution (MERGE WITH SCHEMA EVOLUTION)
- Add a new column `patient_feedback_score` to the Delta table during an upsert operation using schema enforcement overrides.

EXPECTED OUTPUT:
+---------------+-----------------+---------------+
| ENCOUNTER_ID  | TOTAL_COST      | FEEDBACK_SCORE|
+---------------+-----------------+---------------+
| ENC-801       | 5000.00         | 4.8           |
+---------------+-----------------+---------------+


TASK 8: Lakehouse Delta Optimization (Z-ORDER BY)
- Execute `OPTIMIZE FACT_PATIENT_ENCOUNTERS ZORDER BY (primary_diag_id)` and verify storage compaction metrics.

EXPECTED OUTPUT:
+-----------------------+---------------------+
| METRIC                | VALUE               |
+-----------------------+---------------------+
| numFilesAdded         | 1                   |
| numFilesRemoved       | 3                   |
+-----------------------+---------------------+