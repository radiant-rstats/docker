---
title: "Connecting to a postgresql database"
output: 
  html_document: 
    keep_md: yes
---



Starting the `rsm-msba-spark` computing container also starts a postgresql server running on your machine. You can connect to the database from R using the code chunk below.


```r
library(DBI)
library(RPostgreSQL)
con <- dbConnect(
  dbDriver("PostgreSQL"),
  user = "jovyan", 
  host = "127.0.0.1",
  port = 8765,
  dbname = "rsm-docker",
  password = "postgres"
)
```

Is there anything in the database? If this is not the first time you are running this Rmarkdown file, the database should already have one or more tables and the code chunk below should show "flights" as an existing table.


```r
library(dplyr)
```

```

Attaching package: 'dplyr'
```

```
The following objects are masked from 'package:stats':

    filter, lag
```

```
The following objects are masked from 'package:base':

    intersect, setdiff, setequal, union
```

```r
db_tabs <- dbListTables(con)
db_tabs
```

```
[1] "flights"
```

If the database is empty, lets start with the example at <a href="https://db.rstudio.com/dplyr/" target="_blank">https://db.rstudio.com/dplyr/</a> and work through the following 6 steps:

### 1. install the nycflights13 package if not already available


```r
## install nycflights13 package locally if not already available
if (!require("nycflights13")) {
  local_dir <- Sys.getenv("R_LIBS_USER")
  if (!dir.exists(local_dir)) {
    dir.create(local_dir, recursive = TRUE)
  }
  install.packages("nycflights13", lib = local_dir)
  ## now use Session > Restart R and start from the top of
  ## of this file again
}
```

```
Loading required package: nycflights13
```

### 2. Push data into the database 

Note that this is a fairly large dataset that we are copying into the database so make sure you have sufficient resources set for docker to use. See the install instructions for details:

* Windows: <a href="https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md" target="_blank">
https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md</a>
* macOS: <a href="https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md" target="_blank"> https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md</a>


```r
## only push to db if table does not yet exist
## Note: This step requires you have a reasonable amount of memory
## accessible for docker. This can be changed in Docker > Preferences
## > Advanced   
## Memory (RAM) should be set to 4GB or more
if (!"flights" %in% db_tabs) {
  copy_to(con, nycflights13::flights, "flights",
    temporary = FALSE,
    indexes = list(
      c("year", "month", "day"),
      "carrier",
      "tailnum",
      "dest"
    )
  )
}
```

### 3. Create a reference to the data base that (db)plyr can work with


```r
flights_db <- tbl(con, "flights")
```

### 4. Query the data base using (db)plyr


```r
flights_db %>% select(year:day, dep_delay, arr_delay)
```

```
# Source:   lazy query [?? x 5]
# Database: postgres 10.0.10 [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_delay arr_delay
   <int> <int> <int>     <dbl>     <dbl>
 1  2013     7     1       109        90
 2  2013     7     1        63        56
 3  2013     7     1       138       134
 4  2013     7     1         9        -2
 5  2013     7     1       154       174
 6  2013     7     1        29        NA
 7  2013     7     1       150       185
 8  2013     7     1        45        29
 9  2013     7     1        30        19
10  2013     7     1        40        70
# … with more rows
```


```r
flights_db %>% filter(dep_delay > 240)
```

```
# Source:   lazy query [?? x 19]
# Database: postgres 10.0.10 [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_time sched_dep_time dep_delay arr_time
   <int> <int> <int>    <int>          <int>     <dbl>    <int>
 1  2013     7     1     1351            933       258     1648
 2  2013     7     1     1353            930       263     1701
 3  2013     7     1     1404            935       269     1742
 4  2013     7     1     1410            820       350     1558
 5  2013     7     1     1424           1005       259     1538
 6  2013     7     1     1504           1100       244     1801
 7  2013     7     1     1544           1142       242     1717
 8  2013     7     1     1602            959       363     1739
 9  2013     7     1     1621           1100       321     1743
10  2013     7     1     1632           1200       272     1859
# … with more rows, and 12 more variables: sched_arr_time <int>,
#   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#   minute <dbl>, time_hour <dttm>
```


