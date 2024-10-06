
#### Numerical results for Section 4.1 in Chakraborty and Zhang (2021)

library(mvtnorm)
library(ecp)
library(mclust)
library(gSeg)
library(ade4)
library(expm)
library(fGarch)


##-------------------- Single change-point detection -------------------##


#### For Ex 4.1, 4.2 and 4.3 :

source("Homogeneity_metric.R")
source("single_cp_codes.R")

Single.cp.sim <- function(n,p,reptim,nperm,alpha=0.05,data.type){
  
  result=matrix(0,reptim,4)
  colnames(result) <- c("Our", "MJ", "CC", "CZ")
  
  s=matrix(0,p,p)
  for(k in 1:p){
    for(l in 1:p){
      if(k==l) s1[k,l]=1
      if(abs(k-l)>=1 & abs(k-l)<=2) s1[k,l]=0.25
    }
  }
  
  for(i in 1:reptim){
    
    set.seed(i)
    
    # if(i%%10==0) print(i)
    
    ## No change-point example : Ex 4.1
    
    if(data.type==11){                                         
      x <- rmvnorm(n/2, mean=rep(0,p), sigma=diag(p))
      y <- rmvnorm(n/2, mean=(rep(0,p)), sigma=diag(p))
      xmat <- rbind(x,y)
      a <- rep(1,n)
    }
    if(data.type == 12){
      sigma = matrix(0,p,p)
      sigma = (0.7)^(abs(row(sigma)-col(sigma)))
      x = rmvnorm(n/2,rep(0,p),sigma,method="chol")
      y = rmvnorm(n/2,rep(0,p),sigma,method="chol")
      xmat <- rbind(x,y)
      a <- rep(1,n)
    }
    
    if(data.type==13){
      xmat=matrix(0,n,p)
      spec = garchSpec(model = list(alpha = 0.001, beta = 0.001))
      for(i in 1:p){
        xmat[,i]=as.vector(garchSim(spec, n=n+1000))[(1000+1):(1000+n)]
      }
      a <- rep(1,n)
    }
    
    ## Single change-point in mean : Ex 4.2
    
    if(data.type==21){                                    
      x <- rmvnorm(n/2, mean=rep(0,p), sigma=diag(p))     
      y <- rmvnorm(n/2, mean=(rep(0.6,p)), sigma=diag(p))
      xmat <- rbind(x,y)
      a <- c(rep(1,n/2),rep(2,n/2))
    }
    
    if(data.type == 22){
      sigma = matrix(0,p,p)
      sigma = (0.7)^(abs(row(sigma)-col(sigma)))
      x = rmvnorm(n/2,rep(0,p),sigma,method="chol")
      y = rmvnorm(n/2,rep(0.6,p),sigma,method="chol")
      xmat <- rbind(x,y)
      a <- c(rep(1,n/2),rep(2,n/2))
    }
    
    ## Single change in distribution : Ex 4.3
    
    if(data.type==41){                                 
      x <- rmvnorm(n/2, mean=rep(1,p), sigma=diag(p))
      y <- matrix(rexp((n/2)*p,1),n/2,p,byrow=T)
      xmat <- rbind(x,y)
      a <- c(rep(1,n/2),rep(2,n/2))
    }
    
    if(data.type==42){
      x <- matrix(rpois((n/2)*p,1),n/2,p,byrow=T) - matrix(rep(1,(n/2)*p),n/2,p)
      y1 <- matrix(rpois((n/2)*(p/2),1),n/2,p/2,byrow=T) - matrix(rep(1,(n/2)*(p/2)),n/2,p/2)
      avec <- rbinom((n/2)*p/2,1,1/2)
      avec[which(avec ==0)] = -1
      y2 <- matrix(avec, n/2, p/2, byrow=TRUE)
      y <- cbind(y2,y1)
      xmat <- rbind(x,y)
      a <- c(rep(1,n/2),rep(2,n/2))
    }
    
    if(data.type==45){
      z1 <- rmvnorm(n/2, mean=rep(0,p), sigma=diag(p))
      z2 <- matrix(rexp((n/2)*p,1),n/2,p,byrow=T) - matrix(rep(1,(n/2)*p),n/2,p)
      x1 <- sqrtm(s)%*%t(z1)
      y1 <- sqrtm(s)%*%t(z2)
      x <- t(x1) ; y <- t(y1)
      xmat <- rbind(x,y)
      a <- c(rep(1,n/2),rep(2,n/2))
    }
    
    our_clus <- single.changepoint(xmat,B=nperm,alpha=0.05)$cluster   ## Clustering for our test
    
    
    MJ <- e.divisive(xmat,sig.lvl=.05,R=nperm)$cluster   ## Cluster for Matteson & James (2014)
    
    
    E1 <- ade4::mstree(dist(xmat))         ## Cluster for Chu & Chen (2019) (max type scan statistic)
    CCobj <- gseg1(n,E1,"m",pval.appr=FALSE,pval.perm=TRUE,B=nperm)
    if(CCobj$pval.perm$max.type$pval < alpha){
      CCcp <- CCobj$scanZ$max.type$tauhat
      CCcp_new <- c(1,CCcp+1,n+1)
      CC <- rep(1:length(diff(CCcp_new)),diff(CCcp_new))
    }
    if(CCobj$pval.perm$max.type$pval >= alpha){
      CC <- rep(1,n)
    }
    
    
    CZobj <- gseg1(n,E1,"o",pval.appr=FALSE,pval.perm=TRUE,B=nperm) ## Cluster for Chen & Zhang (2015) (original scan statistic)
    if(CZobj$pval.perm$ori$pval < alpha){
      CZcp <- CZobj$scanZ$ori$tauhat 
      CZcp_new <- c(1,CZcp+1,n+1)
      CZ <- rep(1:length(diff(CZcp_new)),diff(CZcp_new))
    }
    if(CZobj$pval.perm$ori$pval >= alpha){
      CZ <- rep(1,n)
    }
    
    
    result[i,1] <- adjustedRandIndex(a,our_clus)
    result[i,2] <- adjustedRandIndex(a,MJ)
    result[i,3] <- adjustedRandIndex(a,CC)
    result[i,4] <- adjustedRandIndex(a,CZ)

  }
  
  return(result)
}

