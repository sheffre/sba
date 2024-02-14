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

splitter <- function(x) {
  output <- strsplit(as.character(x), split = " ")
  return(output)
}


# t <- open(con_serial)

colnames_default <- dbListFields(con_loc, "co2_atm_data")


test_asyncReaderPusher <- function(colnames_default, newText, con_db) {
  buffer <- c(newText, as.numeric(Sys.time()))
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

con_serial <- serialConnection(port = "COM3", 
                               mode = "19200,N,8,1", 
                               buffering = 'none',
                               newline = T, 
                               translation = "CRLF")


con_loc <- dbConnect(drv = RPostgres::Postgres(),
                     host     = 'localhost',
                     user     = 'admin',
                     password = '0i&=1UkV6KGTqJ1',
                     dbname   = "test")

open(con_serial)
i <- 1
newText <- ""
flush(con_serial)
while(i <= 15) {
  newText <- ""
  while(i <= 15) {
    flush(con_serial)
    newText <- read.serialConnection(con_serial)
    test <- parser(newText)
    if (test == TRUE) {
      test_asyncReaderPusher(colnames_default, newText = newText, con_db = con_loc)
      i <- i+1
      Sys.sleep(2)
    } else {
      break
    }
  }
}
close(con_serial)
test_asyncReaderPusher(colnames_default, newText, con_loc)
