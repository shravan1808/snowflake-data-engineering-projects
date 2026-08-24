================================================================================

PROJECT 13: Enterprise Retail Analytics — Star Schema vs. Snowflake Schema Implementation

================================================================================

Technology: Snowflake SQL

Target Modules Covered: 4.3a (Star Schema Architecture), 4.3b (Snowflake Schema Normalization \& Tradeoffs)



================================================================================

1\. PROBLEM STATEMENT

================================================================================

An enterprise retail organization is evaluating Data Warehouse modeling strategies.

The Business Intelligence team needs to compare two primary schema designs:



1\. Star Schema (Module 4.3a):

&#x20;  - Fully denormalized dimension tables connected directly to a central Fact table.

&#x20;  - Provides simpler SQL queries, faster aggregations, and optimized join performance.



2\. Snowflake Schema (Module 4.3b):

&#x20;  - Normalized dimension hierarchies to eliminate redundancy and improve storage efficiency.

&#x20;  - Product attributes are split across DIM\_CATEGORY -> DIM\_SUBCATEGORY -> DIM\_PRODUCT.

&#x20;  - Store attributes are split across DIM\_REGION -> DIM\_STORE.



Students must build both schemas in Snowflake SQL, populate them with the provided source datasets, and run comparison metrics to evaluate storage, normalization, and query join complexity.





================================================================================

2\. BUSINESS SCENARIO

================================================================================

The company operates across multiple geographic regions and maintains a multi-tiered product catalog:



Regions:

\- South Region (Telangana, Andhra Pradesh)

\- West Region (Maharashtra)



Stores:

\- Store 201 (Metro Flagship, Hyderabad -> South Region)

\- Store 202 (Express Hub, Warangal -> South Region)

\- Store 203 (Coastal Center, Vijayawada -> South Region)

\- Store 204 (Western Mart, Nagpur -> West Region)



Products \& Categories:

\- Category: Electronics -> Subcategories: Laptops (Laptop Pro), Accessories (Wireless Mouse)

\- Category: Furniture -> Subcategories: Office (Ergonomic Chair)

\- Category: Appliances -> Subcategories: Kitchen (Coffee Maker)



Transactions (Sales Fact):

\- Sales transactions occur across different stores, products, and customers.





================================================================================

3\. INPUT DATASETS (4 SOURCE CSV FILES)

================================================================================



\--- FILE 1: regions\_and\_stores.csv ---

store\_id,store\_name,city,state,region\_name,regional\_manager

201,Metro Flagship,Hyderabad,Telangana,South,Rajesh Kumar

202,Express Hub,Warangal,Telangana,South,Rajesh Kumar

203,Coastal Center,Vijayawada,Andhra Pradesh,South,Rajesh Kumar

204,Western Mart,Nagpur,Maharashtra,West,Sunil Verma



\--- FILE 2: product\_hierarchy.csv ---

product\_id,product\_name,subcategory\_name,category\_name,unit\_price

501,Laptop Pro,Laptops,Electronics,75000.00

502,Wireless Mouse,Accessories,Electronics,1500.00

503,Ergonomic Chair,Office,Furniture,12000.00

504,Coffee Maker,Kitchen,Appliances,4500.00



\--- FILE 3: customers.csv ---

customer\_id,customer\_name,city,state

101,Amit Sharma,Hyderabad,Telangana

102,Priya Reddy,Warangal,Telangana

103,Rahul Verma,Vijayawada,Andhra Pradesh

104,Neha Patel,Hyderabad,Telangana

105,Arjun Gupta,Nagpur,Maharashtra



\--- FILE 4: sales\_transactions.csv ---

transaction\_id,transaction\_date,customer\_id,store\_id,product\_id,quantity,unit\_price

TXN-3001,2026-05-01,101,201,501,1,75000.00

TXN-3002,2026-05-02,102,202,502,2,1500.00

TXN-3003,2026-05-03,103,203,503,1,12000.00

TXN-3004,2026-05-04,104,201,504,1,4500.00

TXN-3005,2026-05-05,105,204,502,3,1500.00





