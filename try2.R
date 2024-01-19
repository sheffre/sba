# Установите библиотеку "serial" и подключите ее
library(serial)
library(Rduino)

# Функция для чтения данных с анализатора
readFromAnalyzer <- function(port) {
  # Отправьте команду для запроса данных с анализатора
  cat("M", file = port)
  flush(port)
  
  # Считайте ответ от анализатора
  response <- readLines(port, n = 1)
  
  # Возвращаем считанные данные
  return(response)
}

# Укажите порт и другие настройки вашего COM порта
com_port <- "//./COM3"

# Установите соединение с COM портом
port <- serialConnection(port  = "COM3", mode = "19200,n,8,1")
с <- open(port)

if (is.null(port)) {
  cat("Не удалось открыть COM порт.\n")
} else {
  # Прочитайте данные с анализатора
  data <- readFromAnalyzer(port$port)
  
  # Выведите считанные данные
  cat("Данные с анализатора:", data, "\n")
  
  # Закройте COM порт после использования
  close(port)
}
open(port)
close(port)
tryCatch(
  
)
readLines(con = serialConnection(port = "COM3", mode = "115200,n,8,1"), n=1)
