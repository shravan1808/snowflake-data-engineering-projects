================================================================================

PROJECT 12: Enterprise Retail Analytics Data Warehouse (End-to-End Kimball \& SCD Modeling)

================================================================================

Technology: Snowflake SQL

Target Modules Covered: 4.1a (Facts \& Dims), 4.1b (Grain), 4.1c (Conformed Dims), 4.2a (SCD Problem), 4.2b (SCD Type 1 \& 2), 4.2c (SCD Type 3 \& 6)



================================================================================

1\. PROBLEM STATEMENT

================================================================================

An omnichannel retail company sells products across physical stores and online platforms. 

The leadership team requires a central Snowflake Data Warehouse to run daily sales and customer loyalty reporting.



The warehouse design must fulfill the following architectural requirements:

1\. Fact Table Grain: Exactly one row per individual item line in a sales transaction (Module 4.1b).

2\. Conformed Dimensions: Shared Store and Customer dimension tables accessible across all business subjects (Module 4.1c).

3\. Attribute Management (Slowly Changing Dimensions):

&#x20;  - Store Manager Name: Overwritten directly when changes occur (SCD Type 1).

&#x20;  - Customer Segment: Maintained with full historical row versioning (SCD Type 2).

&#x20;  - Customer City: Maintained with immediate previous value tracking (SCD Type 3).

&#x20;  - Customer Membership Tier: Maintained using a combined hybrid solution tracking Current Tier, Previous Tier, and Historical Slice Tier (SCD Type 6).



Students must implement this schema end-to-end in Snowflake SQL based on the task specifications.





================================================================================

2\. BUSINESS SCENARIO

================================================================================

Phase 1: Initial Load (Q1 2026)

\- 3 Store locations are registered.

\- 4 Products are added to the catalog.

\- 5 Initial Customers are loaded into the warehouse.

\- Initial Sales Transactions (TXN-1001, TXN-1002) occur.



Phase 2: Master Data Updates (Q2 2026)

\- Store 201 changes its Store Manager to "Suresh Menon" (SCD Type 1).

\- Customer 101 moves from Hyderabad to Bengaluru (SCD Type 3), updates Segment from Regular to Premium (SCD Type 2), and updates Membership from Silver to Gold (SCD Type 6) on 2026-04-01.

\- Customer 103 moves from Vijayawada to Chennai (SCD Type 3), updates Segment from Regular to Premium (SCD Type 2), and updates Membership from Silver to Gold (SCD Type 6) on 2026-04-05.

\- Customer 104 updates Membership from Gold to Platinum (SCD Type 6) on 2026-04-10.

\- Post-update Sales Transaction (TXN-2001) occurs on 2026-04-15.





================================================================================

3\. INPUT DATASETS (4 SOURCE CSV FILES)

================================================================================



\--- FILE 1: stores.csv ---

store\_id,store\_name,city,state,store\_manager

201,Metro Flagship,Hyderabad,Telangana,Rajesh Kumar

202,Express Hub,Warangal,Telangana,Sita Sharma

203,Coastal Center,Vijayawada,Andhra Pradesh,Vikram Rao



\--- FILE 2: products.csv ---

product\_id,product\_name,category,unit\_price

501,Laptop Pro,Electronics,75000.00

502,Wireless Mouse,Electronics,1500.00

503,Ergonomic Chair,Furniture,12000.00

504,Coffee Maker,Appliances,4500.00



\--- FILE 3: customers\_initial.csv ---

customer\_id,customer\_name,city,state,membership,segment

101,Amit Sharma,Hyderabad,Telangana,Silver,Regular

102,Priya Reddy,Warangal,Telangana,Gold,Premium

103,Rahul Verma,Vijayawada,Andhra Pradesh,Silver,Regular

104,Neha Patel,Hyderabad,Telangana,Gold,Premium

105,Arjun Gupta,Nagpur,Maharashtra,Bronze,Regular



\--- FILE 4: customer\_updates.csv ---

customer\_id,customer\_name,city,state,membership,segment,effective\_date

101,Amit Sharma,Bengaluru,Karnataka,Gold,Premium,2026-04-01

103,Rahul Verma,Chennai,Tamil Nadu,Gold,Premium,2026-04-05

104,Neha Patel,Hyderabad,Telangana,Platinum,Premium,2026-04-10





================================================================================

