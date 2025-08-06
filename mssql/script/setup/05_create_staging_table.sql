-- ============================================================================
-- Script Name : create_staging_table.sql
-- Purpose     : Define the staging table for ridership data
-- Author      : Wenhao Fang (Converted to MSSQL)
-- Notes       : Must run inside toronto_shared_bike in dw_schema
-- ============================================================================

USE toronto_shared_bike;
GO

-- Create staging table
DROP TABLE IF EXISTS dw_schema.staging_trip;
CREATE TABLE dw_schema.staging_trip (
  trip_id               VARCHAR(15),
  trip_duration         VARCHAR(15),
  start_station_id      VARCHAR(15),
  start_time            VARCHAR(50),
  start_station_name    VARCHAR(100),
  end_station_id        VARCHAR(15),
  end_time              VARCHAR(50),
  end_station_name      VARCHAR(100),
  bike_id               VARCHAR(15),
  user_type             VARCHAR(50)
) ON STAGING_FG;
GO
