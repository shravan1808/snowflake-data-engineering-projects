-- WAREHOUSE CREATION
CREATE WAREHOUSE HEALTHCARE_WH
WITH 
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;


-- DATA BASE CREATION
CREATE DATABASE HEALTHCARE_DB;


-- SCHEMA CREATION
CREATE SCHEMA HEALTHCARE_SCHEMA;


-- DIMENSION TABLES
CREATE TABLE DIM_PATIENT
(
patient_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
patient_id VARCHAR,
patient_name VARCHAR,
gender VARCHAR,
city VARCHAR,
state VARCHAR
);

CREATE TABLE DIM_DOCTOR
(
doctor_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
doctor_id VARCHAR,
doctor_name VARCHAR,
specialization VARCHAR
);

CREATE TABLE DIM_HOSPITAL
(
hospital_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
hospital_id VARCHAR,
hospital_name VARCHAR,
city VARCHAR,
state VARCHAR,
region VARCHAR
);

CREATE TABLE DIM_DEPARTMENT
(
department_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
department_id VARCHAR,
department_name VARCHAR
);

CREATE TABLE DIM_TREATMENT
(
treatment_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
treatment_id VARCHAR,
treatment_name VARCHAR,
treatment_category VARCHAR
);

CREATE TABLE DIM_DATE
(
date_key NUMBER PRIMARY KEY,
full_date DATE,
day_no NUMBER,
day_name VARCHAR,
week_no NUMBER,
month_no NUMBER,
month_name VARCHAR,
qtr_no VARCHAR,
year_no NUMBER
);


-- CSV FORMAT
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1;


-- STAGE CREATION
CREATE OR REPLACE STAGE HEALTHCARE_STAGE
FILE_FORMAT = CSV_FORMAT;


-- LOADING FILES INTO DIMENSION TABLES
COPY INTO DIM_PATIENT(patient_id,patient_name,gender,city,state)
FROM @HEALTHCARE_STAGE/patients.csv;

COPY INTO DIM_DOCTOR(doctor_id,doctor_name,specialization)
FROM @HEALTHCARE_STAGE/doctors.csv;

COPY INTO DIM_HOSPITAL(hospital_id,hospital_name,city,state,region)
FROM @HEALTHCARE_STAGE/hospitals.csv;

COPY INTO DIM_DEPARTMENT(department_id,department_name)
FROM @HEALTHCARE_STAGE/departments.csv;

COPY INTO DIM_TREATMENT(treatment_id,treatment_name,treatment_category)
FROM @HEALTHCARE_STAGE/treatments.csv;


INSERT INTO DIM_DATE(date_key,full_date,day_no,day_name,week_no,month_no,month_name,qtr_no,year_no)
SELECT  TO_NUMBER(TO_CHAR(generated_date,'YYYYMMDD')),
        DATE(generated_date),
        DAY(generated_date),
        DAYNAME(generated_date),
        WEEK(generated_date),
        MONTH(generated_date),
        MONTHNAME(generated_date),
        CONCAT('Q',QUARTER(generated_date)),
        YEAR(generated_date)
FROM (SELECT DATEADD(day,SEQ4(),'2026-01-01') AS generated_date
      FROM TABLE(GENERATOR(ROWCOUNT => 90))
      );


-- FACT TABLES CREATION & INSERTION
CREATE TABLE FACT_ADMISSION
(
admission_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
patient_key NUMBER REFERENCES DIM_PATIENT(patient_key),
doctor_key NUMBER REFERENCES DIM_DOCTOR(doctor_key),
hospital_key NUMBER REFERENCES DIM_HOSPITAL(hospital_key),
department_key NUMBER REFERENCES DIM_DEPARTMENT(department_key),
date_key NUMBER REFERENCES DIM_DATE(date_key),
admission_count NUMBER,
length_of_stay NUMBER
);

INSERT INTO FACT_ADMISSION(patient_key,doctor_key,hospital_key,department_key,date_key,admission_count,length_of_stay)
SELECT  pat.patient_key,
        doc.doctor_key,
        hos.hospital_key,
        dep.department_key,
        dat.date_key,
        1,
        datediff(day,adm_file.$6,adm_file.$7)
FROM (SELECT $1,$2,$3,$4,$5,$6,$7
      FROM @HEALTHCARE_STAGE/admissions.csv) AS adm_file
