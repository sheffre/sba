required_packages <- c("tidyverse", "serial", "stringi", "rlist", "DBI", "RPostgres", "future")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

lapply(required_packages, install_if_missing)

plan(multisession)

test_async_pusher <- function(buffer, con_db) {
  pusher(buffer, con_db)
  future::value(NULL)
}


pusher <- function(dataframe_output, con_db) {
  tryCatch({
    dbAppendTable(conn = con_db, 
                  name = "co2_atm_data",
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
                  name = "co2_atm_data", 
                  value = dataframe_output)
  }
  )
}
