library(RCurl)
library(data.table)
library(lubridate)
library(serial)

# Параметры подключения к анализатору
serial_port <- "COM3"  # Измените на соответствующий порт
baud_rate <- 9600  # Скорость обмена данными

# Открываем COM-порт (подключение может потребовать дополнительных библиотек)
ser <- serialConnection(name = "SBA", port = serial_port, 
                        mode = '9600,n,8,2', buffering = 'line',
                        buffersize = 32768)

close(ser)
open(ser)
# Открываем файл CSV для записи данных
csv_filename <- "data.csv"
csv_file <- file(csv_filename, "w")
writeLines("Timestamp,CO2", con = csv_file)

tryCatch({
    # Запрос данных с анализатора (здесь может потребоваться специфический протокол)
    write.serialConnection(ser, dat = "M")
    a <- read.serialConnection(ser)
    # Парсинг данных из ответа (здесь нужно адаптировать под формат ответа анализатора)
    
    
    # Запись данных в CSV
    # writeLines(paste(timestamp, co2_value, sep = ","), con = csv_file)
    # flush(csv_file)
    # 
    # # Пауза перед следующим сбором данных (например, каждые 15 минут)
    # Sys.sleep(900)
  
})


