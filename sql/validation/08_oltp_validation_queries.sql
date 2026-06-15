/*
    Project: FinPulse
    Script: 08_oltp_validation_queries.sql
    Purpose: Validate OLTP database structure, schemas, tables, keys, indexes, and seed data
    Engine: SQL Server / T-SQL

    Notes:
    - This script does not modify data.
    - It is used to verify that the OLTP database has been created correctly.
*/

USE AI_Financial_OLTP;
GO

/* ============================================================
   1. Validate schemas
   ============================================================ */

SELECT
    name AS schema_name
FROM sys.schemas
WHERE name IN ('core', 'ref', 'txn', 'risk', 'audit')
ORDER BY name;
GO

/* Expected:
   audit
   core
   ref
   risk
   txn
*/


/* ============================================================
   2. Validate expected tables
   ============================================================ */

WITH expected_tables AS (
    SELECT 'core' AS schema_name, 'users' AS table_name UNION ALL
    SELECT 'core', 'customers' UNION ALL
    SELECT 'core', 'admins' UNION ALL
    SELECT 'core', 'admin_permissions' UNION ALL
    SELECT 'core', 'branches' UNION ALL
    SELECT 'core', 'accounts' UNION ALL
    SELECT 'core', 'cards' UNION ALL

    SELECT 'ref', 'currencies' UNION ALL
    SELECT 'ref', 'channels' UNION ALL
    SELECT 'ref', 'transaction_types' UNION ALL
    SELECT 'ref', 'merchant_categories' UNION ALL
    SELECT 'ref', 'merchants' UNION ALL
    SELECT 'ref', 'fee_rules' UNION ALL
    SELECT 'ref', 'fraud_rules' UNION ALL

    SELECT 'txn', 'transactions' UNION ALL
    SELECT 'txn', 'transaction_status_history' UNION ALL
    SELECT 'txn', 'transaction_fee_charges' UNION ALL

    SELECT 'risk', 'risk_alerts' UNION ALL
    SELECT 'risk', 'alert_reviews'
),
actual_tables AS (
    SELECT
        s.name AS schema_name,
        t.name AS table_name
    FROM sys.tables t
    JOIN sys.schemas s
        ON t.schema_id = s.schema_id
)
SELECT
    e.schema_name,
    e.table_name,
    CASE
        WHEN a.table_name IS NULL THEN 'MISSING'
        ELSE 'OK'
    END AS validation_status
FROM expected_tables e
LEFT JOIN actual_tables a
    ON e.schema_name = a.schema_name
   AND e.table_name = a.table_name
ORDER BY e.schema_name, e.table_name;
GO


/* ============================================================
   3. Show all OLTP tables
   ============================================================ */

SELECT
    s.name AS schema_name,
    t.name AS table_name,
    t.create_date,
    t.modify_date
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name IN ('core', 'ref', 'txn', 'risk')
ORDER BY s.name, t.name;
GO


/* ============================================================
   4. Validate row counts
   ============================================================ */

SELECT
    s.name AS schema_name,
    t.name AS table_name,
    SUM(p.row_count) AS row_count
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
JOIN sys.dm_db_partition_stats p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
  AND s.name IN ('core', 'ref', 'txn', 'risk')
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
GO


/* ============================================================
   5. Validate seeded reference data counts
   ============================================================ */

SELECT 'ref.currencies' AS table_name, COUNT(*) AS row_count FROM ref.currencies
UNION ALL
SELECT 'ref.channels', COUNT(*) FROM ref.channels
UNION ALL
SELECT 'ref.transaction_types', COUNT(*) FROM ref.transaction_types
UNION ALL
SELECT 'ref.merchant_categories', COUNT(*) FROM ref.merchant_categories
UNION ALL
SELECT 'ref.merchants', COUNT(*) FROM ref.merchants
UNION ALL
SELECT 'ref.fee_rules', COUNT(*) FROM ref.fee_rules
UNION ALL
SELECT 'ref.fraud_rules', COUNT(*) FROM ref.fraud_rules;
GO

/* Expected after running 07_seed_reference_data.sql:
   ref.currencies             5
   ref.channels               6
   ref.transaction_types      6
   ref.merchant_categories    6
   ref.merchants              5
   ref.fee_rules              4
   ref.fraud_rules            4
*/


/* ============================================================
   6. Validate primary keys
   ============================================================ */

SELECT
    s.name AS schema_name,
    t.name AS table_name,
    kc.name AS primary_key_name
