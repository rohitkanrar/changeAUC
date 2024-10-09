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

get_cusum_k <- function(pred, k, nte){
  cusum <- sum(pred[(k+1):(nte)])/(nte-k) - sum(pred[1:k])/k
  cusum <- cusum * sqrt(k * (nte-k) / (nte))
  
  cusum
}

get_cusum <- function(pred, n = 1000, auc_trim = 0.05){
  # browser()
  nte <- length(pred)
  start_ <- floor(n * auc_trim)
  end_ <- nte - floor(auc_trim * n)
  cusums <- numeric(length(start_:end_))
  i <- 1
  for(k in start_:end_){
    cusums[i] <- get_cusum_k(pred, k, nte)
    i <- i + 1
  }
  
  cusums
}