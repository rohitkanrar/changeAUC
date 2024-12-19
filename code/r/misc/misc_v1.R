get_ari <- function(n, true_ch_pt, ch_pt){
  truth <- c(rep(0, true_ch_pt), rep(1, (n-true_ch_pt)))
  estimated <- c(rep(0, ch_pt), rep(1, (n-ch_pt)))
  ari <- pdfCluster::adj.rand.index(truth, estimated)
  return(ari)
}

get_sample_gr_max <- function(n = 100, T_ = 100000, epsilon = 0.15, 
                              eta = 0.05){
  seq_T <- seq(0, 1, length.out = T_)
  trim <- eta / (1 - 2 * epsilon)
  trim <- T_ * trim
  gr <- sapply(1:n, function(i){
    br <- cumsum(rnorm(T_)) / sqrt(T_)
    ( (br[T_] - br[2:T_]) / (1 - seq_T[2:T_]) - 
        br[2:T_] / seq_T[2:T_] ) / sqrt(12 * (1 - 2 * epsilon))
  })
  gr <- t(gr[trim:(T_-trim), ])
  apply(gr, 1, max)
}

get_sample_hr_max <- function(n = 100, T_ = 100000, epsilon = 0.15, 
                              eta = 0.05){
  seq_T <- seq(0, 1, length.out = T_)
  trim <- eta / (1 - 2 * epsilon)
  trim <- T_ * trim
  hr <- sapply(1:n, function(i){
    r <- 2:(T_-1)
    br <- cumsum(rnorm(T_)) / sqrt(T_)
    (br[r] - seq_T[r] * br[T_]) / sqrt(seq_T[r] * (1 - seq_T[r]))
  })
  hr <- t(hr[trim:(T_-trim), ])
  apply(hr, 1, max)
}

get_cusum_k <- function(pred, k, nte){
  cusum <- sum(pred[(k+1):(nte)])/(nte-k) - sum(pred[1:k])/k
  cusum <- cusum * sqrt(k * (nte-k) / (nte))
  
  cusum
}

get_cusum_var_k <- function(pred, k, nte){
  theta_bar_l <- mean(pred[(1:k)])
  theta_bar_r <- mean(pred[((k+1):nte)])
  cusum_var <- sum((pred[1:k] - theta_bar_l)^2) + 
    sum((pred[(k+1):nte] - theta_bar_r)^2)
  cusum_var <- cusum_var / nte
  return(cusum_var)
}

# get_cusum <- function(pred, n = 1000, auc_trim = 0.05){
#   # browser()
#   nte <- length(pred)
#   start_ <- floor(n * auc_trim)
#   end_ <- nte - floor(auc_trim * n)
#   cusums <- numeric(length(start_:end_))
#   i <- 1
#   for(k in start_:end_){
#     cusums[i] <- get_cusum_k(pred, k, nte)
#     i <- i + 1
#   }
#   
#   cusums
# }

get_cusum_stat <- function(pred, n = 1000, auc_trim = 0.05){
  nte <- length(pred)
  start_ <- floor(n * auc_trim)
  end_ <- nte - floor(auc_trim * n)
  cusums <- numeric(length(start_:end_))
  var_cusums <- numeric(length(start_:end_))
  i <- 1
  for(k in start_:end_){
    cusums[i] <- get_cusum_k(pred, k, nte)
    var_cusums[i] <- get_cusum_var_k(pred = pred, k = k, nte = nte)
    i <- i + 1
  }
  sig_hat_min <- sqrt(min(var_cusums))
  sig_hat <- sqrt(var_cusums)
  
  list(cusums = cusums, var_cusums = var_cusums, 
       cusum_stat = cusums / sig_hat_min,
       cusum_std = cusums / sig_hat)
}

# get_cusum_sim <- function(rep, N = 100000, epsilon = 0.15, eta = 0.05){
#   # browser()
#   samp <- sapply(1:rep, function(r){
#     epeta <- epsilon + eta
#     t <- seq(0, 1, length.out = (N+1))
#     t <- t[2:N]
#     ind <- which( (t <= epeta) | (t >= 1 - epeta) )
#     brdg <- sde::BBridge(N = N, T = 1, x = 0, y = 0)
#     brdg <- brdg[2:N]
#     pivot_proc <- abs(brdg) / sqrt(t * (1 - t))
#     return(max(pivot_proc[ind]))
#   })
#   samp
# }

# samp <- get_cusum_sim(rep = 10000)
# saveRDS(samp, "output/cifar/cusum_samp_default_trim.RData")



# source("code/r/misc/misc_v1.R")
# X <- matrix(runif(1000 * 1400), 1000, 1400)
# 
# tmp <- sapply(1:1000, function(i){
#   out <- get_cusum_stat(pred = X[i, ], n = 2000)
#   c(max(abs(out$cusum_std)), max(abs(out$cusum_stat)))
# })
