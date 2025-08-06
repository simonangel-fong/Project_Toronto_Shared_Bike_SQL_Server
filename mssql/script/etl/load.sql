-- ============================================================================
-- Script Name : 03_load.sql (MSSQL Version)
-- Purpose     : Populate dimension and fact tables from staging data
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- Notes       : Execute after staging table has been populated and cleaned
-- ============================================================================

USE toronto_shared_bike;
GO

-- ============================================================================
-- Load time dimension
-- ============================================================================
PRINT '========== Load time dimension! ==========';
MERGE dw_schema.dim_time AS tgt
USING (
  SELECT DISTINCT
    TRY_CAST(time_value AS DATETIME) AS timestamp_value
  FROM (
    SELECT start_time AS time_value FROM dw_schema.staging_trip
    UNION
    SELECT end_time AS time_value FROM dw_schema.staging_trip
    WHERE end_time IS NOT NULL
  ) AS t
) AS src
ON tgt.dim_time_id = src.timestamp_value
WHEN NOT MATCHED THEN
  INSERT (
    dim_time_id,
    dim_time_year,
    dim_time_quarter,
    dim_time_month,
    dim_time_day,
    dim_time_week,
    dim_time_weekday,
    dim_time_hour,
    dim_time_minute
  )
  VALUES (
    src.timestamp_value,
    DATEPART(YEAR, src.timestamp_value),
    DATEPART(QUARTER, src.timestamp_value),
    DATEPART(MONTH, src.timestamp_value),
    DATEPART(DAY, src.timestamp_value),
    DATEPART(WEEK, src.timestamp_value),
    DATEPART(WEEKDAY, src.timestamp_value),
    DATEPART(HOUR, src.timestamp_value),
    DATEPART(MINUTE, src.timestamp_value)
  );
GO

-- ============================================================================
-- Load station dimension
-- ============================================================================
PRINT '========== Load station dimension! ==========';
WITH station_times AS (
    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name,
        TRY_CAST(start_time AS DATETIME) AS trip_datetime
    FROM dw_schema.staging_trip
    WHERE start_station_id IS NOT NULL AND start_station_name IS NOT NULL
    UNION ALL
    SELECT
        end_station_id,
        end_station_name,
        TRY_CAST(end_time AS DATETIME)
    FROM dw_schema.staging_trip
    WHERE end_station_id IS NOT NULL AND end_station_name IS NOT NULL
),
latest_stations AS (
    SELECT
        station_id,
        station_name,
        ROW_NUMBER() OVER (PARTITION BY station_id ORDER BY trip_datetime DESC) AS rn
    FROM station_times
)
MERGE INTO dw_schema.dim_station AS ds
USING (
    SELECT
        station_id AS dim_station_id,
        station_name AS dim_station_name
    FROM latest_stations
    WHERE rn = 1
) AS src
ON ds.dim_station_id = src.dim_station_id
WHEN MATCHED THEN
    UPDATE SET ds.dim_station_name = src.dim_station_name
WHEN NOT MATCHED THEN
    INSERT (dim_station_id, dim_station_name)
    VALUES (src.dim_station_id, src.dim_station_name);


-- ============================================================================
-- Load bike dimension
-- ============================================================================
PRINT '========== Load bike dimension! ==========';
MERGE dw_schema.dim_bike AS tgt
USING (
  SELECT DISTINCT
    CAST(TRIM(bike_id) AS INT) AS bike_id
  FROM dw_schema.staging_trip
) AS src
ON tgt.dim_bike_id = src.bike_id
WHEN NOT MATCHED THEN
  INSERT (dim_bike_id)
  VALUES (src.bike_id);
GO

-- ============================================================================
-- Load user type dimension
-- ============================================================================
PRINT '========== Load user type dimension! ==========';
MERGE dw_schema.dim_user_type AS tgt
USING (
  SELECT DISTINCT user_type AS user_type_name
  FROM dw_schema.staging_trip
  WHERE user_type IS NOT NULL
) AS src
ON tgt.dim_user_type_name = src.user_type_name
WHEN NOT MATCHED THEN
  INSERT (dim_user_type_name)
  VALUES (src.user_type_name);
GO

-- ============================================================================
-- Load fact table
-- ============================================================================
PRINT '========== Load fact table! ==========';
MERGE dw_schema.fact_trip AS tgt
USING (
  SELECT
    CAST(trip_id AS BIGINT) AS fact_trip_source_id,
    CAST(trip_duration AS FLOAT) AS fact_trip_duration,
    TRY_CAST(start_time AS DATETIME) AS fact_trip_start_time_id,
    TRY_CAST(end_time AS DATETIME) AS fact_trip_end_time_id,
    CAST(start_station_id AS INT) AS fact_trip_start_station_id,
    CAST(end_station_id AS INT) AS fact_trip_end_station_id,
    CAST(bike_id AS INT) AS fact_trip_bike_id,
    (
      SELECT dim_user_type_id
      FROM dw_schema.dim_user_type
      WHERE dim_user_type_name = st.user_type
    ) AS fact_trip_user_type_id
  FROM dw_schema.staging_trip AS st
) AS src
ON tgt.fact_trip_source_id = src.fact_trip_source_id
WHEN MATCHED AND (
    tgt.fact_trip_duration           != src.fact_trip_duration OR
    tgt.fact_trip_start_time_id     != src.fact_trip_start_time_id OR
    tgt.fact_trip_end_time_id       != src.fact_trip_end_time_id OR
    tgt.fact_trip_start_station_id  != src.fact_trip_start_station_id OR
    tgt.fact_trip_end_station_id    != src.fact_trip_end_station_id OR
    tgt.fact_trip_bike_id           != src.fact_trip_bike_id OR
    tgt.fact_trip_user_type_id      != src.fact_trip_user_type_id
) THEN
  UPDATE SET
    tgt.fact_trip_duration           = src.fact_trip_duration,
    tgt.fact_trip_start_time_id     = src.fact_trip_start_time_id,
    tgt.fact_trip_end_time_id       = src.fact_trip_end_time_id,
    tgt.fact_trip_start_station_id  = src.fact_trip_start_station_id,
    tgt.fact_trip_end_station_id    = src.fact_trip_end_station_id,
    tgt.fact_trip_bike_id           = src.fact_trip_bike_id,
    tgt.fact_trip_user_type_id      = src.fact_trip_user_type_id
WHEN NOT MATCHED THEN
  INSERT (
    fact_trip_source_id,
    fact_trip_duration,
    fact_trip_start_time_id,
    fact_trip_end_time_id,
    fact_trip_start_station_id,
    fact_trip_end_station_id,
    fact_trip_bike_id,
    fact_trip_user_type_id
  )
  VALUES (
    src.fact_trip_source_id,
    src.fact_trip_duration,
    src.fact_trip_start_time_id,
    src.fact_trip_end_time_id,
    src.fact_trip_start_station_id,
    src.fact_trip_end_station_id,
    src.fact_trip_bike_id,
    src.fact_trip_user_type_id
  );

GO
