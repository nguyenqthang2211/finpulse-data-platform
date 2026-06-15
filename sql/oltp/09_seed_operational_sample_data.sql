/*
    Project: FinPulse
    Script: 09_seed_operational_sample_data.sql
    Purpose: Seed synthetic operational sample data for OLTP end-to-end testing
    Engine: SQL Server / T-SQL

    Notes:
    - This script uses synthetic data only.
    - It is idempotent: running it multiple times will not duplicate records.
    - It should be run after:
        00_create_database.sql
        01_create_core_user_admin_tables.sql
        02_create_account_card_tables.sql
        03_create_reference_merchant_tables.sql
        04_create_transaction_tables.sql
        05_create_fee_risk_tables.sql
        06_create_indexes_constraints.sql
        07_seed_reference_data.sql
*/

USE AI_Financial_OLTP;
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

/* ============================================================
   1. Seed core.users
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'customer_001')
BEGIN
    INSERT INTO core.users (username, phone, email, address, account_status, registered_at)
    VALUES ('customer_001', '0900000001', 'customer001@example.com', 'Ho Chi Minh City, Vietnam', 'ACTIVE', SYSDATETIME());
END;

IF NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'customer_002')
BEGIN
    INSERT INTO core.users (username, phone, email, address, account_status, registered_at)
    VALUES ('customer_002', '0900000002', 'customer002@example.com', 'Ha Noi, Vietnam', 'ACTIVE', SYSDATETIME());
END;

IF NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'customer_003')
BEGIN
    INSERT INTO core.users (username, phone, email, address, account_status, registered_at)
    VALUES ('customer_003', '0900000003', 'customer003@example.com', 'Da Nang, Vietnam', 'ACTIVE', SYSDATETIME());
END;

IF NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'admin_001')
BEGIN
    INSERT INTO core.users (username, phone, email, address, account_status, registered_at)
    VALUES ('admin_001', '0910000001', 'admin001@example.com', 'Ho Chi Minh City, Vietnam', 'ACTIVE', SYSDATETIME());
END;

IF NOT EXISTS (SELECT 1 FROM core.users WHERE username = 'admin_002')
BEGIN
    INSERT INTO core.users (username, phone, email, address, account_status, registered_at)
    VALUES ('admin_002', '0910000002', 'admin002@example.com', 'Ha Noi, Vietnam', 'ACTIVE', SYSDATETIME());
END;


/* ============================================================
   2. Seed core.customers
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    WHERE u.username = 'customer_001'
)
BEGIN
    INSERT INTO core.customers (
        user_id, first_name, middle_initial, last_name,
        gender, date_of_birth, kyc_status, customer_segment, customer_status
    )
    SELECT
        user_id, 'Nguyen', 'Q', 'Thang',
        'MALE', '2002-01-01', 'VERIFIED', 'RETAIL', 'ACTIVE'
    FROM core.users
    WHERE username = 'customer_001';
END;

IF NOT EXISTS (
    SELECT 1
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    WHERE u.username = 'customer_002'
)
BEGIN
    INSERT INTO core.customers (
        user_id, first_name, middle_initial, last_name,
        gender, date_of_birth, kyc_status, customer_segment, customer_status
    )
    SELECT
        user_id, 'Tran', 'A', 'Linh',
        'FEMALE', '1998-05-12', 'VERIFIED', 'PREMIUM', 'ACTIVE'
    FROM core.users
    WHERE username = 'customer_002';
END;

IF NOT EXISTS (
    SELECT 1
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    WHERE u.username = 'customer_003'
)
BEGIN
    INSERT INTO core.customers (
        user_id, first_name, middle_initial, last_name,
        gender, date_of_birth, kyc_status, customer_segment, customer_status
    )
    SELECT
        user_id, 'Le', 'B', 'Minh',
        'MALE', '1995-09-20', 'VERIFIED', 'BUSINESS', 'ACTIVE'
    FROM core.users
    WHERE username = 'customer_003';
END;


/* ============================================================
   3. Seed core.admins
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM core.admins a
    JOIN core.users u ON a.user_id = u.user_id
    WHERE u.username = 'admin_001'
)
BEGIN
    INSERT INTO core.admins (user_id, role, department, admin_status)
    SELECT user_id, 'SUPER_ADMIN', 'Risk Management', 'ACTIVE'
    FROM core.users
    WHERE username = 'admin_001';
END;

IF NOT EXISTS (
    SELECT 1
    FROM core.admins a
    JOIN core.users u ON a.user_id = u.user_id
    WHERE u.username = 'admin_002'
)
BEGIN
    INSERT INTO core.admins (user_id, role, department, admin_status)
    SELECT user_id, 'RISK_ANALYST', 'Fraud Monitoring', 'ACTIVE'
    FROM core.users
    WHERE username = 'admin_002';
END;


/* ============================================================
   4. Seed core.admin_permissions
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM core.admin_permissions ap
    JOIN core.admins grantor ON ap.grantor_admin_id = grantor.admin_id
    JOIN core.users grantor_user ON grantor.user_id = grantor_user.user_id
    JOIN core.admins grantee ON ap.grantee_admin_id = grantee.admin_id
    JOIN core.users grantee_user ON grantee.user_id = grantee_user.user_id
    WHERE grantor_user.username = 'admin_001'
      AND grantee_user.username = 'admin_002'
      AND ap.permission_scope = 'RISK_ALERT_REVIEW'
)
BEGIN
    INSERT INTO core.admin_permissions (
        grantor_admin_id,
        grantee_admin_id,
        granted_at,
        permission_scope,
        permission_content
    )
    SELECT
        grantor.admin_id,
        grantee.admin_id,
        SYSDATETIME(),
        'RISK_ALERT_REVIEW',
        'Allow reviewing and updating risk alerts'
    FROM core.admins grantor
    JOIN core.users grantor_user ON grantor.user_id = grantor_user.user_id
    CROSS JOIN core.admins grantee
    JOIN core.users grantee_user ON grantee.user_id = grantee_user.user_id
    WHERE grantor_user.username = 'admin_001'
      AND grantee_user.username = 'admin_002';
END;


/* ============================================================
   5. Seed core.branches
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM core.branches WHERE branch_code = 'HCM001')
BEGIN
    INSERT INTO core.branches (branch_name, branch_code, city, address, branch_status)
    VALUES ('Ho Chi Minh Central Branch', 'HCM001', 'Ho Chi Minh City', 'District 1, Ho Chi Minh City', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM core.branches WHERE branch_code = 'HN001')
BEGIN
    INSERT INTO core.branches (branch_name, branch_code, city, address, branch_status)
    VALUES ('Ha Noi Central Branch', 'HN001', 'Ha Noi', 'Hoan Kiem District, Ha Noi', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM core.branches WHERE branch_code = 'DN001')
BEGIN
    INSERT INTO core.branches (branch_name, branch_code, city, address, branch_status)
    VALUES ('Da Nang Central Branch', 'DN001', 'Da Nang', 'Hai Chau District, Da Nang', 'ACTIVE');
END;


/* ============================================================
   6. Seed core.accounts
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM core.accounts WHERE account_number = 'FP-ACC-000001')
BEGIN
    INSERT INTO core.accounts (
        customer_id, branch_id, currency_code, account_number,
        account_type, balance, opened_date, account_status
    )
    SELECT
        c.customer_id,
        b.branch_id,
        'VND',
        'FP-ACC-000001',
        'SAVINGS',
        50000000.0000,
        '2026-01-05',
        'ACTIVE'
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    JOIN core.branches b ON b.branch_code = 'HCM001'
    WHERE u.username = 'customer_001';
END;

IF NOT EXISTS (SELECT 1 FROM core.accounts WHERE account_number = 'FP-ACC-000002')
BEGIN
    INSERT INTO core.accounts (
        customer_id, branch_id, currency_code, account_number,
        account_type, balance, opened_date, account_status
    )
    SELECT
        c.customer_id,
        b.branch_id,
        'VND',
        'FP-ACC-000002',
        'PAYMENT',
        25000000.0000,
        '2026-01-10',
        'ACTIVE'
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    JOIN core.branches b ON b.branch_code = 'HN001'
    WHERE u.username = 'customer_002';
END;

IF NOT EXISTS (SELECT 1 FROM core.accounts WHERE account_number = 'FP-ACC-000003')
BEGIN
    INSERT INTO core.accounts (
        customer_id, branch_id, currency_code, account_number,
        account_type, balance, opened_date, account_status
    )
    SELECT
        c.customer_id,
        b.branch_id,
        'USD',
        'FP-ACC-000003',
        'CURRENT',
        5000.0000,
        '2026-01-15',
        'ACTIVE'
    FROM core.customers c
    JOIN core.users u ON c.user_id = u.user_id
    JOIN core.branches b ON b.branch_code = 'DN001'
    WHERE u.username = 'customer_003';
END;


/* ============================================================
   7. Seed core.cards
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM core.cards WHERE masked_card_number = '411111******1111')
BEGIN
    INSERT INTO core.cards (account_id, masked_card_number, card_type, expiry_date, card_status)
    SELECT account_id, '411111******1111', 'DEBIT', '2030-12-31', 'ACTIVE'
    FROM core.accounts
    WHERE account_number = 'FP-ACC-000001';
END;

IF NOT EXISTS (SELECT 1 FROM core.cards WHERE masked_card_number = '422222******2222')
BEGIN
    INSERT INTO core.cards (account_id, masked_card_number, card_type, expiry_date, card_status)
    SELECT account_id, '422222******2222', 'DEBIT', '2030-12-31', 'ACTIVE'
    FROM core.accounts
    WHERE account_number = 'FP-ACC-000002';
END;


/* ============================================================
   8. Seed txn.transactions
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM txn.transactions WHERE reference_number = 'TXN-2026-000001')
BEGIN
    INSERT INTO txn.transactions (
        account_id, card_id, channel_id, transaction_type_id, currency_code,
        merchant_id, transaction_amount, transaction_time, reference_number,
        description, transaction_status, created_at
    )
    SELECT
        a.account_id,
        NULL,
        ch.channel_id,
        tt.transaction_type_id,
        'VND',
        NULL,
        5000000.0000,
        '2026-02-01T09:15:00',
        'TXN-2026-000001',
        'Mobile banking transfer',
        'SUCCESS',
        SYSDATETIME()
    FROM core.accounts a
    JOIN ref.channels ch ON ch.channel_name = 'Mobile Banking'
    JOIN ref.transaction_types tt ON tt.transaction_type_name = 'Transfer'
    WHERE a.account_number = 'FP-ACC-000001';
END;

IF NOT EXISTS (SELECT 1 FROM txn.transactions WHERE reference_number = 'TXN-2026-000002')
BEGIN
    INSERT INTO txn.transactions (
        account_id, card_id, channel_id, transaction_type_id, currency_code,
        merchant_id, transaction_amount, transaction_time, reference_number,
        description, transaction_status, created_at
    )
    SELECT
        a.account_id,
        c.card_id,
        ch.channel_id,
        tt.transaction_type_id,
        'VND',
        m.merchant_id,
        750000.0000,
        '2026-02-01T12:30:00',
        'TXN-2026-000002',
        'POS payment at FinMart Supermarket',
        'SUCCESS',
        SYSDATETIME()
    FROM core.accounts a
    JOIN core.cards c ON c.account_id = a.account_id
    JOIN ref.channels ch ON ch.channel_name = 'POS'
    JOIN ref.transaction_types tt ON tt.transaction_type_name = 'Payment'
    JOIN ref.merchants m ON m.merchant_code = 'MRC_RETAIL_001'
    WHERE a.account_number = 'FP-ACC-000002';
END;

IF NOT EXISTS (SELECT 1 FROM txn.transactions WHERE reference_number = 'TXN-2026-000003')
BEGIN
    INSERT INTO txn.transactions (
        account_id, card_id, channel_id, transaction_type_id, currency_code,
        merchant_id, transaction_amount, transaction_time, reference_number,
        description, transaction_status, created_at
    )
    SELECT
        a.account_id,
        NULL,
        ch.channel_id,
        tt.transaction_type_id,
        'USD',
        NULL,
        250.0000,
        '2026-02-02T10:00:00',
        'TXN-2026-000003',
        'Internet banking USD transfer',
        'PENDING',
        SYSDATETIME()
    FROM core.accounts a
    JOIN ref.channels ch ON ch.channel_name = 'Internet Banking'
    JOIN ref.transaction_types tt ON tt.transaction_type_name = 'Transfer'
    WHERE a.account_number = 'FP-ACC-000003';
END;

IF NOT EXISTS (SELECT 1 FROM txn.transactions WHERE reference_number = 'TXN-2026-000004')
BEGIN
    INSERT INTO txn.transactions (
        account_id, card_id, channel_id, transaction_type_id, currency_code,
        merchant_id, transaction_amount, transaction_time, reference_number,
        description, transaction_status, created_at
    )
    SELECT
        a.account_id,
        NULL,
        ch.channel_id,
        tt.transaction_type_id,
        'VND',
        m.merchant_id,
        150000000.0000,
        '2026-02-02T23:45:00',
        'TXN-2026-000004',
        'High amount online payment to crypto merchant',
        'SUCCESS',
        SYSDATETIME()
    FROM core.accounts a
    JOIN ref.channels ch ON ch.channel_name = 'POS'
    JOIN ref.transaction_types tt ON tt.transaction_type_name = 'Payment'
    JOIN ref.merchants m ON m.merchant_code = 'MRC_CRYPTO_001'
    WHERE a.account_number = 'FP-ACC-000001';
END;


/* ============================================================
   9. Seed txn.transaction_status_history
   ============================================================ */

