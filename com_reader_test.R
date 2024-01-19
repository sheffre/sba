library(serial)

port <- "COM2"

data_to_save <- data.frame()
output <- read.serialConnection(ser)

data_1 <- as.vector(strsplit(x = data, split = " ")[[1]])

# создание подключения и открытие
ser <- serialConnection(port = "COM3", mode = "19200,n,8,1", buffering = 'line')
t <- open(ser)

t1 <- as.vector(strsplit(x = foo, split = "\n")[[1]])

t2 <- as.vector(strsplit(x = foo, split = " ")[[1]])

data_test <- data.frame()

t3 <- lapply(t1, as.vector(strsplit(t1[], split = " ")[[1]]))

n = 5
t4 <- vector()
close(ser)

newText <- ""
stopTime <- Sys.time() + 15
foo <- ""
textSize <- 0
t <- open(ser)
while(Sys.time() < stopTime) {
  newText <- read.serialConnection(ser)
  if(0 < nchar(newText))
  {
    foo <- paste(foo, newText, sep = '\n')
  }
}