4\. IMPLEMENTATION TASKS FOR STUDENTS \& EXPECTED OUTPUTS

================================================================================



\--------------------------------------------------------------------------------

TASK 1 — Create Database and Schema Context

\--------------------------------------------------------------------------------

Task Instruction:

Write Snowflake SQL statements to create a database named `RETAIL\_DW` and a schema named `SALES\_ANALYTICS`, then set the session context to use this schema.



EXPECTED OUTPUT:

\-------------------------------------------------

Statement executed successfully.

Current database: RETAIL\_DW

Current schema: SALES\_ANALYTICS

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 2 — Create Store Conformed Dimension Table (`DIM\_STORE`)

\--------------------------------------------------------------------------------

Task Instruction:

Create a conformed Store dimension table named `DIM\_STORE` with an autoincrementing surrogate key using the following specification:



| Column Name   | Data Type    | Constraint                    |

| :------------ | :----------- | :---------------------------- |

| STORE\_KEY     | NUMBER       | AUTOINCREMENT, PRIMARY KEY    |

| STORE\_ID      | NUMBER       | Business Key                  |

| STORE\_NAME    | VARCHAR(100) | Store Title                   |

| CITY          | VARCHAR(50)  | City Name                     |

| STATE         | VARCHAR(50)  | State Name                    |

| STORE\_MANAGER | VARCHAR(100) | Store Manager (SCD Type 1)    |



EXPECTED OUTPUT:

\-------------------------------------------------

Table DIM\_STORE successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 3 — Create Product Dimension Table (`DIM\_PRODUCT`)

\--------------------------------------------------------------------------------

Task Instruction:

Create a Product dimension table named `DIM\_PRODUCT` using the following specification:



| Column Name  | Data Type    | Constraint                 |

| :----------- | :----------- | :------------------------- |

| PRODUCT\_KEY  | NUMBER       | AUTOINCREMENT, PRIMARY KEY |

| PRODUCT\_ID   | NUMBER       | Business Key               |

| PRODUCT\_NAME | VARCHAR(100) | Item Name                  |

| CATEGORY     | VARCHAR(50)  | Product Category           |

| UNIT\_PRICE   | NUMBER(10,2) | Unit Retail Price          |



EXPECTED OUTPUT:

\-------------------------------------------------

Table DIM\_PRODUCT successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 4 — Create Hybrid Customer Dimension Table (`DIM\_CUSTOMER\_HYBRID`)

\--------------------------------------------------------------------------------

Task Instruction:

Create a customer dimension table named `DIM\_CUSTOMER\_HYBRID` designed to handle multi-SCD tracking.



| Column Name           | Data Type    | Purpose / Strategy                                   |

| :-------------------- | :----------- | :--------------------------------------------------- |

| CUSTOMER\_KEY          | NUMBER       | AUTOINCREMENT, PRIMARY KEY                           |

| CUSTOMER\_ID           | NUMBER       | Business Key                                         |

| CUSTOMER\_NAME         | VARCHAR(100) | Customer Full Name                                   |

| CITY                  | VARCHAR(50)  | Current City (Globally Updated)                      |

| PREVIOUS\_CITY         | VARCHAR(50)  | Immediate Prior City (SCD Type 3)                    |

| STATE                 | VARCHAR(50)  | Current State                                        |

| CURRENT\_MEMBERSHIP    | VARCHAR(30)  | Current Active Tier (Globally Updated - SCD Type 6)  |

| PREVIOUS\_MEMBERSHIP   | VARCHAR(30)  | Immediate Prior Tier (SCD Type 6 / Type 3 Column)    |

| HISTORICAL\_MEMBERSHIP | VARCHAR(30)  | Point-in-Time Slice Tier (SCD Type 6 / Type 2 Row)   |

| SEGMENT               | VARCHAR(30)  | Customer Segment (SCD Type 2 Row Versioned)          |

| EFFECTIVE\_DATE        | DATE         | Record Version Start Date                            |

| EXPIRY\_DATE           | DATE         | Record Version End Date                              |

| IS\_CURRENT            | BOOLEAN      | Active Indicator (TRUE / FALSE)                      |



EXPECTED OUTPUT:

\-------------------------------------------------

Table DIM\_CUSTOMER\_HYBRID successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 5 — Populate Initial Store and Product Dimension Data

\--------------------------------------------------------------------------------

Task Instruction:

