library(DBI)
con <- dbConnect(
  RPostgres::Postgres(),
  user = "jovyan",
  host = "127.0.0.1",
  port = 8765,
  dbname = "rsm-docker",
  password = "postgres"
)

## show list of tables
db_tabs <- dbListTables(con)
db_tabs

## add a dataframe that is available in R by default to the dbase
library(dplyr)
if (!"mtcars" %in% db_tabs) {
  copy_to(con, mtcars, "mtcars", temporary = FALSE)
}

## extract data from dbase connection
dat <- tbl(con, "mtcars")
dat

## show updated list of tables
dbListTables(con)

## drop a table
# dbRemoveTable(con, "mtcars")

## show updated list of tables
# dbListTables(con)

## disconnect from database
dbDisconnect(con)
