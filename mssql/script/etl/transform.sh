#!/bin/bash

SCRIPT_PATH="/usr/src/app/script/etl"
SCRIPT_FILE="transform.sql"

echo -e "\n#################### Transforming $SCRIPT_FILE ... ####################"

/opt/mssql-tools18/bin/sqlcmd -S localhost \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C \
    -i "$SCRIPT_PATH/$SCRIPT_FILE"