================================================================================

4\. IMPLEMENTATION TASKS FOR STUDENTS \& EXPECTED OUTPUTS

================================================================================



\--------------------------------------------------------------------------------

TASK 1 — Create Database and Schema Context

\--------------------------------------------------------------------------------

Task Instruction:

Write Snowflake SQL statements to create a database named `RETAIL\_SCHEMAS\_DW` and a schema named `SCHEMA\_COMPARISON`, then set the session context.



EXPECTED OUTPUT:

\-------------------------------------------------

Statement executed successfully.

Current database: RETAIL\_SCHEMAS\_DW

Current schema: SCHEMA\_COMPARISON

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 2 — Create Denormalized Star Schema Store Dimension (`STAR\_DIM\_STORE`)

\--------------------------------------------------------------------------------

Task Instruction:

Create a denormalized Store dimension table `STAR\_DIM\_STORE` containing all store, geographic, and regional manager attributes in a single table.



| Column Name      | Data Type    | Constraint                 |

| :--------------- | :----------- | :------------------------- |

| STORE\_KEY        | NUMBER       | AUTOINCREMENT, PRIMARY KEY |

| STORE\_ID         | NUMBER       | Business Key               |

| STORE\_NAME       | VARCHAR(100) | Store Name                 |

| CITY             | VARCHAR(50)  | City Name                  |

| STATE            | VARCHAR(50)  | State Name                 |

| REGION\_NAME      | VARCHAR(50)  | Region Name                |

| REGIONAL\_MANAGER | VARCHAR(100) | Regional Manager Name      |



EXPECTED OUTPUT:

\-------------------------------------------------

Table STAR\_DIM\_STORE successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 3 — Create Denormalized Star Schema Product Dimension (`STAR\_DIM\_PRODUCT`)

\--------------------------------------------------------------------------------

Task Instruction:

Create a fully denormalized Product dimension table `STAR\_DIM\_PRODUCT` containing item, subcategory, and category attributes in one flat table.



| Column Name      | Data Type    | Constraint                 |

| :--------------- | :----------- | :------------------------- |

| PRODUCT\_KEY      | NUMBER       | AUTOINCREMENT, PRIMARY KEY |

| PRODUCT\_ID       | NUMBER       | Business Key               |

| PRODUCT\_NAME     | VARCHAR(100) | Item Name                  |

| SUBCATEGORY\_NAME | VARCHAR(50)  | Subcategory Name           |

| CATEGORY\_NAME    | VARCHAR(50)  | Category Name              |

| UNIT\_PRICE       | NUMBER(10,2) | Unit Retail Price          |



EXPECTED OUTPUT:

\-------------------------------------------------

Table STAR\_DIM\_PRODUCT successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 4 — Load Star Schema Dimensions \& Create Star Fact Table (`STAR\_FACT\_SALES`)

\--------------------------------------------------------------------------------

Task Instruction:

1\. Populate `STAR\_DIM\_STORE` and `STAR\_DIM\_PRODUCT` using data from the source CSV files.

2\. Create `STAR\_FACT\_SALES` at the line-item grain, directly joining foreign keys to `STAR\_DIM\_STORE` and `STAR\_DIM\_PRODUCT`.



| Column Name      | Data Type    | Reference                         |

| :--------------- | :----------- | :-------------------------------- |

| SALES\_KEY        | NUMBER       | AUTOINCREMENT, PRIMARY KEY        |

| TRANSACTION\_ID   | VARCHAR(50)  | Business Transaction ID           |

| TRANSACTION\_DATE | DATE         | Transaction Date                  |

| CUSTOMER\_ID      | NUMBER       | Natural Customer Key              |

| STORE\_KEY        | NUMBER       | Foreign Key -> STAR\_DIM\_STORE     |

| PRODUCT\_KEY      | NUMBER       | Foreign Key -> STAR\_DIM\_PRODUCT   |

| QUANTITY         | NUMBER       | Quantity Sold                     |

