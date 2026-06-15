/*
    Project: FinPulse
    Script: 10_oltp_business_queries.sql
    Purpose: Business analysis queries for OLTP sample data
    Engine: SQL Server / T-SQL

    Notes:
    - This script does not modify data.
    - It is used to demonstrate how the OLTP model supports business analysis.
    - It should be run after the OLTP tables and sample data have been created.
*/

USE AI_Financial_OLTP;
GO

/* ============================================================
   1. Transaction volume by status
   Business question:
   How many transactions are successful, pending, failed, reversed, or cancelled?
   ============================================================ */

SELECT
    transaction_status,
    COUNT(*) AS transaction_count,
    SUM(transaction_amount) AS total_transaction_amount
FROM txn.transactions
GROUP BY transaction_status
ORDER BY transaction_count DESC;
GO


/* ============================================================
   2. Transaction amount by channel
   Business question:
   Which channel has the highest transaction amount?
   ============================================================ */

SELECT
    ch.channel_name,
    ch.channel_type,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.transaction_amount) AS total_transaction_amount,
    AVG(t.transaction_amount) AS average_transaction_amount
FROM txn.transactions t
JOIN ref.channels ch
    ON t.channel_id = ch.channel_id
GROUP BY
    ch.channel_name,
    ch.channel_type
ORDER BY total_transaction_amount DESC;
GO


/* ============================================================
   3. Transaction amount by transaction type
   Business question:
   Which transaction type generates the highest transaction amount?
   ============================================================ */

SELECT
    tt.transaction_type_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.transaction_amount) AS total_transaction_amount,
    AVG(t.transaction_amount) AS average_transaction_amount
FROM txn.transactions t
JOIN ref.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
GROUP BY
    tt.transaction_type_name
ORDER BY total_transaction_amount DESC;
GO


/* ============================================================
   4. Customer transaction summary
   Business question:
   Which customers generate the highest transaction value?
   ============================================================ */

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.middle_initial, ' ', c.last_name) AS customer_name,
    c.customer_segment,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.transaction_amount) AS total_transaction_amount,
    AVG(t.transaction_amount) AS average_transaction_amount
FROM core.customers c
JOIN core.accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN txn.transactions t
    ON a.account_id = t.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.middle_initial,
    c.last_name,
    c.customer_segment
ORDER BY total_transaction_amount DESC;
GO


/* ============================================================
   5. Account balance and transaction activity
   Business question:
   Which accounts are active and how much transaction activity do they have?
   ============================================================ */

SELECT
    a.account_number,
    a.account_type,
    a.currency_code,
    a.balance,
    a.account_status,
    COUNT(t.transaction_id) AS transaction_count,
    COALESCE(SUM(t.transaction_amount), 0) AS total_transaction_amount
FROM core.accounts a
LEFT JOIN txn.transactions t
    ON a.account_id = t.account_id
GROUP BY
    a.account_number,
    a.account_type,
    a.currency_code,
    a.balance,
    a.account_status
ORDER BY total_transaction_amount DESC;
GO


/* ============================================================
   6. Merchant category transaction analysis
   Business question:
   Which merchant categories generate the most transaction amount?
   ============================================================ */

SELECT
    mc.category_name,
    mc.risk_level,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.transaction_amount) AS total_transaction_amount,
    AVG(t.transaction_amount) AS average_transaction_amount
FROM txn.transactions t
JOIN ref.merchants m
    ON t.merchant_id = m.merchant_id
JOIN ref.merchant_categories mc
    ON m.merchant_category_id = mc.merchant_category_id
GROUP BY
    mc.category_name,
    mc.risk_level
ORDER BY total_transaction_amount DESC;
GO


/* ============================================================
   7. Transaction fee analysis
   Business question:
   How much transaction fee is charged by transaction type, channel, and currency?
   ============================================================ */

SELECT
    tt.transaction_type_name,
    ch.channel_name,
    fr.currency_code,
    COUNT(fc.fee_charge_id) AS fee_charge_count,
    SUM(fc.fee_amount) AS total_fee_amount,
    AVG(fc.fee_amount) AS average_fee_amount
FROM txn.transaction_fee_charges fc
JOIN ref.fee_rules fr
    ON fc.fee_rule_id = fr.fee_rule_id
