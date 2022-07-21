#!/usr/bin/env bash
# script to use for SQL+ETL course
# run from a terminal in JupyterLab

cd ~
mkdir sql_data

wget -O ~/sql_data/WestCoastImporters_Full_Dump.sql https://www.dropbox.com/s/gqnhvhhxyjrslmb/WestCoastImporters_Full_Dump.sql

wget -O ~/sql_data/Northwind_DB_Dump.sql https://www.dropbox.com/s/s3bn7mkmpo391s3/Northwind_DB_Dump.sql

createdb -p 8765  -U jovyan WestCoastImporters
psql -p 8765 WestCoastImporters -U jovyan < ~/sql_data/WestCoastImporters_Full_Dump.sql

createdb -p 8765  -U jovyan Northwind
psql -p 8765 Northwind -U jovyan < ~/sql_data/Northwind_DB_Dump.sql

printf "\n\nDo you want to delete the directory with the raw data (y/n)?"
read del_sql_data
if [ ${del_sql_data} == "y" ]; then
    {
        rm -rf ~/sql_data/
        echo "Raw data directory deleted"
    } || {
        echo "There was a problem deleting the data directory ~/sql_data"
        echo "Please remove it manually"
    }
fi

# to connect to the database from pgweb in the docker container
# use the below as the "Scheme"
# postgresql://jovyan:postgres@127.0.0.1:8765/WestCoastImporters
# postgresql://jovyan:postgres@127.0.0.1:8765/Northwind

# if you have an issue connecting to postgres
# (1) stop the containers with q + Enter from the launch menu
# (2) type "docker volume rm pg_data" + Enter in an Ubuntu of macOS terminal
# (3) start the docker container again and re-run this script
