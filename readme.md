# Snowflake & Databricks Data Engineering Projects

A progressive, hands-on portfolio of data engineering projects covering SQL, Snowflake, Databricks, dimensional modeling, data warehousing, lakehouse architecture, incremental processing, SCDs, semi-structured data, Time Travel, governance, reconciliation, and enterprise analytics.

The portfolio starts with Snowflake fundamentals and gradually moves toward enterprise-grade dimensional and lakehouse architectures. Projects are organized by number and, where applicable, by parts such as A, B, and C.

---

## Project Portfolio

### 01. Customer Sales Analytics using Snowflake
**Folder:** `01-Customer-Sales-Analytics-Snowflake/`

Foundational retail analytics using Snowflake objects, staged CSV data, transformations, joins, aggregations, reusable views, and management reporting.

**Key concepts:** Warehouses, databases, schemas, stages, file formats, COPY INTO, joins, aggregations, views.

### 02. Retail Sales Analytics using Snowflake
**Folder:** `02-Retail-Sales-Analytics-Snowflake/`

Retail analytics using customer, product, branch, and sales data with increasingly advanced SQL.

**Key concepts:** Multi-table joins, CTEs, aggregations, window functions, views, materialized views.

### 03. Enterprise Incremental Sales Data Warehouse
**Folder:** `03-Enterprise-Incremental-Sales-Warehouse/`

Incremental warehouse processing that introduces change capture and operational Snowflake features.

**Key concepts:** Incremental loading, Streams, Tasks, Time Travel, Zero-Copy Cloning, validation, audit logs.

### 04. Retail Data Warehouse Design using Dimensional Modeling
**Folder:** `04-Retail-Dimensional-Data-Warehouse/`

Design-focused dimensional modeling for retail business processes.

**Key concepts:** Fact tables, dimension tables, grain, measures, surrogate keys, dimensional relationships.

### 05. Retail Sales Data Warehouse using Star Schema
**Folder:** `05-Retail-Star-Schema-Data-Warehouse/`

Implementation of a Star Schema for BI and analytical workloads.

**Key concepts:** Star Schema, facts, dimensions, keys, measures, OLAP and BI reporting.

### 06. Enterprise Retail Data Warehouse using Snowflake Schema
**Folder:** `06-Enterprise-Retail-Snowflake-Schema/`

Normalized dimensional architecture with hierarchical lookup structures.

**Key concepts:** Snowflake Schema, normalization, hierarchies, lookup tables, join complexity.

### 07. Hospital Healthcare Analytics using Snowflake Dimensional Modeling
**Folder:** `07-Hospital-Healthcare-Dimensional-Modeling/`

Multi-business-process healthcare model using shared dimensions.

**Key concepts:** Kimball modeling, business-process grain, additive measures, conformed dimensions, drill-across analysis.

### 08. Customer Profile History Analysis using Snowflake
**Folder:** `08-Customer-Profile-History-SCD-Problem/`

Demonstrates the historical-data problem created by overwriting changing customer attributes.

**Key concepts:** SCD problem, current versus historical state, attribute changes, history preservation.

### 09. Customer History Management using SCD Type 1 and Type 2
**Folder:** `09-Customer-History-SCD-Type-1-and-2/`

Comparison and implementation of Type 1 and Type 2 customer history strategies.

**Key concepts:** SCD1, SCD2, surrogate keys, effective dates, expiry dates, IS_CURRENT.

### 10. Customer Membership History using SCD Type 3 and Type 6
**Folder:** `10-Customer-Membership-History-SCD-Type-3-and-6/`

Advanced history handling using previous-value and hybrid historical patterns.

**Key concepts:** SCD3, SCD6, current value, previous value, effective/expiry dates.

### 11. Enterprise Customer Master Data Management using Hybrid SCD Strategies
**Folder:** `11-Enterprise-Customer-Master-Hybrid-SCD/`

A unified customer master using different SCD strategies according to attribute behavior.

**Key concepts:** Hybrid SCD, Type 1, Type 2, Type 3, Type 6, effective dating, point-in-time analysis.