JOIN ref.transaction_types tt
    ON fr.transaction_type_id = tt.transaction_type_id
JOIN ref.channels ch
    ON fr.channel_id = ch.channel_id
GROUP BY
    tt.transaction_type_name,
    ch.channel_name,
    fr.currency_code
ORDER BY total_fee_amount DESC;
GO


/* ============================================================
   8. Transaction detail with calculated fee
   Business question:
   What is the total fee amount for each transaction?
   ============================================================ */

SELECT
    t.reference_number,
    t.transaction_amount,
    t.currency_code,
    t.transaction_status,
    COALESCE(SUM(fc.fee_amount), 0) AS total_fee_amount
FROM txn.transactions t
LEFT JOIN txn.transaction_fee_charges fc
    ON t.transaction_id = fc.transaction_id
GROUP BY
    t.reference_number,
    t.transaction_amount,
    t.currency_code,
    t.transaction_status
ORDER BY t.reference_number;
GO


/* ============================================================
   9. Risk alert monitoring
   Business question:
   Which transactions triggered risk alerts?
   ============================================================ */

SELECT
    ra.risk_alert_id,
    t.reference_number,
    t.transaction_amount,
    t.currency_code,
    fr.rule_name,
    fr.rule_type,
    ra.risk_score,
    ra.risk_reason,
    ra.alert_status,
    ra.created_at
FROM risk.risk_alerts ra
JOIN txn.transactions t
    ON ra.transaction_id = t.transaction_id
JOIN ref.fraud_rules fr
    ON ra.fraud_rule_id = fr.fraud_rule_id
ORDER BY
    ra.risk_score DESC,
    ra.created_at DESC;
GO


/* ============================================================
   10. Alert review summary
   Business question:
   Which alerts have been reviewed and by which admins?
   ============================================================ */

SELECT
    ar.review_id,
    t.reference_number,
    fr.rule_name,
    ra.risk_score,
    ar.review_decision,
    ar.review_note,
    ar.reviewed_at,
    u.username AS reviewed_by_admin
FROM risk.alert_reviews ar
JOIN risk.risk_alerts ra
    ON ar.risk_alert_id = ra.risk_alert_id
JOIN txn.transactions t
    ON ra.transaction_id = t.transaction_id
JOIN ref.fraud_rules fr
    ON ra.fraud_rule_id = fr.fraud_rule_id
JOIN core.admins a
    ON ar.admin_id = a.admin_id
JOIN core.users u
    ON a.user_id = u.user_id
ORDER BY ar.reviewed_at DESC;
GO


/* ============================================================
   11. Transaction status history
   Business question:
   How does transaction status change over time?
   ============================================================ */

SELECT
    t.reference_number,
    h.status_sequence_no,
    h.old_status,
    h.new_status,
    h.changed_at,
    h.change_reason
FROM txn.transaction_status_history h
JOIN txn.transactions t
    ON h.transaction_id = t.transaction_id
ORDER BY
    t.reference_number,
    h.status_sequence_no;
GO


/* ============================================================
   12. High-risk transaction view
   Business question:
   Which transactions should risk analysts prioritize?
   ============================================================ */

SELECT
    t.reference_number,
    t.transaction_amount,
    t.currency_code,
    ch.channel_name,
    tt.transaction_type_name,
    m.merchant_name,
    mc.category_name AS merchant_category,
    mc.risk_level AS merchant_risk_level,
    ra.risk_score,
    ra.alert_status,
    fr.rule_name
FROM txn.transactions t
JOIN ref.channels ch
    ON t.channel_id = ch.channel_id
JOIN ref.transaction_types tt
    ON t.transaction_type_id = tt.transaction_type_id
LEFT JOIN ref.merchants m
    ON t.merchant_id = m.merchant_id
LEFT JOIN ref.merchant_categories mc
    ON m.merchant_category_id = mc.merchant_category_id
LEFT JOIN risk.risk_alerts ra
    ON t.transaction_id = ra.transaction_id
LEFT JOIN ref.fraud_rules fr
    ON ra.fraud_rule_id = fr.fraud_rule_id
WHERE ra.risk_score >= 80
   OR mc.risk_level IN ('HIGH', 'CRITICAL')
ORDER BY
    ra.risk_score DESC,
    t.transaction_amount DESC;
GO