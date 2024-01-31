
## Computes the two-sample statistic with unit group sizes
## (as in Chakraborty and Zhang(2021))


library(mvtnorm)
library(expm)


gam2 <- function(u){  ## input u is a N*p matrix ; output is the median distance (excluding zeroes) among rows
  D = as.matrix(dist(u,"euclidean")); D_vec = as.vector(D)
  val = median(D_vec[D_vec!=0])
  return(val)
}


gam_grp <- function(x,y){  # input : samples of X & Y, calculates the choice of the tuning parameter gamma 
  # groupwise according to the median heuristic
  comb=as.matrix(rbind(x,y))
  combt=t(comb)
  gnew = as.vector(apply(combt, 1, gam2))
  return(gnew)
}


XXdist <- function(x,z,type){   # input (x): n by p matrix; output: n by n distance matrix (between X & X)
  # z is the other sample matrix, required to compute the bandwidth parameter
  x1 = t(x)                    
  n = dim(x)[1]; p=dim(x)[2]
  d = matrix(NA, n, n)
  
  if(type == "E") { for(i in 1:n) d[i,] = sqrt( apply((x1 - x1[,i])^2, 2, sum) ) }  ## for usual Euclidean ED
  
  if(type == "K") { for(i in 1:n) d[i,] = sqrt( apply(abs(x1 - x1[,i]), 2, sum) ) }
  ## for \cal{E} with d_i=1 and \rho_i is the Euclidean distance
  g=gam2(rbind(x,z))
  
  if(type == "MMD-E")     ## for MMD with Laplace kernel
  { 
    for(i in 1:n) d[i,] = sqrt( apply((x1 - x1[,i])^2, 2, sum) ) 
    d = exp(-d/g) 
    diag(d) = 0
  }
  if(type == "MMD-G")     ## for MMD with Gaussian kernel
  { 
    for(i in 1:n) d[i,] = sqrt( apply((x1 - x1[,i])^2, 2, sum) ) 
    d = exp(-d^2/g^2/2)
    diag(d) = 0
  }
  
  gnew=gam_grp(x,z)
  
  if(type=="L-induced"){  ## for \cal{E} with d_i=1 and \rho_i is the distance induced by the Laplace kernel
    for(i in 1:n){
      #if(i%%2==0) print(i)
      d[i,i]=0
      if(i<n){
        for(l in (i+1):n){
          d[i,l]=sqrt( sum( 2-2*exp(-abs(x1[,i] - x1[,l])/gnew )))
          d[l,i]=d[i,l]
        }
      }
    }
  }
  
  if(type=="G-induced"){  ## for \cal{E} with d_i=1 and \rho_i is the distance induced by the Gaussian kernel
    for(i in 1:n){
      #if(i%%10==0) print(i)
      d[i,i]=0
      if(i<n){
        for(l in (i+1):n){
          d[i,l]=sqrt( sum( 2-2*exp(-(x1[,i] - x1[,l])^2 /2/(gnew)^2 )))
          d[l,i]=d[i,l]
        }
      }
    }
  }
  
  return(d)
}


XYdist <- function(x,y,type){    # input: n1*p & n2*p matrices; output: n1*n2 distance matrix (between X & Y)
  
  x1 <- t(x) ; y1 <- t(y)
  n1 <- dim(x)[1] ; n2 <- dim(y)[1]
  dxy <- matrix(NA, n1, n2); dxy1 <- matrix(NA, n1, n2)
  
  if(type == "E") { for(i in 1:n1) dxy[i,] = sqrt( apply((y1 - x1[,i])^2, 2, sum) ) }
  if(type == "K") { for(i in 1:n1) dxy[i,] = sqrt( apply(abs(y1 - x1[,i]), 2, sum) ) }
  
  g=gam2(rbind(x,y))
  
  if(type == "MMD-E")     ## for MMD with Laplace kernel
  { 
    for(i in 1:n1) dxy1[i,] = sqrt( apply((y1 - x1[,i])^2, 2, sum) ) 
    dxy = exp(-dxy1/g) 
  }
  if(type == "MMD-G")     ## for MMD with Gaussian kernel
  { 
    for(i in 1:n1) dxy1[i,] = sqrt( apply((y1 - x1[,i])^2, 2, sum) ) 
    dxy = exp(-dxy1^2/g^2/2)
  }
  
  gnew1=gam_grp(x,y)
  
  if(type=="L-induced"){ ## for \cal{E} with d_i=1 and \rho_i is the distance induced by the Laplace kernel
    for(i in 1:n1){
      for(l in 1:n2){
        dxy[i,l]=sqrt( sum( 2-2*exp(-abs(x1[,i] - y1[,l])/gnew1 )))
      }
    }
  }
  
  if(type=="G-induced"){ ## for \cal{E} with d_i=1 and \rho_i is the distance induced by the Gaussian kernel
    for(i in 1:n1){
      for(l in 1:n2){
        dxy[i,l]=sqrt( sum( 2-2*exp(-(x1[,i] - y1[,l])^2 /2/(gnew1)^2 )))
      }
    }
  }
  
  return(dxy)
}

