library(DBI)
library(RPostgres)
con <- dbConnect(
  dbDriver("Postgres"),
  user = "jovyan",
  host = "127.0.0.1",
  port = 8765,
  dbname = "rsm-docker",
  password = "postgres"
)

## show list of tables
db_tabs <- dbListTables(con)
db_tabs

## add a table to the dbase
library(dplyr)
if (!"mtcars" %in% db_tabs) {
  copy_to(con, mtcars, "mtcars", temporary = FALSE)
}

## extra data from dbase connection
dat <- tbl(con, "mtcars")
dat

## show updated list of tables
dbListTables(con)

## drop a table (not working anymore)
# dbRemoveTable(con, table = "mtcars")

## show updated list of tables
dbListTables(con)