## Usage : Single.cp.sim(n=50,p=50,reptim=10,nperm=50,alpha=0.05,data.type=1)



##-------------------- Multiple change-point detection ----------------------##


#### For Ex 4.4 and 4.5 :

source("Homogeneity_metric.R")
source("single_cp_codes.R")
source("multiple_cp_codes.R")

Multiple.cp.sim <- function(n,p,M,reptim,nperm,alpha=0.05,data.type){
  
  result=matrix(0,reptim,5)
  colnames(result) <- c("Our", "MJ", "CC", "CZ", "WS")
  a <- c(rep(1,floor(n/3)),rep(2,floor(n/3)),rep(3,n-2*floor(n/3)))
  
  for(i in 1:reptim){
    
    #set.seed(10*i)
    
    ## Two changes in mean : Ex 4.3
    
    if(data.type==51){                                    
      x <- rmvnorm(floor(n/3), mean=rep(0,p), sigma=diag(p))     
      y <- rmvnorm(floor(n/3), mean=(rep(0.6,p)), sigma=diag(p))
      z <- rmvnorm(n-2*floor(n/3), mean=rep(0,p), sigma=diag(p)) 
      xmat <- rbind(x,y,z)
    }
    
    if(data.type == 52){
      sigma = matrix(0,p,p)
      sigma = (0.7)^(abs(row(sigma)-col(sigma)))
      x = rmvnorm(floor(n/3),rep(0,p),sigma,method="chol")
      y = rmvnorm(floor(n/3),rep(0.6,p),sigma,method="chol")
      z = rmvnorm(n-2*floor(n/3),rep(0,p),sigma,method="chol")
      xmat <- rbind(x,y,z)
    }
    
    
    ## Two changes in distribution : Ex 4.5
    
    if(data.type==61){                                 
      x <- rmvnorm(floor(n/3), mean=rep(1,p), sigma=diag(p))                   
      y <- matrix(rexp((floor(n/3))*p,1),floor(n/3),p,byrow=T)
      z <- rmvnorm(n-2*floor(n/3), mean=rep(1,p), sigma=diag(p))
      xmat <- rbind(x,y,z)
    }
    
    if(data.type==62){
      x <- matrix(rpois((floor(n/3))*p,1),floor(n/3),p,byrow=T) - matrix(rep(1,(floor(n/3))*p),floor(n/3),p)
      y1 <- matrix(rpois((floor(n/3))*(p/2),1),floor(n/3),p/2,byrow=T) - matrix(rep(1,(floor(n/3))*(p/2)),floor(n/3),p/2)
      avec <- rbinom((floor(n/3))*p/2,1,1/2)
      avec[which(avec ==0)] = -1
      y2 <- matrix(avec, floor(n/3), p/2, byrow=TRUE)
      y <- cbind(y2,y1)
      z <- matrix(rpois((n-2*floor(n/3))*p,1),n-2*floor(n/3),p,byrow=T) - matrix(rep(1,(n-2*floor(n/3))*p),n-2*floor(n/3),p)
      xmat <- rbind(x,y,z)
    }
    
    our_clus <- wbs.main(xmat,M,alpha=0.05)$cluster   ## Clustering for our test
    
    
    MJ <- e.divisive(xmat,sig.lvl=.05,R=nperm)$cluster   ## Cluster for Matteson & James (2014)
    
    
    E1 <- ade4::mstree(dist(xmat))         ## Cluster for Chu & Chen (2019) (max type scan statistic)
    CCobj <- gseg2(n,E1,"m",pval.appr=FALSE,pval.perm=TRUE,B=nperm)
    CCcp <- sort(CCobj$scanZ$max.type$tauhat)   
    CCcp_new <- c(1,CCcp+1,n+1)
    CC <- rep(1:length(diff(CCcp_new)),diff(CCcp_new))
    
    
    CZobj <- gseg2(n,E1,"o",pval.appr=FALSE,pval.perm=TRUE,B=nperm) ## Cluster for Chen & Zhang (2015) (original scan statistic)
    CZcp <- sort(CZobj$scanZ$ori$tauhat)
    CZcp_new <- c(1,CZcp+1,n+1)
    CZ <- rep(1:length(diff(CZcp_new)),diff(CZcp_new))
    
    
    result[i,1] <- adjustedRandIndex(a,our_clus)
    result[i,2] <- adjustedRandIndex(a,MJ)
    result[i,3] <- adjustedRandIndex(a,CC)
    result[i,4] <- adjustedRandIndex(a,CZ)
    
  }
  
  return(apply(result,2,mean))
}

## Usage : Multiple.cp.sim(n=50,p=50,M=50,reptim=10,nperm=50,alpha=0.05,data.type=51)





