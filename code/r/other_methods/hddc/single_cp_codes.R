
## Performs `Algorithm 1 : Single change-point detection' as in Chakraborty 
## and Zhang (2021), using permutation quantiles of the test statistic M_n


library(parallel)

source("Homogeneity_metric.R")

single.changepoint <- function(xmat,B=199,alpha=0.05){
  
  locations <-NULL; ## would return change point locations
  p_val <- NULL; ## would return pvalues corresponding to the change point locations
  
  ret <- list()
  
  n0 <- nrow(xmat) ##basically n
  
  iter_ <- seq(20, (n0-20), 10) ## --MY MODIFICATION
  
  val.list <- mclapply(iter_, function(ii){ ## --MY MODIFICATION
    tmp <- (n0-ii)*ii/(n0^2) * Test_stat(xmat[1:ii,],xmat[(ii+1):n0,],"K")
    tmp
  })
  print(unlist(val.list))
  b_0 <- iter_[which.max(unlist(val.list))]  ## potential changepoint location
  val_Test_stat <- max(unlist(val.list))   ## value of the test statistic at b_0
  
  print(b_0) ## --MY MODIFICATION
  print(val_Test_stat) ## --MY MODIFICATION
  return(b_0) ## --MY MODIFICATION
  
  stat_vec <- numeric(0)
  
  for(perm in 1:B){ ## performing a permutation test
    set.seed(perm)
    print(perm) ## --MY MODIFICATION
    u <- sample(1:n0)
    xmat_1 <- xmat[u,]
    val.list1 <- mclapply(4:(n0-4), function(ii) (n0-ii)*ii/(n0^2) * Test_stat(xmat_1[1:ii,],xmat_1[(ii+1):n0,],"K"))
    stat_vec[perm] <- max(unlist(val.list1))  
  }
  pval <- (1+length(stat_vec[stat_vec > val_Test_stat]))/(1+B)  ## permutation pvalue
  p_val <- c(p_val,pval)
  locations <- c(locations,b_0)
  
  if(p_val < alpha){
    ret$locations <- locations
    ret$pvalue <- p_val
    ret$cluster <- c(rep(1,b_0),rep(2,(n0-b_0))) #returns the clustering orientation of the data
    return(ret)
  }
  if(p_val >= alpha){
    ret$locations <- locations
    ret$pvalue <- p_val
    ret$cluster <- rep(1,n0) #returns the clustering orientation of the data
    return(ret) 
  }
  
}


