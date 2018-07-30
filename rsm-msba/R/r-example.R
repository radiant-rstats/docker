## load radiant library
library(radiant)

## run cluster analysis
result <- kclus(shopping, vars = "v1:v6", nr_clus = 3)
summary(result)
plot(result, plots = c("density","bar"))

## store cluster membership
shopping <- store(shopping, result, name = "clus")

## installing R packagess *in* the container environment
install.packages("fortunes")
fortunes::fortune()
remove.packages("fortunes")

## installing R packages in a personal library on the host machine
.libPaths()
Sys.getenv("R_LIBS_USER")
install.packages("fortunes", Sys.getenv("R_LIBS_USER"))

## in case the personal library is not created ...
fs::dir_create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)

## restart R session
.libPaths()
install.packages("fortunes")
fortunes::fortune()
remove.packages("fortunes")

## check if you can build packages that need to be compiled
install.packages("purrr")
remove.packages("purrr")
