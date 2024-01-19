#THIS CODE FRAGMENTS MUST BE USED WHEN sys.time() == stopTime!!
#THEN stopTime MUST BE INCREASED


#splitter function (split measurement to a numbers)

splitter <- function(x) {
  output <- strsplit(x, split = " ")
  return(output)
}
test <- lapply(t1, splitter)


#getting a list of splitted measurements
vec_test <- vector()
for (n in c(1:length(test))) {
  vec_test <- c(vec_test, as.vector(test[[n]]))
}

#dataframing the list => preparing to form a CSV file
dataf_test <- data.frame(t(sapply(vec_test, c)))           


