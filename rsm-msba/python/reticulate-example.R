## load the reticulate library
library(reticulate)

## check what versions of python are available
py_discover_config()

## set the version of python to use if needed
# use_python("/usr/bin/python3", required = TRUE)

os <- import("os")
os$listdir(".")
pnd <- import("pandas")

## start the python "console"
repl_python()

## you can now execute python code in the console
# import os
# os.listdir(".")

## stop the python console and return to R
exit
