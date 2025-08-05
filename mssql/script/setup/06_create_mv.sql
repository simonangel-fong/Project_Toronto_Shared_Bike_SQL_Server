USE TorontoSharedBikeDB;
GO

-- ============================================================================
-- MV for Time-based and User-based Aggregation
-- ============================================================================

IF OBJECT_ID('dw_schema.mv_user_time', 'V') IS NOT NULL
    DROP VIEW dw_schema.mv_user_time;
GO

CREATE VIEW dw_schema.mv_user_time
WITH SCHEMABINDING
AS
SELECT	
	COUNT(*)									AS trip_count
	, SUM(CAST(fact_trip_duration AS BIGINT))	AS duration_sum
	, AVG(CAST(fact_trip_duration AS BIGINT))	AS duration_avg
	, dim_time_year								AS dim_year
	, dim_time_month							AS dim_month
	, dim_time_hour								AS dim_hour
	, dim_user_type_name						AS dim_user
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t 
    ON f.fact_trip_start_time_id = t.dim_time_id
JOIN dw_schema.dim_user_type u
	ON f.fact_trip_user_type_id = u.dim_user_type_id
GROUP BY
	dim_time_year
	, dim_time_month
	, dim_time_hour
	, dim_user_type_name
;
GO

-- ============================================================================
-- MV for Station-based and User-based Aggregation
-- ============================================================================

IF OBJECT_ID('dw_schema.mv_user_station', 'V') IS NOT NULL
    DROP VIEW dw_schema.mv_user_station;
GO

CREATE VIEW dw_schema.mv_user_station
WITH SCHEMABINDING
AS
WITH ranked_station_year_all AS (
	SELECT
		trip_count
		, dim_station
		, dim_year
		, RANK() OVER(PARTITION BY dim_year ORDER BY trip_count DESC) AS trip_rank
	FROM (
		SELECT 
			COUNT(*) AS trip_count,
			dim_station_name AS dim_station,
			dim_time_year AS dim_year
		FROM dw_schema.fact_trip f
		JOIN dw_schema.dim_time t 
			ON f.fact_trip_start_time_id = t.dim_time_id
		JOIN dw_schema.dim_station s 
			ON f.fact_trip_start_station_id = s.dim_station_id
		JOIN dw_schema.dim_user_type u 
			ON f.fact_trip_user_type_id = u.dim_user_type_id
		WHERE 
			dim_station_name <> 'UNKNOWN'
		GROUP BY 
			dim_station_name
			, dim_time_year
	) AS station_all_year
),
ranked_station_year_user AS (
	SELECT 
		trip_count
		, dim_year
		, dim_user
		, dim_station
		, RANK() OVER(PARTITION BY dim_year, dim_user ORDER BY trip_count DESC) AS trip_rank
	FROM (
		SELECT
			COUNT(*)								AS trip_count
			, dim_time_year							AS dim_year
			, dim_user_type_name					AS dim_user
			, dim_station_name						AS dim_station
		FROM dw_schema.fact_trip f
		JOIN dw_schema.dim_time t
			ON f.fact_trip_start_time_id = t.dim_time_id
		JOIN dw_schema.dim_station s
			ON f.fact_trip_start_station_id = s.dim_station_id
		JOIN dw_schema.dim_user_type u
			ON f.fact_trip_user_type_id = u.dim_user_type_id
		WHERE 
			dim_station_name <> 'UNKNOWN'
		GROUP BY
			dim_time_year
			, dim_user_type_name
			, dim_station_name
	) AS station_user_year
)
SELECT
	trip_count
	, dim_station
	, dim_year
	, 'all' AS dim_user
FROM ranked_station_year_all
WHERE trip_rank <= 10
UNION ALL
SELECT 
	trip_count
	, dim_station
	, dim_year
	, dim_user
FROM ranked_station_year_user
WHERE 
	trip_rank <= 10
;
GO

-- ============================================================================
-- MV for station cout per year
-- ============================================================================

CREATE VIEW dw_schema.mv_station_count
WITH SCHEMABINDING
AS
SELECT
	COUNT(DISTINCT f.fact_trip_start_station_id)	AS	"station_count"
	, t.dim_time_year								AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
;
GO

-- ============================================================================
-- MV for bike cout per year
-- ============================================================================

CREATE VIEW dw_schema.mv_bike_count
WITH SCHEMABINDING
AS
SELECT
	COUNT(DISTINCT f.fact_trip_bike_id)	AS	"bike_count"
	, t.dim_time_year					AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
;
GO