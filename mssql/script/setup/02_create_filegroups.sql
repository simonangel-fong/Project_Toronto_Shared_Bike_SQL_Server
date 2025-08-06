-- ============================================================================
-- Script Name : create_filegroups.sql
-- Purpose     : Create filegroups for fact, dimension, index, staging, and materialized view storage
--               in the Toronto Shared Bike Data Warehouse on SQL Server
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Run as a system administrator
-- ============================================================================

-- USE the target database first (replace with your DB name)
USE toronto_shared_bike;
GO

-- FACT Filegroup
ALTER DATABASE toronto_shared_bike 
ADD FILEGROUP FACT_FG;
GO

ALTER DATABASE toronto_shared_bike 
ADD FILE 
(
    NAME = 'fact_data01',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/fact_data01.ndf',
    SIZE = 100MB,
    FILEGROWTH = 1024MB,
    MAXSIZE = 51200MB
),
(
    NAME = 'fact_data02',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/fact_data02.ndf',
    SIZE = 100MB,
    FILEGROWTH = 1024MB,
    MAXSIZE = 51200MB
)
TO FILEGROUP FACT_FG;
GO

-- DIMENSION Filegroup
ALTER DATABASE toronto_shared_bike 
ADD FILEGROUP DIM_FG;
GO

ALTER DATABASE toronto_shared_bike 
ADD FILE 
(
    NAME = 'dim_data01',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/dim_data01.ndf',
    SIZE = 50MB,
    FILEGROWTH = 25MB,
    MAXSIZE = 5120MB
),
(
    NAME = 'dim_data02',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/dim_data02.ndf',
    SIZE = 50MB,
    FILEGROWTH = 25MB,
    MAXSIZE = 5120MB
)
TO FILEGROUP DIM_FG;
GO

-- INDEX Filegroup
ALTER DATABASE toronto_shared_bike 
ADD FILEGROUP INDEX_FG;
GO

ALTER DATABASE toronto_shared_bike 
ADD FILE 
(
    NAME = 'index_data01',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/index_data01.ndf',
    SIZE = 50MB,
    FILEGROWTH = 25MB,
    MAXSIZE = 2048MB
),
(
    NAME = 'index_data02',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/index_data02.ndf',
    SIZE = 50MB,
    FILEGROWTH = 25MB,
    MAXSIZE = 2048MB
)
TO FILEGROUP INDEX_FG;
GO

-- STAGING Filegroup
ALTER DATABASE toronto_shared_bike 
ADD FILEGROUP STAGING_FG;
GO

ALTER DATABASE toronto_shared_bike 
ADD FILE 
(
    NAME = 'staging_data01',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/staging_data01.ndf',
    SIZE = 1024MB,
    FILEGROWTH = 512MB,
    MAXSIZE = 10240MB
),
(
    NAME = 'staging_data02',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/staging_data02.ndf',
    SIZE = 1024MB,
    FILEGROWTH = 512MB,
    MAXSIZE = 10240MB
)
TO FILEGROUP STAGING_FG;
GO

-- MATERIALIZED VIEW Filegroup (Indexed View in SQL Server)
ALTER DATABASE toronto_shared_bike 
ADD FILEGROUP MV_FG;
GO

ALTER DATABASE toronto_shared_bike 
ADD FILE 
(
    NAME = 'mv_data01',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/mv_data01.ndf',
    SIZE = 100MB,
    FILEGROWTH = 50MB,
    MAXSIZE = 5120MB
),
(
    NAME = 'mv_data02',
    FILENAME = '/var/opt/mssql/data/toronto_shared_bike/mv_data02.ndf',
    SIZE = 100MB,
    FILEGROWTH = 50MB,
    MAXSIZE = 5120MB
)
TO FILEGROUP MV_FG;
GO

-- View filegroups and files
SELECT 
    mf.name AS LogicalName,
    physical_name AS PhysicalPath,
    mf.type_desc,
    state_desc,
    size * 8 / 1024 AS SizeMB,
    filegroup_name = fg.name
FROM sys.master_files mf
JOIN sys.filegroups fg ON mf.data_space_id = fg.data_space_id
WHERE database_id = DB_ID('toronto_shared_bike');
