get_dense_shift_normal_moment <- function(n, p, prop = 0.2, tau = 0.5){
  t0 <- floor(n*tau)
  d <- floor(p*prop)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), (n-t0), p)
  for(j in 1:d)
    s2[, j] <- rexp(n-t0) - 1
  rbind(s1, s2)
}

get_sparse_shift_normal_moment <- function(n, p, prop = 0.01, tau = 0.5){
  t0 <- floor(n*tau)
  d <- floor(p*prop)
  s1 <- matrix(rnorm(t0*p), t0, p)
  s2 <- matrix(rnorm((n-t0)*p), (n-t0), p)
  for(j in 1:d)
    s2[, j] <- rexp(n-t0) - 1
  rbind(s1, s2)
}

get_exponential <- function(n, p){
  s <- matrix(0, n, p)
  for(j in 1:p)
    s[, j] <- rexp(n)
  s
}