#libs
tryCatch({
  library(tidyverse)
  library(serial)
  library(stringi)
  library(rlist)
  library(DBI)
  library(RPostgres)
  print("Libraries connected!")
  }, 
  error = function(cond) {
    install.packages("tidyverse", "serial", "stringi",
                     "rlist", "DBI", "RPostgres")
    print("Libraries installed. Connection...")
    library(tidyverse)
    library(serial)
    library(stringi)
    library(rlist)
    library(DBI)
    library(RPostgres)
    print("Libraries connected after installation successfully!")
  }
  )

op <- options(digit.secs = 0)
options(op)

tryCatch({
  con_db <- dbConnect(drv = RPostgres::Postgres(), 
                      host     = '81.31.246.77', 
                      user     = 'testuser', 
                      password = '0i&=1UkV6KGTqJ', 
                      dbname   = "default_db")
  
  
},
error = function(cond) {
  cat("Error wneh connectin database! Check your verification data!")
})

splitter <- function(x) {
  output <- strsplit(as.character(x), split = " ")
  return(output)
}


saver <- function(dataframe_output, stopTime, path) {
  tryCatch({
    write.csv2(dataframe_output, 
               file = paste0(path, paste0("output_for_",
                                          str_replace_all(stopTime, ":", " "), 
                                          ".csv")))
  }, 
  error = function(cond) {
    print("Saving data in file at", 
          Sys.time(), 
          ": error. \n
    Please check path.")
  })
}

pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data", 
                  value = dataframe_output)
  }, 
  error = function(cond) {
    print("Connecting to a database... \n")
    tryCatch(
      {open(con_db)
      }, 
      error = function(cond) {
        print("Error connecting database! Please check 
              your verification data! \n")
      })
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data", 
                  value = dataframe_output)
  }
  )
}

combiner <- function(names, path) {
  dataframe_output_daily <- data.frame()
  
  for (file_name in names) {
    file_path <- file.path(path, file_name)
    df <- read.csv2(file_path)
    dataframe_output_daily <- rbind(dataframe_output_daily, df)
  }
  
  output_folder <- paste0(path, "output_for_", str_replace_all(Sys.Date(), ":", " "))
  dir.create(output_folder)
  
  saving_path <- paste0(output_folder, "\\combined_output.csv")
  write.csv2(dataframe_output_daily, file = saving_path, row.names = FALSE)
}

colnames_default <- dbListFields(con_db, "co2_atm_data")

#main


path <- paste0(choose.dir(caption = "Choose directory for saving data:"), "\\")
# path <- gsub("\\", "/", fixed = T)
listPorts()
port <- readline(prompt = "Enter the port name in style of COMXX: ")

stopTime_interval <- as.numeric(readline(prompt =
                                           "Enter the stop time 
                                         interval in hours (hh.hh): "))*3600

stopTime_interval <- 3600

ser <- serialConnection(port = port, mode = "19200,N,8,1", buffering = 'line',
                        newline = T, translation = "CRLF")
is_con_open <- open(ser)

newText <- ""
foo <- list()
textSize <- 0
vec <- vector()
dataframed_output <- data.frame()
stopTime <- Sys.time() + stopTime_interval
counter <- 0

flush(ser)
if (is_con_open == "DONE") {
  while(T) {
    while (Sys.time() < stopTime) {
      if (Sys.time() < stopTime) {
        newText <- read.serialConnection(ser)
        if(0 < nchar(newText))
        {
          foo <- c(foo, paste(newText, Sys.time()))
          newText <- ""
        }
      } 
      if (Sys.time() >= stopTime) {
        cat("Data for last 5 minutes is now pushing to a DB and saving into a file...\n")
        foo <- foo[c(2:length(foo))]
        foo <- foo[!grepl("^Z", foo)]
        foo <- foo[!grepl("^W", foo)]
        for (i in c(1:length(foo))) {
          vec <- c(vec, as.vector(foo[[i]]))
          vecSplitted <- splitter(vec)[[1]]
          dataframed_output_temp <- t(data.frame(vecSplitted))
          colnames (dataframed_output_temp) <- colnames_default
          dataframed_output <- rbind(dataframed_output, dataframed_output_temp)
          colnames (dataframed_output) <- colnames_default
          vec <- vector()
        }
        colnames(dataframed_output) <- colnames_default
        saver(dataframed_output, stopTime, path)
        pusher(dataframed_output, con_db)
        cat("Data successfully saved!\n")
        foo <- list()
        vec <- vector()
        counter <- counter + 1
        cat(" Now counter value is ", counter, ".\n")
        stopTime <- Sys.time() + stopTime_interval
        break
      }
      
      if (counter >= 24) {
        cat("Data saving in progress!")
        files <- list.files(path = path, pattern = "*.csv")
        if (length(files) != 0) {
          combiner(files, path)
          stopTime = Sys.time() + stopTime_interval
          cat(paste("Resaving data at", Sys.time(), "was successful!\n"))
          counter <- 0
          break
        } else if (length(files) == 0) {
          break
        }
      }
    }
  }} else cat("(Error code: 1)")

close(ser)
