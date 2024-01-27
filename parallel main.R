#libs
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
plan(multisession)
print("Libraries connected!")

op <- options(digit.secs = 0)
options(op)

tryCatch({
  con_db <- dbConnect(drv = RPostgres::Postgres(), 
                      host     = '81.31.246.77', 
                      user     = 'testuser', 
                      password = '0i&=1UkV6KGTqJ', 
                      dbname   = "default_db")
}, error = function(cond) {
  cat("Error when connecting to the database! Check your verification data!")
})

splitter <- function(x) {
  output <- strsplit(as.character(x), split = " ")
  return(output)
}

async_reader <- function(ser, buffer) {
  newText <- read.serialConnection(ser)
  if (nchar(newText) > 0) {
    future::value(paste(newText, Sys.time()))
  } else {
    future::value(NULL)
  }
}

async_processor <- function(newText, buffer) {
  if (!is.null(newText) && !grepl("^Z", newText) && !grepl("^W", newText)) {
    vec <- c(vec, as.vector(strsplit(newText, split = " ")[[1]]))
    vecSplitted <- splitter(vec)[[1]]
    dataframed_output_temp <- t(data.frame(vecSplitted))
    colnames(dataframed_output_temp) <- colnames_default
    buffer <- rbind(buffer, dataframed_output_temp)
    colnames(buffer) <- colnames_default
    vec <- vector()
  }
  future::value(buffer)
}

async_pusher <- function(buffer, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data", 
                  value = buffer)
  }, 
  error = function(cond) {
    print("Connecting to a database... \n")
    tryCatch(
      {open(con_db)
      }, 
      error = function(cond) {
        print("Error connecting to the database! Please check your verification data! \n")
      })
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data", 
                  value = buffer)
  }
  )
}

# combiner <- function(names, path) {
#   dataframe_output_daily <- data.frame()
#   
#   for (file_name in names) {
#     file_path <- file.path(path, file_name)
#     df <- read.csv2(file_path)
#     dataframe_output_daily <- rbind(dataframe_output_daily, df)
#   }
#   
#   output_folder <- paste0(path, "output_for_", str_replace_all(Sys.Date(), ":", " "))
#   dir.create(output_folder)
#   
#   saving_path <- paste0(output_folder, "/combined_output.csv")
#   write.csv2(dataframe_output_daily, file = saving_path, row.names = FALSE)
# }

colnames_default <- dbListFields(con_db, "co2_atm_data")

#main

path <- paste0(choose.dir(caption = "Choose directory for saving data:"), "/")
listPorts()
port <- readline(prompt = "Enter the port name in style of COMXX: ")

stopTime_interval <- as.numeric(readline(prompt =
                                           "Enter the stop time 
                                         interval in hours (hh.hh): "))*3600

ser <- serialConnection(port = port, mode = "19200,N,8,1", buffering = 'line',
                        newline = T, translation = "CRLF")
is_con_open <- open(ser)

newText <- ""
foo <- list()
textSize <- 0
vec <- vector()
dataframed_output <- data.frame()
stopTime <- Sys.time() + stopTime_interval
# counter <- 0

flush(ser)
if (is_con_open == "DONE") {
  while (TRUE) {
    while (Sys.time() < stopTime) {
      if (Sys.time() < stopTime) {
        future_reader <- future({async_reader(ser, newText)})
        newText <- future::value(future_reader)
        if (!is.null(newText)) {
          future_processor <- future({async_processor(newText, vec)})
          vec <- future::value(future_processor)
        }
      }
      
      if (Sys.time() >= stopTime) {
        cat("Data for the last 5 minutes is now pushing to a DB...\n")
        future_pusher <- future({async_pusher(vec, con_db)})
        future::value(future_pusher)
        cat("Data successfully pushed to the database!\n")
        vec <- vector()
        # counter <- counter + 1
        # cat("Now the counter value is ", counter, ".\n")
        stopTime <- Sys.time() + stopTime_interval
        break
      }
      
      # if (counter >= 24) {
      #   cat("Data saving in progress!")
      #   files <- list.files(path = path, pattern = "*.csv")
      #   if (length(files) != 0) {
      #     combiner(files, path)
      #     stopTime <- Sys.time() + stopTime_interval
      #     cat(paste("Resaving data at", Sys.time(), "was successful!\n"))
      #     counter <- 0
      #     break
      #   } else if (length(files) == 0) {
      #     break
      #   }
      # }
    }
  }
} else cat("(Error code: 1)")

close(ser)
