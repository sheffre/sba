# ... (все импорты остаются неизменными)

library(future)
plan(multisession)

# Определение асинхронных функций
async_reader <- function(ser, buffer) {
  newText <- read.serialConnection(ser)
  if (nchar(newText) > 0) {
    future::value(paste(newText, Sys.time()))
  } else {
    future::value(NULL)
  }
}

async_processor <- function(newText, buffer) {
  if (!is.null(newText) && !grepl("^Z", newText) && !grepl("^W", newText)) {
    vec <- c(vec, as.vector(strsplit(newText, split = " ")[[1]]))
    vecSplitted <- splitter(vec)[[1]]
    dataframed_output_temp <- t(data.frame(vecSplitted))
    colnames(dataframed_output_temp) <- colnames_default
    buffer <- rbind(buffer, dataframed_output_temp)
    colnames(buffer) <- colnames_default
    vec <- vector()
  }
  future::value(buffer)
}
# 
# async_saver <- function(buffer, stopTime, path) {
#   saver(buffer, stopTime, path)
#   future::value(NULL)
# }

async_pusher <- function(buffer, con_db) {
  pusher(buffer, con_db)
  future::value(NULL)
}

# saver <- function(dataframe_output, stopTime, path) {
#   tryCatch({
#     write.csv2(dataframe_output, 
#                file = paste0(path, paste0("output_for_",
#                                           str_replace_all(stopTime, ":", " "), 
#                                           ".csv")))
#   }, 
#   error = function(cond) {
#     print("Saving data in file at", 
#           Sys.time(), 
#           ": error. \n
#     Please check path.")
#   })
# }

pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2",
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
                  name = "co2", 
                  value = dataframe_output)
  }
  )
}

splitter <- function(x) {
  output <- strsplit(as.character(x), split = " ")
  return(output)
}

# combiner <- function(names, path) {
#   dataframe_output_daily <- data.frame()
#   
#   for (file_name in names) {
#     file_path <- file.path(path, file_name)
#     df <- read.csv2(file_path)
#     dataframe_output_daily <- rbind(dataframe_output_daily, df)
#   }
#   
#   output_folder <- paste0(path, "output_for_", str_replace_all(Sys.Date(), ":", " "))
#   dir.create(output_folder)
#   
#   saving_path <- paste0(output_folder, "\\combined_output.csv")
#   write.csv2(dataframe_output_daily, file = saving_path, row.names = FALSE)
# }

# ... (остальные функции остаются неизменными)

# Изменения в основной части кода
if (is_con_open == "DONE") {
  while (TRUE) {
    while (Sys.time() < stopTime) {
      if (Sys.time() < stopTime) {
        future_reader <- future({async_reader(ser, newText)})
        newText <- future::value(future_reader)
        if (!is.null(newText)) {
          future_processor <- future({async_processor(newText, vec)})
          vec <- future::value(future_processor)
        }
      }
      
      if (Sys.time() >= stopTime) {
        cat("Data for the last 5 minutes is now pushing to a DB and saving into a file...\n")
        future_saver <- future({async_saver(vec, stopTime, path)})
        future_pusher <- future({async_pusher(vec, con_db)})
        future::value(future_saver)
        future::value(future_pusher)
        cat("Data successfully saved!\n")
        vec <- vector()
        # counter <- counter + 1
        cat("Now the counter value is ", counter, ".\n")
        stopTime <- Sys.time() + stopTime_interval
        break
      }
      
      # if (counter >= 24) {
      #   cat("Data saving in progress!")
      #   files <- list.files(path = path, pattern = "*.csv")
      #   if (length(files) != 0) {
      #     combiner(files, path)
      #     stopTime <- Sys.time() + stopTime_interval
      #     cat(paste("Resaving data at", Sys.time(), "was successful!\n"))
      #     counter <- 0
      #     break
      #   } else if (length(files) == 0) {
      #     break
      #   }
      # }
    }
  }
} else cat("(Error code: 1)")

close(ser)
