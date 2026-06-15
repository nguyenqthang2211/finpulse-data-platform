/*
    Project: FinPulse
    Script: 05_create_fee_risk_tables.sql
    Purpose: Create fee and risk management tables
    Engine: SQL Server / T-SQL

    Notes:
    - This script creates fee rule, transaction fee charge, fraud rule,
      risk alert, and alert review tables based on the Chen-style EERD.
    - It implements:
        FEE RULES
        TRANSACTIONS - Charged Fee - FEE RULES
        FRAUD RULES
        TRANSACTIONS - Triggers - RISK ALERTS
        FRAUD RULES - Based On - RISK ALERTS
        ADMINS - Reviewed By - RISK ALERTS
*/

USE AI_Financial_OLTP;
GO

/* ============================================================
   Drop tables in dependency order for development reruns
   ============================================================ */

IF OBJECT_ID('risk.alert_reviews', 'U') IS NOT NULL
    DROP TABLE risk.alert_reviews;
GO

IF OBJECT_ID('risk.risk_alerts', 'U') IS NOT NULL
    DROP TABLE risk.risk_alerts;
GO

IF OBJECT_ID('txn.transaction_fee_charges', 'U') IS NOT NULL
    DROP TABLE txn.transaction_fee_charges;
GO

IF OBJECT_ID('ref.fee_rules', 'U') IS NOT NULL
    DROP TABLE ref.fee_rules;
GO

IF OBJECT_ID('ref.fraud_rules', 'U') IS NOT NULL
    DROP TABLE ref.fraud_rules;
GO

/* ============================================================
   Table: ref.fee_rules
   Entity: FEE RULES
   Relationships:
   - TRANSACTION TYPE 1 - Applies To - N FEE RULES
   - CHANNELS 1 - Applies Through - N FEE RULES
   - CURRENCIES 1 - Applies In - N FEE RULES
   ============================================================ */

CREATE TABLE ref.fee_rules (
    fee_rule_id             BIGINT IDENTITY(1,1) NOT NULL,
    transaction_type_id     BIGINT NOT NULL,
    channel_id              BIGINT NOT NULL,
    currency_code           CHAR(3) NOT NULL,
    fixed_fee               DECIMAL(19,4) NOT NULL,
    percentage              DECIMAL(9,6) NOT NULL,
    minimum_amount          DECIMAL(19,4) NOT NULL,
    maximum_amount          DECIMAL(19,4) NULL,
    valid_from              DATE NOT NULL,
    valid_to                DATE NULL,
    fee_rule_status         VARCHAR(30) NOT NULL,

    CONSTRAINT pk_ref_fee_rules
        PRIMARY KEY (fee_rule_id),

    CONSTRAINT fk_ref_fee_rules_transaction_types
        FOREIGN KEY (transaction_type_id)
        REFERENCES ref.transaction_types(transaction_type_id),

    CONSTRAINT fk_ref_fee_rules_channels
        FOREIGN KEY (channel_id)
        REFERENCES ref.channels(channel_id),

    CONSTRAINT fk_ref_fee_rules_currencies
        FOREIGN KEY (currency_code)
        REFERENCES ref.currencies(currency_code),

    CONSTRAINT ck_ref_fee_rules_fixed_fee
        CHECK (fixed_fee >= 0),

    CONSTRAINT ck_ref_fee_rules_percentage
        CHECK (percentage >= 0 AND percentage <= 1),

    CONSTRAINT ck_ref_fee_rules_minimum_amount
        CHECK (minimum_amount >= 0),

    CONSTRAINT ck_ref_fee_rules_maximum_amount
        CHECK (maximum_amount IS NULL OR maximum_amount >= minimum_amount),

    CONSTRAINT ck_ref_fee_rules_valid_dates
        CHECK (valid_to IS NULL OR valid_to >= valid_from),

    CONSTRAINT ck_ref_fee_rules_status
        CHECK (fee_rule_status IN ('ACTIVE', 'INACTIVE', 'EXPIRED'))
);
GO

/* ============================================================
   Table: txn.transaction_fee_charges
   Associative table from relationship:
   TRANSACTIONS - Charged Fee - FEE RULES
   ============================================================ */

