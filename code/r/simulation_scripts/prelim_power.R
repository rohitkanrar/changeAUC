epsilon_ <- c(0.1, 0.15)
eta_ <- c(0.02, 0.05)
p_ <- c(10, 100, 1000)
n_ <- c(1000, 2000, 4000)
dgp_ <- c("dense_mean", "sparse_mean",
          "dense_cov", "sparse_cov",
          "dense_diag_cov", "sparse_diag_cov",
          "dense_moment", "sparse_moment")

tune <- expand.grid(epsilon_, eta_)
np <- expand.grid(p_, n_)
ari_sig_all <- vector(mode = "list", length = 8)

cric <- numeric(nrow(tune))
for(j in 1:nrow(tune)){
  epsilon <- tune[j, 1]
  eta <- tune[j, 2]
  source("code/r/get_null_quantiles/combine.R")
  cric[j] <- q95
}

d <- 1
for(dgp__ in dgp_){
  dir_ <- paste("output", dgp__, "rf/", sep = "/")
  ari_sig <- matrix(0, nrow(np), nrow(tune))
  rownames_ <- character(nrow(np))
  for(i in 1:nrow(np)){
    rownames_[i] <- paste("(", np[i, 1], ",", np[i, 2], ")", sep = "")
    for(j in 1:nrow(tune)){
      file_ <- paste("p_", np[i, 1], "_n_", np[i, 2], "_ep_", tune[j, 1], 
                     "_et_", tune[j, 2], "_.RData", sep = "")
      tryCatch({
        out <- readRDS(paste(dir_, file_, sep = ""))
      }, warning = function(w){
        print(paste(file_, "not found in", dgp__))
      }, error = function(e) next)
      ari_sig[i, j] <- mean(
        out$ari * (sqrt(np[i, 2]) * (out$max_aucs - 0.5) > cric[j])
          )
    }
  }
  rownames(ari_sig) <- rownames_
  ari_sig_all[[d]] <- ari_sig
  d <- d + 1
}

xtable::xtable(cbind(ari_sig_all[[1]], ari_sig_all[[2]]))
xtable::xtable(cbind(ari_sig_all[[3]], ari_sig_all[[4]]))
xtable::xtable(cbind(ari_sig_all[[5]], ari_sig_all[[6]]))
xtable::xtable(cbind(ari_sig_all[[7]], ari_sig_all[[8]]))
