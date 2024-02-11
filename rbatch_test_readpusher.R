#readpusher

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


test_asyncReaderPusher <- function(ethalone, con_db) {
  buffer <- paste(ethalone, as.numeric(Sys.time()))
  buffer <- splitter(buffer)[[1]]
  df <- data.frame(t(buffer))
  colnames(df) <- dbListFields(con_db, "co2_atm_data")
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

ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"
con_loc <- dbConnect(drv = RPostgres::Postgres(),
                     host     = 'localhost',
                     user     = 'admin',
                     password = '0i&=1UkV6KGTqJ',
                     dbname   = "postgres")
while(T) {
  test_asyncReaderPusher(ethalone, con_loc)
  print("Appending succesfull!\n")
  Sys.sleep(2)
}