CREATE TABLE txn.transaction_fee_charges (
    fee_charge_id       BIGINT IDENTITY(1,1) NOT NULL,
    transaction_id      BIGINT NOT NULL,
    fee_rule_id         BIGINT NOT NULL,
    fee_amount          DECIMAL(19,4) NOT NULL,
    calculated_at       DATETIME2(0) NOT NULL,
    calculation_note    NVARCHAR(500) NULL,

    CONSTRAINT pk_txn_transaction_fee_charges
        PRIMARY KEY (fee_charge_id),

    CONSTRAINT fk_txn_fee_charges_transactions
        FOREIGN KEY (transaction_id)
        REFERENCES txn.transactions(transaction_id),

    CONSTRAINT fk_txn_fee_charges_fee_rules
        FOREIGN KEY (fee_rule_id)
        REFERENCES ref.fee_rules(fee_rule_id),

    CONSTRAINT ck_txn_fee_charges_amount
        CHECK (fee_amount >= 0),

    CONSTRAINT uq_txn_fee_charges_transaction_fee_rule
        UNIQUE (transaction_id, fee_rule_id)
);
GO

/* ============================================================
   Table: ref.fraud_rules
   Entity: FRAUD RULES
   ============================================================ */

CREATE TABLE ref.fraud_rules (
    fraud_rule_id       BIGINT IDENTITY(1,1) NOT NULL,
    rule_name           NVARCHAR(150) NOT NULL,
    rule_type           VARCHAR(50) NOT NULL,
    threshold_value     DECIMAL(19,4) NULL,
    description         NVARCHAR(500) NULL,
    is_active           BIT NOT NULL,

    CONSTRAINT pk_ref_fraud_rules
        PRIMARY KEY (fraud_rule_id),

    CONSTRAINT uq_ref_fraud_rules_rule_name
        UNIQUE (rule_name),

    CONSTRAINT ck_ref_fraud_rules_rule_type
        CHECK (rule_type IN (
            'AMOUNT_THRESHOLD',
            'VELOCITY',
            'MERCHANT_RISK',
            'CHANNEL_RISK',
            'COUNTRY_RISK',
            'CUSTOM'
        ))
);
GO

/* ============================================================
   Table: risk.risk_alerts
   Entity: RISK ALERTS
   Relationships:
   - TRANSACTIONS 1 - Triggers - N RISK ALERTS
   - FRAUD RULES 1 - Based On - N RISK ALERTS
   ============================================================ */

CREATE TABLE risk.risk_alerts (
    risk_alert_id       BIGINT IDENTITY(1,1) NOT NULL,
    transaction_id      BIGINT NOT NULL,
    fraud_rule_id       BIGINT NOT NULL,
    risk_score          DECIMAL(5,2) NOT NULL,
    risk_reason         NVARCHAR(500) NOT NULL,
    alert_status        VARCHAR(30) NOT NULL,
    created_at          DATETIME2(0) NOT NULL,
    resolved_at         DATETIME2(0) NULL,

    CONSTRAINT pk_risk_risk_alerts
        PRIMARY KEY (risk_alert_id),

    CONSTRAINT fk_risk_alerts_transactions
        FOREIGN KEY (transaction_id)
        REFERENCES txn.transactions(transaction_id),

    CONSTRAINT fk_risk_alerts_fraud_rules
        FOREIGN KEY (fraud_rule_id)
        REFERENCES ref.fraud_rules(fraud_rule_id),

    CONSTRAINT ck_risk_alerts_score
        CHECK (risk_score >= 0 AND risk_score <= 100),

    CONSTRAINT ck_risk_alerts_status
        CHECK (alert_status IN (
            'OPEN',
            'UNDER_REVIEW',
            'RESOLVED',
            'DISMISSED',
            'ESCALATED'
        )),

    CONSTRAINT ck_risk_alerts_resolved_at
        CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);
GO

/* ============================================================
   Table: risk.alert_reviews
   Associative table from relationship:
   ADMINS - Reviewed By - RISK ALERTS
   ============================================================ */

CREATE TABLE risk.alert_reviews (
    review_id           BIGINT IDENTITY(1,1) NOT NULL,
    risk_alert_id       BIGINT NOT NULL,
    admin_id            BIGINT NOT NULL,
    reviewed_at         DATETIME2(0) NOT NULL,
    review_decision     VARCHAR(50) NOT NULL,
    review_note         NVARCHAR(500) NULL,

    CONSTRAINT pk_risk_alert_reviews
        PRIMARY KEY (review_id),

    CONSTRAINT fk_risk_alert_reviews_risk_alerts
        FOREIGN KEY (risk_alert_id)
        REFERENCES risk.risk_alerts(risk_alert_id),

    CONSTRAINT fk_risk_alert_reviews_admins
        FOREIGN KEY (admin_id)
        REFERENCES core.admins(admin_id),

    CONSTRAINT ck_risk_alert_reviews_decision
        CHECK (review_decision IN (
            'CONFIRMED_FRAUD',
            'FALSE_POSITIVE',
            'NEED_MORE_INFO',
            'ESCALATED',
            'DISMISSED'
        ))
);
GO