#regex parsing

parser <- function(x) {
  if (x != "") {
  z <- strsplit(x, split = " ")[[1]]
  if (z[1] == "W" | z[1] == "Z") {
    return(FALSE)
  } else  if (z[1] == "M") {
  for (number in c(1:length(z))) {
    if (str_detect(z[number], pattern = ".M") == TRUE) {
      output <- z[1:number]
      output[length(output)] <- str_sub(output[length(output)], end = -2)
      break
    }
  }
    rm(number, z, x)
  return(output)
  } else {
    x_retry <- read.serialConnection(con_serial)
    parser(x_retry)
  }
  }
}

t2 <- parser(foo[[1]])
t2[length(t2)] <- str_sub(t2[length(t2)], end = -2)

str_detect(splitter(foo[[1]])[[1]], pattern = ".M")
t <- splitter(foo[[1]])[[1]]
