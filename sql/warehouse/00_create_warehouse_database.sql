/*
    Project: FinPulse
    Script: 00_create_warehouse_database.sql
    Purpose: Create data warehouse database and schemas
    Engine: SQL Server / T-SQL

    Notes:
    - This script creates the first data warehouse database for FinPulse.
    - It is idempotent: running it multiple times will not duplicate the database or schemas.
    - The warehouse database is separated from the OLTP database.
*/

USE master;
GO

IF DB_ID('AI_Financial_DW') IS NULL
BEGIN
    CREATE DATABASE AI_Financial_DW;
END;
GO

IF DATABASEPROPERTYEX('AI_Financial_DW', 'Status') = 'ONLINE'
BEGIN
    ALTER DATABASE AI_Financial_DW
    SET RECOVERY SIMPLE;
END;
GO

USE AI_Financial_DW;
GO

/* ============================================================
   Create warehouse schemas
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dim')
BEGIN
    EXEC('CREATE SCHEMA dim');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'fact')
BEGIN
    EXEC('CREATE SCHEMA fact');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'mart')
BEGIN
    EXEC('CREATE SCHEMA mart');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
BEGIN
    EXEC('CREATE SCHEMA audit');
END;
GO

/* ============================================================
   Create ETL batch tracking table
   ============================================================ */

IF OBJECT_ID('audit.etl_batch_runs', 'U') IS NULL
BEGIN
    CREATE TABLE audit.etl_batch_runs (
        batch_run_id        BIGINT IDENTITY(1,1) NOT NULL,
        pipeline_name       VARCHAR(150) NOT NULL,
        source_system       VARCHAR(100) NOT NULL,
        target_layer        VARCHAR(100) NOT NULL,
        started_at          DATETIME2(0) NOT NULL,
        ended_at            DATETIME2(0) NULL,
        run_status          VARCHAR(30) NOT NULL,
        rows_inserted       BIGINT NOT NULL DEFAULT 0,
        rows_updated        BIGINT NOT NULL DEFAULT 0,
        rows_failed         BIGINT NOT NULL DEFAULT 0,
        error_message       NVARCHAR(1000) NULL,

        CONSTRAINT pk_audit_etl_batch_runs
            PRIMARY KEY (batch_run_id),

        CONSTRAINT ck_audit_etl_batch_runs_status
            CHECK (run_status IN ('STARTED', 'SUCCESS', 'FAILED', 'PARTIAL_SUCCESS'))
    );
END;
GO

/* ============================================================
   Validation
   ============================================================ */

SELECT
    name AS schema_name
FROM sys.schemas
WHERE name IN ('stg', 'dim', 'fact', 'mart', 'audit')
ORDER BY name;
GO

SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name IN ('stg', 'dim', 'fact', 'mart', 'audit')
ORDER BY s.name, t.name;
GO
