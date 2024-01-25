tryCatch({
  library(tidyverse)
  library(serial)
  library(stringi)
  library(rlist)
  library(DBI)
  library(RPostgres)
  library(future)
  print("Libraries connected!")
}, 
error = function(cond) {
  install.packages("tidyverse", "serial", "stringi",
                   "rlist", "DBI", "RPostgres", "future")
  print("Libraries installed. Connection...")
  library(tidyverse)
  library(serial)
  library(stringi)
  library(rlist)
  library(DBI)
  library(RPostgres)
  library(future)
  print("Libraries connected after installation successfully!")
}
)

plan(multisession)

data <- "M 56725 53156 453 55.0 0.0 0.0 999 \n"

sender <- future({
  
})