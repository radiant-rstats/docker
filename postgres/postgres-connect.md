---
title: "Connecting to a postgresql database"
output: 
  html_document: 
    keep_md: yes
---



Starting the `rsm-msba-spark` computing container also starts a postgresql server running on your machine. You can connect to the database from R using the code chunk below.


```r
library(DBI)
library(RPostgres)
con <- dbConnect(
  dbDriver("Postgres"),
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
[1] "mtcars"  "flights"
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
 1  2013    10     6        -5       -31
 2  2013    10     6        -2       -21
 3  2013    10     6        -3       -25
 4  2013    10     6       -10       -23
 5  2013    10     6        16        14
 6  2013    10     6       -10       -22
 7  2013    10     6        -9       -25
 8  2013    10     6        -4        -9
 9  2013    10     6         2       -19
10  2013    10     6        -2        16
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
 1  2013    10     6     1357            929       268     1640           1234
 2  2013    10     6     2208           1645       323       20           1912
 3  2013    10     7     1738           1300       278     1858           1434
 4  2013    10     7     1741           1159       342     1909           1309
 5  2013    10     7     1858           1240       378     2025           1425
 6  2013    10     7     1905           1453       252     2002           1556
 7  2013    10     7     1912           1425       287     2048           1547
 8  2013    10     7     2002           1600       242     2100           1715
 9  2013    10     7     2004           1400       364     2112           1506
10  2013    10     7     2310           1905       245        8           2038
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
1 2013    10   7     2351           2359        -8      353            350
2 2013    10   7     2356           2159       117       56           2312
3 2013    10  10     2353           2159       114       46           2308
4 2013    10  10     2358           2359        -1      352            350
5 2013    10  11     2351           1905       286      103           2038
6 2013    10  11     2353           2100       173      111           2235
  arr_delay carrier flight tailnum origin dest air_time distance hour minute
1         3      B6    745  N703JB    JFK  PSE      214     1617   23     59
2       104      EV   5904  N12924    EWR  BTV       46      266   21     59
3        98      9E   3525  N913XJ    LGA  SYR       32      198   21     59
4         2      B6    745  N580JB    JFK  PSE      212     1617   23     59
5       265      EV   5383  N761ND    LGA  ROC       46      254   19      5
6       156      MQ   3317  N507MQ    LGA  RDU       64      431   21      0
            time_hour
1 2013-10-08 03:00:00
2 2013-10-08 01:00:00
3 2013-10-11 01:00:00
4 2013-10-11 03:00:00
5 2013-10-11 23:00:00
6 2013-10-12 01:00:00
```