INSERT INTO txn.transaction_status_history (
    transaction_id, status_sequence_no, old_status, new_status, changed_at, change_reason
)
SELECT t.transaction_id, 1, NULL, 'PENDING', DATEADD(MINUTE, -2, t.transaction_time), 'Transaction received'
FROM txn.transactions t
WHERE t.reference_number IN ('TXN-2026-000001', 'TXN-2026-000002', 'TXN-2026-000003', 'TXN-2026-000004')
  AND NOT EXISTS (
      SELECT 1
      FROM txn.transaction_status_history h
      WHERE h.transaction_id = t.transaction_id
        AND h.status_sequence_no = 1
  );

INSERT INTO txn.transaction_status_history (
    transaction_id, status_sequence_no, old_status, new_status, changed_at, change_reason
)
SELECT t.transaction_id, 2, 'PENDING', t.transaction_status, t.transaction_time, 'Transaction final status updated'
FROM txn.transactions t
WHERE t.reference_number IN ('TXN-2026-000001', 'TXN-2026-000002', 'TXN-2026-000004')
  AND NOT EXISTS (
      SELECT 1
      FROM txn.transaction_status_history h
      WHERE h.transaction_id = t.transaction_id
        AND h.status_sequence_no = 2
  );


/* ============================================================
   10. Seed txn.transaction_fee_charges
   ============================================================ */