### 12. Enterprise Retail Analytics Data Warehouse — End-to-End Kimball & SCD Modeling
**Folder:** `12-Enterprise-Retail-Kimball-SCD-Warehouse/`

End-to-end retail warehouse combining grain, conformed dimensions, and multiple SCD strategies.

**Key concepts:** Kimball modeling, fact grain, conformed dimensions, SCD1/2/3/6, point-in-time analytics.

### 13A. Enterprise Retail Analytics — Star Schema vs Snowflake Schema
**Folder:** `13A-Enterprise-Retail-Star-vs-Snowflake/`

Comparative implementation of Star and Snowflake Schema architectures.

**Key concepts:** Star Schema, Snowflake Schema, normalization, denormalization, hierarchies, join complexity.

### 13B. Healthcare Analytics — Star Schema vs Snowflake Schema
**Folder:** `13B-Healthcare-Star-vs-Snowflake/`

Healthcare claims modeling using alternative dimensional architectures.

**Key concepts:** Star Schema, Snowflake Schema, normalized hierarchies, multi-hop joins, claims analytics.

### 14A. E-Commerce Web Event Analytics — Data Lake vs Warehouse Ingestion
**Folder:** `14A-E-Commerce-Web-Event-Analytics-Lake-vs-Warehouse/`

Semi-structured web-event processing comparing schema-on-read and schema-on-write approaches.

**Key concepts:** JSON, VARIANT, Schema-on-Read, Schema-on-Write, schema evolution, malformed payload handling.

### 14B. Financial Gateway — Medallion Lakehouse & Snapshot Auditing
**Folder:** `14B-Financial-Gateway-Medallion-Lakehouse/`

FinTech lakehouse using Bronze, Silver, and Gold layers with historical auditing and reconciliation.

**Key concepts:** Medallion Architecture, VARIANT, JSON extraction, masking, financial transformations, Time Travel, recovery, reconciliation.

### 15. Cross-Border Logistics & Fleet Telematics Lakehouse Platform
**Folder:** `15-Cross-Border-Logistics-Fleet-Lakehouse/`

IoT telematics and customs processing through a Medallion architecture with malformed-record quarantine and recovery.

**Key concepts:** Medallion Architecture, JSON, TRY_PARSE_JSON, schema evolution, quarantine/dead-letter processing, Time Travel.

### 16. Healthcare Claims Dynamic Tables & CDC
**Folder:** `16-Healthcare-Claims-Dynamic-Tables-CDC/`

Healthcare claims processing focused on incremental state synchronization.

**Key concepts:** Dynamic Tables, CDC patterns, incremental transformations, analytical data freshness.

### 17. Banking Security & Governance
**Folder:** `17-Banking-Security-Governance/`

Security-oriented banking data engineering and governance workflows.

**Key concepts:** Data protection, governance, access control, secure data handling, auditing.

### 18. Cross-Enterprise Clean Room Data Sharing
**Folder:** `18-Cross-Enterprise-Clean-Room-Data-Sharing/`

Enterprise data sharing with controlled collaboration across organizations.

**Key concepts:** Secure data sharing, collaboration, privacy-aware analytics, governance.

---

# Week 3 — Data Modeling Deep Dive

## 19A. E-Commerce Sales, Snapshot Inventory & Lifecycle Pipeline
**Folder:** `19A-Snowflake-Ecommerce-Sales-Warehouse/`

A multi-fact retail model combining transaction facts, periodic snapshots, accumulating snapshots, junk dimensions, and degenerate dimensions.

**Key concepts:** Transaction facts, periodic snapshots, accumulating snapshots, junk dimensions, degenerate dimensions.

## 19B. Healthcare Patient Journeys & Promotion Coverage Factless Models
**Folder:** `19B-Snowflake-Healthcare-Patient-Analytics/`

Healthcare business processes modeled with factless coverage and lifecycle facts.

**Key concepts:** Factless facts, additive/non-additive measures, accumulating snapshots, lifecycle modeling.

## 19C. Enterprise Financial Wire Transfers, Inventory Balances & Coverage Matrix
**Folder:** `19C-Snowflake-Enterprise-Financial-Analytics/`

Enterprise multi-fact dimensional model combining transactions, periodic snapshots, accumulating snapshots, factless facts, junk dimensions, and degenerate dimensions.

