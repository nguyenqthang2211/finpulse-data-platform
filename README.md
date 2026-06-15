# FinPulse — Financial Transaction Analytics and Fraud Detection Platform

FinPulse is an end-to-end data platform project designed for financial transaction analytics, fraud detection, business intelligence, MLOps, and future AI/RAG integration.

The project simulates a banking and fintech environment using synthetic data only. It is designed to demonstrate practical skills across data analysis, data engineering, data science, business intelligence, machine learning engineering, and AI engineering.

---

## Project Objectives

The main objectives of FinPulse are to:

* Design a normalized OLTP database for financial operations.
* Model customers, accounts, cards, transactions, fees, merchants, fraud rules, and risk alerts.
* Build a SQL Server-based transactional data layer.
* Prepare data for analytics, reporting, fraud detection, and future data warehouse development.
* Demonstrate clean database design, documentation, validation, and Git-based project workflow.

---

## Current Project Scope

The current completed scope focuses on the OLTP layer.

Completed components include:

* Business requirements documentation.
* Chen-style Enhanced Entity Relationship Diagram.
* Entity list and normalization notes.
* Relationship rules and cardinality documentation.
* SQL Server OLTP database creation script.
* Core user, customer, admin, account, card, transaction, fee, and risk tables.
* Primary keys, foreign keys, check constraints, and unique constraints.
* Query performance indexes.
* Reference seed data.
* Operational sample data.
* OLTP validation queries.
* Business analysis queries.

---

## Repository Structure

```text
FinPulse
├── diagrams
│   └── finpulse_eerd_chen.png
│
├── docs
│   ├── architecture.md
│   ├── business_requirements.md
│   ├── entity_list.md
│   ├── normalization_note.md
│   └── relationship_rules.md
│
├── sql
│   ├── analytics
│   │   └── 10_oltp_business_queries.sql
│   │
│   ├── etl
│   │   └── .gitkeep
│   │
│   ├── oltp
│   │   ├── 00_create_database.sql
│   │   ├── 01_create_core_user_admin_tables.sql
│   │   ├── 02_create_account_card_tables.sql
│   │   ├── 03_create_reference_merchant_tables.sql
│   │   ├── 04_create_transaction_tables.sql
│   │   ├── 05_create_fee_risk_tables.sql
│   │   ├── 06_create_indexes_constraints.sql
│   │   ├── 07_seed_reference_data.sql
│   │   └── 09_seed_operational_sample_data.sql
│   │
│   ├── validation
│   │   └── 08_oltp_validation_queries.sql
│   │
│   └── warehouse
│       └── .gitkeep
│
└── README.md
```

---

## OLTP Database

The OLTP database is implemented using Microsoft SQL Server.

Database name:

```sql
AI_Financial_OLTP
```

Main schemas:

| Schema  | Purpose                                                                                         |
| ------- | ----------------------------------------------------------------------------------------------- |
| `core`  | Users, customers, admins, branches, accounts, cards                                             |
| `ref`   | Currencies, channels, transaction types, merchant categories, merchants, fee rules, fraud rules |
| `txn`   | Transactions, transaction status history, transaction fee charges                               |
| `risk`  | Risk alerts and alert reviews                                                                   |
| `audit` | Reserved for future audit logs                                                                  |

---

## Main OLTP Entities

The OLTP model includes the following major entities:

* Users
* Customers
* Admins
* Admin Permissions
* Branches
* Accounts
* Cards
* Currencies
* Channels
* Transaction Types
* Merchant Categories
* Merchants
* Fee Rules
* Transactions
* Transaction Status History
* Transaction Fee Charges
* Fraud Rules
* Risk Alerts
* Alert Reviews

---

## Key Design Features

The OLTP layer includes:

* Supertype/subtype modeling for users, customers, and admins.
* Recursive admin permission relationship.
* Weak entity design for transaction status history.
* Optional relationships for card-based transactions and merchant-based transactions.
* Associative tables for fee charges and alert reviews.
* Normalized table structure following 1NF, 2NF, and 3NF principles.
* Synthetic data only, with no real personal or financial information.

---

## SQL Script Execution Order

Run the OLTP scripts in this order:

```text
00_create_database.sql
01_create_core_user_admin_tables.sql
02_create_account_card_tables.sql
03_create_reference_merchant_tables.sql
04_create_transaction_tables.sql
05_create_fee_risk_tables.sql
06_create_indexes_constraints.sql
07_seed_reference_data.sql
09_seed_operational_sample_data.sql
08_oltp_validation_queries.sql
10_oltp_business_queries.sql
```

Note:

* Scripts `00` to `07` and `09` create and populate the OLTP database.
* Script `08` validates database structure, constraints, indexes, and row counts.
* Script `10` demonstrates business analysis queries using the OLTP sample data.

---

## Sample Business Questions Supported

The current OLTP layer can answer questions such as:

* How many transactions are successful, pending, failed, reversed, or cancelled?
* Which transaction channels generate the highest transaction volume?
* Which customers generate the highest transaction value?
* Which merchant categories are associated with higher risk?
* How much fee is charged by transaction type, channel, and currency?
* Which transactions triggered risk alerts?
* Which alerts have been reviewed by risk analysts?
* How does transaction status change over time?

---

## Technology Stack

Current technologies used:

* Microsoft SQL Server 2022
* T-SQL
* Docker Desktop
* SQL Server Management Studio
* Git and GitHub
* Draw.io for EERD design

Planned technologies:

* Python
* PySpark
* Data Lake architecture
* Data Warehouse modeling
* Power BI
* Machine learning fraud detection
* MLOps pipeline
* RAG-based financial assistant

---

## Current Status

The OLTP layer is completed.

Completed milestones:

* Requirements documentation
* Conceptual EERD
* Normalized OLTP schema
* SQL Server database scripts
* Reference data seeding
* Operational sample data seeding
* Validation queries
* Business analysis queries

Next planned milestone:

* Design and implement the analytical data warehouse layer.
