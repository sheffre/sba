#timestamp

ethalone <- "M 56725 53156 453 55.0 0.0 0.0 999"
buffer <- paste(ethalone, as.numeric(Sys.time()))
buffer <- splitter(buffer)[[1]]
df <- data.frame(t(buffer))
colnames(df) <- colnames_default

t <- as.numeric(Sys.time())
dput(t)
as.POSIXct(t)
