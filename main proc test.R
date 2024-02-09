required_packages <- c("tidyverse", "serial", "stringi", "rlist", "DBI", "RPostgres", "future")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

lapply(required_packages, install_if_missing)

library(tidyverse)
library(serial)
library(stringi)
library(rlist)
library(DBI)
library(RPostgres)
library(future)
plan(multisession, workers = 2)

test_async_pusher <- function(buffer, con_db) {
  pusher(buffer, con_db)
  future::value(NULL)
}


pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data",
                  value = dataframe_output)
  }, 
  error = function(cond) {
    print("Connecting to a database...\n")
    tryCatch(
      {open(con_db)
      }, 
      error = function(cond) {
        print("Error connecting database! Please check 
              your verification data!\n")
      })
  }
  )
}

con_loc <- dbConnect(drv = RPostgres::Postgres(), 
                    host     = 'localhost', 
                    user     = 'admin', 
                    password = '0i&=1UkV6KGTqJ', 
                    dbname   = "test")

con_serv <- dbConnect(drv = RPostgres::Postgres(), 
                    host     = '81.31.246.77', 
                    user     = 'testuser', 
                    password = 'x*5?kxaM>MgD,v', 
                    dbname   = "default_db")

colnames_default <- dbListFields(con_serv, "co2_atm_data")


ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"
buffer <- paste(ethalone, Sys.time())
buffer <- splitter(buffer)[[1]]
df <- data.frame(t(buffer))
colnames(df) <- colnames_default

i <- 1

while(i <= 15) {
  pusher(df, con_loc)
  pusher(df, con_serv)
  i <- i +1
}
t1 <- future::value(test_async_pusher(df, con_loc))
