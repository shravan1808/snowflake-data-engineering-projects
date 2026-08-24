# Snowflake Data Engineering Projects

A progressive, hands-on portfolio of Snowflake SQL and Data Engineering projects, starting with core cloud data warehouse concepts and advancing into dimensional modeling, incremental pipelines, Slowly Changing Dimensions, semi-structured JSON processing, Medallion Lakehouse architecture, Time Travel, data recovery, and data reconciliation.

Each project is designed around a realistic business scenario and includes its own detailed README with the problem statement, tasks, implementation approach, and Snowflake concepts practiced.

---

## Project Portfolio

### 01. Customer Sales Analytics using Snowflake

A foundational retail analytics warehouse that loads customer, food-item, and order CSV data into Snowflake and produces management reports. Covers Snowflake object creation, CSV ingestion, analytical SQL, reusable views, and business reporting.

**Key concepts:** Warehouses, databases, schemas, stages, file formats, `COPY INTO`, joins, aggregations, views.

[Open Project 01](./01-Customer-Sales-Analytics-Snowflake/)

---

### 02. Retail Sales Analytics using Snowflake

A retail sales warehouse using customer, product, branch, and sales datasets to analyze purchasing behavior and business performance. Extends the foundation into multi-table analytics, CTEs, window functions, and materialized views.

**Key concepts:** Multi-table joins, aggregate functions, window functions, CTEs, views, materialized views.

[Open Project 02](./02-Retail-Sales-Analytics-Snowflake/)

---

### 03. Enterprise Incremental Sales Data Warehouse

An incremental retail data warehouse designed to process newly arriving sales while preserving historical data. The project introduces operational Snowflake features for reliable and automated pipelines.

**Key concepts:** Incremental loading, Streams, Tasks, Time Travel, Zero-Copy Cloning, validation, audit logs.

[Open Project 03](./03-Enterprise-Incremental-Sales-Warehouse/)

---

### 04. Retail Data Warehouse Design using Dimensional Modeling

A dimensional-modeling project for an enterprise retail warehouse, focused on identifying business processes, fact and dimension tables, grain, measures, relationships, and analytical reporting requirements.

**Key concepts:** Dimensional modeling, fact tables, dimension tables, grain, measures, surrogate keys, analytical design.

[Open Project 04](./04-Retail-Dimensional-Data-Warehouse/)

---

### 05. Retail Sales Data Warehouse using Star Schema

A retail warehouse implementation using a Star Schema to support BI and OLAP reporting. The project focuses on fact/dimension design and efficient analytical access patterns.

**Key concepts:** Star Schema, fact tables, dimension tables, primary/foreign keys, measures, BI and OLAP reporting.

[Open Project 05](./05-Retail-Star-Schema-Data-Warehouse/)

---

### 06. Enterprise Retail Data Warehouse using Snowflake Schema

A normalized redesign of the retail warehouse that converts dimensional structures into hierarchical lookup tables to reduce redundancy and improve master-data consistency.

**Key concepts:** Snowflake Schema, normalization, lookup tables, hierarchies, primary/foreign keys, storage optimization.

[Open Project 06](./06-Enterprise-Retail-Snowflake-Schema/)

---

### 07. Hospital Healthcare Analytics using Snowflake Dimensional Modeling

A healthcare data warehouse covering patient admissions and medical billing as two business processes. Shared dimensions enable analysis across hospitals, doctors, departments, patients, and dates.

**Key concepts:** Kimball dimensional modeling, business processes, fact-table grain, additive measures, surrogate keys, conformed dimensions, drill-across analysis.

[Open Project 07](./07-Hospital-Healthcare-Dimensional-Modeling/)

---

### 08. Customer Profile History Analysis using Snowflake

A project that demonstrates the Slowly Changing Dimension problem by showing how overwriting customer attributes can destroy historical information when city, membership, and segment change.

**Key concepts:** SCD problem, customer dimensions, current vs. historical data, attribute changes, historical information loss.

[Open Project 08](./08-Customer-Profile-History-SCD-Problem/)

---

### 09. Customer History Management using SCD Type 1 and Type 2

