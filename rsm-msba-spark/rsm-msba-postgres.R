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

library(dplyr)
flights_db <- tbl(con, "flights")

flights_db %>% select(year:day, dep_delay, arr_delay)
flights_db %>% filter(dep_delay > 240)
flights_db %>%
  group_by(dest) %>%
  summarise(delay = mean(dep_time))

