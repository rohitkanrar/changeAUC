epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")
c95 <- q95/sqrt(1000) + 0.5
dgp <- c("3-5", "4-5", "4-7", "4-4", "5-5")
method_ <- c("gseg", "vgg16", "vgg19")
final_cifar_table <- matrix(0, length(dgp), length(method_)+3)
library(reticulate)
pd <- import("pandas")

i <- 0
j <- 0
# browser()
for(dgp_ in dgp){
  i <- i + 1
  for(m in method_){
    j <- j + 1
    file_dir <- paste("output/cifar/", dgp_, "/", m, "/", sep = "")
    if(m == "gseg"){
      out <- readRDS(paste(file_dir, 
                           "cifar_", dgp_, "_n_1000_seed_1.RData", sep = ""))
      
      ari_orig <- out$orig$ari
      pval_orig <- out$orig$pval
      ari_orig[pval_orig > 0.05] <- 0
      if(i <= 3){
        final_cifar_table[i, 1] <- mean(ari_orig)
      } else{
        final_cifar_table[i, 1] <- mean(pval_orig < 0.05)
      }
      
      ari_wei <- out$wei$ari
      pval_wei <- out$wei$pval
      ari_wei[pval_wei > 0.05] <- 0
      if(i <= 3){
        final_cifar_table[i, 2] <- mean(ari_wei)
      } else{
        final_cifar_table[i, 2] <- mean(pval_wei < 0.05)
      }
      
      ari_maxt <- out$maxt$ari
      pval_maxt <- out$maxt$pval
      ari_maxt[pval_maxt > 0.05] <- 0
      if(i <= 3){
        final_cifar_table[i, 3] <- mean(ari_maxt)
      } else{
        final_cifar_table[i, 3] <- mean(pval_maxt < 0.05)
      }
      
      ari_gen <- out$gen$ari
      pval_gen <- out$gen$pval
      ari_gen[pval_gen > 0.05] <- 0
      if(i <= 3){
        final_cifar_table[i, 4] <- mean(ari_gen)
      } else{
        final_cifar_table[i, 4] <- mean(pval_gen < 0.05)
      }
      j <- 4
    } else{
      ari <- numeric(0)
      size <- numeric(0)
      for(file_ in list.files(file_dir)){
        file__ <- paste(file_dir, file_, sep = "")
        out <- pd$read_pickle(file__)
        if(i <= 3){
          ari <- c(ari, ifelse(out$max_auc >= c95, out$ari, 0))
        } else{
          size <- c(size, ifelse(out$max_auc >= c95, 1, 0))
        }
      }
      if(i <= 3){
        final_cifar_table[i, j] <- mean(ari)
      } else{
        final_cifar_table[i, j] <- mean(size)
      }
    }
  }
}

xtable::xtable(final_cifar_table, digits = 3)
