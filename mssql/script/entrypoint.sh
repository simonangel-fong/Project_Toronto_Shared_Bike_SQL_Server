#!/bin/bash
# set -e

# # start the SQL Server service
# # /opt/mssql/bin/sqlservr & sleep 10
# /opt/mssql/bin/sqlservr &&

# # echo "############################## Waiting for SQL Server to be ready... ##############################"
# # for i in {1..30}; do
# #   /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 0" > /dev/null 2>&1
# #   if [ $? -eq 0 ]; then
# #     echo "SQL Server is ready."
# #     break
# #   fi

# #   echo "########## sleep 2 ##########"
# #   sleep 10
# # done

# echo "############################## Initialize SQL scripts... ##############################"

# for script in /usr/src/app/scripts/setup/*.sql; do
#   if [ -f "$script" ]; then
#     echo "################  Running $script..."
#     /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i "$script"
#     echo ""################ Completed $script"
#   fi
# done

# wait

/opt/mssql/bin/sqlservr & 

# echo "############################## Initialize SQL scripts... ##############################"

# for script in /usr/src/app/scripts/setup/*.sql; do
#   if [ -f "$script" ]; then
#     echo "################  Running $script..."
#     /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i "$script"
#     echo "################ Completed $script"
#   fi

#   sleep 10
# done


sleep 60

echo "############################## Initialize SQL scripts... ##############################"

for script in /usr/src/app/script/setup/*.sql; do
  if [ -f "$script" ]; then
    echo "################  Running $script..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -l 60 -C -i "$script"
    echo "################ Completed $script"
  fi
done

wait

