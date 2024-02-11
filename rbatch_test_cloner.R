#cloner

required_packages <- c("tidyverse", "serial", "stringi", "rlist", "DBI", "RPostgres", "future", "lubridate")

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
library(lubridate)

test_asyncCloner <- function() {
  con_serv <- dbConnect(drv = RPostgres::Postgres(),
                        host     = '81.31.246.77',
                        user     = 'testuser',
                        password = 'x*5?kxaM>MgD,v',
                        dbname   = "default_db")
  
  sql_query_time <- "SELECT * FROM co2_atm_data ORDER BY timestamp DESC LIMIT 1"
  
  last <- dbGetQuery(con_serv, sql_query_time)
  last$timestamp <- as.POSIXct(as.numeric(last$timestamp))
  dbDisconnect(con_serv)
  
  con_loc <- dbConnect(drv = RPostgres::Postgres(),
                       host     = 'localhost',
                       user     = 'cloner',
                       password = 'cloner',
                       dbname   = "postgres")
  
  sql_query <- paste0("SELECT * FROM co2_atm_data WHERE timestamp < ", "to_timestamp('",
                      lubridate::round_date(last$timestamp, unit ="second"), "',  'yyyy-mm-dd hh24:mi:ss')")
  result <- dbGetQuery(con_loc, sql_query)
  
  dbDisconnect(con_loc)
  
  con_serv <- dbConnect(drv = RPostgres::Postgres(),
                        host     = '81.31.246.77',
                        user     = 'testuser',
                        password = 'x*5?kxaM>MgD,v',
                        dbname   = "default_db")
  dbAppendTable(con_serv, "co2_atm_data", result)
  
  sql_query_dupl <- "WITH cte AS (
                 SELECT *, ROW_NUMBER() OVER (PARTITION BY timestamp ORDER BY timestamp) AS row_num
                 FROM co2_atm_data
              )
              DELETE FROM co2_atm_data
              WHERE (timestamp) IN (SELECT timestamp FROM cte WHERE row_num > 1);"
  
  dbExecute(con_serv, sql_query_dupl)
  
  dbDisconnect(con_serv)
  rm(result, sql_query, sql_query_time, sql_query_dupl, last)
}


while(T) {
  test_asyncCloner()
  Sys.sleep(2)
}

