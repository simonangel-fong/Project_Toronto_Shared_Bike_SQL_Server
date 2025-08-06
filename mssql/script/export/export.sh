#!/bin/bash

DB_NAME="toronto_shared_bike"
SCHEMA_NAME="dw_schema"
MV_VIEW_LIST=("mv_user_time" "mv_user_station" "mv_station_count" "mv_bike_count")

echo "#######################################################"
echo "Export Job Starts..."
echo "#######################################################"

for VIEW in "${MV_VIEW_LIST[@]}"
do
  EXPORT_PATH="/export/${VIEW}.csv"

  echo "#######################################################"
  echo "Exporting $VIEW..."
  echo "#######################################################"
  
  /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -d "$DB_NAME" \
    -C \
    -Q "SET NOCOUNT ON; SELECT * FROM $SCHEMA_NAME.$VIEW;" \
    -s"," \
    -o "$EXPORT_PATH"


done

echo "#######################################################"
echo "Export Job Finish."
echo "#######################################################"
