/*
    Project: FinPulse
    Script: 07_seed_reference_data.sql
    Purpose: Seed reference and configuration data for the OLTP database
    Engine: SQL Server / T-SQL

    Notes:
    - This script inserts synthetic reference data only.
    - It is idempotent: running it multiple times will not duplicate records.
    - It seeds currencies, channels, transaction types, merchant categories,
      merchants, fee rules, and fraud rules.
*/

USE AI_Financial_OLTP;
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

/* ============================================================
   Seed: ref.currencies
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.currencies WHERE currency_code = 'VND')
BEGIN
    INSERT INTO ref.currencies (currency_code, currency_name, symbol, country)
    VALUES ('VND', 'Vietnamese Dong', N'₫', 'Vietnam');
END;

IF NOT EXISTS (SELECT 1 FROM ref.currencies WHERE currency_code = 'USD')
BEGIN
    INSERT INTO ref.currencies (currency_code, currency_name, symbol, country)
    VALUES ('USD', 'US Dollar', N'$', 'United States');
END;

IF NOT EXISTS (SELECT 1 FROM ref.currencies WHERE currency_code = 'EUR')
BEGIN
    INSERT INTO ref.currencies (currency_code, currency_name, symbol, country)
    VALUES ('EUR', 'Euro', N'€', 'European Union');
END;

IF NOT EXISTS (SELECT 1 FROM ref.currencies WHERE currency_code = 'JPY')
BEGIN
    INSERT INTO ref.currencies (currency_code, currency_name, symbol, country)
    VALUES ('JPY', 'Japanese Yen', N'¥', 'Japan');
END;

IF NOT EXISTS (SELECT 1 FROM ref.currencies WHERE currency_code = 'SGD')
BEGIN
    INSERT INTO ref.currencies (currency_code, currency_name, symbol, country)
    VALUES ('SGD', 'Singapore Dollar', N'S$', 'Singapore');
END;


/* ============================================================
   Seed: ref.channels
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'Mobile Banking')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('Mobile Banking', 'DIGITAL', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'Internet Banking')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('Internet Banking', 'DIGITAL', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'ATM')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('ATM', 'ATM', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'POS')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('POS', 'POS', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'Branch Counter')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('Branch Counter', 'BRANCH', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM ref.channels WHERE channel_name = 'Partner API')
BEGIN
    INSERT INTO ref.channels (channel_name, channel_type, channel_status)
    VALUES ('Partner API', 'API', 'ACTIVE');
END;


/* ============================================================
   Seed: ref.transaction_types
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Deposit')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Deposit', 'Money deposited into a customer account.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Withdrawal')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Withdrawal', 'Money withdrawn from a customer account.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Transfer')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Transfer', 'Money transferred between accounts.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Payment')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Payment', 'Payment made to a merchant or service provider.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Refund')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Refund', 'Money returned to a customer account.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.transaction_types WHERE transaction_type_name = 'Reversal')
BEGIN
    INSERT INTO ref.transaction_types (transaction_type_name, description)
    VALUES ('Reversal', 'Transaction reversed due to correction or failure.');
END;


/* ============================================================
   Seed: ref.merchant_categories
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Retail')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Retail', 'LOW', 'General retail stores and supermarkets.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Restaurant')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Restaurant', 'LOW', 'Restaurants, cafes, and food services.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Travel')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Travel', 'MEDIUM', 'Airlines, hotels, and travel agencies.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Entertainment')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Entertainment', 'MEDIUM', 'Entertainment services and digital content.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Online Services')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Online Services', 'HIGH', 'Online platforms, subscriptions, and digital services.');
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchant_categories WHERE category_name = 'Crypto Exchange')
BEGIN
    INSERT INTO ref.merchant_categories (category_name, risk_level, description)
    VALUES ('Crypto Exchange', 'CRITICAL', 'High-risk digital asset exchange merchants.');
END;


/* ============================================================
   Seed: ref.merchants
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.merchants WHERE merchant_code = 'MRC_RETAIL_001')
BEGIN
    INSERT INTO ref.merchants (
        merchant_category_id,
        merchant_code,
        merchant_name,
        country,
        city,
        merchant_status
    )
    SELECT
        merchant_category_id,
        'MRC_RETAIL_001',
        'FinMart Supermarket',
        'Vietnam',
        'Ho Chi Minh City',
        'ACTIVE'
    FROM ref.merchant_categories
    WHERE category_name = 'Retail';
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchants WHERE merchant_code = 'MRC_RESTAURANT_001')
BEGIN
    INSERT INTO ref.merchants (
        merchant_category_id,
        merchant_code,
        merchant_name,
        country,
        city,
        merchant_status
    )
    SELECT
        merchant_category_id,
        'MRC_RESTAURANT_001',
        'Lotus Coffee',
        'Vietnam',
        'Ha Noi',
        'ACTIVE'
    FROM ref.merchant_categories
    WHERE category_name = 'Restaurant';
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchants WHERE merchant_code = 'MRC_TRAVEL_001')
BEGIN
    INSERT INTO ref.merchants (
        merchant_category_id,
        merchant_code,
        merchant_name,
        country,
        city,
        merchant_status
    )
    SELECT
        merchant_category_id,
        'MRC_TRAVEL_001',
        'SkyWay Travel',
        'Singapore',
        'Singapore',
        'ACTIVE'
    FROM ref.merchant_categories
    WHERE category_name = 'Travel';
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchants WHERE merchant_code = 'MRC_ONLINE_001')
BEGIN
    INSERT INTO ref.merchants (
        merchant_category_id,
        merchant_code,
        merchant_name,
        country,
        city,
        merchant_status
    )
    SELECT
        merchant_category_id,
        'MRC_ONLINE_001',
        'CloudBox Online Services',
        'United States',
        'San Francisco',
        'ACTIVE'
    FROM ref.merchant_categories
    WHERE category_name = 'Online Services';
END;

IF NOT EXISTS (SELECT 1 FROM ref.merchants WHERE merchant_code = 'MRC_CRYPTO_001')
BEGIN
    INSERT INTO ref.merchants (
        merchant_category_id,
        merchant_code,
        merchant_name,
        country,
        city,
        merchant_status
    )
    SELECT
        merchant_category_id,
        'MRC_CRYPTO_001',
        'BlockX Exchange',
        'Singapore',
        'Singapore',
        'ACTIVE'
    FROM ref.merchant_categories
    WHERE category_name = 'Crypto Exchange';
END;


/* ============================================================
   Seed: ref.fee_rules
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM ref.fee_rules fr
    JOIN ref.transaction_types tt
        ON fr.transaction_type_id = tt.transaction_type_id
    JOIN ref.channels ch
        ON fr.channel_id = ch.channel_id
    WHERE tt.transaction_type_name = 'Transfer'
      AND ch.channel_name = 'Mobile Banking'
      AND fr.currency_code = 'VND'
)
BEGIN
    INSERT INTO ref.fee_rules (
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
    SELECT
        tt.transaction_type_id,
        ch.channel_id,
        'VND',
        1000.0000,
        0.001000,
        0.0000,
        NULL,
        '2026-01-01',
        NULL,
        'ACTIVE'
    FROM ref.transaction_types tt
    CROSS JOIN ref.channels ch
    WHERE tt.transaction_type_name = 'Transfer'
      AND ch.channel_name = 'Mobile Banking';
END;

IF NOT EXISTS (
    SELECT 1
    FROM ref.fee_rules fr
    JOIN ref.transaction_types tt
        ON fr.transaction_type_id = tt.transaction_type_id
    JOIN ref.channels ch
        ON fr.channel_id = ch.channel_id
    WHERE tt.transaction_type_name = 'Withdrawal'
      AND ch.channel_name = 'ATM'
      AND fr.currency_code = 'VND'
)
BEGIN
    INSERT INTO ref.fee_rules (
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
    SELECT
        tt.transaction_type_id,
        ch.channel_id,
        'VND',
        3000.0000,
        0.000000,
        0.0000,
        NULL,
        '2026-01-01',
        NULL,
        'ACTIVE'
    FROM ref.transaction_types tt
    CROSS JOIN ref.channels ch
    WHERE tt.transaction_type_name = 'Withdrawal'
      AND ch.channel_name = 'ATM';
END;

IF NOT EXISTS (
    SELECT 1
    FROM ref.fee_rules fr
    JOIN ref.transaction_types tt
        ON fr.transaction_type_id = tt.transaction_type_id
    JOIN ref.channels ch
        ON fr.channel_id = ch.channel_id
    WHERE tt.transaction_type_name = 'Payment'
      AND ch.channel_name = 'POS'
      AND fr.currency_code = 'VND'
)
BEGIN
    INSERT INTO ref.fee_rules (
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
    SELECT
        tt.transaction_type_id,
        ch.channel_id,
        'VND',
        0.0000,
        0.002000,
        0.0000,
        NULL,
        '2026-01-01',
        NULL,
        'ACTIVE'
    FROM ref.transaction_types tt
    CROSS JOIN ref.channels ch
    WHERE tt.transaction_type_name = 'Payment'
      AND ch.channel_name = 'POS';
END;

IF NOT EXISTS (
    SELECT 1
    FROM ref.fee_rules fr
    JOIN ref.transaction_types tt
        ON fr.transaction_type_id = tt.transaction_type_id
    JOIN ref.channels ch
        ON fr.channel_id = ch.channel_id
    WHERE tt.transaction_type_name = 'Transfer'
      AND ch.channel_name = 'Internet Banking'
      AND fr.currency_code = 'USD'
)
BEGIN
    INSERT INTO ref.fee_rules (
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
    SELECT
        tt.transaction_type_id,
        ch.channel_id,
        'USD',
        1.0000,
        0.001500,
        0.0000,
        NULL,
        '2026-01-01',
        NULL,
        'ACTIVE'
    FROM ref.transaction_types tt
    CROSS JOIN ref.channels ch
    WHERE tt.transaction_type_name = 'Transfer'
      AND ch.channel_name = 'Internet Banking';
END;


/* ============================================================
   Seed: ref.fraud_rules
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM ref.fraud_rules WHERE rule_name = 'High Amount Transaction')
BEGIN
    INSERT INTO ref.fraud_rules (
        rule_name,
        rule_type,
        threshold_value,
        description,
        is_active
    )
    VALUES (
        'High Amount Transaction',
        'AMOUNT_THRESHOLD',
        100000000.0000,
        'Generate an alert when a transaction amount exceeds the configured threshold.',
        1
    );
END;

IF NOT EXISTS (SELECT 1 FROM ref.fraud_rules WHERE rule_name = 'High Frequency Transactions')
BEGIN
    INSERT INTO ref.fraud_rules (
        rule_name,
        rule_type,
        threshold_value,
        description,
        is_active
    )
    VALUES (
        'High Frequency Transactions',
        'VELOCITY',
        10.0000,
        'Generate an alert when too many transactions occur within a short time window.',
        1
    );
END;

IF NOT EXISTS (SELECT 1 FROM ref.fraud_rules WHERE rule_name = 'High Risk Merchant Category')
BEGIN
    INSERT INTO ref.fraud_rules (
        rule_name,
        rule_type,
        threshold_value,
        description,
        is_active
    )
    VALUES (
        'High Risk Merchant Category',
        'MERCHANT_RISK',
        NULL,
        'Generate an alert when a transaction involves a high-risk merchant category.',
        1
    );
END;

IF NOT EXISTS (SELECT 1 FROM ref.fraud_rules WHERE rule_name = 'Suspicious Digital Channel')
BEGIN
    INSERT INTO ref.fraud_rules (
        rule_name,
        rule_type,
        threshold_value,
        description,
        is_active
    )
    VALUES (
        'Suspicious Digital Channel',
        'CHANNEL_RISK',
        NULL,
        'Generate an alert when digital channel behavior appears suspicious.',
        1
    );
END;

COMMIT TRANSACTION;
GO