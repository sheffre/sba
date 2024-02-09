#timestamp

ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"
buffer <- paste(ethalone, as.numeric(Sys.time()))
buffer <- splitter(buffer)[[1]]
df <- data.frame(t(buffer))
colnames(df) <- colnames_default

df$timestamp <- as.POSIXct(as.numeric(df$timestamp))




t <- as.numeric(Sys.time())
dput(t)
as.POSIXct(t)

pusher(df, con_loc)

colnames_default <- dbListFields(con_loc, "co2_atm_data")
dbAppendTable(con_loc, "co2_atm_data", df)
