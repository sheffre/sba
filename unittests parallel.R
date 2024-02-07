library(testthat)

# Замените "path_to_your_code" на путь к вашему скрипту

test_data <- dataframed_output[c(1:10),]

# Тест для функции splitter
test_that("splitter correctly splits the string", {
  input_string <- c("M 56725 53156 453 55.0 0.0 0.0 999")
  output <- splitter(input_string)
  expect_equal(output, list(c("M", "56725", "53156", "453", "55.0", "0.0", "0.0", "999")))
})

# Тест для функции saver
test_that("saver correctly saves the dataframe to a file", {
  data <- data.frame(x = 1:5, y = c("a", "b", "c", "d", "e"))
  stopTime <- Sys.time()
  path <- getwd()
  saving_path <- paste0(path, "/test_saver_output.csv")
  saver(data, stopTime, path)
  expect_true(file.exists(saving_path))
  # Дополнительно можно проверить содержимое файла и сравнить с ожидаемым результатом
  # Для этого используйте соответствующие функции testthat, например, expect_equal.
})

# Тест для функции pusher
test_that("pusher correctly appends dataframe to the database", {
  data <- dataframed_output
  con_db <- dbConnect(drv = RPostgres::Postgres(), 
                                host     = 'localhost', 
                                user     = 'admin', 
                                password = '0i&=1UkV6KGTqJ', 
                                dbname   = "test")  # Фиктивное подключение для теста
  pusher(data, con_db)
  # Дополнительно можно проверить, что данные были действительно добавлены в базу данных
  # Используйте соответствующие функции testthat, например, expect_equal.
})

# Тест для функции combiner
# test_that("combiner correctly combines files into a single file", {
#   path <- "path_to_your_code"
#   files <- c("file1.csv", "file2.csv", "file3.csv")
#   combiner(files, path)
#   combined_path <- paste0(path, "/output_for_", str_replace_all(Sys.Date(), ":", " "), "/combined_output.csv")
#   expect_true(file.exists(combined_path))
#   # Дополнительно можно проверить содержимое объединенного файла и сравнить с ожидаемым результатом
#   # Используйте соответствующие функции testthat, например, expect_equal.
# })


con_db <- dbConnect(drv = RPostgres::Postgres(), 
                    host     = 'localhost', 
                    user     = 'admin', 
                    password = '0i&=1UkV6KGTqJ', 
                    dbname   = "postgres")
