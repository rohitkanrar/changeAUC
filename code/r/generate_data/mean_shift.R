get_dense_shift_normal_mean <- function(delta, n, p, prop = 0.2, tau = 0.5){
  d <- floor(p * prop)
  shift <- delta / sqrt(d)
  t0 <- floor(n * tau)
  s1 <- matrix(0, t0, p)
  s2 <- matrix(0, (n - t0), p)
  for(j in 1:p)
    s1[, j] <- rnorm(t0)
  for(j in 1:p){
    if(j <= d)
      s2[, j] <- rnorm(n-t0, shift)
    else
      s2[, j] <- rnorm(n-t0)
  }
  rbind(s1, s2)
}

get_sparse_shift_normal_mean <- function(delta, n, p, prop = 0.01, 
                                        tau = 0.5){
  d <- floor(p * prop)
  shift <- delta / sqrt(d)
  t0 <- floor(n * tau)
  s1 <- matrix(0, t0, p)
  s2 <- matrix(0, (n - t0), p)
  for(j in 1:p)
    s1[, j] <- rnorm(t0)
  for(j in 1:p){
    if(j <= d)
      s2[, j] <- rnorm(n-t0, shift)
    else
      s2[, j] <- rnorm(n-t0)
  }
  rbind(s1, s2)
}