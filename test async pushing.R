#test async pushing

pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data",
                  value = dataframe_output)
  }, 
  error = function(cond) {
    print("Connecting to a database...\n")
    tryCatch(
      {open(con_db)
      }, 
      error = function(cond) {
        print("Error connecting database! Please check 
              your verification data!\n")
      })
  }
  )
}

async_pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data", 
                  value = dataframe_output)
    # Возвращаем что-то, чтобы future::value не был NULL
    return(invisible())
  }, 
  error = function(cond) {
    cat("Error pushing data to the database: ", conditionMessage(cond), "\n")
    
    # Перед повторным использованием соединения, убедимся, что оно отключено
    if (dbIsValid(con_db)) {
      dbDisconnect(con_db)
    }
    
    # Создаем новое соединение для повторной попытки
    con_db_retry <- dbConnect(drv = RPostgres::Postgres(), 
                              host     = 'localhost', 
                              user     = 'admin', 
                              password = '0i&=1UkV6KGTqJ', 
                              dbname   = "postgres")
    
    # Повторно вызываем dbAppendTable
    tryCatch({
      dbAppendTable(conn = con_db_retry, 
                    name = "co2_atm_data", 
                    value = dataframe_output)
    }, 
    error = function(cond_retry) {
      cat("Error pushing data to the database on retry: ", conditionMessage(cond_retry), "\n")
    }) 
    
    # Всегда закрываем новое соединение, даже если была ошибка в retry
    dbDisconnect(con_db_retry)
    
    return(invisible())
  })
}





# con_loc <- dbConnect(drv = RPostgres::Postgres(), 
#                      host     = 'localhost', 
#                      user     = 'admin', 
#                      password = '0i&=1UkV6KGTqJ', 
#                      dbname   = "postgres")

future_pusher_loc <- future({
  con_loc <- dbConnect(drv = RPostgres::Postgres(), 
                       host     = 'localhost', 
                       user     = 'admin', 
                       password = '0i&=1UkV6KGTqJ', 
                       dbname   = "postgres")
  
  on.exit(dbDisconnect(con_loc), add = TRUE)
  
  async_pusher(df, con_loc)
})


future::value(future_pusher_loc)
