# OLTP Relational Schema Mapping

## 1. Overview

This document describes the mapping from the FinPulse EERD design to the relational database schema.

The mapping follows the same style as a database design report: each relation is listed with its attributes, followed by primary key and foreign key constraints.

The current relational schema is implemented in Microsoft SQL Server under the database:

```sql
AI_Financial_OLTP
```

Main schemas:

* `core`: user, customer, admin, branch, account, and card data.
* `ref`: reference data such as currencies, channels, transaction types, merchants, fee rules, and fraud rules.
* `txn`: transaction data and transaction history.
* `risk`: risk alerts and alert reviews.
* `audit`: reserved for future audit logs.

---

# 2. Relational Schema Mapping

## 2.1 USERS

```text
USERS (
    user_id,
    username,
    phone,
    email,
    address,
    account_status,
    registered_at
)
```

**PK:** `user_id`

**Unique constraints:**

```text
username
email
```

**Explanation:**

The `USERS` relation stores common information shared by all system users. In the EERD, `USERS` is the superclass of `CUSTOMERS` and `ADMINS`.

---

## 2.2 CUSTOMERS

```text
CUSTOMERS (
    customer_id,
    user_id,
    first_name,
    middle_initial,
    last_name,
    gender,
    date_of_birth,
    kyc_status,
    customer_segment,
    customer_status
)
```

**PK:** `customer_id`

**FK:**

```text
user_id → USERS(user_id)
```

**Unique constraints:**

```text
user_id
```

**Explanation:**

The `CUSTOMERS` relation stores customer-specific information. The `user_id` attribute links each customer to exactly one record in `USERS`.

Although the EERD represents `CUSTOMERS` as a subclass of `USERS`, the SQL implementation uses a separate surrogate key `customer_id` and a unique foreign key `user_id`.

---

## 2.3 ADMINS

```text
ADMINS (
    admin_id,
    user_id,
    role,
    department,
    admin_status
)
```

**PK:** `admin_id`

**FK:**

```text
user_id → USERS(user_id)
```

**Unique constraints:**

```text
user_id
```

**Explanation:**

The `ADMINS` relation stores administrator-specific information. Each admin is linked to one user account through `user_id`.

This table maps the admin subclass in the EERD.

---

## 2.4 ADMIN_PERMISSIONS

```text
ADMIN_PERMISSIONS (
    admin_permission_id,
    grantor_admin_id,
    grantee_admin_id,
    granted_at,
    permission_scope,
    permission_content
)
```

**PK:** `admin_permission_id`

**FK:**

```text
grantor_admin_id → ADMINS(admin_id)
grantee_admin_id → ADMINS(admin_id)
```

**Semantic constraint:**

```text
grantor_admin_id <> grantee_admin_id
```

**Explanation:**

The `ADMIN_PERMISSIONS` relation maps the recursive permission delegation relationship between administrators.

One admin can grant permissions to many other admins, and one admin can receive permissions from many admins.

---

## 2.5 BRANCHES

```text
BRANCHES (
    branch_id,
    branch_name,
    branch_code,
    city,
    address,
    branch_status
)
```

**PK:** `branch_id`

**Unique constraints:**

```text
branch_code
```

**Explanation:**

The `BRANCHES` relation stores information about bank branches or operating offices.

A branch can manage many accounts.

---

## 2.6 CURRENCIES

```text
CURRENCIES (
    currency_code,
    currency_name,
    symbol,
    country
)
```

**PK:** `currency_code`

**Unique constraints:**

```text
currency_name
```

**Explanation:**

The `CURRENCIES` relation stores currency reference data such as VND, USD, EUR, JPY, and SGD.

A currency can be used by many accounts, transactions, and fee rules.

---

## 2.7 ACCOUNTS

```text
ACCOUNTS (
    account_id,
    customer_id,
    branch_id,
    currency_code,
    account_number,
    account_type,
    balance,
    opened_date,
    account_status
)
```

**PK:** `account_id`

**FK:**

```text
customer_id → CUSTOMERS(customer_id)
branch_id → BRANCHES(branch_id)
currency_code → CURRENCIES(currency_code)
```

**Unique constraints:**

```text
account_number
```

**Explanation:**

The `ACCOUNTS` relation maps customer financial accounts.

Each account belongs to one customer, is managed by one branch, and uses one primary currency.

---

## 2.8 CARDS

```text
CARDS (
    card_id,
    account_id,
    masked_card_number,
    card_type,
    expiry_date,
    card_status
)
```

**PK:** `card_id`

**FK:**

```text
account_id → ACCOUNTS(account_id)
```

**Unique constraints:**

```text
masked_card_number
```

**Explanation:**

The `CARDS` relation stores payment cards linked to accounts.

