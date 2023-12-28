get_dense_shift_normal_cov <- function(delta = 0.1, n, p, tau = 0.5){
  t0 <- floor(n * tau)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), n-t0, p)
  Sig <- matrix(delta, p, p)
  diag(Sig) <- rep(1, p)
  chol.sig <- chol(Sig)
  s2 <- s2 %*% chol.sig
  rbind(s1, s2)
}

get_sparse_shift_normal_cov <- function(delta = 0.8, n, p, tau = 0.5){
  t0 <- floor(n * tau)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), n-t0, p)
  Sig <- matrix(0, p, p)
  for(i in 1:p){
    for(j in 1:p){
      if(i == j){
        Sig[i, j] <- 1
      } else if(i < j){
        Sig[i, j] <- delta ^ abs(i-j)
      } else{
        Sig[i, j] <- Sig[j, i]
      }
    }
  }
  chol.sig <- chol(Sig)
  s2 <- s2 %*% chol.sig
  rbind(s1, s2)
}

get_dense_normal_cov <- function(n, p, rho = 0.1){
  s <- matrix(rnorm(n*p), n, p)
  Sig <- matrix(rho, p, p)
  diag(Sig) <- rep(1, p)
  chol.sig <- chol(Sig)
  s <- s %*% chol.sig
  s
}

get_sparse_normal_cov <- function(n, p, rho = 0.8){
  s <- matrix(rnorm(n*p), n, p)
  Sig <- matrix(0, p, p)
  for(i in 1:p){
    for(j in 1:p){
      if(i == j)
        Sig[i, j] <- 1
      else
        Sig[i, j] <- rho ^ abs(i-j)
    }
  }
  chol.sig <- chol(Sig)
  s <- s %*% chol.sig
  s
}

get_dense_diag_shift_normal_cov <- function(delta, n, p, prop = 0.2,
                                            tau = 0.5){
  t0 <- floor(n * tau)
  d <- floor(p * prop)
  shift <- 1 + delta / sqrt(d)
  signal_len <- floor(p*prop)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), n-t0, p)
  Sig <- matrix(0, p, p)
  diag(Sig) <- c(rep(shift, d), rep(1, (p - d)))
  chol.sig <- chol(Sig)
  s2 <- s2 %*% chol.sig
  rbind(s1, s2)
}

get_sparse_diag_shift_normal_cov <- function(delta, n, p, prop = 0.01,
                                            tau = 0.5){
  t0 <- floor(n * tau)
  d <- floor(p * prop)
  shift <- 1 + delta / sqrt(d)
  signal_len <- floor(p*prop)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), n-t0, p)
  Sig <- matrix(0, p, p)
  diag(Sig) <- c(rep(shift, d), rep(1, (p - d)))
  chol.sig <- chol(Sig)
  s2 <- s2 %*% chol.sig
  rbind(s1, s2)
}