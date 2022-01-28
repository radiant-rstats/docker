#!/usr/bin/env bash

cd ~
mkdir sql_data

usethis --dest './sql_data/' "https://www.dropbox.com/s/a02acwp9amg5ukc/WestCoastImporters_Full_Dump.sql?dl=1"

createdb -p 8765  -U jovyan WestCoastImporters
psql -p 8765 WestCoastImporters -U jovyan < './sql_data/WestCoastImporters_Full_Dump.sql'
