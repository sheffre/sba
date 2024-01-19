#SAVER FUNCTION PROTOTYPE

#Ремарка: ПРОПИСАТЬ: запрос ком-порта, запрос пути к файлу, запрос интервала 
#                    сбора данных,  

install.packages("stringi")
library(tidyverse)
library(stringi)

saver <- function(dataframe_output, stopTime, path) {
  
  stopTime_str <- str_replace_all(stopTime, ":", " ")
  write.csv2(dataframe_output, 
            file = paste0(path, "/", paste0("output_for_", 
                                       stopTime_str, ".csv")))  
}

path <- getwd() 
t1 <- paste0(path, "/", paste0("output_for", 
                               stopTime, ".csv"))

saver(dataf_test, stopTime, path)

