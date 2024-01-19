library(serial)

# установка номера порта
port <- "COM1"

# создание подключения и открытие
ser <- serialConnection(port = port, mode = "19200,n,8,1", buffering = 'line')
t <- open(ser)

# основная петля
m <- 0
while (m<10) {
  # данные для отправки
  data <- "M 56725 53156 453 55.0 0.0 0.0 999 \n"
  
  # команда отправки
  write.serialConnection(con = ser, dat = data)
  
  # Задержка на 1 секунду
  Sys.sleep(1)
  
  output <- read.serialConnection(ser, n = 0)
  rbind(data_to_save, as.vector(strsplit(x = output, split = " ")[[1]]))
}

# закрытие порта
close(ser)