ED <- function(x,y,type){    # computes Energy Distance between X & Y
  n1 <- dim(x)[1] ; n2 <- dim(y)[1]
  
  Axx=XXdist(x,y,type)
  Ayy=XXdist(y,x,type)
  Axy=XYdist(x,y,type)
  
  if(type=="K" || type=="E" || type=="L-induced" || type=="G-induced"){
    ed <- sum(Axy) * (2/(n1*n2)) - sum(Axx) *(1/(n1*(n1-1))) - sum(Ayy) *(1/(n2*(n2-1)))
  }
  else{
    ed <- sum(Axx) *(1/(n1*(n1-1))) + sum(Ayy) *(1/(n2*(n2-1))) - sum(Axy) * (2/(n1*n2)) 
  }
  l=list(ed,Axx,Ayy,Axy)
  return(l)
}


cdCov <- function(D){  # computes cdCov between x & y, input n1*n2 distance matrix between x & y
  n1=dim(D)[1]; n2=dim(D)[2]
  #D <- XYdist(x,y,type)
  R <- rowMeans(D) ; C <- colMeans(D) ; T <- mean(D)
  Rm <- matrix(rep(R,n2),n1,n2)
  Cm <- matrix(rep(C,n1),n1,n2, byrow=TRUE)
  Tm <- matrix(rep(T, n1*n2), n1, n2)
  Dhat <- D - Rm - Cm + Tm
  A <- sum(Dhat*Dhat)/((n1-1)*(n2-1))
  return(A)
}


u.center = function(A){    ## computes the U-centering of a distance matrix for samples of x,
  n = dim(A)[1]                 ## input n1*n1 distance matrix of x
  #A = XXdist(x,z,type)
  R = rowSums(A)
  C = colSums(A)
  T = sum(A)
  r = matrix(rep(R,n),n,n)/(n-2)
  c = t(matrix(rep(C,n),n,n))/(n-2)
  t = matrix(T/(n-1)/(n-2),n,n)
  UA = -(A-r-c+t)
  diag(UA)=0
  return(UA)
}

MdCov.U = function(B) {   # computes dCov between X & X, input n1*n1 distance matrix of x
  n = dim(B)[1] 
  A1 = u.center(B)
  return( sum(A1*A1)/n/(n-3) )
}


Test_stat <- function(x,y,type){   ## computes the two-sample test statistic, inputs sample matrices
  n1 <- dim(x)[1] ; n2 <- dim(y)[1]
  L=ED(x,y,type)
  Num <- L[[1]]
  AXX=L[[2]]; AYY=L[[3]]; AXY=L[[4]]
  scalar.den <- 1/(n1*n2) + 1/(2*n1*(n1-1)) + 1/(2*n2*(n2-1))
  
  numSnm <- 4*(n1-1)*(n2-1)*cdCov(AXY) + 4*n1*(n1-3)/2 * MdCov.U(AXX) + 4*n2*(n2-3)/2 * MdCov.U(AYY)
  denSnm <- (n1-1)*(n2-1) + n1*(n1-3)/2 + n2*(n2-3)/2
  Snm = numSnm/denSnm
  
  Den <- sqrt(scalar.den * Snm)
  return(Num/Den)
}
## Usage

# n1<-100; n2<-100; p<- 100
# x <- rmvnorm(n_1, mean=rep(0,p), sigma=diag(p))
# y <- rmvnorm(n_2, mean=(rep(0,p)), sigma=diag(p))
# Test_stat(x,y,"K")


## Performs `Algorithm 1 : Single change-point detection' as in Chakraborty 
## and Zhang (2021), using permutation quantiles of the test statistic M_n


