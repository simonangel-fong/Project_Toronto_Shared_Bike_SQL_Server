USE toronto_shared_bike;
GO

-- =========================================
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
ORDER BY 
	dim_year
	, dim_user
	, trip_count DESC
	, dim_station;


-- ====================

SELECT *
FROM dw_schema.mv_user_station
-- WHERE dim_user = 'all'
ORDER BY 
	dim_year,
	trip_count DESC;

-- ==============================
-- station cout per year
SELECT
	COUNT(DISTINCT f.fact_trip_start_station_id)	AS	"station_count"
	, t.dim_time_year					AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
ORDER BY dim_year
;

-- ==============================
-- bike cout per year
SELECT
	COUNT(DISTINCT f.fact_trip_bike_id)	AS	"bike_count"
	, t.dim_time_year					AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
ORDER BY dim_year
;


-- =============================
SELECT *
FROM toronto_shared_bike.dw_schema.mv_station_count;

SELECT *
FROM toronto_shared_bike.dw_schema.mv_bike_count;