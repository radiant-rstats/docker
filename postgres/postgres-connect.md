---
title: "Connecting to a postgresql database"
output: 
  html_document: 
    keep_md: yes
---



Starting the `rsm-msba-spark` (or `rsm-jupyter`) computing container also starts a postgresql server running on your machine. You can connect to the database from R using the code chunk below.


```r
library(DBI)
library(RPostgres)
con <- dbConnect(
  RPostgres::Postgres(),
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
library(dbplyr)
```

```

Attaching package: 'dbplyr'
```

```
The following objects are masked from 'package:dplyr':

    ident, sql
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
# Database: postgres [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_delay arr_delay
   <int> <int> <int>     <dbl>     <dbl>
 1  2013    12     9         7         3
 2  2013    12     9        -7        -8
 3  2013    12     9         5         2
 4  2013    12     9         1        -5
 5  2013    12     9        12        28
 6  2013    12     9        83        86
 7  2013    12     9        16        12
 8  2013    12     9        -4        -3
 9  2013    12     9        77        87
10  2013    12     9        49        40
# … with more rows
```


```r
flights_db %>% filter(dep_delay > 240)
```

```
# Source:   lazy query [?? x 19]
# Database: postgres [jovyan@127.0.0.1:8765/rsm-docker]
    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
 1  2013    12     9     1651           1135       316     1815           1250
 2  2013    12     9     1654           1230       264     1928           1455
 3  2013    12     9     1837           1229       368     2029           1413
 4  2013    12     9     1940           1527       253     2122           1656
 5  2013    12     9     2033           1630       243     2354           1935
 6  2013    12     9     2108           1700       248     2252           1840
 7  2013    12     9     2129           1725       244     2338           1915
 8  2013    12     9     2310           1848       262       31           2005
 9  2013    12    10     1048            645       243     1333            857
10  2013    12    10     1328            905       263     1618           1133
# … with more rows, and 11 more variables: arr_delay <dbl>, carrier <chr>,
#   flight <int>, tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
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
# Database: postgres [jovyan@127.0.0.1:8765/rsm-docker]
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
  window_order(desc(delay)) %>%
  filter(n > 100)

tailnum_delay_db
```

```
# Source:     lazy query [?? x 3]
# Database:   postgres [jovyan@127.0.0.1:8765/rsm-docker]
# Ordered by: desc(delay)
   tailnum delay       n
   <chr>   <dbl> <int64>
 1 N0EGMQ   9.98     371
 2 N10156  12.7      153
 3 N10575  20.7      289
 4 N11106  14.9      129
 5 N11107  15.0      148
 6 N11109  14.9      148
 7 N11113  15.8      138
 8 N11119  30.3      148
 9 N11121  10.3      154
10 N11127  13.6      124
# … with more rows
```

```r
tailnum_delay_db %>% show_query()
```

```
<SQL>
SELECT *
FROM (SELECT "tailnum", AVG("arr_delay") AS "delay", COUNT(*) AS "n"
FROM "flights"
GROUP BY "tailnum") "q01"
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
# A tibble: 6 × 3
  tailnum delay       n
  <chr>   <dbl> <int64>
1 N5FNAA   8.92     101
2 N305DQ  -4.26     139
3 N373NW  -1.39     110
4 N543MQ  13.8      202
5 N602LR  12.1      274
6 N637VA  -1.20     142
```

### 5. Query the flights table using SQL

You can specify a SQL code chunk to query the database directly


```sql
/* 
set the header of the sql chunck to
{sql, connection = con, output.var = "flights"}
*/
SELECT * FROM flights WHERE dep_time > 2350
```

The variable `flights` now contains the result from the SQL query and will be shown below.


```r
head(flights)
```

```
  year month day dep_time sched_dep_time dep_delay arr_time sched_arr_time
1 2013    12   9     2359           2359         0      759            437
2 2013    12   9     2400           2359         1      432            440
3 2013    12   9     2400           2250        70       59           2356
4 2013    12  11     2355           2359        -4      430            440
5 2013    12  11     2358           2359        -1      449            437
6 2013    12  11     2359           2359         0      440            445
  arr_delay carrier flight tailnum origin dest air_time distance hour minute
1        NA      B6    839  N520JB    JFK  BQN       NA     1576   23     59
2        -8      B6   1503  N705JB    JFK  SJU      195     1598   23     59
3        63      B6   1816  N187JB    JFK  SYR       41      209   22     50
4       -10      B6   1503  N606JB    JFK  SJU      196     1598   23     59
5        12      B6    839  N562JB    JFK  BQN      207     1576   23     59
6        -5      B6    745  N657JB    JFK  PSE      203     1617   23     59
            time_hour
1 2013-12-10 04:00:00
2 2013-12-10 04:00:00
3 2013-12-10 03:00:00
4 2013-12-12 04:00:00
5 2013-12-12 04:00:00
6 2013-12-12 04:00:00
```