A customer-dimension implementation comparing two historical strategies: Type 1 overwrites values, while Type 2 preserves previous versions using effective dates, expiry dates, and current-record indicators.

**Key concepts:** SCD Type 1, SCD Type 2, surrogate keys, effective dates, expiry dates, `IS_CURRENT`.

[Open Project 09](./09-Customer-History-SCD-Type-1-and-2/)

---

### 10. Customer Membership History using SCD Type 3 and Type 6

A customer membership-history project implementing both immediate previous-value tracking and a more complete hybrid historical approach.

**Key concepts:** SCD Type 3, SCD Type 6, current value, previous value, historical records, effective/expiry dates.

[Open Project 10](./10-Customer-Membership-History-SCD-Type-3-and-6/)

---

### 11. Enterprise Customer Master Data Management using Hybrid SCD Strategies

A unified customer dimension that applies different SCD strategies according to attribute requirements: direct overwrite, full historical tracking, previous-value tracking, and hybrid history.

**Key concepts:** Hybrid SCD, Type 1, Type 2, Type 3, Type 6, effective dating, current records, historical point-in-time analysis.

[Open Project 11](./11-Enterprise-Customer-Master-Hybrid-SCD/)

---

### 12. Enterprise Retail Analytics Data Warehouse — End-to-End Kimball & SCD Modeling

An end-to-end retail warehouse combining fact grain, conformed dimensions, and multiple SCD strategies in a single business scenario.

**Key concepts:** Kimball modeling, fact grain, conformed dimensions, SCD Type 1, Type 2, Type 3, Type 6, point-in-time analytics.

[Open Project 12](./12-Enterprise-Retail-Kimball-SCD-Warehouse/)

---

### 13A. Enterprise Retail Analytics — Star Schema vs. Snowflake Schema

A comparative retail implementation that builds both Star and Snowflake Schema architectures from the same source data and evaluates their structural and analytical trade-offs.

**Key concepts:** Star Schema, Snowflake Schema, denormalization, normalization, dimensional hierarchies, join complexity, data redundancy.

[Open Project 13A](./13A-Enterprise-Retail-Star-vs-Snowflake/)

---

### 13B. Healthcare Analytics — Star Schema vs. Snowflake Schema

A healthcare claims implementation comparing flat Star Schema dimensions with normalized Snowflake Schema hierarchies for hospitals, networks, treatments, and diagnosis groups.

**Key concepts:** Star Schema, Snowflake Schema, normalized hierarchies, multi-hop joins, claims analytics, master-data maintenance.

[Open Project 13B](./13B-Healthcare-Star-vs-Snowflake/)

---

### 14A. E-Commerce Web Event Analytics — Data Lake vs. Warehouse Ingestion

A semi-structured event analytics project comparing Schema-on-Read raw JSON ingestion with Schema-on-Write structured warehouse processing. It also demonstrates schema evolution and malformed-payload handling.

**Key concepts:** JSON, `VARIANT`, Schema-on-Read, Schema-on-Write, schema evolution, raw ingestion, structured transformations.

[Open Project 14A](./14A-E-Commerce-Web-Event-Analytics-Lake-vs-Warehouse/)

---

### 14B. Financial Gateway — Medallion Lakehouse & Snapshot Auditing

A FinTech payment gateway implemented using Bronze, Silver, and Gold layers. Raw JSON transactions are transformed into cleaned settlement data and merchant-level business aggregates, followed by Time Travel recovery and reconciliation.

**Key concepts:** Medallion Architecture, Bronze/Silver/Gold, `VARIANT`, JSON extraction, data masking, financial transformations, Time Travel, recovery, reconciliation.

[Open Project 14B](./14B-Financial-Gateway-Medallion-Lakehouse/)

---

### 15. Cross-Border Logistics & Fleet Telematics Lakehouse Platform

An end-to-end logistics lakehouse processing IoT telematics and customs JSON payloads through Bronze, Silver, and Gold layers. The pipeline handles schema evolution, malformed records, quarantine, customs calculations, Time Travel recovery, and reconciliation.

**Key concepts:** Medallion Architecture, Schema-on-Read, Schema-on-Write, `VARIANT`, JSON, `TRY_PARSE_JSON`, schema evolution, quarantine/dead-letter processing, Time Travel, disaster recovery.

