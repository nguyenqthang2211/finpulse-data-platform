/*
    Project: FinPulse
    Script: 06_create_indexes_constraints.sql
    Purpose: Create additional indexes for OLTP query performance
    Engine: SQL Server / T-SQL

    Notes:
    - Primary keys, unique constraints, foreign keys, and check constraints
      are already defined in previous table creation scripts.
    - This script adds nonclustered indexes for common join, filter,
      lookup, and reporting patterns.
*/

USE AI_Financial_OLTP;
GO

/* ============================================================
   core.users
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_users_account_status'
      AND object_id = OBJECT_ID('core.users')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_users_account_status
    ON core.users (account_status);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_users_registered_at'
      AND object_id = OBJECT_ID('core.users')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_users_registered_at
    ON core.users (registered_at);
END;
GO

/* ============================================================
   core.customers
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_customers_user_id'
      AND object_id = OBJECT_ID('core.customers')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_customers_user_id
    ON core.customers (user_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_customers_segment_status'
      AND object_id = OBJECT_ID('core.customers')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_customers_segment_status
    ON core.customers (customer_segment, customer_status);
END;
GO

/* ============================================================
   core.admins
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_admins_user_id'
      AND object_id = OBJECT_ID('core.admins')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_admins_user_id
    ON core.admins (user_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_admins_role_status'
      AND object_id = OBJECT_ID('core.admins')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_admins_role_status
    ON core.admins (role, admin_status);
END;
GO

/* ============================================================
   core.admin_permissions
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_admin_permissions_grantor'
      AND object_id = OBJECT_ID('core.admin_permissions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_admin_permissions_grantor
    ON core.admin_permissions (grantor_admin_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_admin_permissions_grantee'
      AND object_id = OBJECT_ID('core.admin_permissions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_admin_permissions_grantee
    ON core.admin_permissions (grantee_admin_id);
END;
GO

/* ============================================================
   core.accounts
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_accounts_customer_id'
      AND object_id = OBJECT_ID('core.accounts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_accounts_customer_id
    ON core.accounts (customer_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_accounts_branch_id'
      AND object_id = OBJECT_ID('core.accounts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_accounts_branch_id
    ON core.accounts (branch_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_accounts_currency_code'
      AND object_id = OBJECT_ID('core.accounts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_accounts_currency_code
    ON core.accounts (currency_code);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_accounts_status_type'
      AND object_id = OBJECT_ID('core.accounts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_accounts_status_type
    ON core.accounts (account_status, account_type);
END;
GO

/* ============================================================
   core.cards
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_cards_account_id'
      AND object_id = OBJECT_ID('core.cards')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_cards_account_id
    ON core.cards (account_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_core_cards_status_type'
      AND object_id = OBJECT_ID('core.cards')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_core_cards_status_type
    ON core.cards (card_status, card_type);
END;
GO

/* ============================================================
   ref.merchants
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_ref_merchants_category_id'
      AND object_id = OBJECT_ID('ref.merchants')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_ref_merchants_category_id
    ON ref.merchants (merchant_category_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_ref_merchants_country_city'
      AND object_id = OBJECT_ID('ref.merchants')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_ref_merchants_country_city
    ON ref.merchants (country, city);
END;
GO

/* ============================================================
   txn.transactions
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_account_id'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_account_id
    ON txn.transactions (account_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_card_id'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_card_id
    ON txn.transactions (card_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_channel_id'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_channel_id
    ON txn.transactions (channel_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_transaction_type_id'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_transaction_type_id
    ON txn.transactions (transaction_type_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_currency_code'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_currency_code
    ON txn.transactions (currency_code);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_merchant_id'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_merchant_id
    ON txn.transactions (merchant_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_time_status'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_time_status
    ON txn.transactions (transaction_time, transaction_status);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_transactions_status_time'
      AND object_id = OBJECT_ID('txn.transactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_transactions_status_time
    ON txn.transactions (transaction_status, transaction_time);
END;
GO

/* ============================================================
   txn.transaction_status_history
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_status_history_changed_at'
      AND object_id = OBJECT_ID('txn.transaction_status_history')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_status_history_changed_at
    ON txn.transaction_status_history (changed_at);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_status_history_new_status'
      AND object_id = OBJECT_ID('txn.transaction_status_history')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_status_history_new_status
    ON txn.transaction_status_history (new_status);
END;
GO

/* ============================================================
   ref.fee_rules
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_ref_fee_rules_type_channel_currency'
      AND object_id = OBJECT_ID('ref.fee_rules')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_ref_fee_rules_type_channel_currency
    ON ref.fee_rules (transaction_type_id, channel_id, currency_code);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_ref_fee_rules_status_validity'
      AND object_id = OBJECT_ID('ref.fee_rules')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_ref_fee_rules_status_validity
    ON ref.fee_rules (fee_rule_status, valid_from, valid_to);
END;
GO

/* ============================================================
   txn.transaction_fee_charges
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_fee_charges_transaction_id'
      AND object_id = OBJECT_ID('txn.transaction_fee_charges')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_fee_charges_transaction_id
    ON txn.transaction_fee_charges (transaction_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_fee_charges_fee_rule_id'
      AND object_id = OBJECT_ID('txn.transaction_fee_charges')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_fee_charges_fee_rule_id
    ON txn.transaction_fee_charges (fee_rule_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_txn_fee_charges_calculated_at'
      AND object_id = OBJECT_ID('txn.transaction_fee_charges')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_txn_fee_charges_calculated_at
    ON txn.transaction_fee_charges (calculated_at);
END;
GO

/* ============================================================
   risk.risk_alerts
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alerts_transaction_id'
      AND object_id = OBJECT_ID('risk.risk_alerts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alerts_transaction_id
    ON risk.risk_alerts (transaction_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alerts_fraud_rule_id'
      AND object_id = OBJECT_ID('risk.risk_alerts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alerts_fraud_rule_id
    ON risk.risk_alerts (fraud_rule_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alerts_status_created_at'
      AND object_id = OBJECT_ID('risk.risk_alerts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alerts_status_created_at
    ON risk.risk_alerts (alert_status, created_at);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alerts_score'
      AND object_id = OBJECT_ID('risk.risk_alerts')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alerts_score
    ON risk.risk_alerts (risk_score);
END;
GO

/* ============================================================
   risk.alert_reviews
   ============================================================ */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alert_reviews_risk_alert_id'
      AND object_id = OBJECT_ID('risk.alert_reviews')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alert_reviews_risk_alert_id
    ON risk.alert_reviews (risk_alert_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alert_reviews_admin_id'
      AND object_id = OBJECT_ID('risk.alert_reviews')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alert_reviews_admin_id
    ON risk.alert_reviews (admin_id);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'ix_risk_alert_reviews_reviewed_at'
      AND object_id = OBJECT_ID('risk.alert_reviews')
)
BEGIN
    CREATE NONCLUSTERED INDEX ix_risk_alert_reviews_reviewed_at
    ON risk.alert_reviews (reviewed_at);
END;
GO