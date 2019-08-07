---
title: "Connecting to a postgresql database"
output: 
  html_document: 
    keep_md: yes
---



Start the `rsm-msba-spark` computing container to also start postgresql. You can connect to the database from R using the code chunk below.


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

Is there anything in the database? If this is not the first time you are running this Rmarkdown file the database should already have one or more tables and the code chunk below should show "flights" as an existing table.


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
character(0)
```

If the database is empty, lets start with the example at <a href="https://db.rstudio.com/dplyr/" target="_blank">https://db.rstudio.com/dplyr/</a> and work through the following 6 steps:

### 1. install the nycflights13 package if not already available


```r
## install nycflights13 package locally if not already available
if (!require("nycflights13")) {
  local_r_dir <- Sys.getenv("R_LIBS_USER")
  if (!dir.exists(local_r_dir)) {
    dir.create(local_r_dir, recursive = TRUE)
  }
  install.packages("nycflights13", lib = local_r_dir)
}
```

```
Loading required package: nycflights13
```

### 2. Push data into the database 

Note that this is a fairly large file that we are copying into the database so make sure you have sufficient resources set for docker to use. See the install instructions for details:

* Windows: <a href="https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md" target="_blank">
https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md</a>
* macOS: <a href="https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md" target="_blank"> https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md</a>


```r
## only push to db if table does not yet exist
## Note: This step requires you have a reasonable amount of memory accessible 
## for docker. This can be changed in Docker > Preferences > Advanced 
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

### 3. Create a reference to the table(s) that (db)plyr can work with


```r
flights_db <- tbl(con, "flights")
```

### 4. Query the flights table using (db)plyr


```r
flights_db %>% select(year:day, dep_delay, arr_delay)
```

```
# Source:   lazy query [?? x 5]
# Database: postgres 10.0.9 [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_delay arr_delay
   <int> <int> <int>     <dbl>     <dbl>
 1  2013     1     1         2        11
 2  2013     1     1         4        20
 3  2013     1     1         2        33
 4  2013     1     1        -1       -18
 5  2013     1     1        -6       -25
 6  2013     1     1        -4        12
 7  2013     1     1        -5        19
 8  2013     1     1        -3       -14
 9  2013     1     1        -3        -8
10  2013     1     1        -2         8
# … with more rows
```

```r
flights_db %>% filter(dep_delay > 300)
```

```
# Source:   lazy query [?? x 19]
# Database: postgres 10.0.9 [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_time sched_dep_time dep_delay arr_time
   <int> <int> <int>    <int>          <int>     <dbl>    <int>
 1  2013     1     1      848           1835       853     1001
 2  2013     1     1     2343           1724       379      314
 3  2013     1     2     1412            838       334     1710
 4  2013     1     2     1607           1030       337     2003
 5  2013     1     2     2131           1512       379     2340
 6  2013     1     5     1344            817       327     1635
 7  2013     1     7     2021           1415       366     2332
 8  2013     1     9      641            900      1301     1242
 9  2013     1    10     1121           1635      1126     1239
10  2013     1    10     1525            900       385     1713
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
# Database: postgres 10.0.9 [jovyan@127.0.0.1:8765/rsm-docker]
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
  filter(n > 200)

tailnum_delay_db
```

```
# Source:     lazy query [?? x 3]
# Database:   postgres 10.0.9 [jovyan@127.0.0.1:8765/rsm-docker]
# Ordered by: desc(delay)
   tailnum delay     n
   <chr>   <dbl> <dbl>
 1 <NA>     NA    2512
 2 N16919   29.9   251
 3 N14998   27.9   230
 4 N15910   27.6   280
 5 N14950   25.3   219
 6 N22971   24.7   230
 7 N36915   24.1   228
 8 N17984   23.7   240
 9 N15980   23.5   316
10 N21537   23.4   224
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
WHERE ("n" > 200.0)
```

```r
nrow(tailnum_delay_db)
```

```
[1] NA
```

```r
tailnum_delay <- tailnum_delay_db %>% collect()
nrow(tailnum_delay)
```

```
[1] 502
```

```r
tail(tailnum_delay)
```

```
# A tibble: 6 x 3
  tailnum delay     n
  <chr>   <dbl> <dbl>
1 N705TW  -7.09   293
2 N718TW  -7.16   328
3 N721TW  -7.25   318
4 N711ZX  -7.43   291
5 N706TW  -9.28   220
6 N727TW  -9.64   275
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
1 2013     1  12     2359           2359         0      429            437
2 2013     1  13     2354           2250        64      100           2359
3 2013     1  13     2358           2045       193      233           2310
4 2013     1  13     2359           2130       149      435            218
5 2013     1  14     2353           2359        -6      429            444
6 2013     1  15     2356           2359        -3      439            444
  arr_delay carrier flight tailnum origin dest air_time distance hour
1        -8      B6    727  N509JB    JFK  BQN      185     1576   23
2        61      B6    608  N334JB    JFK  PWM       42      273   22
3       203      B6    115  N239JB    JFK  MSY      187     1182   20
4       137      B6    701  N337JB    JFK  SJU      189     1598   21
5       -15      B6    739  N775JB    JFK  PSE      193     1617   23
6        -5      B6    739  N547JB    JFK  PSE      202     1617   23
  minute           time_hour
1     59 2013-01-13 04:00:00
2     50 2013-01-14 03:00:00
3     45 2013-01-14 01:00:00
4     30 2013-01-14 02:00:00
5     59 2013-01-15 04:00:00
6     59 2013-01-16 04:00:00
```
