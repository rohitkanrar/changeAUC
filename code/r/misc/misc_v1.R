get_ari <- function(n, true_ch_pt, ch_pt){
  truth <- c(rep(0, true_ch_pt), rep(1, (n-true_ch_pt)))
  estimated <- c(rep(0, ch_pt), rep(1, (n-ch_pt)))
  ari <- pdfCluster::adj.rand.index(truth, estimated)
  return(ari)
}

train_test_split <- function(n, ntr_0, ntr_1, nte_0, nte_1, time_){
  ind0 <- 1:(time_-1)
  ind1 <- time_:n
  indtr_0 <- sample(ind0, ntr_0, replace = F)
  indtr_1 <- sample(ind1, ntr_1, replace = F)
  indte_0 <- setdiff(ind0, indtr_0)
  indte_1 <- setdiff(ind1, indtr_1)
  return(list(indtr_0=indtr_0, indtr_1=indtr_1,
              indte_0=indte_0, indte_1=indte_1))
}

change_trim <- function(auc_mat, iter_t, n, trim = 0.1){
  bound <- c(floor(2*n*trim), 2*n - floor(2*n*trim))
  cond <- (iter_t >= bound[1]) & (iter_t <= bound[2])
  apply(auc_mat[, cond], 1, max)
}