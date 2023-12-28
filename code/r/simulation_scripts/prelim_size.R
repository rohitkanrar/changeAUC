epsilon_ <- c(0.1, 0.15)
eta_ <- c(0.02, 0.05)
p_ <- c(10, 100, 1000)
n_ <- c(1000, 2000, 4000)

tune <- expand.grid(epsilon_, eta_)
np <- expand.grid(n_, p_)

cric <- numeric(nrow(tune))
for(j in 1:nrow(tune)){
  epsilon <- tune[j, 1]
  eta <- tune[j, 2]
  source("code/r/get_null_quantiles/combine.R")
  cric[j] <- q95
}

dir_ <- "output/prelim_sim/dense_mean/rf/null/"
size_all <- matrix(0, nrow(np), nrow(tune))

rownames_ <- character(nrow(np))
for(i in 1:nrow(np)){
  rownames_[i] <- paste("(", np[i, 1], ",", np[i, 2], ")", sep = "")
  for(j in 1:nrow(tune)){
    file_ <- paste("p_", np[i, 2], "_n_", np[i, 1], "_ep_", tune[j, 1], 
                   "_et_", tune[j, 2], "_.RData", sep = "")
    tryCatch({
      out <- readRDS(paste(dir_, file_, sep = ""))
    }, warning = function(w){
      print(paste(file_, "not found in", dgp__))
    }, error = function(e) next)
    size_all[i, j] <- 
      mean((sqrt(np[i, 1]) * (out$max_aucs - 0.5) > cric[j]))
  }
}
rownames(size_all) <- rownames_
xtable::xtable(size_all)
