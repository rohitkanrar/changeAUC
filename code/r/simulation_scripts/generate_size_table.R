epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")
library(reticulate)
# py_install("pandas")
pd <- import("pandas")

clf_ <- c("reg_logis", "rf", "fnn")
p_ <- c(10, 50, 200, 500, 1000)
n_ <- c(1000, 2000)
np <- expand.grid(p_, n_)
dgp <- c("standard_null", "banded_null", "exp_null")
size_all_dgp <- numeric(0)

for(dgp_ in dgp){
  dir_ <- paste("output", dgp_, sep = "/")
  size_all <- matrix(0, nrow(np), length(clf_))
  
  rownames_ <- character(nrow(np))
  for(i in 1:nrow(np)){
    rownames_[i] <- paste("(", np[i, 2], ",", np[i, 1], ")", sep = "")
    for(j in 1:length(clf_)){
      tryCatch({
        if(clf_[j] == "fnn"){
          file_ <- paste("delta_0_p_", np[i, 1], "_n_", np[i, 2], "_ep_", 
                         epsilon, "_et_", eta, "_seed_1_.pkl", sep = "")
          file_path <- paste(dir_, clf_[j], file_, sep = "/")
          out <- pd$read_pickle(file_path)
        } else{
          file_ <- paste("delta_0_p_", np[i, 1], "_n_", np[i, 2], "_ep_", 
                         epsilon, "_et_", eta, "_seed_1_.RData", sep = "")
          file_path <- paste(dir_, clf_[j], file_, sep = "/")
          out <- readRDS(file_path)
        }
      }, warning = function(w){
        print(paste(file_path, "not found in", dgp_))
      }, error = function(e) next)
      size_all[i, j] <- 
        mean((sqrt(np[i, 2]) * (out$max_aucs - 0.5) > q95))
    }
  }
  rownames(size_all) <- rownames_
  size_all_dgp <- cbind(size_all_dgp, size_all)
}

xtable::xtable(size_all_dgp, digits = 3)
