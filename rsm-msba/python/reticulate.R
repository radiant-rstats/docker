## use python in R https://github.com/rstudio/reticulate
library(reticulate)

## check if you have pandas installed
py_discover_config(required_module = "pandas")

## interact with python from R
os <- import("os")
os$listdir(".")

## start the python REPL and open a .py file
repl_python()