FROM sys.key_constraints kc
JOIN sys.tables t
    ON kc.parent_object_id = t.object_id
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE kc.type = 'PK'
  AND s.name IN ('core', 'ref', 'txn', 'risk')
ORDER BY s.name, t.name;
GO


/* ============================================================
   7. Validate foreign keys
   ============================================================ */

SELECT
    fk.name AS foreign_key_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS child_schema,
    OBJECT_NAME(fk.parent_object_id) AS child_table,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS parent_schema,
    OBJECT_NAME(fk.referenced_object_id) AS parent_table
FROM sys.foreign_keys fk
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) IN ('core', 'ref', 'txn', 'risk')
ORDER BY child_schema, child_table, foreign_key_name;
GO


/* ============================================================
   8. Validate indexes
   ============================================================ */

SELECT
    SCHEMA_NAME(t.schema_id) AS schema_name,
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint
FROM sys.indexes i
JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
  AND SCHEMA_NAME(t.schema_id) IN ('core', 'ref', 'txn', 'risk')
ORDER BY schema_name, table_name, index_name;
GO


/* ============================================================
   9. Validate nullable optional foreign keys
   ============================================================ */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'txn'
  AND TABLE_NAME = 'transactions'
  AND COLUMN_NAME IN ('card_id', 'merchant_id')
ORDER BY COLUMN_NAME;
GO

/* Expected:
   card_id      YES
   merchant_id  YES
*/


/* ============================================================
   10. Validate transaction_status_history composite primary key
   ============================================================ */

SELECT
    KU.TABLE_SCHEMA,
    KU.TABLE_NAME,
    KU.COLUMN_NAME,
    KU.ORDINAL_POSITION,
    TC.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KU
    ON TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
   AND TC.TABLE_SCHEMA = KU.TABLE_SCHEMA
   AND TC.TABLE_NAME = KU.TABLE_NAME
WHERE TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND KU.TABLE_SCHEMA = 'txn'
  AND KU.TABLE_NAME = 'transaction_status_history'
ORDER BY KU.ORDINAL_POSITION;
GO

/* Expected:
   transaction_id
   status_sequence_no
*/


/* ============================================================
   11. Validate fee rule relationships
   ============================================================ */

SELECT
    fr.fee_rule_id,
    tt.transaction_type_name,
    ch.channel_name,
    fr.currency_code,
    fr.fixed_fee,
    fr.percentage,
    fr.fee_rule_status
FROM ref.fee_rules fr
JOIN ref.transaction_types tt
    ON fr.transaction_type_id = tt.transaction_type_id
JOIN ref.channels ch
    ON fr.channel_id = ch.channel_id
JOIN ref.currencies c
    ON fr.currency_code = c.currency_code
ORDER BY fr.fee_rule_id;
GO


/* ============================================================
   12. Validate merchant category relationships
   ============================================================ */

SELECT
    m.merchant_code,
    m.merchant_name,
    mc.category_name,
    mc.risk_level,
    m.country,
    m.city,
    m.merchant_status
FROM ref.merchants m
JOIN ref.merchant_categories mc
    ON m.merchant_category_id = mc.merchant_category_id
ORDER BY m.merchant_code;
GO


/* ============================================================
   13. Validate fraud rules
   ============================================================ */

SELECT
    fraud_rule_id,
    rule_name,
    rule_type,
    threshold_value,
    is_active
FROM ref.fraud_rules
ORDER BY fraud_rule_id;
GO


/* ============================================================
   14. Check for disabled foreign keys
   ============================================================ */

SELECT
    fk.name AS foreign_key_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS child_schema,
    OBJECT_NAME(fk.parent_object_id) AS child_table,
    fk.is_disabled,
    fk.is_not_trusted
FROM sys.foreign_keys fk
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) IN ('core', 'ref', 'txn', 'risk')
  AND (fk.is_disabled = 1 OR fk.is_not_trusted = 1)
ORDER BY child_schema, child_table, foreign_key_name;
GO

/* Expected:
   No rows
*/


/* ============================================================
   15. Check for tables without primary keys
   ============================================================ */

SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
LEFT JOIN sys.key_constraints kc
    ON t.object_id = kc.parent_object_id
   AND kc.type = 'PK'
WHERE s.name IN ('core', 'ref', 'txn', 'risk')
  AND kc.name IS NULL
ORDER BY s.name, t.name;
GO

/* Expected:
   No rows
*/