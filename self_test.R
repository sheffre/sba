# Установка библиотеки serial
library(serial)

txtPath <- tempfile(fileext = ".txt")

catch <- function(port) {
  write.serialConnection(con = port, dat = 'M\n')
  response <- read.serialConnection(con = port)
  return(response)
}

# Устанавливаем соединение с COM-портом
com_port <- serialConnection(port = "COM3", mode = "19200,n,8,1", 
                             buffering = 'line', buffersize =  )
o <- open(com_port)
c <- close(com_port)

w <- write.serialConnection(con = com_port, dat = 'M')
r1 <- read.serialConnection(con = com_port)

t <- catch(com_port)

typeof(r)

th <- c(r, r1)