| TOTAL\_AMOUNT     | NUMBER(12,2) | Total Amount (QUANTITY \* PRICE)   |



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 4 (STAR\_DIM\_STORE)

number of rows inserted: 4 (STAR\_DIM\_PRODUCT)

Table STAR\_FACT\_SALES successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 5 — Load Star Schema Fact Data

\--------------------------------------------------------------------------------

Task Instruction:

Insert the 5 transaction records from `sales\_transactions.csv` into `STAR\_FACT\_SALES` by dynamically looking up surrogate keys from `STAR\_DIM\_STORE` and `STAR\_DIM\_PRODUCT`.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 5

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 6 — Build Normalized Snowflake Schema Store Hierarchy

\--------------------------------------------------------------------------------

Task Instruction:

Normalize the Store hierarchy into two tables to eliminate regional manager redundancy:

1\. `SNOW\_DIM\_REGION` (Parent table)

&#x20;  - Columns: `REGION\_KEY` (AUTOINCREMENT PRIMARY KEY), `REGION\_NAME`, `REGIONAL\_MANAGER`

2\. `SNOW\_DIM\_STORE` (Child table)

&#x20;  - Columns: `STORE\_KEY` (AUTOINCREMENT PRIMARY KEY), `STORE\_ID`, `STORE\_NAME`, `CITY`, `STATE`, `REGION\_KEY` (FK -> SNOW\_DIM\_REGION)



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_DIM\_REGION successfully created.

Table SNOW\_DIM\_STORE successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 7 — Build Normalized Snowflake Schema Product Hierarchy

\--------------------------------------------------------------------------------

Task Instruction:

Normalize the Product hierarchy into three distinct tables:

1\. `SNOW\_DIM\_CATEGORY`: `CATEGORY\_KEY` (PK), `CATEGORY\_NAME`

2\. `SNOW\_DIM\_SUBCATEGORY`: `SUBCATEGORY\_KEY` (PK), `SUBCATEGORY\_NAME`, `CATEGORY\_KEY` (FK -> SNOW\_DIM\_CATEGORY)

3\. `SNOW\_DIM\_PRODUCT`: `PRODUCT\_KEY` (PK), `PRODUCT\_ID`, `PRODUCT\_NAME`, `UNIT\_PRICE`, `SUBCATEGORY\_KEY` (FK -> SNOW\_DIM\_SUBCATEGORY)



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_DIM\_CATEGORY successfully created.

Table SNOW\_DIM\_SUBCATEGORY successfully created.

Table SNOW\_DIM\_PRODUCT successfully created.

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 8 — Populate Snowflake Schema Normalized Dimensions

\--------------------------------------------------------------------------------

Task Instruction:

Write INSERT statements to populate `SNOW\_DIM\_REGION`, `SNOW\_DIM\_STORE`, `SNOW\_DIM\_CATEGORY`, `SNOW\_DIM\_SUBCATEGORY`, and `SNOW\_DIM\_PRODUCT` from the source data while preserving foreign key relationships.



EXPECTED OUTPUT:

\-------------------------------------------------

number of rows inserted: 2 (SNOW\_DIM\_REGION)

number of rows inserted: 4 (SNOW\_DIM\_STORE)

number of rows inserted: 3 (SNOW\_DIM\_CATEGORY)

number of rows inserted: 4 (SNOW\_DIM\_SUBCATEGORY)

number of rows inserted: 4 (SNOW\_DIM\_PRODUCT)

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 9 — Create Snowflake Schema Fact Table (`SNOW\_FACT\_SALES`) \& Load Data

\--------------------------------------------------------------------------------

Task Instruction:

1\. Create `SNOW\_FACT\_SALES` referencing `SNOW\_DIM\_STORE(STORE\_KEY)` and `SNOW\_DIM\_PRODUCT(PRODUCT\_KEY)`.

2\. Populate `SNOW\_FACT\_SALES` with the 5 transaction records.



EXPECTED OUTPUT:

\-------------------------------------------------

Table SNOW\_FACT\_SALES successfully created.

number of rows inserted: 5

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 10 — Star Schema Analytics Query (Single-Hop Join Performance)

