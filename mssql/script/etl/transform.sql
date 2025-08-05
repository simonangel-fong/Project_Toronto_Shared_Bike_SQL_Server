-- ============================================================================
-- Script Name : 02_transform.sql (MSSQL Version)
-- Purpose     : Clean and transform data in the staging table before loading into the Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to TorontoSharedBikeDB and dw_schema
-- ============================================================================

USE TorontoSharedBikeDB;
GO

-- ============================================================================
-- Data Processing: Remove rows with NULLs in key columns
-- ============================================================================
PRINT '========== Remove NULL! ==========';
DELETE FROM dw_schema.staging_trip
WHERE trip_id IS NULL
   OR trip_duration IS NULL
   OR start_time IS NULL
   OR start_station_id IS NULL
   OR end_station_id IS NULL;
GO

-- Remove rows where key columns contain the string 'NULL'
PRINT '========== Remove "NULL"! ==========';
DELETE FROM dw_schema.staging_trip
WHERE trip_id = 'NULL'
   OR trip_duration = 'NULL'
   OR start_time = 'NULL'
   OR start_station_id = 'NULL'
   OR end_station_id = 'NULL';
GO

-- ============================================================================
-- Remove rows with invalid formats in key columns
-- ============================================================================
PRINT '========== Remove invalid format! ==========';
DELETE FROM dw_schema.staging_trip
WHERE 
    TRY_CAST(trip_id AS INT) IS NULL OR
    TRY_CAST(trip_duration AS FLOAT) IS NULL OR
    TRY_CONVERT(DATETIME, start_time, 101) IS NULL OR  -- MM/DD/YYYY HH:MI
    TRY_CAST(start_station_id AS INT) IS NULL OR
    TRY_CAST(end_station_id AS INT) IS NULL;
GO

-- ============================================================================
-- Remove rows with non-positive trip durations
-- ============================================================================
PRINT '========== Remove rows with non-positive trip durations! ==========';
DELETE FROM dw_schema.staging_trip
WHERE TRY_CAST(trip_duration AS FLOAT) <= 0;
GO

-- ============================================================================
-- Fix end_time: recompute where missing or invalid
-- ============================================================================
PRINT '========== Fix end_time: recompute where missing or invalid! ==========';
UPDATE dw_schema.staging_trip
SET end_time = 
    FORMAT(
        DATEADD(SECOND, TRY_CAST(trip_duration AS INT), TRY_CAST(start_time AS DATETIME)),
        'MM/dd/yyyy HH:mm'
    )
WHERE 
    end_time IS NULL OR
    TRY_CONVERT(DATETIME, end_time, 101) IS NULL;
GO

-- ============================================================================
-- Handle NULL or 'NULL' station names
-- ============================================================================
PRINT '========== Handle NULL or "NULL" station names! ==========';
UPDATE dw_schema.staging_trip
SET start_station_name = 'UNKNOWN'
WHERE start_station_name IS NULL OR LTRIM(RTRIM(start_station_name)) = 'NULL';

UPDATE dw_schema.staging_trip
SET end_station_name = 'UNKNOWN'
WHERE end_station_name IS NULL OR LTRIM(RTRIM(end_station_name)) = 'NULL';
GO

-- ============================================================================
-- Substitute missing user_type with 'UNKNOWN'
-- ============================================================================
PRINT '========== Substitute missing user_type with UNKNOWN! ==========';
UPDATE dw_schema.staging_trip
SET user_type = 'UNKNOWN'
WHERE user_type IS NULL;
GO

-- ============================================================================
-- Substitute invalid or missing bike_id with '-1'
-- ============================================================================
PRINT '========== Substitute invalid or missing bike_id with -1! ==========';
UPDATE dw_schema.staging_trip
SET bike_id = '-1'
WHERE bike_id IS NULL 
   OR (TRY_CAST(bike_id AS INT) IS NULL AND bike_id != '-1');
GO

-- ============================================================================
-- Clean carriage return in user_type
-- ============================================================================
PRINT '========== Clean carriage return in user_type! ==========';
UPDATE dw_schema.staging_trip
SET user_type = REPLACE(user_type, CHAR(13), '')
WHERE user_type LIKE '%' + CHAR(13) + '%';
GO

-- ============================================================================
-- Final Confirm
-- ============================================================================

SELECT TOP 2 * 
FROM dw_schema.staging_trip;
GO
