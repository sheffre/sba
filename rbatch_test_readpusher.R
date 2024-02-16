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

con_loc <- dbConnect(drv = RPostgres::Postgres(),
                     host     = 'localhost',
                     user     = 'admin',
                     password = '0i&=1UkV6KGTqJ1',
                     dbname   = "test")

con_serial <- serialConnection(port = "COM3", 
                               mode = "19200,n,8,1", 
                               buffering = 'none',
                               newline = 1, 
                               translation = "crlf")

colnames_default <- dbListFields(con_loc, "co2_atm_data")

reader_mod <- function(conn) {
  flush(conn)
  output <- read.serialConnection(conn)
  while(nchar(output) != 35) {
    output <- read.serialConnection(conn)
  }
  return(output)
}


test_asyncReaderPusher <- function(colnames_default, newText, con_db) {
  buffer <- strsplit(newText, split = " ")[[1]]
  buffer <- c(buffer, as.numeric(Sys.time()))
  df <- data.frame(t(buffer))
  colnames(df) <- colnames_default
  df$timestamp <- as.POSIXct(as.numeric(df$timestamp), origin = "1970-01-01")
  
  tryCatch({
    dbAppendTable(conn = con_db,
                  name = "co2_atm_data",
                  value = df)
    # Возвращаем что-то, чтобы future::value не был NULL
    cat("Appending succesfull!\n")
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
                              password = '0i&=1UkV6KGTqJ1',
                              dbname   = "test")
    
    # Повторно вызываем dbAppendTable
    tryCatch({
      dbAppendTable(conn = con_db_retry,
                    name = "co2_atm_data",
                    value = df)
      cat("Appending succesfull!\n")
    },
    error = function(cond_retry) {
      cat("Error pushing data to the database on retry: ", conditionMessage(cond_retry), "\n")
    })
    
    # Всегда закрываем новое соединение, даже если была ошибка в retry
    dbDisconnect(con_db_retry)
    
    return(invisible())
  })
}

# ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"

open(con_serial)
i <- 1
newText <- ""
flush(con_serial)
while(TRUE) {
  while(TRUE) {
  newText <- reader_mod(con_serial)
  if (strsplit(newText, split = " ")[[1]][1] == "M") {
  test_asyncReaderPusher(colnames_default, newText = newText, con_loc)
  } else {break}
  }
}
# close(con_serial)
# test_asyncReaderPusher(colnames_default, newText, con_loc)