**Key concepts:** Multi-fact modeling, measure behavior, factless facts, junk dimensions, degenerate dimensions.

---

## 20A. Healthcare Lakehouse Engine — Role-Playing, Hierarchies & Delta Lake
**Folder:** `20A-Healthcare-Lakehouse-Model/`

Healthcare lakehouse implementation covering multiple date roles, bridges, parent-child hierarchies, Delta operations, Time Travel, and schema evolution.

**Key concepts:** Role-playing dimensions, bridge tables, parent-child hierarchies, Delta Lake, Time Travel, schema evolution.

## 20B. Multi-Entity Financial Risk Lakehouse
**Folder:** `20B-Multi-Entity-Financial-Risk-Lakehouse/`

Financial lakehouse pipeline with incremental processing, reconciliation, historical auditing, and physical optimization.

**Key concepts:** Lakehouse processing, incremental updates, validation, Time Travel, reconciliation, clustering.

---

## 21A. Enterprise Retail Data Mart Architecture
**Folder:** `21A-Enterprise-Retail-Data-Mart-Architecture/`

Enterprise retail data-mart architecture connecting sales and inventory processes through conformed dimensions.

**Key concepts:** Data marts, Kimball Bus Matrix, conformed dimensions, referential integrity, Time Travel, clustering.

## 21B. Global E-Commerce Cross-Mart Lakehouse Engine
**Folder:** `21B-Global-E-Commerce-Cross-Mart-Lakehouse-Engine/`

Cross-mart e-commerce model combining clickstream, orders, returns, customer conformance, CDC MERGE, completeness auditing, Time Travel, and traffic-fact optimization.

**Key concepts:** Multi-source ingestion, bus matrix grain, conformed surrogate keys, cross-mart views, MERGE, completeness audits, clustering.

## 21C. Global Supply Chain & Multi-Currency Cross-Mart Engine
**Folder:** `21C-Global-Supply-Chain-Multi-Currency-Cross-Mart-Engine/`

Global procurement architecture with multi-currency normalization, FX surrogate keys, cross-mart reconciliation, late-arriving FX updates, historical audit, and multi-column clustering.

**Key concepts:** Currency normalization, conformed dimensions, FX conversion, reconciliation, late-arriving updates, Time Travel, multi-column clustering.

---

# Day 14 — SCD Type 2 & Late-Arriving Dimensions

## 22A. Automated SCD Type 2 Pipeline Engine
**Folder:** `22A-Automated-SCD-Type-2-Pipeline-Engine/`

Automated customer SCD2 pipeline using deterministic row hashes, change detection, effective-date windowing, SCD1/SCD2 decisions, atomic MERGE, temporal validation, Time Travel, and surrogate-key optimization.

**Key concepts:** SHA256 row hashing, tracked attributes, SCD1 versus SCD2, effective-date windows, expire-and-insert logic, temporal integrity, Time Travel, clustering.

## 22B. Late-Arriving Data & Complex SCD Type 2 Pipeline
**Folder:** `22B-Late-Arriving-Data-Complex-SCD2-Pipeline/`

Handles facts arriving before their dimensions by creating inferred members and resolving them when true customer data arrives.

**Key concepts:** Late-arriving dimensions, inferred members, durable surrogate keys, inferred-member resolution, historical fact alignment, automated data quality, Time Travel, clustering.

---

# Day 15 — End-to-End Enterprise Architecture

## 23A. Enterprise Sales Analytics & Multi-Tier Cohort Warehouse
**Folder:** `23A-Enterprise-Sales-Analytics-Cohort-Warehouse/`

Enterprise sales warehouse covering Star Schema modeling, customer LTV and retention, cohort trends, MERGE-based adjustments, grain alignment, Time Travel, windowing, rollups, and warehouse auditing.

**Key concepts:** Star Schema, LTV, retention, cohort analysis, grain alignment, MERGE, Time Travel, window functions, ROLLUP/CUBE, referential integrity.

## 23B. Enterprise Customer Analytics Engine — RFM, LTV & Churn
**Folder:** `23B-Enterprise-Customer-Analytics-RFM-LTV-Churn/`

