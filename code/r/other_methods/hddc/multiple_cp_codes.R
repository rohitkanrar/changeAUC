
## Performs `Algorithm 2 WBS procedure for multiple change-point detection' as 
## in Chakraborty and Zhang (2021), using using permutation quantiles of the 
## test statistic M_n

library(parallel)

source("other_methods/hd_dc/Homogeneity_metric.R")


matbuild <- function(data_matrix,start,end,M, skip){    
  ## for m=1:M
  Mmat_0 <- matrix(0,4,M)
  
  for(m in 1:M){
    
    if(start==end-7){    
      Mmat_0[1,m] <- start
    }
    else{
      Mmat_0[1,m] <- sample(start:(end-7),1)
    }
    s_m <- Mmat_0[1,m]  ## 1st row of Mmat_0 contains s_m's
    
    if(s_m+7==end){     
      Mmat_0[2,m] <- s_m+7
    }
    else{
      Mmat_0[2,m] <- sample((s_m+7):end,1)
    }
    e_m <- Mmat_0[2,m]   ## 2nd row of Mmat_0 contains e_m's
    candidate_cp <- seq((s_m+3), (e_m-4), skip)
    val.list <- mclapply(candidate_cp, 
                         function(b) (e_m - b)*(b - s_m + 1)/((e_m - s_m + 1)^2) * Test_stat(data_matrix[s_m:b,],data_matrix[(b+1):e_m,],"K"))
    val <- unlist(val.list)
    b_0m <- s_m + 2 + which.max(val)  ## potential changepoint location; b_0m
    val.b_0m <- max(val) ## value of the test statistic at b_0m
    
    Mmat_0[3,m] <- b_0m ## 3rd row of Mmat_0 contains the values of b which maximises 
                        ## the test statistic within that particular (s_m, e_m)
    Mmat_0[4,m] <- val.b_0m ## 4th row of Mmat_0 contains the value of the maximized  
                            ## value of the test statistic within that (s_m, e_m)
  }
  return(Mmat_0)
}


wbs.testing <- function(data_matrix_wbs,start_wbs,end_wbs,M,B,alpha,skip){
  
  Mmat <- matbuild(data_matrix=data_matrix_wbs,start=start_wbs,end=end_wbs,M,skip=skip)
  
  m_0 <- which.max(Mmat[4,]) ## global maximizer m_0 among 1:M
  b_0 <- Mmat[3,m_0] ## global maximizer b_0
  val.b_0 <- Mmat[4,m_0] ## maximized value of the test statistic for m=m_0 and b=b_0
  
  ## now to conduct a permutation test to check if b_0 is a significant change point
  
  stat_vec <- numeric(0)
  
  for(perm in 1:B){
    u <- sample(start_wbs:end_wbs)
    data_matrix_1 <- data_matrix_wbs
    data_matrix_1[start_wbs:end_wbs,] <- data_matrix_1[u,] ## permuting the rows between start_wbs:end_wbs 
    Mmat_perm <- matbuild(data_matrix=data_matrix_1,start=start_wbs,end=end_wbs,M,skip=skip)
    m_0_perm <- which.max(Mmat_perm[4,]) 
    val.b_01_perm <- Mmat_perm[4,m_0_perm] 
    stat_vec[perm] <- val.b_01_perm
  }
  pval0 <- (1 + length(stat_vec[stat_vec > val.b_0])) / (1+B)
  
  if(pval0 < alpha){
    vec.ret <- c(1,b_0,pval0)
  }
  else{
    vec.ret <- c(0,b_0,pval0)
  }
  return(vec.ret)
}


wbs.location.tracker <- function(Xmat,s,e,M,B,alpha,skip){
  
  SegmentList<-c(s,e)
  FoundList<-NULL
  pvalues <- NULL
  ret.intermediate <-list()
  
  while(length(SegmentList)>0){              ## checking if there are any pair of end points left
    s1<-SegmentList[1]; e1<-SegmentList[2]
    Tlen<-e1-s1+1
    print(c(s1,e1))
    
    if(Tlen>=8){                             ## e-s >=7 or equivalently Tlen >= 8
      Cpvec<- wbs.testing(data_matrix_wbs=Xmat,start_wbs=s1,end_wbs=e1,M,B,alpha,skip=skip)  ## should return a vector, viz. c(b, pvalue)
      
      if(Cpvec[1]==1){                       ## i.e., if there exists a cp
        b<-Cpvec[2]
        SegmentList<-c(SegmentList,s1,b,(b+1),e1)
        print(SegmentList)
        FoundList<-c(FoundList,b)
        #print(FoundList)
        pvalues <- c(pvalues,Cpvec[3])
      }
    }
    SegmentList<-SegmentList[-c(1,2)]
    #print(SegmentList)
  }
  
  if(is.null(FoundList)){
    ret.intermediate$locations <- NULL
  }
  else{
    pvalues <- pvalues[order(FoundList)]
    FoundList <- sort(FoundList)
    ret.intermediate$locations <- FoundList
    ret.intermediate$pval <- pvalues
  }
  
  return(ret.intermediate)
}


wbs.main <- function(xmat,M,B,alpha){
  
  n0 <- nrow(xmat)
  ret.final <- list()
  res <- wbs.location.tracker(xmat,1,n0,M,B,alpha)
  cpts <- res$locations
  
  if(is.null(cpts)){
    ret.final$locations <- c(1,n0+1)
    ret.final$cluster <- rep(1,n0)
  }
  
  else{
    ret.final$locations <- cpts
    ret.final$pvalues <- res$pval
    clus0 <- c(1,cpts+1,n0+1)
    clus1 <- rep(1:length(diff(clus0)),diff(clus0))
    ret.final$cluster <- clus1
  }
  return(ret.final)
}