[Open Project 15](./15-Cross-Border-Logistics-Fleet-Lakehouse/)

---

## Snowflake & Data Engineering Concepts Covered

### Snowflake Fundamentals
- Virtual Warehouses
- Databases and Schemas
- Tables and Views
- Internal Stages
- File Formats
- `COPY INTO`

### Data Loading
- CSV ingestion
- JSON ingestion
- Schema-on-Read
- Schema-on-Write
- Incremental loading
- Error handling
- Data validation
- Quarantine / dead-letter processing

### Data Warehousing
- Kimball dimensional modeling
- Fact tables
- Dimension tables
- Fact grain
- Measures
- Surrogate keys
- Conformed dimensions
- Star Schema
- Snowflake Schema
- Dimension normalization
- Hierarchical dimensions

### Slowly Changing Dimensions
- SCD Type 1
- SCD Type 2
- SCD Type 3
- SCD Type 6
- Hybrid SCD strategies
- Effective dates
- Expiry dates
- Current-record indicators
- Historical point-in-time analysis

### Snowflake Platform Features
- Streams
- Tasks
- Time Travel
- Zero-Copy Cloning
- Incremental pipelines
- Historical recovery
- Audit validation

### Semi-Structured Data
- `VARIANT`
- JSON
- Nested JSON extraction
- Schema evolution
- `TRY_PARSE_JSON`
- Raw-text ingestion
- Malformed-record quarantine

### Lakehouse Architecture
- Bronze Layer
- Silver Layer
- Gold Layer
- Medallion Architecture
- Raw → Cleaned → Business-ready transformations

### SQL & Analytics
- Joins
- Aggregations
- CTEs
- Window functions
- Conditional aggregation
- Business KPIs
- Analytical reporting
- Data reconciliation

---

## Learning Progression

```text
Snowflake Fundamentals
        ↓
CSV Data Loading
        ↓
Analytical SQL
        ↓
Incremental Data Pipelines
        ↓
Streams + Tasks
        ↓
Time Travel + Zero-Copy Cloning
        ↓
Dimensional Modeling
        ↓
Star Schema
        ↓
Snowflake Schema
        ↓
SCD Type 1 / 2
        ↓
SCD Type 3 / 6
        ↓
Hybrid SCD
        ↓
Semi-Structured JSON
        ↓
Schema-on-Read / Schema-on-Write
        ↓
Medallion Lakehouse
        ↓
Schema Evolution
        ↓
Quarantine / Dead-Letter Processing
        ↓
Time-Travel Disaster Recovery
        ↓
Cross-Layer Reconciliation
```

---

## Repository Structure

```text
Snowflake-Data-Engineering-Projects/
│
├── 01-Customer-Sales-Analytics-Snowflake/
├── 02-Retail-Sales-Analytics-Snowflake/
├── 03-Enterprise-Incremental-Sales-Warehouse/
├── 04-Retail-Dimensional-Data-Warehouse/
├── 05-Retail-Star-Schema-Data-Warehouse/
├── 06-Enterprise-Retail-Snowflake-Schema/
├── 07-Hospital-Healthcare-Dimensional-Modeling/
├── 08-Customer-Profile-History-SCD-Problem/
├── 09-Customer-History-SCD-Type-1-and-2/
├── 10-Customer-Membership-History-SCD-Type-3-and-6/
├── 11-Enterprise-Customer-Master-Hybrid-SCD/
├── 12-Enterprise-Retail-Kimball-SCD-Warehouse/
├── 13A-Enterprise-Retail-Star-vs-Snowflake/
├── 13B-Healthcare-Star-vs-Snowflake/
├── 14A-E-Commerce-Web-Event-Analytics-Lake-vs-Warehouse/
├── 14B-Financial-Gateway-Medallion-Lakehouse/
└── 15-Cross-Border-Logistics-Fleet-Lakehouse/
```

---

## About This Repository

This repository documents a practical progression through Snowflake and Data Engineering concepts using business-oriented projects rather than isolated SQL exercises.

Each project is implemented independently and focuses on understanding the architecture, SQL patterns, Snowflake features, data modeling decisions, and real-world data engineering problems involved.
