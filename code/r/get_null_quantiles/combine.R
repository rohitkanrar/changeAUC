dir_ <- paste("output/prelim_sim/null_quantiles/epsilon_", epsilon,
              "_eta_", eta, "/", sep = "")
samp_ <- numeric(0)
for(file_ in list.files(paste(dir_, sep = ""))){
  samp_ <- c(samp_, readRDS(paste(dir_, file_, sep = "")))
  if(length(samp_) == 100000)
    break
}

q95 <- quantile(samp_, 0.95)

qs <- quantile(samp_, c(0.8, 0.9, 0.95, 0.99, 0.995))
xtable::xtable(matrix(qs, nrow = 1), digits = 3)

xtable::xtable(matrix(q95/sqrt(c(500, 1000, 2000, 5000)) + 0.5, nrow = 1),
               digits = 3)


# CUSUM

dir_ <- paste("output/null_quantiles_cusum/epsilon_", epsilon,
              "_eta_", eta, "/", sep = "")
samp_ <- numeric(0)
for(file_ in list.files(paste(dir_, sep = ""))){
  samp_ <- c(samp_, readRDS(paste(dir_, file_, sep = "")))
  if(length(samp_) == 100000)
    break
}

q95_cusum <- quantile(samp_, 0.95)

qs_cusum <- quantile(samp_, c(0.8, 0.9, 0.95, 0.99, 0.995))
xtable::xtable(matrix(qs_cusum, nrow = 1), digits = 3)
