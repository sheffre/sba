newText <- "M 56725 53156 453 55.0 0.0 0.0 999"
foo <- list()
i <- 1
while (i < 100) {
  foo <- c(foo, paste(newText,Sys.time()))
  i <- i + 1
}

vec <- vector()
mat <- matrix(nrow = 1, ncol = 10)
for (i in c(1:length(foo))) {
  vec <- c(vec, as.vector(foo[[i]]))
  vecSplitted <- splitter(vec)[[1]]
  mat <- rbind(mat, vecSplitted)
}
dataframed_output <- data.frame(mat)

dataframed_output <- data.frame()
colnames(dataframed_output) <- c("M", "X2", "X3", "CO2", "T", "X6", "X7", "P_atm")

for (i in c(1:length(vec))) {
  meas <- vec[i]
  meas_splitted <- splitter(meas)[[1]]
  dataframed_output <- rbind(dataframed_output, meas_splitted)
}
meas <- vec[1]
meas_splitted <- splitter(meas)[[1]]


t2 <- read.csv2("C:\\sba\\data_exchange_new\\output_for_2023-09-28 15 28 48.csv")