Enterprise customer analytics using multi-channel events, multi-fact modeling, RFM segmentation, LTV, churn scoring, anti-pattern auditing, N-tile analysis, deduplication, conversion funnels, and clustering.

**Key concepts:** RFM, Recency/Frequency/Monetary scoring, LTV, churn risk, N-TILE, fact-to-fact join prevention, event deduplication, funnel analysis.

---

# 24. Advanced Enterprise Retail Dimensional Warehouse
**Folder:** `24-Advanced-Enterprise-Retail-Dimensional-Warehouse/`

Advanced enterprise warehouse implementation combining role-playing and conformed date dimensions, SCD Type 2 customer history, hierarchical product dimensions, transaction facts, periodic inventory snapshots, and factless promotion coverage.

The supplied Project 24 implementation contains 15 practical tasks covering role-playing date joins, additive and semi-additive measures, factless promotion analysis, degenerate dimensions, hierarchical rollups, current-versus-historical SCD2 analysis, point-in-time customer joins, late-arriving dimension key routing, dependent data-mart extraction, enterprise bus-matrix verification, RFM analysis, data-quality checks, an SCD2 MERGE pipeline, and automated audit tracking.

**Key concepts:** Role-playing dimensions, conformed dimensions, SCD Type 2, transaction facts, periodic snapshots, factless facts, additive/semi-additive measures, degenerate dimensions, hierarchy rollups, point-in-time joins, dependent marts, Bus Matrix, RFM, data quality, SCD2 MERGE, auditing.

> Folder 24 is named from the architecture and tasks in the supplied Project 24 implementation. The uploaded file itself is a Snowflake implementation script and does not provide a formal project title.

---

# Project Status

| Project | Status | Primary Practice |
|---|---|---|
| 01–18 | Completed | Snowflake / Data Engineering foundations |
| 19A–19C | Completed | Dimensional modeling |
| 20A–20B | Completed | Lakehouse / advanced warehouse |
| 21A | Completed | Databricks |
| 21B | Completed | Databricks |
| 21C | Completed | Databricks + Snowflake |
| 22A | Next | SCD Type 2 |
| 22B | Planned | Late-arriving dimensions |
| 23A | Planned | Enterprise sales analytics |
| 23B | Planned | RFM / LTV / churn |
| 24 | Defined | Advanced enterprise dimensional warehouse |

---

# Learning Progression

```text
Snowflake Fundamentals
        ↓
CSV / JSON Data Loading
        ↓
Analytical SQL
        ↓
Incremental Data Pipelines
        ↓
Streams + Tasks / CDC
        ↓
Time Travel + Recovery
        ↓
Dimensional Modeling
        ↓
Fact & Dimension Design
        ↓
Star Schema
        ↓
Snowflake Schema
        ↓
Kimball Modeling
        ↓
SCD Type 1 / Type 2
        ↓
SCD Type 3 / Type 6
        ↓
Hybrid SCD
        ↓
Role-Playing Dimensions
        ↓
Bridge Tables
        ↓
Hierarchies
        ↓
Factless Facts
        ↓
Junk & Degenerate Dimensions
        ↓
Data Marts
        ↓
Kimball Bus Matrix
        ↓
Conformed Dimensions
        ↓
Lakehouse / Medallion Architecture
        ↓
Late-Arriving Dimensions
        ↓
Inferred Members
        ↓
Hash-Based SCD2 Detection
        ↓
Cross-Mart Reconciliation
        ↓
Multi-Currency Modeling
        ↓
Enterprise Star Schemas
        ↓
Cohort / LTV / Retention
        ↓
RFM / Churn
        ↓
Data Quality & Architecture Auditing
        ↓
Physical Optimization / Clustering
        ↓
Enterprise Dimensional Architecture
```

---

# Core Concepts Covered

## Snowflake
- Virtual Warehouses
- Databases and Schemas
- Tables and Views
- Stages and File Formats
- COPY INTO
- Streams
- Tasks
- Dynamic Tables
- Time Travel
- Zero-Copy Cloning
- Secure / governed data patterns
- Incremental processing
- Reconciliation and auditing