INSERT INTO txn.transaction_fee_charges (
    transaction_id, fee_rule_id, fee_amount, calculated_at, calculation_note
)
SELECT
    t.transaction_id,
    fr.fee_rule_id,
    6000.0000,
    SYSDATETIME(),
    'Synthetic fee charge for mobile transfer'
FROM txn.transactions t
JOIN ref.transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
JOIN ref.channels ch ON t.channel_id = ch.channel_id
JOIN ref.fee_rules fr
    ON fr.transaction_type_id = tt.transaction_type_id
   AND fr.channel_id = ch.channel_id
   AND fr.currency_code = t.currency_code
WHERE t.reference_number = 'TXN-2026-000001'
  AND NOT EXISTS (
      SELECT 1
      FROM txn.transaction_fee_charges fc
      WHERE fc.transaction_id = t.transaction_id
        AND fc.fee_rule_id = fr.fee_rule_id
  );

INSERT INTO txn.transaction_fee_charges (
    transaction_id, fee_rule_id, fee_amount, calculated_at, calculation_note
)
SELECT
    t.transaction_id,
    fr.fee_rule_id,
    1500.0000,
    SYSDATETIME(),
    'Synthetic fee charge for POS payment'
FROM txn.transactions t
JOIN ref.transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
JOIN ref.channels ch ON t.channel_id = ch.channel_id
JOIN ref.fee_rules fr
    ON fr.transaction_type_id = tt.transaction_type_id
   AND fr.channel_id = ch.channel_id
   AND fr.currency_code = t.currency_code
