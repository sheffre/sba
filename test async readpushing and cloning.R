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
plan(multisession)
options(digits = 1)

ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"

splitter <- function(x) {
  output <- strsplit(as.character(x), split = " ")
  return(output)
}

plan(multisession)
# asyncReaderPusher <- function() {}

test_asyncReaderPusher <- function(ethalone, con_db) {
  buffer <- paste(ethalone, as.numeric(Sys.time()))
  buffer <- splitter(buffer)[[1]]
  df <- data.frame(t(buffer))
  colnames(df) <- colnames_default
  df$timestamp <- as.POSIXct(as.numeric(df$timestamp))
  
  tryCatch({
    dbAppendTable(conn = con_db,
                  name = "co2_atm_data",
                  value = df)
    # Возвращаем что-то, чтобы future::value не был NULL
    return(invisible())
  },
  error = function(cond) {
    cat("Error pushing data to the database: ", conditionMessage(cond), "\n")
    
    # Перед повторным использованием соединения, убедимся, что оно отключено
    if (dbIsValid(con_db)) {
      dbDisconnect(con_db)
    }
    
    # Создаем новое соединение для повторной попытки
    con_db_retry <- dbConnect(drv = RPostgres::Postgres(),
                              host     = 'localhost',
                              user     = 'admin',
                              password = '0i&=1UkV6KGTqJ',
                              dbname   = "postgres")
    
    # Повторно вызываем dbAppendTable
    tryCatch({
      dbAppendTable(conn = con_db_retry,
                    name = "co2_atm_data",
                    value = df)
    },
    error = function(cond_retry) {
      cat("Error pushing data to the database on retry: ", conditionMessage(cond_retry), "\n")
    })
    
    # Всегда закрываем новое соединение, даже если была ошибка в retry
    dbDisconnect(con_db_retry)
    
    return(invisible())
  })
}

# sql_query <- "SELECT * FROM co2_atm_data ORDER BY timestamp DESC LIMIT 1"

# test_asyncCloner <- function() {
#   con_limit <- dbConnect(drv = RPostgres::Postgres(),
#                    host     = '81.31.246.77',
#                    user     = 'testuser',
#                    password = 'x*5?kxaM>MgD,v',
#                    dbname   = "default_db")
#   
#   dbSendQuery(con_limit, "SET datestyle = dmy;")
#   
#   sql_query <- "SELECT * FROM co2_atm_data ORDER BY timestamp DESC LIMIT 1"
#   
#   # Выполнение запроса и получение данных
#   limit <- dbGetQuery(con_limit, sql_query)
#   limit$timestamp <- as.POSIXct(as.numeric(limit$timestamp))
#   
#   # Закрытие соединения
#   dbDisconnect(con_limit)
#   
#   
#   con <- dbConnect(drv = RPostgres::Postgres(),
#                    host     = 'localhost',
#                    user     = 'cloner',
#                    password = 'cloner',
#                    dbname   = "postgres") 
#   dbSendQuery(con, "SET datestyle = dmy;")
#   
#   # SQL-запрос для получения последней строки
#   sql_query <- paste0("SELECT * FROM co2_atm_data WHERE timestamp > ", "to_timestamp('",
#                       floor_date(limit$timestamp, "secs"), "',  'dd-mm-yyyy hh24:mm:ss')")
#   
#   # Выполнение запроса и получение данных
#   result <- dbGetQuery(con, sql_query)
#   
#   # Закрытие соединения
#   dbDisconnect(con)
#   
  # con <- dbConnect(drv = RPostgres::Postgres(),
  #                  host     = '81.31.246.77',
  #                  user     = 'testuser',
  #                  password = 'x*5?kxaM>MgD,v',
  #                  dbname   = "default_db")
#   dbAppendTable(con, name = "co2_atm_data", value = result)
#   rm(result)
#   
# }

time

test_asyncCloner <- function(con_loc, con_serv, stopTime) {
  con_loc <- dbConnect(drv = RPostgres::Postgres(),
                                          host     = 'localhost',
                                          user     = 'cloner',
                                          password = 'cloner',
                                          dbname   = "postgres")
  
  sql_query <- paste0("SELECT * FROM co2_atm_data WHERE timestamp > ", "to_timestamp('",
                      stopTime, "',  'dd-mm-yyyy hh24:mm:ss')")
  result <- dbGetQuery(con_loc, sql_query)
  dbDisconnect(con_loc)
  
  con_serv <- dbConnect(drv = RPostgres::Postgres(),
                   host     = '81.31.246.77',
                   user     = 'testuser',
                   password = 'x*5?kxaM>MgD,v',
                   dbname   = "default_db")
  dbAppendTable(con_serv, "co2_atm_data", result)
  rm(result)
  
  
}

future({
  while(T) {
    ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"
    con_loc <- dbConnect(drv = RPostgres::Postgres(),
                              host     = 'localhost',
                              user     = 'admin',
                              password = '0i&=1UkV6KGTqJ',
                              dbname   = "postgres")
    test_asyncReaderPusher(ethalone, con_loc)
    Sys.sleep(1)
  }
},lazy = T, label = "Async ReadPusher")


  timestamp <- Sys.time()
  stopTime_interval <- 60
  stopTime <- timestamp + stopTime_interval
  while(T) {
    while(Sys.time() < stopTime) {
      if(Sys.time() >= stopTime) {
        test_asyncCloner()
        stopTime <- Sys.time() + stopTime_interval
        break
      }
    }
  }




future::plan("sequential")
future::value(Future(environment()))
