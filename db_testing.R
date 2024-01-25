library(DBI)
library(RPostgres)

con_db <- dbConnect(drv = RPostgres::Postgres(), 
                 host     = '81.31.246.77', 
                 user     = 'gen_user', 
                 password = '0,%Bhaq!TLz=Aa', 
                 dbname   = "default_db")

dbDisconnect(con_db)

dbWriteTable(con_db, "mtcars", mtcars)

dbAppendTable(conn = con_db, name = "mtcars", value = mtcars)

dbListFields(con_db, "main_table")


tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to Database…")
  connec <- dbConnect(drv, 
                      dbname = "81.31.246.77",
                      host = "localhost", 
                      port = "5432",
                      user = "gen_user", 
                      password = "%3FM%5Ci%5E7VyG%5C!%25%7Bf")
  print("Database Connected!")
},
error=function(cond) {
  print("Unable to connect to Database.")
})


connec <- dbConnect(drv, 
                    dbname = "tester",
                    host = "185.41.163.219", 
                    port = "5432",
                    user = "tester", 
                    password = "tester")
