epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")
source("code/r/misc/misc_v1.R")
c95_cusum <- q95_cusum
library(reticulate)
# py_install("pandas")
pd <- import("pandas")

clf_ <- c("reg_logis", "rf", "fnn")
p_ <- c(10, 50, 200, 500, 1000)
n_ <- c(1000, 2000)
np <- expand.grid(p_, n_)
dgp <- c("standard_null", "banded_null", "exp_null")
size_all_dgp <- numeric(0)
size_all_cusum_dgp <- numeric(0)

for(dgp_ in dgp){
  dir_ <- paste("output", dgp_, sep = "/")
  size_all <- matrix(0, nrow(np), length(clf_))
  size_all_cusum <- size_all
  
  rownames_ <- character(nrow(np))
  for(i in 1:nrow(np)){
    print(np[i, ])
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
      max_cusums <- sapply(1:nrow(out$pred), function(r){
        cusum <- get_cusum_stat(out$pred[r, ], n = n_, auc_trim = eta)$cusum_stat
        max(cusum)
      })
      size_all_cusum[i, j] <- mean(max_cusums >= c95_cusum, na.rm = TRUE)
    }
  }
  rownames(size_all) <- rownames_
  rownames(size_all_cusum) <- rownames_
  size_all_dgp <- cbind(size_all_dgp, size_all)
  size_all_cusum_dgp <- cbind(size_all_cusum_dgp, size_all_cusum)
}

print(xtable::xtable(size_all_dgp, digits = 3))
print(xtable::xtable(size_all_cusum_dgp, digits = 3))
saveRDS(size_all_cusum_dgp, "output/size_all_cusum_dgp.RData")
saveRDS(size_all_dgp, "output/size_all_dgp.RData")

# size_all_dgp <- readRDS("output/size_all_dgp.RData")
# size_all_cusum_dgp <- readRDS("output/size_all_cusum_dgp.RData")

combined_table <- matrix(
  paste(formatC(100 * size_all_dgp, format = "f", digits = 1), 
        "% (", formatC(100 * size_all_cusum_dgp, format = "f", digits = 1), "%)", sep = ""),
  nrow = nrow(size_all_dgp), ncol = ncol(size_all_cusum_dgp)
)
rownames(combined_table) <- rownames(size_all_dgp)

xtable::xtable(combined_table)
