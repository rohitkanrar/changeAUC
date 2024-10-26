tau1 <- 1/3; tau2 <- 2/3
eps <- 0.15

c01 <- seq(0.01, 0.5, length.out = 100)
c02 <- c01; c12 <- c01

find_ab <- function(tau1, tau2, eps, c01, c02, c12){
  a <- c01 * (tau1 - eps) * tau2 + (tau1 - eps) * (1 - eps - tau2) * c02 -
    tau1 * (1 - eps - tau2) * c12
  b <- c12 * (1 - eps - tau2) - c01 * (tau1 - eps)
  c(a, b)
}

find_r <- function(a, b, eps){
  # browser()
  tmp <- a^2 + a * b + b^2 * eps * (1 - eps)
  if(tmp < 0 || b == 0){
    return(NULL)
  } else{
    tmp <- sqrt(tmp)
    roots <- c((- a + tmp) / b, (- a - tmp) / b)
    return(roots)
  }
}

find_dd <- function(r, a, b, eps){
  num <- b * r^3 + 3 * a * r^2 - 3 * r * (b * eps * (1 - eps) + a) +
    (b * eps + a * (1 - eps))
  deno <- (r - eps)^3 * (1 - eps - r)^3
  num / deno
}

find_s <- function(r, tau1, tau2, eps, c01, c02, c12){
  if(eps < r && r <= tau1){
    num <- (tau2 - tau1) * c01 + (1 - eps - tau2) * c02
    s <- num / (1 - eps - r)
  } else if(tau1 < r && r <= tau2){
    num <- (tau1 - eps) * (tau2 - r) * c01 + 
      (tau1 - eps) * (1 - eps - tau2) * c02 + 
      (r - tau1) * (1 - eps - tau2) * c12
    s <- num / ((1 - eps - r) * (r - eps))
  } else if(tau2 < r && r <= (1 - eps)){
    num <- (tau1 - eps) * c02 + (tau2 - tau1) * c12
    s <- num / (r - eps)
  }
  else{
    s <- 0
  }
  return(s)
}

get_sign_dd <- function(c01, c02, c12, tau1 = 1/3, tau2 = 2/3, eps = 0.15){
  # browser()
  tmp <- find_ab(tau1, tau2, eps, c01, c02, c12)
  a <- tmp[1]; b <- tmp[2]
  tmp <- find_r(a, b, eps)
  if(is.null(tmp)){
    return(c(c01, c02, c12, 0, 0))
  }
  r1 <- tmp[1]; r2 <- tmp[2]
  flag <- 0
  if(r1 >= eps && r1 <= (1-eps)){
    tmp <- find_dd(r1, a, b, eps)
    s_r <- find_s(r1, tau1, tau2, eps, c01, c02, c12)
    s_tau1 <- find_s(tau1, tau1, tau2, eps, c01, c02, c12)
    s_tau2 <- find_s(tau2, tau2, tau2, eps, c01, c02, c12)
    if(tmp < 0 && (s_r > s_tau1 && s_r > s_tau2))
      flag <- flag + 1
  }
  if(r2 >= eps && r2 <= (1-eps)){
    tmp <- find_dd(r2, a, b, eps)
    s_r <- find_s(r2, tau1, tau2, eps, c01, c02, c12)
    s_tau1 <- find_s(tau1, tau1, tau2, eps, c01, c02, c12)
    s_tau2 <- find_s(tau2, tau2, tau2, eps, c01, c02, c12)
    if(tmp < 0 && (s_r > s_tau1 && s_r > s_tau2))
      flag <- flag + 1
  }
  if(flag > 0){
    print(c(c01, c02, c12))
    print(c(r1, r2))
  }
  return(c(c01, c02, c12, ifelse(flag > 0, 1, 0), tmp))
}

param_grid <- expand.grid(c01 = c01, c02 = c02, c12 = c12)

results <- mapply(get_sign_dd, param_grid$c01, param_grid$c02, param_grid$c12,
                  MoreArgs = list(tau1 = 1/3, tau2 = 2/3, eps = 0.15),
                  SIMPLIFY = FALSE
                  )
results1 <- do.call(rbind, results)
results1 <- results1[, 1:5]
tmp <- results1[130331, ]
c01 <- tmp[1]; c02 <- tmp[2]; c12 <- tmp[3]
tmp1 <- find_ab(tau1, tau2, eps, c01, c02, c12)
a <- tmp1[1]; b <- tmp1[2]
tmp2 <- find_r(a, b, eps)
r <- tmp2[1]
# single derivative
b * r^2 + 2 * a * r - (a + b * eps * (1 - eps))
find_dd(r, a, b, eps)
s_r <- sapply(seq(0, 1, length.out = 1000), function(r){
  find_s(r, tau1, tau2, eps, c01, c02, c12)
})
plot(s_r, type = "l")
abline(v = tau1*1000); abline(v = tau2*1000)
find_s(r, tau1, tau2, eps, c01, c02, c12)
