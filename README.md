# Data Warehouse Project - Toronto Shared Bike (SQL Server + Power BI Solution)

A data warehouse project of Toronto Shared Bike using SQL Server & Power BI.

- [Data Warehouse Project - Toronto Shared Bike (SQL Server + Power BI Solution)](#data-warehouse-project---toronto-shared-bike-sql-server--power-bi-solution)
	- [Data Warehouse](#data-warehouse)
		- [Logical Design](#logical-design)
		- [Physical Implementation](#physical-implementation)
		- [Connect with MSSQL](#connect-with-mssql)
	- [ETL Pipeline](#etl-pipeline)
		- [Confirm](#confirm)
		- [Export Processed Data](#export-processed-data)
	- [Data Visualization: Power BI](#data-visualization-power-bi)

---

## Data Warehouse

- Data Source:
  - https://open.toronto.ca/dataset/bike-share-toronto-ridership-data/

### Logical Design

![pic](./pic/Logical_design_ERD.png)

---

### Physical Implementation

- Initialize MSSQL Instance

```sh
cd mssql
docker compose up -d
```

---

### Connect with MSSQL

- Connection

![pic](./pic/connect_mssql.png)

- Tables & views

![pic](./pic/connect_mssql02.png)

---

## ETL Pipeline

- Diagram

![pic](./pic/etl.gif)

- Extract

```sh
docker exec -it mssql bash /usr/src/app/script/etl/extract.sh
```

![pic](./pic/etl01.png)

- Transform

```sh
docker exec -it mssql bash /usr/src/app/script/etl/transform.sh
```

![pic](./pic/etl02.png)

- Load

```sh
docker exec -it mssql bash /usr/src/app/script/etl/load.sh
```

![pic](./pic/etl03.png)

---

### Confirm

- Time dimension

```sh
SELECT
	dim_year
	, dim_month
	, dim_hour
	, dim_user
	, trip_count
	, duration_sum
FROM toronto_shared_bike.dw_schema.mv_user_time
ORDER BY dim_year, dim_month, dim_hour, dim_user
```

![pic](./pic/query01.png)

- Station dimension

```sh
SELECT
	dim_year
	, dim_user
	, dim_station
	, trip_count
FROM toronto_shared_bike.dw_schema.mv_user_station
ORDER BY dim_year, dim_user, trip_count DESC
```

![pic](./pic/query02.png)

---

### Export Processed Data

```sh
docker exec -it mssql bash /usr/src/app/script/export/export.sh
```

![pic](./pic/export01.png)

---

## Data Visualization: Power BI

- Connect with SQL Server

![pic](./pic/powerbi01.png)

- Import Data model

![pic](./pic/powerbi02.png)

- Dashboard Design

![pic](./pic/powerbi03.png)

- Publish Dashboard

![pic](./pic/powerbi04.png)

- Embedded with GitHub Page
  - https://simonangel-fong.github.io/Project_Toronto_Shared_Bike_SQL_Server/

![pic](./pic/github_page.png)