\--------------------------------------------------------------------------------

Task Instruction:

Write a query against the \*\*Star Schema\*\* to aggregate total revenue by `REGION\_NAME` and `CATEGORY\_NAME`.



EXPECTED OUTPUT:

\-------------------------------------------------

REGION\_NAME  CATEGORY\_NAME  TOTAL\_REVENUE

\-----------------------------------------

South        Electronics    79500.00

South        Furniture      12000.00

West         Electronics    4500.00

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 11 — Snowflake Schema Analytics Query (Multi-Hop Normalized Join)

\--------------------------------------------------------------------------------

Task Instruction:

Write a query against the \*\*Snowflake Schema\*\* to compute the exact same metrics (total revenue by `REGION\_NAME` and `CATEGORY\_NAME`) by traversing the normalized dimension tables (`SNOW\_FACT\_SALES` -> `SNOW\_DIM\_STORE` -> `SNOW\_DIM\_REGION` and `SNOW\_DIM\_PRODUCT` -> `SNOW\_DIM\_SUBCATEGORY` -> `SNOW\_DIM\_CATEGORY`).



EXPECTED OUTPUT:

\-------------------------------------------------

REGION\_NAME  CATEGORY\_NAME  TOTAL\_REVENUE

\-----------------------------------------

South        Electronics    79500.00

South        Furniture      12000.00

West         Electronics    4500.00

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 12 — Architectural Analysis: Compare Star vs. Snowflake Schemas

\--------------------------------------------------------------------------------

Task Instruction:

Students must execute a query or output a formatted analysis table comparing the structural differences between Star Schema and Snowflake Schema implementations.



EXPECTED OUTPUT:

\----------------------------------------------------------------------------------------

METRIC / FEATURE               STAR SCHEMA                 SNOWFLAKE SCHEMA

\----------------------------------------------------------------------------------------

Dimension Normalization Level  Denormalized (Flat)         Normalized (Hierarchical)

Total Dimension Tables         2 Tables                    5 Tables

Joins for Category Revenue     2 Joins (Fact + 2 Dims)     4 Joins (Fact + 4 Dims)

Data Redundancy                Higher (Repeated text)      Lower (Normalized IDs)

Query Simplicity               High (Simple GROUP BY)      Lower (Requires nested FKs)

\----------------------------------------------------------------------------------------





\--------------------------------------------------------------------------------

TASK 13 — Regional Manager Sales Performance Report

\--------------------------------------------------------------------------------

Task Instruction:

Write a SQL query against the Star Schema to summarize total sales amount and item quantity sold per `REGIONAL\_MANAGER`.



EXPECTED OUTPUT:

\-------------------------------------------------

REGIONAL\_MANAGER  TOTAL\_ITEMS\_SOLD  TOTAL\_SALES\_AMOUNT

\------------------------------------------------------

Rajesh Kumar      5                 91500.00

Sunil Verma       3                 4500.00

\-------------------------------------------------





\--------------------------------------------------------------------------------

TASK 14 — Full Warehouse Architecture Audit \& Record Count Verification

\--------------------------------------------------------------------------------

Task Instruction:

Write a single SQL query using `UNION ALL` to audit record counts across both Star and Snowflake schemas.



EXPECTED OUTPUT:

\-------------------------------------------------

SCHEMA\_TYPE       TABLE\_NAME           RECORD\_COUNT

\-------------------------------------------------

Star Schema       STAR\_DIM\_STORE       4

Star Schema       STAR\_DIM\_PRODUCT     4

Star Schema       STAR\_FACT\_SALES      5

Snowflake Schema  SNOW\_DIM\_REGION      2

Snowflake Schema  SNOW\_DIM\_STORE       4

Snowflake Schema  SNOW\_DIM\_CATEGORY    3

Snowflake Schema  SNOW\_DIM\_SUBCATEGORY 4

Snowflake Schema  SNOW\_DIM\_PRODUCT     4

Snowflake Schema  SNOW\_FACT\_SALES      5

\-------------------------------------------------

