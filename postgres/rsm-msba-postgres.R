library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "jovyan",
  host = "127.0.0.1",
  port = 5432,
  dbname = "rsm-docker",
  password = "postgres"
)

library(dplyr)
db_tabs <- dbListTables(con)
db_tabs

if (!"mtcars" %in% db_tabs) {
  copy_to(con, mtcars, "mtcars", temporary = FALSE)
}

dat <- tbl(con, "mtcars")
dat


dbListTables(con)
db_drop_table(con, table='mtcars')
dbListTables(con)
