library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "postgres",
  host = "postgres",
  port = 5432,
  dbname = "postgres",
  password = "postgres"
)
