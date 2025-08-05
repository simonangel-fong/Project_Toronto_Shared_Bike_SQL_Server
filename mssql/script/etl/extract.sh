#!/bin/bash

BASE_PATH="/usr/src/app/data"
ERROR_FILE="$BASE_PATH/error.log"


/opt/mssql-tools18/bin/sqlcmd -S localhost \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -Q "
    USE TorontoSharedBikeDB;
    GO

    TRUNCATE TABLE dw_schema.staging_trip;
    "

for year in {2019..2022..1}; do
    for file in "$BASE_PATH/$year"/*;  do
        echo -e "\n#################### Extracting $file ... ####################"

        /opt/mssql-tools18/bin/sqlcmd -S localhost \
            -U sa \
            -P "$MSSQL_SA_PASSWORD" \
            -C \
            -i /usr/src/app/script/etl/extract.sql \
            -v CSV_FILE="$file" \
            # -v ERROR_FILE="$ERROR_FILE"
    done
done