Write INSERT statements to load the initial records into `DIM\_STORE` (from `stores.csv`) and `DIM\_PRODUCT` (from `products.csv`).



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 3

number of rows inserted: 4

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 6 — Populate Initial Customer Dimension Data

\--------------------------------------------------------------------------------

Task Instruction:

Write an INSERT statement to load initial data from `customers\_initial.csv` into `DIM\_CUSTOMER\_HYBRID`.

\- `EFFECTIVE\_DATE` must be set to `'2026-01-01'`.

\- `EXPIRY\_DATE` must be set to `'9999-12-31'`.

\- `IS\_CURRENT` must be set to `TRUE`.

\- Initial `PREVIOUS\_CITY` and `PREVIOUS\_MEMBERSHIP` must be `NULL`.

\- Initial `HISTORICAL\_MEMBERSHIP` and `CURRENT\_MEMBERSHIP` should equal `membership`.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 5

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 7 — Create Sales Transaction Fact Table (`FACT\_SALES`)

\--------------------------------------------------------------------------------

Task Instruction:

Create the fact table `FACT\_SALES` at the grain of \*\*One row per line item\*\*. Define Foreign Keys linking to dimension surrogate keys.



| Column Name      | Data Type    | Constraint / Reference                           |

| :--------------- | :----------- | :----------------------------------------------- |

| SALES\_KEY        | NUMBER       | AUTOINCREMENT, PRIMARY KEY                       |

| TRANSACTION\_ID   | VARCHAR(50)  | Business Transaction Number                      |

| TRANSACTION\_DATE | DATE         | Date of Sale                                     |

| CUSTOMER\_KEY     | NUMBER       | Foreign Key -> DIM\_CUSTOMER\_HYBRID(CUSTOMER\_KEY) |

| STORE\_KEY        | NUMBER       | Foreign Key -> DIM\_STORE(STORE\_KEY)              |

| PRODUCT\_KEY      | NUMBER       | Foreign Key -> DIM\_PRODUCT(PRODUCT\_KEY)          |

| QUANTITY         | NUMBER       | Units Sold                                       |

| UNIT\_PRICE       | NUMBER(10,2) | Unit Price at Sale                               |

| TOTAL\_AMOUNT     | NUMBER(12,2) | Calculated Amount (QUANTITY \* UNIT\_PRICE)        |



EXPECTED OUTPUT:

\-------------------------------------------------

Table FACT\_SALES successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 8 — Insert Q1 2026 Sales Fact Transactions

\--------------------------------------------------------------------------------

Task Instruction:

Write INSERT queries for the following transactions by dynamically joining to current dimension surrogate keys:

1\. Transaction `TXN-1001` on `'2026-02-15'`: Customer 101 purchases 1 unit of Product 501 at Store 201.

2\. Transaction `TXN-1002` on `'2026-03-10'`: Customer 103 purchases 2 units of Product 502 at Store 203.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 1

number of rows inserted: 1

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 9 — Apply Store Manager Update (SCD Type 1 Overwrite)

\--------------------------------------------------------------------------------

Task Instruction:

Write an UPDATE statement to change the `STORE\_MANAGER` of Store 201 (`Metro Flagship`) to `'Suresh Menon'`. Write a SELECT query to verify the overwrite.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows updated: 1



STORE\_ID  STORE\_NAME      CITY       STATE      STORE\_MANAGER

\--------------------------------------------------------------

201       Metro Flagship  Hyderabad  Telangana  Suresh Menon

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 10 — Execute Multi-Attribute Customer Updates

\--------------------------------------------------------------------------------

Task Instruction:

Write SQL statements to process changes from `customer\_updates.csv`:

\- \*\*Step 1:\*\* Expire active records for Customers 101, 103, and 104 by updating `EXPIRY\_DATE` to the day before their `effective\_date` and setting `IS\_CURRENT = FALSE`.

\- \*\*Step 2:\*\* Insert new active row versions for updated customers with `IS\_CURRENT = TRUE` and `EXPIRY\_DATE = '9999-12-31'`. Preserve their old city in `PREVIOUS\_CITY`.

\- \*\*Step 3:\*\* Synchronize `CURRENT\_MEMBERSHIP`, `PREVIOUS\_MEMBERSHIP`, `CITY`, and `STATE` across \*\*all\*\* historical rows for affected customers so current profile attributes match everywhere.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows updated: 1

number of rows updated: 1

