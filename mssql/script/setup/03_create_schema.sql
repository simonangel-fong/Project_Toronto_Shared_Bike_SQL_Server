-- ============================================================================
-- Script Name : create_dw_user.sql
-- Purpose     : Create a DW user and schema with permissions in SQL Server
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- ============================================================================

-- Use the target database
USE toronto_shared_bike;
GO

-- 1. Create a SQL Server Login
CREATE LOGIN dw_user_login
WITH PASSWORD = 'SecurePassword!23';
GO

-- 2. Create a Database User from the Login
CREATE USER dw_user FOR LOGIN dw_user_login;
GO

-- 3. Create a dedicated Schema for DW objects
CREATE SCHEMA dw_schema AUTHORIZATION dw_user;
GO

-- 4. Set dw_user's default schema to dw_schema
ALTER USER dw_user WITH DEFAULT_SCHEMA = dw_schema;
GO

-- 5. Grant privileges to allow controlled data warehouse operations
-- Grant only the necessary permissions
GRANT CREATE TABLE TO dw_user;
GRANT CREATE VIEW TO dw_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dw_schema TO dw_user;
GO

-- 6. (Optional) Confirm user and schema info
SELECT 
    dp.name AS database_user,
    dp.type_desc AS user_type,
    dp.default_schema_name,
    s.name AS owned_schema
FROM sys.database_principals dp
LEFT JOIN sys.schemas s ON s.principal_id = dp.principal_id
WHERE dp.name = 'dw_user';
