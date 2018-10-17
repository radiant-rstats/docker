library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "postgres",
  host = "postgres",       ## use when establishing a connection between containers
  # host = "127.0.0.1",    ## use when connection to postgres from local Rstudio
  port = 5432,
  dbname = "postgres",
  password = "postgres"
)