INNER JOIN DIM_PATIENT pat
ON adm_file.$2=pat.patient_id
INNER JOIN DIM_DOCTOR doc
ON adm_file.$3=doc.doctor_id
INNER JOIN DIM_HOSPITAL hos
ON adm_file.$4=hos.hospital_id
INNER JOIN DIM_DEPARTMENT dep
ON adm_file.$5=dep.department_id
INNER JOIN DIM_DATE dat
ON adm_file.$6=dat.full_date;


CREATE TABLE FACT_BILLING
(
billing_key NUMBER AUTOINCREMENT START 1 INCREMENT 1 PRIMARY KEY,
patient_key NUMBER REFERENCES DIM_PATIENT(patient_key),
doctor_key NUMBER REFERENCES DIM_DOCTOR(doctor_key),
hospital_key NUMBER REFERENCES DIM_HOSPITAL(hospital_key),
department_key NUMBER REFERENCES DIM_DEPARTMENT(department_key),
treatment_key NUMBER REFERENCES DIM_TREATMENT(treatment_key),
date_key NUMBER REFERENCES DIM_DATE(date_key),
quantity NUMBER,
treatment_amount NUMBER,
discount NUMBER,
net_amount NUMBER
);


INSERT INTO FACT_BILLING(patient_key,doctor_key,hospital_key,department_key,treatment_key,date_key,quantity,treatment_amount,discount,net_amount)
SELECT  pk.patient_key,
        dk.doctor_key,
        hk.hospital_key,
        dpk.department_key,
        tk.treatment_key,
        dtk.date_key,
        bill_file.$8::NUMBER,
        bill_file.$9::NUMBER,
        bill_file.$10::NUMBER,
        bill_file.$9::NUMBER-bill_file.$10::NUMBER
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
      FROM @HEALTHCARE_STAGE/billings.csv
      ) as bill_file
INNER JOIN DIM_PATIENT pk
ON pk.patient_id=bill_file.$2
INNER JOIN DIM_DOCTOR dk
ON dk.doctor_id=bill_file.$3
INNER JOIN DIM_HOSPITAL hk
ON hk.hospital_id=bill_file.$4
INNER JOIN DIM_DEPARTMENT dpk
ON dpk.department_id=bill_file.$5
INNER JOIN DIM_TREATMENT tk
ON tk.treatment_id=bill_file.$6
INNER JOIN DIM_DATE dtk
ON dtk.full_date=TO_DATE(bill_file.$7);


-- Hospital wise Admissions 
SELECT  hk.hospital_name,
        SUM(adm.admission_count) AS total_admissions
FROM DIM_HOSPITAL hk
INNER JOIN FACT_ADMISSION adm
ON hk.hospital_key=adm.hospital_key
GROUP BY hk.hospital_name
ORDER BY total_admissions DESC;


-- Hospital wise Revenue
SELECT  hk.hospital_name,
        SUM(bill.net_amount) AS total_revenue
FROM DIM_HOSPITAL hk
INNER JOIN FACT_BILLING bill
ON hk.hospital_key=bill.hospital_key
GROUP BY hk.hospital_name
ORDER BY total_revenue DESC;


-- Monthly Revenue Report
SELECT  CONCAT(dk.year_no,'-',TO_CHAR(dk.month_no,'FM00')) AS cal_month,
        SUM(bill.net_amount) AS monthly_revenue
FROM DIM_DATE dk
INNER JOIN FACT_BILLING bill
ON dk.date_key=bill.date_key
GROUP BY dk.year_no,dk.month_no
ORDER BY cal_month;


-- Doctor wise Revenue
SELECT  dk.doctor_name,
        SUM(bill.net_amount) AS doctor_revenue
FROM DIM_DOCTOR dk
INNER JOIN FACT_BILLING bill
ON dk.doctor_key=bill.doctor_key
GROUP BY dk.doctor_name
ORDER BY doctor_revenue DESC;
    

-- Hospital Analytics 
WITH hospital_admissions AS 
(
SELECT  hospital_key,
        SUM(admission_count) AS total_admissions
FROM FACT_ADMISSION 
GROUP BY hospital_key
), hospital_revenue AS
(
SELECT  hospital_key,
        SUM(net_amount) AS total_revenue
FROM FACT_BILLING 
GROUP BY hospital_key
)
SELECT  hk.hospital_name,
        ha.total_admissions,
        hr.total_revenue
FROM DIM_HOSPITAL hk
INNER JOIN hospital_admissions ha
ON hk.hospital_key=ha.hospital_key
INNER JOIN hospital_revenue hr
ON hk.hospital_key=hr.hospital_key
ORDER BY ha.total_admissions DESC,hr.total_revenue DESC;
