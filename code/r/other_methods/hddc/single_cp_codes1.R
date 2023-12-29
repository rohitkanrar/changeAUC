
## Performs `Algorithm 1 : Single change-point detection' as in Chakraborty 
## and Zhang (2021), using simulated quantiles of the limiting distribution of M_n

library(parallel)

source("Homogeneity_metric.R")

single.changepoint <- function(xmat,alpha=0.05){
  
  locations <-NULL; ## would return change point locations
  p_val <- NULL; ## would return pvalues corresponding to the detected
                 ##change point locations
  
  ret <- list()
  
  n0 <- nrow(xmat) ##basically n

  val.list <- mclapply(4:(n0-4), function(ii) (n0-ii)*ii/(n0^2) * Test_stat(xmat[1:ii,],xmat[(ii+1):n0,],"K"))
  b_0 <- 3 + which.max(unlist(val.list))  ## potential changepoint location
  val_Test_stat <- max(unlist(val.list))   ## value of the test statistic at b_0
  
  
  ind=1*(val_Test_stat>0.642)
  locations <- c(locations,b_0)
  
  if(ind==1){
    ret$locations <- locations
    ret$cluster <- c(rep(1,b_0),rep(2,(n0-b_0))) #returns the clustering orientation of the data
    return(ret)
  }
  if(ind==0){
    ret$locations <- locations
    ret$cluster <- rep(1,n0) #returns the clustering orientation of the data
    return(ret) 
  }
  
}