One account can have many cards, but each card belongs to exactly one account.

---

## 2.9 CHANNELS

```text
CHANNELS (
    channel_id,
    channel_name,
    channel_type,
    channel_status
)
```

**PK:** `channel_id`

**Unique constraints:**

```text
channel_name
```

**Explanation:**

The `CHANNELS` relation stores transaction channels such as Mobile Banking, Internet Banking, ATM, POS, Branch Counter, and Partner API.

A channel can be used by many transactions and many fee rules.

---

## 2.10 TRANSACTION_TYPES

```text
TRANSACTION_TYPES (
    transaction_type_id,
    transaction_type_name,
    description
)
```

**PK:** `transaction_type_id`

**Unique constraints:**

```text
transaction_type_name
```

**Explanation:**

The `TRANSACTION_TYPES` relation stores transaction categories such as Deposit, Withdrawal, Transfer, Payment, Refund, and Reversal.

A transaction type can classify many transactions and can be used by many fee rules.

---

## 2.11 MERCHANT_CATEGORIES

```text
MERCHANT_CATEGORIES (
    merchant_category_id,
    category_name,
    risk_level,
    description
)
```

**PK:** `merchant_category_id`

**Unique constraints:**

```text
category_name
```

**Explanation:**

The `MERCHANT_CATEGORIES` relation stores merchant groups and their risk levels.

One merchant category can contain many merchants.

---

## 2.12 MERCHANTS

```text
MERCHANTS (
    merchant_id,
    merchant_category_id,
    merchant_code,
    merchant_name,
    country,
    city,
    merchant_status
)
```

**PK:** `merchant_id`

**FK:**

```text
merchant_category_id → MERCHANT_CATEGORIES(merchant_category_id)
```

**Unique constraints:**

```text
merchant_code
```

**Explanation:**

The `MERCHANTS` relation stores merchant information.

Each merchant belongs to one merchant category. A merchant can appear in many transactions, but not every transaction must involve a merchant.

---

## 2.13 FEE_RULES

```text
FEE_RULES (
    fee_rule_id,
    transaction_type_id,
    channel_id,
    currency_code,
    fixed_fee,
    percentage,
    minimum_amount,
    maximum_amount,
    valid_from,
    valid_to,
    fee_rule_status
)
```

**PK:** `fee_rule_id`

**FK:**

```text
transaction_type_id → TRANSACTION_TYPES(transaction_type_id)
channel_id → CHANNELS(channel_id)
currency_code → CURRENCIES(currency_code)
```

**Explanation:**

The `FEE_RULES` relation stores configurable transaction fee rules.

Each fee rule applies to one transaction type, one channel, and one currency.

---

## 2.14 TRANSACTIONS

```text
TRANSACTIONS (
    transaction_id,
    account_id,
    card_id,
    channel_id,
    transaction_type_id,
    currency_code,
    merchant_id,
    transaction_amount,
    transaction_time,
    reference_number,
    description,
    transaction_status,
    created_at
)
```

**PK:** `transaction_id`

**FK:**

```text
account_id → ACCOUNTS(account_id)
card_id → CARDS(card_id)
channel_id → CHANNELS(channel_id)
transaction_type_id → TRANSACTION_TYPES(transaction_type_id)
currency_code → CURRENCIES(currency_code)
merchant_id → MERCHANTS(merchant_id)
```

**Unique constraints:**

```text
reference_number
```

**Nullable foreign keys:**

```text
card_id
merchant_id
```

**Explanation:**

The `TRANSACTIONS` relation is the central fact-like OLTP table.

Each transaction must belong to one account, one channel, one transaction type, and one currency.

The attributes `card_id` and `merchant_id` are optional because not every transaction uses a card or involves a merchant. For example, a branch transfer may not use a card, and an internal transfer may not involve a merchant.

---

## 2.15 TRANSACTION_STATUS_HISTORY

```text
TRANSACTION_STATUS_HISTORY (
    transaction_id,
    status_sequence_no,
    old_status,
    new_status,
    changed_at,
    change_reason
)
```

**PK:**

```text
(transaction_id, status_sequence_no)
```

**FK:**

```text
transaction_id → TRANSACTIONS(transaction_id)
```

**Explanation:**

The `TRANSACTION_STATUS_HISTORY` relation maps the weak entity that records the status changes of each transaction.

The primary key is composite because one transaction can have multiple status changes over time.

---

## 2.16 TRANSACTION_FEE_CHARGES

```text
TRANSACTION_FEE_CHARGES (
    fee_charge_id,
    transaction_id,
    fee_rule_id,
    fee_amount,
    calculated_at,
    calculation_note
)
```

**PK:** `fee_charge_id`

**FK:**

