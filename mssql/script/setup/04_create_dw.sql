USE TorontoSharedBikeDB;
GO

DROP INDEX IF EXISTS index_fact_trip_user_type ON dw_schema.fact_trip;
DROP INDEX IF EXISTS index_fact_trip_station_pair ON dw_schema.fact_trip;
DROP INDEX IF EXISTS index_fact_trip_user_type ON dw_schema.fact_trip;
DROP TABLE IF EXISTS dw_schema.fact_trip;

DROP INDEX IF EXISTS index_dim_time_year_month ON dw_schema.dim_time;
DROP TABLE IF EXISTS dw_schema.dim_time;

DROP INDEX IF EXISTS index_dim_station_station_name ON dw_schema.dim_station;
DROP TABLE IF EXISTS dw_schema.dim_station;

DROP TABLE IF EXISTS dw_schema.dim_bike;
DROP TABLE IF EXISTS dw_schema.dim_user_type;

IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'ps_fact_trip')
    DROP PARTITION SCHEME ps_fact_trip;
GO

IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'ps_fact_trip')
    DROP PARTITION SCHEME ps_fact_trip;
GO

IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'pf_fact_trip')
    DROP PARTITION FUNCTION pf_fact_trip;
GO

-- =====================================
-- TIME DIMENSION
-- =====================================

CREATE TABLE dw_schema.dim_time (
  dim_time_id       DATETIME NOT NULL PRIMARY KEY,
  dim_time_year     SMALLINT NOT NULL CHECK (dim_time_year BETWEEN 2000 AND 2999),
  dim_time_quarter  TINYINT NOT NULL CHECK (dim_time_quarter BETWEEN 1 AND 4),
  dim_time_month    TINYINT NOT NULL CHECK (dim_time_month BETWEEN 1 AND 12),
  dim_time_day      TINYINT NOT NULL CHECK (dim_time_day BETWEEN 1 AND 31),
  dim_time_week     TINYINT NOT NULL CHECK (dim_time_week BETWEEN 1 AND 53),
  dim_time_weekday  TINYINT NOT NULL CHECK (dim_time_weekday BETWEEN 1 AND 7),
  dim_time_hour     TINYINT NOT NULL CHECK (dim_time_hour BETWEEN 0 AND 23),
  dim_time_minute   TINYINT NOT NULL CHECK (dim_time_minute BETWEEN 0 AND 59)
) ON DIM_FG;

CREATE NONCLUSTERED INDEX index_dim_time_year_month
  ON dw_schema.dim_time (dim_time_year, dim_time_month)
  ON INDEX_FG;
GO

-- =====================================
-- STATION DIMENSION
-- =====================================
CREATE TABLE dw_schema.dim_station (
  dim_station_id   INT NOT NULL PRIMARY KEY,
  dim_station_name VARCHAR(100) NOT NULL
) ON DIM_FG;

CREATE NONCLUSTERED INDEX index_dim_station_station_name
  ON dw_schema.dim_station (dim_station_name)
  ON INDEX_FG;
GO

-- =====================================
-- BIKE DIMENSION
-- =====================================
CREATE TABLE dw_schema.dim_bike (
  dim_bike_id    INT NOT NULL PRIMARY KEY
) ON DIM_FG;
GO

-- =====================================
-- USER TYPE DIMENSION
-- =====================================
CREATE TABLE dw_schema.dim_user_type (
  dim_user_type_id   INT IDENTITY(1,1) PRIMARY KEY,
  dim_user_type_name VARCHAR(50) NOT NULL UNIQUE
) ON DIM_FG;
GO

-- =====================================
-- PARTITION FUNCTION & SCHEME (For fact_trip)
-- =====================================
-- Partition by year start dates (adjust range as needed)
CREATE PARTITION FUNCTION pf_fact_trip (DATETIME)
AS RANGE LEFT FOR VALUES (
  '2018-12-31', '2019-12-31', '2020-12-31', '2021-12-31',
  '2022-12-31', '2023-12-31', '2024-12-31'
);
GO

CREATE PARTITION SCHEME ps_fact_trip
AS PARTITION pf_fact_trip
ALL TO ([FACT_FG]);  -- optionally spread across multiple filegroups
GO

-- =====================================
-- FACT TRIP TABLE
-- =====================================
CREATE TABLE dw_schema.fact_trip (
  fact_trip_id               INT IDENTITY(1,1),
  fact_trip_source_id        INT NOT NULL,
  fact_trip_duration         INT NOT NULL,
  fact_trip_start_time_id    DATETIME NOT NULL,
  fact_trip_end_time_id      DATETIME NOT NULL,
  fact_trip_start_station_id INT NOT NULL,
  fact_trip_end_station_id   INT NOT NULL,
  fact_trip_bike_id          INT NOT NULL,
  fact_trip_user_type_id     INT NOT NULL,

  CONSTRAINT pk_fact_trip PRIMARY KEY (fact_trip_id, fact_trip_start_time_id),

  CONSTRAINT fk_trip_start_time FOREIGN KEY (fact_trip_start_time_id)
      REFERENCES dw_schema.dim_time(dim_time_id),
  CONSTRAINT fk_trip_end_time FOREIGN KEY (fact_trip_end_time_id)
      REFERENCES dw_schema.dim_time(dim_time_id),
  CONSTRAINT fk_trip_start_station FOREIGN KEY (fact_trip_start_station_id)
      REFERENCES dw_schema.dim_station(dim_station_id),
  CONSTRAINT fk_trip_end_station FOREIGN KEY (fact_trip_end_station_id)
      REFERENCES dw_schema.dim_station(dim_station_id),
  CONSTRAINT fk_trip_bike FOREIGN KEY (fact_trip_bike_id)
      REFERENCES dw_schema.dim_bike(dim_bike_id),
  CONSTRAINT fk_trip_user_type FOREIGN KEY (fact_trip_user_type_id)
      REFERENCES dw_schema.dim_user_type(dim_user_type_id)
) ON ps_fact_trip (fact_trip_start_time_id);  -- Partitioned
GO

-- =====================================
-- FACT TRIP INDEXES
-- =====================================
CREATE NONCLUSTERED INDEX index_fact_trip_start_time
  ON dw_schema.fact_trip (fact_trip_start_time_id)
  ON INDEX_FG;

CREATE NONCLUSTERED INDEX index_fact_trip_station_pair
  ON dw_schema.fact_trip (fact_trip_start_station_id, fact_trip_end_station_id)
  ON INDEX_FG;

CREATE NONCLUSTERED INDEX index_fact_trip_user_type
  ON dw_schema.fact_trip (fact_trip_user_type_id)
  ON INDEX_FG;
GO

-- =====================================
-- Confirm Tables and Indexes
-- =====================================
SELECT name AS table_name, schema_name(schema_id) AS schema_name
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dw_schema');

SELECT name AS index_name, type_desc, object_name(object_id) AS table_name
FROM sys.indexes
WHERE object_id IN (
  SELECT object_id FROM sys.tables WHERE schema_id = SCHEMA_ID('dw_schema')
);