number of rows updated: 1

number of rows inserted: 3

number of rows updated: 2

number of rows updated: 2

number of rows updated: 2

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 11 — Insert Q2 2026 Sales Transaction

\--------------------------------------------------------------------------------

Task Instruction:

Insert Transaction `TXN-2001` occurring on `'2026-04-15'`: Customer 101 purchases 1 unit of Product 503 at Store 201. (Ensure it binds to Customer 101's \*\*new active surrogate key\*\*).



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 1

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 12 — Display Full Customer Dimension History

\--------------------------------------------------------------------------------

Task Instruction:

Write a SELECT query on `DIM\_CUSTOMER\_HYBRID` sorted by `CUSTOMER\_ID` and `EFFECTIVE\_DATE` to display the complete historical dimension state.



EXPECTED OUTPUT:

\--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CUSTOMER\_ID  CUSTOMER\_NAME  CITY       PREVIOUS\_CITY  CURRENT\_MEMBERSHIP  PREVIOUS\_MEMBERSHIP  HISTORICAL\_MEMBERSHIP  SEGMENT  EFFECTIVE\_DATE  EXPIRY\_DATE  IS\_CURRENT

\--------------------------------------------------------------------------------------------------------------------------------------------------------------------

101          Amit Sharma    Bengaluru  Hyderabad      Gold                Silver               Silver                 Regular  2026-01-01      2026-03-31   FALSE

101          Amit Sharma    Bengaluru  Hyderabad      Gold                Silver               Gold                   Premium  2026-04-01      9999-12-31   TRUE

102          Priya Reddy    Warangal   NULL           Gold                NULL                 Gold                   Premium  2026-01-01      9999-12-31   TRUE

103          Rahul Verma    Chennai    Vijayawada     Gold                Silver               Silver                 Regular  2026-01-01      2026-04-04   FALSE

103          Rahul Verma    Chennai    Vijayawada     Gold                Silver               Gold                   Premium  2026-04-05      9999-12-31   TRUE

104          Neha Patel     Hyderabad  NULL           Platinum            Gold                 Gold                   Premium  2026-01-01      2026-04-09   FALSE

104          Neha Patel     Hyderabad  NULL           Platinum            Gold                 Platinum               Premium  2026-04-10      9999-12-31   TRUE

105          Arjun Gupta    Nagpur     NULL           Bronze              NULL                 Bronze                 Regular  2026-01-01      9999-12-31   TRUE

\--------------------------------------------------------------------------------------------------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 13 — Point-in-Time Point-of-Sale Analytics Query

\--------------------------------------------------------------------------------

Task Instruction:

Write an analytical JOIN query combining `FACT\_SALES`, `DIM\_CUSTOMER\_HYBRID`, `DIM\_STORE`, and `DIM\_PRODUCT` for Customer 101. 

The query must output Customer 101's `CURRENT\_CITY`, the `MEMBERSHIP\_AT\_PURCHASE` (historical slice membership), and `SEGMENT\_AT\_PURCHASE`.



EXPECTED OUTPUT:

\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

TRANSACTION\_ID  TRANSACTION\_DATE  CUSTOMER\_ID  CUSTOMER\_NAME  CURRENT\_CITY  MEMBERSHIP\_AT\_PURCHASE  SEGMENT\_AT\_PURCHASE  STORE\_NAME      PRODUCT\_NAME     TOTAL\_AMOUNT

\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

TXN-1001        2026-02-15        101          Amit Sharma    Bengaluru     Silver                  Regular              Metro Flagship  Laptop Pro       75000.00

TXN-2001        2026-04-15        101          Amit Sharma    Bengaluru     Gold                    Premium              Metro Flagship  Ergonomic Chair  12000.00

\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 14 — Warehouse Record Count and Data Auditing Validation

\--------------------------------------------------------------------------------

Task Instruction:

Write a single SQL query using `UNION ALL` to audit record counts across all dimensions and fact tables.



EXPECTED OUTPUT:

\---------------------------------------

METRIC                            VALUE

\---------------------------------------

STORE DIMENSION RECORDS           3

PRODUCT DIMENSION RECORDS         4

TOTAL CUSTOMER DIMENSION RECORDS  8

CURRENT CUSTOMER RECORDS          5

HISTORICAL CUSTOMER RECORDS       3

FACT SALES TRANSACTIONS           3

\---------------------------------------

