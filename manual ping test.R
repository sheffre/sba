#manual ping test

ping <- function(ip, stderr = FALSE, stdout = FALSE) {
  pingvec <- system2("ping", ip, stdout = F, stderr = F)
  if (pingvec == 0) TRUE else FALSE
}

ping("81.31.246.77")
