dir_ <- paste("output/null_quantiles/epsilon_", epsilon,
              "_eta_", eta, "/", sep = "")
samp_ <- numeric(0)
for(file_ in list.files(paste(dir_, sep = ""))){
  samp_ <- c(samp_, readRDS(paste(dir_, file_, sep = "")))
  if(length(samp_) == 100000)
    break
}

q95 <- quantile(samp_, 0.95)