## Databricks / Delta Lake
- Delta tables
- Databricks SQL
- PySpark concepts
- Delta Lake operations
- Time Travel
- MERGE
- OPTIMIZE
- Z-Ordering
- Lakehouse modeling
- Staging and fact/dimension pipelines

## Dimensional Modeling
- Fact tables
- Transaction facts
- Periodic snapshot facts
- Accumulating snapshot facts
- Factless fact tables
- Additive, semi-additive, and non-additive measures
- Dimensions and conformed dimensions
- Surrogate keys
- Degenerate dimensions
- Junk dimensions
- Role-playing dimensions
- Bridge tables
- Hierarchies
- Star Schema
- Snowflake Schema
- Grain definition and grain validation
- Kimball Bus Matrix
- Data marts

## Slowly Changing Dimensions
- SCD Type 1
- SCD Type 2
- SCD Type 3
- SCD Type 6
- Hybrid SCD strategies
- Effective dating
- Expiry dating
- Current-record indicators
- Hash-based change detection
- SCD2 MERGE
- Temporal integrity
- Point-in-time analysis
- Late-arriving dimensions
- Inferred members
- Historical fact alignment

## Enterprise Analytics
- Customer LTV
- Retention
- Cohort analysis
- RFM segmentation
- N-Tile scoring
- Churn-risk categorization
- Conversion funnels
- Running totals and window functions
- Rollups and cubes
- Cross-mart reconciliation

## Data Quality & Architecture
- Referential integrity
- Null validation
- Range validation
- Freshness and volume checks
- Grain parity
- Orphan-key detection
- Anti-pattern auditing
- Fan-out detection
- Fact-to-fact join prevention
- Historical auditing
- Pipeline verification

## Performance Optimization
- Micro-partition-aware design
- Clustering
- Z-Ordering
- Multi-column clustering
- Surrogate-key optimization
- Query-oriented physical layout

---

# Repository Structure

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
├── 15-Cross-Border-Logistics-Fleet-Lakehouse/
├── 16-Healthcare-Claims-Dynamic-Tables-CDC/
├── 17-Banking-Security-Governance/
├── 18-Cross-Enterprise-Clean-Room-Data-Sharing/
├── 19A-Snowflake-Ecommerce-Sales-Warehouse/
├── 19B-Snowflake-Healthcare-Patient-Analytics/
├── 19C-Snowflake-Enterprise-Financial-Analytics/
├── 20A-Healthcare-Lakehouse-Model/
├── 20B-Multi-Entity-Financial-Risk-Lakehouse/
├── 21A-Enterprise-Retail-Data-Mart-Architecture/
├── 21B-Global-E-Commerce-Cross-Mart-Lakehouse-Engine/
├── 21C-Global-Supply-Chain-Multi-Currency-Cross-Mart-Engine/
├── 22A-Automated-SCD-Type-2-Pipeline-Engine/
├── 22B-Late-Arriving-Data-Complex-SCD2-Pipeline/
├── 23A-Enterprise-Sales-Analytics-Cohort-Warehouse/
├── 23B-Enterprise-Customer-Analytics-RFM-LTV-Churn/
└── 24-Advanced-Enterprise-Retail-Dimensional-Warehouse/
```

---

# Project Implementation Style

Each project is treated as an independent engineering exercise with:

- Business scenario and requirements
- Source/staging layer
- Fact and dimension design
- Transformations and analytical logic
- Validation queries
- Historical / Time Travel auditing where required
- Performance optimization where relevant
- Expected outputs
- Engine-specific implementation

For larger projects, Databricks and Snowflake implementations can be maintained separately so the same architectural pattern can be practiced on both engines without unnecessary duplication.

---

# Portfolio Goal

The portfolio is designed to demonstrate progression from:

**SQL practitioner → Data warehouse developer → Dimensional modeler → Lakehouse engineer → Enterprise data engineer**

The later projects emphasize not only writing SQL, but also choosing the correct grain, preserving history, designing conformed dimensions, handling late-arriving data, validating integrity, preventing analytical anti-patterns, and optimizing physical storage for real workloads.

---

## Reference

GitHub repository:
https://github.com/shravan1808/snowflake-data-engineering-projects
