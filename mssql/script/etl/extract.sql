-- :SETVAR CSV_FILE "/usr/src/app/data/20219/Ridership-2019-Q1.csv"

USE TorontoSharedBikeDB;
GO

BULK INSERT dw_schema.staging_trip
FROM '$(CSV_FILE)'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	-- ERRORFILE = '$(ERROR_FILE)',
	MAXERRORS = 100000,
	TABLOCK
);
