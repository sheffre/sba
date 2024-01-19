library(R6)
library(serial)

tech <- R6Class(classname = "tech",
               public = list(
                  port = "COM3",
                  mode = "19200,n,8,1",
                  buffering = "line",
                  setConnection = function(port = NULL, mode = NULL, buffering = NULL){
                    connection <- serialConnection(port = self$port, 
                                                mode = self$mode, 
                                                buffering = self$buffering)
                    return(connection)
                  },
                  initialize = function(port, mode, buffering) {
                    self$port <- port
                    self$mode   <- mode
                    self$buffering <- buffering
                  } 
                )
               ) 

db <- 


interface <- R6Class(classname = "interface",
                     public = list(
                       splitter <- function(x) {
                         output <- strsplit(x, split = " ")
                         return(output)
                       },
                       databaseExporter <- function() {
                         
                       }
                       loop = function() {
                         sba <- tech$new(port = "COM3", 
                                         mode = "19200,n,8,1", 
                                         buffering = "line")
                         
                         is_con_open <- open(tech&connection)
                         if (is_con_open == "DONE") {
                           while(T) {
                             newText <- read.serialConnection(ser)
                             if(0 < nchar(newText))
                             {
                               foo <- c(foo, paste(newText, Sys.time()))
                             }
                             
                           }
                         }
                       }
                     ))




splitter <- function(x) {
  output <- strsplit(x, split = " ")
  return(output)
}



saver <- function(dataframe_output, stopTime, path) {
  stopTime_str <- str_replace_all(stopTime, ":", " ")
  # write.csv2(dataframe_output, 
  #            file = paste0(path, paste0("output_for_", 
  #                                       str_replace_all(stopTime, ":", " "), ".csv")))  
}





main_loop <- function() {
  is_con_open <- open(self&connection)
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
          cat("Начато сохранение данных. Не прерывайте работу программы!")
          
          
          for (i in c(1:length(foo))) {
            vec <- c(vec, as.vector(foo[[i]]))
            vecSplitted <- splitter(vec)[[1]]
            mat <- rbind(mat, vecSplitted)
          }
          
          dataframed_output <- data.frame(mat)
          saver(dataframed_output, stopTime, path)
          
          stopTime = Sys.time() + stopTime_interval
          cat(paste("Сохранение в ", Sys.time(), "прошло успешно"))
          foo <- list()
          mat <- matrix(nrow = 1, ncol = 10)
          vec <- vector()
          break
        } 
      }
    }} else cat("Ошибка: COM-порт недоступен (код ошибки: 1)")
}