```text
transaction_id → TRANSACTIONS(transaction_id)
fee_rule_id → FEE_RULES(fee_rule_id)
```

**Unique constraints:**

```text
(transaction_id, fee_rule_id)
```

**Explanation:**

The `TRANSACTION_FEE_CHARGES` relation maps the relationship between transactions and fee rules.

It is separated from `TRANSACTIONS` because a transaction may have different fee components and the system must preserve the exact fee rule applied at calculation time.

---

## 2.17 FRAUD_RULES

```text
FRAUD_RULES (
    fraud_rule_id,
    rule_name,
    rule_type,
    threshold_value,
    description,
    is_active
)
```

**PK:** `fraud_rule_id`

**Unique constraints:**

```text
rule_name
```

**Explanation:**

The `FRAUD_RULES` relation stores fraud detection rules such as high amount transaction, high frequency transactions, high risk merchant category, and suspicious digital channel.

One fraud rule can generate many risk alerts.

---

## 2.18 RISK_ALERTS

```text
RISK_ALERTS (
    risk_alert_id,
    transaction_id,
    fraud_rule_id,
    risk_score,
    risk_reason,
    alert_status,
    created_at,
    resolved_at
)
```

**PK:** `risk_alert_id`

**FK:**

```text
transaction_id → TRANSACTIONS(transaction_id)
fraud_rule_id → FRAUD_RULES(fraud_rule_id)
```

**Explanation:**

The `RISK_ALERTS` relation stores suspicious transaction alerts.

One transaction can trigger multiple risk alerts if it violates multiple fraud rules.

---

## 2.19 ALERT_REVIEWS

```text
ALERT_REVIEWS (
    review_id,
    risk_alert_id,
    admin_id,
    reviewed_at,
    review_decision,
    review_note
)
```

**PK:** `review_id`

**FK:**

```text
risk_alert_id → RISK_ALERTS(risk_alert_id)
admin_id → ADMINS(admin_id)
```

**Explanation:**

The `ALERT_REVIEWS` relation stores review actions performed by administrators or fraud analysts.

It maps the relationship between admins and risk alerts.

---

# 3. Mapping Rules by EERD Feature

## 3.1 Strong Entity Mapping

Each strong entity in the EERD is mapped to one relation.

Examples:

```text
USERS
BRANCHES
CURRENCIES
ACCOUNTS
CARDS
TRANSACTIONS
MERCHANTS
FRAUD_RULES
```

Each relation has its own primary key.

---

## 3.2 Superclass and Subclass Mapping

The EERD contains a superclass/subclass structure:

```text
USERS → CUSTOMERS
USERS → ADMINS
```

Mapping:

```text
USERS(user_id, username, phone, email, address, account_status, registered_at)

CUSTOMERS(customer_id, user_id, first_name, middle_initial, last_name, gender,
          date_of_birth, kyc_status, customer_segment, customer_status)

ADMINS(admin_id, user_id, role, department, admin_status)
```

Foreign keys:

```text
CUSTOMERS.user_id → USERS.user_id
ADMINS.user_id → USERS.user_id
```

The `user_id` in both subclass tables is unique to ensure that each customer or admin maps to one user account.

---

## 3.3 Recursive Relationship Mapping

The recursive relationship between admins is mapped into the relation:

```text
ADMIN_PERMISSIONS (
    admin_permission_id,
    grantor_admin_id,
    grantee_admin_id,
    granted_at,
    permission_scope,
    permission_content
)
```

Foreign keys:

```text
grantor_admin_id → ADMINS(admin_id)
grantee_admin_id → ADMINS(admin_id)
```

This relation stores permission delegation from one admin to another admin.

---

## 3.4 One-to-Many Relationship Mapping

Most 1:N relationships are mapped by placing the foreign key on the N-side relation.

Examples:

```text
CUSTOMERS 1:N ACCOUNTS
→ ACCOUNTS.customer_id references CUSTOMERS.customer_id

BRANCHES 1:N ACCOUNTS
→ ACCOUNTS.branch_id references BRANCHES.branch_id

ACCOUNTS 1:N CARDS
→ CARDS.account_id references ACCOUNTS.account_id

ACCOUNTS 1:N TRANSACTIONS
→ TRANSACTIONS.account_id references ACCOUNTS.account_id

MERCHANT_CATEGORIES 1:N MERCHANTS
→ MERCHANTS.merchant_category_id references MERCHANT_CATEGORIES.merchant_category_id

FRAUD_RULES 1:N RISK_ALERTS
→ RISK_ALERTS.fraud_rule_id references FRAUD_RULES.fraud_rule_id
```

---

## 3.5 Optional Relationship Mapping

Optional relationships are implemented using nullable foreign keys.

In the `TRANSACTIONS` relation:

