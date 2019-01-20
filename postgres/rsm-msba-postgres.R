library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "postgres",
  host = "postgres",       ## use when establishing a connection between containers
  # host = "127.0.0.1",    ## use when connection to postgres from local Rstudio (desktop)
  port = 5432,
  dbname = "postgres",
  password = "postgres"
)

## If the lines *above* run without error than you have successfully connect to the postgres database
