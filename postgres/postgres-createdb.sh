#!/usr/bin/env bash
# script to use for SQL+ETL course
# run from a terminal in JupyterLab

cd ~
mkdir sql_data

wget -O ~/sql_data/WestCoastImporters_Full_Dump.sql https://www.dropbox.com/s/a02acwp9amg5ukc/WestCoastImporters_Full_Dump.sql

createdb -p 8765  -U jovyan WestCoastImporters
psql -p 8765 WestCoastImporters -U jovyan < ~/sql_data/WestCoastImporters_Full_Dump.sql
