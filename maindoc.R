#libs
library(tidyverse)
library(serial)
library(stringi)

con_db <- dbConnect(drv = RPostgres::Postgres(), 
                    host     = '81.31.246.77', 
                    user     = 'gen_user', 
                    password = '0,%Bhaq!TLz=Aa', 
                    dbname   = "default_db")


splitter <- function(x) {
  output <- strsplit(x, split = " ")
  return(output)
}


saver <- function(dataframe_output, stopTime, path) {
  stopTime_str <- str_replace_all(stopTime, ":", " ")
  write.csv2(dataframe_output, 
             file = paste0(path, paste0("output_for_",
                                        str_replace_all(stopTime, ":", " "), 
                                        ".csv")))
}

pusher <- function(dataframe_output, con_db) {
  dbAppendTable(conn = con_db, name = "main_table", value = dataframe_output)
}

#main


path <- paste0(choose.dir(caption = "Choose directory for saving data:"), "\\")
gsub(x = path, replacement = "/", pattern = "\\",)
port <- readline(prompt = "Enter the port name in style of COMXX: ")

stopTime_interval <- as.numeric(readline(prompt = 
                                           "Enter the stop time interval in hours (hh.hh): "))*3600

ser <- serialConnection(port = port, mode = "19200,n,8,1", buffering = 'line')
is_con_open <- open(ser)


newText <- ""
stopTime <- Sys.time() + stopTime_interval
foo <- list()
textSize <- 0
vec <- vector()
mat <- matrix(nrow = 1, ncol = 10)


if (is_con_open == "DONE") {
  while(T) {
    while (Sys.time() < stopTime) {
    if (Sys.time() < stopTime) {
      newText <- read.serialConnection(ser)
      if(0 < nchar(newText))
      {
        foo <- c(foo, paste(newText, Sys.time()))
      }
    } 
    if (Sys.time() >= stopTime) {
      cat("Data saving in progress!")
      
      for (i in c(1:length(foo))) {
        vec <- c(vec, as.vector(foo[[i]]))
        vecSplitted <- splitter(vec)[[1]]
        mat <- rbind(mat, vecSplitted)
      }
      
      dataframed_output <- data.frame(mat)
      dataframed_output <- dataframed_output[-1,-1]
      colnames(dataframed_output) <- dbListFields(con_db, "main_table")
      # dataframed_output <- subset(dataframed_output, typeof == "M")
      saver(dataframed_output, stopTime, path)
      pusher(dataframed_output, con_db)
      stopTime = Sys.time() + stopTime_interval
      cat(paste("Saving data at", Sys.time(), "was successful!"))
      foo <- list()
      mat <- matrix(nrow = 1, ncol = 10)
      vec <- vector()
      break
    } 
  }
}} else cat("(Error code: 1)")
 



