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
[1] "flights"
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
 1  2013     1    24        10       -18
 2  2013     1    24         6       -13
 3  2013     1    24         4       -16
 4  2013     1    24       -11       -19
 5  2013     1    24        10        17
 6  2013     1    24        15       -18
 7  2013     1    24        33        -3
 8  2013     1    24         0       -20
 9  2013     1    24        66        63
10  2013     1    24        11         3
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
 1  2013     1    24     1953           1435       318     2227
 2  2013     1    24     2051           1522       329     2307
 3  2013     1    25       15           1815       360      208
 4  2013     1    25       26           1850       336      225
 5  2013     1    25      123           2000       323      229
 6  2013     1    25     2203           1635       328       34
 7  2013     1    26     1409            820       349     1528
 8  2013    10     1     1342            815       327     1458
 9  2013    10     2     2002           1456       306     2113
10  2013    10     6     2208           1645       323       20
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
1 2013    10   7     2351           2359        -8      353            350
2 2013    10   7     2356           2159       117       56           2312
3 2013    10  10     2353           2159       114       46           2308
4 2013    10  10     2358           2359        -1      352            350
5 2013    10  11     2351           1905       286      103           2038
6 2013    10  11     2353           2100       173      111           2235
  arr_delay carrier flight tailnum origin dest air_time distance hour
1         3      B6    745  N703JB    JFK  PSE      214     1617   23
2       104      EV   5904  N12924    EWR  BTV       46      266   21
3        98      9E   3525  N913XJ    LGA  SYR       32      198   21
4         2      B6    745  N580JB    JFK  PSE      212     1617   23
5       265      EV   5383  N761ND    LGA  ROC       46      254   19
6       156      MQ   3317  N507MQ    LGA  RDU       64      431   21
  minute           time_hour
1     59 2013-10-08 03:00:00
2     59 2013-10-08 01:00:00
3     59 2013-10-11 01:00:00
4     59 2013-10-11 03:00:00
5      5 2013-10-11 23:00:00
6      0 2013-10-12 01:00:00
```