```text
card_id nullable
merchant_id nullable
```

Meaning:

```text
A transaction may not use a card.
A transaction may not involve a merchant.
```

---

## 3.6 Weak Entity Mapping

The weak entity `TRANSACTION_STATUS_HISTORY` is mapped using a composite primary key:

```text
TRANSACTION_STATUS_HISTORY (
    transaction_id,
    status_sequence_no,
    old_status,
    new_status,
    changed_at,
    change_reason
)
```

Primary key:

```text
(transaction_id, status_sequence_no)
```

Foreign key:

```text
transaction_id → TRANSACTIONS(transaction_id)
```

The `status_sequence_no` distinguishes multiple status history records for the same transaction.

---

## 3.7 Associative Relationship Mapping

Associative relationships are mapped into separate relations.

### 3.7.1 Transaction Fee Charge

```text
TRANSACTION_FEE_CHARGES (
    fee_charge_id,
    transaction_id,
    fee_rule_id,
    fee_amount,
    calculated_at,
    calculation_note
)
```

Foreign keys:

```text
transaction_id → TRANSACTIONS(transaction_id)
fee_rule_id → FEE_RULES(fee_rule_id)
```

This relation stores the exact fee rule applied to a transaction.

### 3.7.2 Alert Review

```text
ALERT_REVIEWS (
    review_id,
    risk_alert_id,
    admin_id,
    reviewed_at,
    review_decision,
    review_note
)
```

Foreign keys:

```text
risk_alert_id → RISK_ALERTS(risk_alert_id)
admin_id → ADMINS(admin_id)
```

This relation stores which admin reviewed which risk alert.

---

# 4. Summary of Foreign Keys

```text
CUSTOMERS.user_id → USERS.user_id
ADMINS.user_id → USERS.user_id

ADMIN_PERMISSIONS.grantor_admin_id → ADMINS.admin_id
ADMIN_PERMISSIONS.grantee_admin_id → ADMINS.admin_id

ACCOUNTS.customer_id → CUSTOMERS.customer_id
ACCOUNTS.branch_id → BRANCHES.branch_id
ACCOUNTS.currency_code → CURRENCIES.currency_code

CARDS.account_id → ACCOUNTS.account_id

MERCHANTS.merchant_category_id → MERCHANT_CATEGORIES.merchant_category_id

FEE_RULES.transaction_type_id → TRANSACTION_TYPES.transaction_type_id
FEE_RULES.channel_id → CHANNELS.channel_id
FEE_RULES.currency_code → CURRENCIES.currency_code

TRANSACTIONS.account_id → ACCOUNTS.account_id
TRANSACTIONS.card_id → CARDS.card_id
TRANSACTIONS.channel_id → CHANNELS.channel_id
TRANSACTIONS.transaction_type_id → TRANSACTION_TYPES.transaction_type_id
TRANSACTIONS.currency_code → CURRENCIES.currency_code
TRANSACTIONS.merchant_id → MERCHANTS.merchant_id

TRANSACTION_STATUS_HISTORY.transaction_id → TRANSACTIONS.transaction_id

TRANSACTION_FEE_CHARGES.transaction_id → TRANSACTIONS.transaction_id
TRANSACTION_FEE_CHARGES.fee_rule_id → FEE_RULES.fee_rule_id

RISK_ALERTS.transaction_id → TRANSACTIONS.transaction_id
RISK_ALERTS.fraud_rule_id → FRAUD_RULES.fraud_rule_id

ALERT_REVIEWS.risk_alert_id → RISK_ALERTS.risk_alert_id
ALERT_REVIEWS.admin_id → ADMINS.admin_id
```

---

# 5. Mapping Summary

The FinPulse OLTP relational schema contains the following relations:

```text
1.  USERS
2.  CUSTOMERS
3.  ADMINS
4.  ADMIN_PERMISSIONS
5.  BRANCHES
6.  CURRENCIES
7.  ACCOUNTS
8.  CARDS
9.  CHANNELS
10. TRANSACTION_TYPES
11. MERCHANT_CATEGORIES
12. MERCHANTS
13. FEE_RULES
14. TRANSACTIONS
15. TRANSACTION_STATUS_HISTORY
16. TRANSACTION_FEE_CHARGES
17. FRAUD_RULES
18. RISK_ALERTS
19. ALERT_REVIEWS
```

This mapping preserves the main EERD design features:

```text
- Superclass/subclass mapping
- Recursive relationship mapping
- One-to-many relationship mapping
- Optional foreign key mapping
- Weak entity mapping
- Associative relationship mapping
- Reference table mapping
```

The result is a normalized relational schema suitable for SQL Server implementation, OLTP transaction processing, validation queries, business analysis queries, and future data warehouse development.
