#cloner manual test

test_asyncCloner <- function() {
  con_loc <- dbConnect(drv = RPostgres::Postgres(),
                       host     = 'localhost',
                       user     = 'cloner',
                       password = 'cloner',
                       dbname   = "postgres")
  
  sql_query <- paste0("SELECT * FROM co2_atm_data WHERE timestamp > ", "to_timestamp('",
                      stopTime, "',  'dd-mm-yyyy hh24:mm:ss')")
  result <- dbGetQuery(con_loc, sql_query)
  dbDisconnect(con_loc)
  
  con_serv <- dbConnect(drv = RPostgres::Postgres(),
                        host     = '81.31.246.77',
                        password = 'x*5?kxaM>MgD,v',
                        dbname   = "default_db")
  dbAppendTable(con_serv, "co2_atm_data", result)
  rm(result)
}

con_loc <- dbConnect(drv = RPostgres::Postgres(),
                     host     = 'localhost',
                     user     = 'cloner',
                     password = 'cloner',
                     dbname   = "postgres")



con_serv <- dbConnect(drv = RPostgres::Postgres(),
                      host     = '81.31.246.77',
                      user     = 'testuser',
                      password = 'x*5?kxaM>MgD,v',
                      dbname   = "default_db")

sql_query_time <- "SELECT * FROM co2_atm_data ORDER BY timestamp DESC LIMIT 1"

last <- dbGetQuery(con_serv, sql_query_time)
last$timestamp <- as.POSIXct(as.numeric(last$timestamp))