```r
flights_db %>%
  group_by(dest) %>%
  summarise(delay = mean(dep_time))
```

```
Warning: Missing values are always removed in SQL.
Use `mean(x, na.rm = TRUE)` to silence this warning
This warning is displayed only once per session.
```

```
# Source:   lazy query [?? x 2]
# Database: postgres 10.0.10 [jovyan@127.0.0.1:8765/rsm-docker]
   dest  delay
   <chr> <dbl>
 1 ABQ   2006.
 2 ACK   1033.
 3 ALB   1627.
 4 ANC   1635.
 5 ATL   1293.
 6 AUS   1521.
 7 AVL   1175.
 8 BDL   1490.
 9 BGR   1690.
10 BHM   1944.
# … with more rows
```


```r
tailnum_delay_db <- flights_db %>% 
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  ) %>% 
  arrange(desc(delay)) %>%
  filter(n > 100)

tailnum_delay_db
```

```
# Source:     lazy query [?? x 3]
# Database:   postgres 10.0.10 [jovyan@127.0.0.1:8765/rsm-docker]
# Ordered by: desc(delay)
   tailnum delay     n
   <chr>   <dbl> <dbl>
 1 <NA>     NA    2512
 2 N11119   30.3   148
 3 N16919   29.9   251
 4 N14998   27.9   230
 5 N15910   27.6   280
 6 N13123   26.0   121
 7 N11192   25.9   154
 8 N14950   25.3   219
 9 N21130   25.0   126
10 N24128   24.9   129
# … with more rows
```

```r
tailnum_delay_db %>% show_query()
```

```
<SQL>
SELECT *
FROM (SELECT *
FROM (SELECT "tailnum", AVG("arr_delay") AS "delay", COUNT(*) AS "n"
FROM "flights"
GROUP BY "tailnum") "dbplyr_003"
ORDER BY "delay" DESC) "dbplyr_004"
WHERE ("n" > 100.0)
```


```r
nrow(tailnum_delay_db) ## why doesn't this work?
```

```
[1] NA
```

```r
tailnum_delay <- tailnum_delay_db %>% collect()
nrow(tailnum_delay)
```

```
[1] 1201
```

```r
tail(tailnum_delay)
```

```
# A tibble: 6 x 3
  tailnum  delay     n
  <chr>    <dbl> <dbl>
1 N494UA   -8.47   107
2 N839VA   -8.81   127
3 N706TW   -9.28   220
4 N727TW   -9.64   275
5 N3772H   -9.73   157
6 N3753   -10.2    130
```

### 5. Query the flights table using SQL

You can specify a SQL code chunk to query the database directly


```sql
SELECT * FROM flights WHERE dep_time > 2350
```

The variable `flights` now contains the result from the SQL query and will be shown below.


```r
head(flights)
```

```
  year month day dep_time sched_dep_time dep_delay arr_time sched_arr_time
1 2013     7   1     2359           2049       190      239           2348
2 2013     7   3     2356           1900       296      237           2240
3 2013     7   3     2359           2359         0      401            350
4 2013     7   4     2357           2359        -2      343            344
5 2013     7   5     2353           2359        -6      331            340
6 2013     7   5     2358           2359        -1      330            344
  arr_delay carrier flight tailnum origin dest air_time distance hour
1       171      B6    523  N789JB    JFK  LAX      314     2475   20
2       237      DL   1465  N624AG    JFK  SFO      311     2586   19
3        11      B6    745  N519JB    JFK  PSE      212     1617   23
4        -1      B6   1503  N524JB    JFK  SJU      197     1598   23
5        -9      B6    839  N661JB    JFK  BQN      196     1576   23
6       -14      B6   1503  N712JB    JFK  SJU      193     1598   23
  minute           time_hour
1     49 2013-07-02 00:00:00
2      0 2013-07-03 23:00:00
3     59 2013-07-04 03:00:00
4     59 2013-07-05 03:00:00
5     59 2013-07-06 03:00:00
6     59 2013-07-06 03:00:00
```