library(parallel)

single.changepoint <- function(xmat, skip_t = 10,
                               return.acc.only = FALSE){
  n0 <- nrow(xmat) ##basically n
  print("Detection Started...") ## --MY MODIFICATION
  iter_ <- sort(c(seq(4, n0-4, skip_t), floor(n0*0.5))) ## --MY MODIFICATION
  
  val.list <- mclapply(iter_, function(ii){ ## --MY MODIFICATION
    tmp <- (n0-ii)*ii/(n0^2) * Test_stat(xmat[1:ii,],xmat[(ii+1):n0,],"K")
    tmp
  }, mc.cores = detectCores())
  b_0 <- iter_[which.max(unlist(val.list))]  ## potential changepoint location
  if(return.acc.only)
    return(list(iter_t = iter_, accur = unlist(val.list), cp = b_0))
  else{
    return(b_0) ## --MY MODIFICATION
  }
}

source("code/r/get_change_point/get_multiple_change_point_v1.R") # to import 'seeded_intervals' function

get.sbs.cp <- function(xmat, left, right, skip_t = 10, skim = 0.05,
                       decay = sqrt(2), n_min_sample = 300){
  n <- nrow(xmat)
  seeded_intv <- seeded_intervals(n, decay, T, n_min_sample)
  output <- vector(mode = "list", length = nrow(seeded_intv))
  seeded_tstat <- numeric(nrow(seeded_intv))
  seeded_cp <- numeric(nrow(seeded_intv))
  for(i in 1:nrow(seeded_intv)){
    intv <- seeded_intv[i, ]
    out_ <- single.changepoint(xmat = xmat[left:right, ], 
                                      skip_t = skip_t,
                               return.acc.only = TRUE)
    output[[i]] <- out_
    output[[i]]$interval <- intv
    seeded_tstat[i] <- max(out_$accur)
    seeded_cp[i] <- out_$cp
  }
  return(list(output = output, max_seeded_tstat = max(seeded_tstat),
              seeded_cp = seeded_cp[which.max(seeded_tstat)]))
}

multiple.cp <- function(xmat, left, right,
                        skip_t = 10, skim = 0.05,
                        n_min_sample = 300){
  # browser()
  print(paste("----- Detecting cp between", left, right, sep = " "))
  if((right - left) >= n_min_sample){
    out_ <- get.sbs.cp(xmat = xmat, left = left, right = right, 
                       skip_t = skip_t, skim = skim,
                       n_min_sample = n_min_sample)
    max_seeded_tstat <- out_$max_seeded_tstat
    seeded_cp <- out_$seeded_cp
    out_ <- out_$output
    if(left == 1){
      cp_ <- seeded_cp
    }
    else{
      cp_ <- left + seeded_cp
    }
    output_counter <<- output_counter + 1
    multiple_cp_output[[output_counter]] <<- list(interval = c(left, right),
                                                  cp = cp_,
                                                  max_stat = max_seeded_tstat,
                                                  output = out_)
    if(max_seeded_tstat >= 0.642){ # cutoff taken from the 2021 arXiv version
      if((cp_ - left) >= n_min_sample){
        multiple_cp <<- rbind(multiple_cp, 
                              multiple.cp(xmat, left = left, right = cp_,
                                          skip_t = skip_t, skim = skim,
                                          n_min_sample = n_min_sample))
      }
      if((right - cp_) >= n_min_sample){
        multiple_cp <<- rbind(multiple_cp, 
                              multiple.cp(xmat, left = (cp_+1), 
                                          right = right,
                                          skip_t = skip_t, skim = skim,
                                          n_min_sample = n_min_sample))
      }
      return(multiple_cp)
    } else{
      return(c(left, right))
    }
  } else{
    return(c(left, right))
  }
}


multiple.changepoint <- function(xmat, left, right,
                                 skip_t = 10, skim = 0.05,
                                 n_min_sample = 300){
  assign("multiple_cp", numeric(0), .GlobalEnv)
  assign("output_counter", 0, .GlobalEnv)
  assign("multiple_cp_output", list(), .GlobalEnv)
  
  out_ <- multiple.cp(xmat = xmat, left = left, right = right,
                      skip_t = skip_t, skim = skim,
                      n_min_sample = n_min_sample)
  
  return(list(intervals = unique(out_), output = multiple_cp_output))
}
