library(gSeg)
library(ade4)
source("code/r/misc/misc_v1.R")

gseg_wrapper <- function(dat, method = "euclidean", p = 2, 
                              statistics = "all", pval_perm = TRUE){
  n <- nrow(dat)
  samp.dist <- dist(dat, method = method, p = p)
  samp.e1 <- ade4::mstree(samp.dist)
  st.time <- Sys.time()
  out <- gSeg::gseg1(n, samp.e1, statistics = statistics,
              pval.perm = pval_perm, pval.appr = FALSE, B = 199)
  en.time <- Sys.time() - st.time
  orig_ <- list()
  wei_ <- list()
  maxt_ <- list()
  gen_ <- list()
  
  if(statistics == "all" || statistics == "o"){
    orig_$cp <- out$scanZ$ori$tauhat
    orig_$maxZ <- out$scanZ$ori$Zmax
    orig_$pval <- out$pval.perm$ori$pval
    orig_$ari <- get_ari(n, floor(n/2), orig_$cp)
  }
  
  if(statistics == "all" || statistics == "w"){
    wei_$cp <- out$scanZ$weighted$tauhat
    wei_$maxZ <- out$scanZ$weighted$Zmax
    wei_$pval <- out$pval.perm$weighted$pval
    wei_$ari <- get_ari(n, floor(n/2), wei_$cp)
  }
  
  if(statistics == "all" || statistics == "m"){
    maxt_$cp <- out$scanZ$max.type$tauhat
    maxt_$maxZ <- out$scanZ$max.type$Zmax
    maxt_$pval <- out$pval.perm$max.type$pval
    maxt_$ari <- get_ari(n, floor(n/2), maxt_$cp)
  }
  
  if(statistics == "all" || statistics == "g"){
    gen_$cp <- out$scanZ$generalized$tauhat
    gen_$maxZ <- out$scanZ$generalized$Zmax
    gen_$pval <- out$pval.perm$generalized$pval
    gen_$ari <- get_ari(n, floor(n/2), gen_$cp)
  }
  
  list(orig = orig_, wei = wei_, maxt = maxt_, gen = gen_,
       runtime = en.time)
}