WHERE t.reference_number = 'TXN-2026-000002'
  AND NOT EXISTS (
      SELECT 1
      FROM txn.transaction_fee_charges fc
      WHERE fc.transaction_id = t.transaction_id
        AND fc.fee_rule_id = fr.fee_rule_id
  );

INSERT INTO txn.transaction_fee_charges (
    transaction_id, fee_rule_id, fee_amount, calculated_at, calculation_note
)
SELECT
    t.transaction_id,
    fr.fee_rule_id,
    300000.0000,
    SYSDATETIME(),
    'Synthetic fee charge for high amount POS payment'
FROM txn.transactions t
JOIN ref.transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
JOIN ref.channels ch ON t.channel_id = ch.channel_id
JOIN ref.fee_rules fr
    ON fr.transaction_type_id = tt.transaction_type_id
   AND fr.channel_id = ch.channel_id
   AND fr.currency_code = t.currency_code
WHERE t.reference_number = 'TXN-2026-000004'
  AND NOT EXISTS (
      SELECT 1
      FROM txn.transaction_fee_charges fc
      WHERE fc.transaction_id = t.transaction_id
        AND fc.fee_rule_id = fr.fee_rule_id
  );


/* ============================================================
   11. Seed risk.risk_alerts
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM risk.risk_alerts ra
    JOIN txn.transactions t ON ra.transaction_id = t.transaction_id
    JOIN ref.fraud_rules fr ON ra.fraud_rule_id = fr.fraud_rule_id
    WHERE t.reference_number = 'TXN-2026-000004'
      AND fr.rule_name = 'High Amount Transaction'
)
BEGIN
    INSERT INTO risk.risk_alerts (
        transaction_id, fraud_rule_id, risk_score, risk_reason,
        alert_status, created_at, resolved_at
    )
    SELECT
        t.transaction_id,
        fr.fraud_rule_id,
        92.50,
        'Transaction amount exceeds high amount threshold.',
        'UNDER_REVIEW',
        SYSDATETIME(),
        NULL
    FROM txn.transactions t
    JOIN ref.fraud_rules fr ON fr.rule_name = 'High Amount Transaction'
    WHERE t.reference_number = 'TXN-2026-000004';
END;

IF NOT EXISTS (
    SELECT 1
    FROM risk.risk_alerts ra
    JOIN txn.transactions t ON ra.transaction_id = t.transaction_id
    JOIN ref.fraud_rules fr ON ra.fraud_rule_id = fr.fraud_rule_id
    WHERE t.reference_number = 'TXN-2026-000004'
      AND fr.rule_name = 'High Risk Merchant Category'
)
BEGIN
    INSERT INTO risk.risk_alerts (
        transaction_id, fraud_rule_id, risk_score, risk_reason,
        alert_status, created_at, resolved_at
    )
    SELECT
        t.transaction_id,
        fr.fraud_rule_id,
        88.00,
        'Transaction involves a critical-risk merchant category.',
        'OPEN',
        SYSDATETIME(),
        NULL
    FROM txn.transactions t
    JOIN ref.fraud_rules fr ON fr.rule_name = 'High Risk Merchant Category'
    WHERE t.reference_number = 'TXN-2026-000004';
END;


/* ============================================================
   12. Seed risk.alert_reviews
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM risk.alert_reviews ar
    JOIN risk.risk_alerts ra ON ar.risk_alert_id = ra.risk_alert_id
    JOIN txn.transactions t ON ra.transaction_id = t.transaction_id
    JOIN core.admins a ON ar.admin_id = a.admin_id
    JOIN core.users u ON a.user_id = u.user_id
    JOIN ref.fraud_rules fr ON ra.fraud_rule_id = fr.fraud_rule_id
    WHERE t.reference_number = 'TXN-2026-000004'
      AND fr.rule_name = 'High Amount Transaction'
      AND u.username = 'admin_002'
)
BEGIN
    INSERT INTO risk.alert_reviews (
        risk_alert_id, admin_id, reviewed_at, review_decision, review_note
    )
    SELECT
        ra.risk_alert_id,
        a.admin_id,
        SYSDATETIME(),
        'ESCALATED',
        'High amount transaction requires further investigation.'
    FROM risk.risk_alerts ra
    JOIN txn.transactions t ON ra.transaction_id = t.transaction_id
    JOIN ref.fraud_rules fr ON ra.fraud_rule_id = fr.fraud_rule_id
    JOIN core.admins a ON 1 = 1
    JOIN core.users u ON a.user_id = u.user_id
    WHERE t.reference_number = 'TXN-2026-000004'
      AND fr.rule_name = 'High Amount Transaction'
      AND u.username = 'admin_002';
END;

COMMIT TRANSACTION;
GO