source("code/r/misc/misc_v1.R")
epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")
c95 <- q95/sqrt(1000) + 0.5
c95_cusum <- q95_cusum
dgp <- c("3-5", "4-5", "4-7", "4-4", "5-5")
method_ <- c("gseg", "changeforest", "vgg16", "vgg19")
final_cifar_table <- matrix(0, length(dgp), 4+1+2+2)
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
    } else if(m == "changeforest"){
      if(i <= 3){
        file_ <- paste(file_dir, "cifar_", dgp_, "_n_1000_rep_500.pkl", sep = "")
        out <- pd$read_pickle(file_)
        ari <- out$ari
        ari <- ari * ifelse(out$pval < 0.05, 1, 0)
        final_cifar_table[i, 5] <- mean(ari)
      } else{
        file_ <- paste(file_dir, "cifar_", dgp_, "_n_1000_rep_500.pkl", sep = "")
        out <- pd$read_pickle(file_)
        final_cifar_table[i, 5] <- mean(out$pval < 0.05)
      }
      j <- 5
    } else{
      if(i <= 3){
        # browser()
        file_ <- paste(file_dir, "cifar_", dgp_, "_n_1000_rep_500.pkl", sep = "")
        out <- pd$read_pickle(file_)
        ari <- out$ari
        ari <- ari * ifelse(out$max_auc >= c95, 1, 0)
        ch_pt_cusum <- apply(out$cusums, 1, which.max) + 
          out$n * (out$split_trim + out$auc_trim)
        ari_cusum <- sapply(1:length(ch_pt_cusum), function(i){
          cp <- ch_pt_cusum[i]
          get_ari(n = out$n, true_ch_pt = floor(out$n / 2), ch_pt = cp)
        })
        ari_cusum <- ari_cusum * ifelse(out$max_cusums >= c95_cusum, 1, 0)
        
        final_cifar_table[i, j] <- mean(ari)
        final_cifar_table[i, j+2] <- mean(ari_cusum)
      } else{
        file_ <- paste(file_dir, "cifar_", dgp_, "_n_1000_rep_500.pkl", sep = "")
        out <- pd$read_pickle(file_)
        max_auc <- out$max_aucs
        max_cusum <- out$max_cusums
        final_cifar_table[i, j] <- mean(max_auc >= c95)
        final_cifar_table[i, j+2] <- mean(max_cusum >= c95_cusum)
      }
    }
  }
}
# saveRDS(final_cifar_table, "output/cifar/final_cifar_table.RData")
xtable::xtable(final_cifar_table, digits = 4)

# if(FALSE){
#   cifar_cusum_size <- matrix(0, 2, 4)
#   
#   out <- pd$read_pickle("output/cifar/4-4/vgg16/cifar_4-4_n_2000_rep_500.pkl")
#   max_cusums <- sapply(1:500, function(i){
#     cusum <- get_cusum_stat(out$pred[i, ], n = 2000)$cusum_stat
#     max(cusum)
#   })
#   cifar_cusum_size[1, 3] <- mean(max_cusums > c95_cusum)
#   
#   out <- pd$read_pickle("output/cifar/5-5/vgg16/cifar_5-5_n_2000_rep_500.pkl")
#   max_cusums <- sapply(1:500, function(i){
#     cusum <- get_cusum_stat(out$pred[i, ], n = 2000)$cusum_stat
#     max(cusum)
#   })
#   cifar_cusum_size[2, 3] <- mean(max_cusums > c95_cusum)
#   
#   out <- pd$read_pickle("output/cifar/4-4/vgg19/cifar_4-4_n_2000_rep_500.pkl")
#   max_cusums <- sapply(1:500, function(i){
#     cusum <- get_cusum_stat(out$pred[i, ], n = 2000)$cusum_stat
#     max(cusum)
#   })
#   cifar_cusum_size[1, 4] <- mean(max_cusums > c95_cusum)
#   
#   out <- pd$read_pickle("output/cifar/5-5/vgg19/cifar_5-5_n_2000_rep_500.pkl")
#   max_cusums <- sapply(1:500, function(i){
#     cusum <- get_cusum_stat(out$pred[i, ], n = 2000)$cusum_stat
#     max(cusum)
#   })
#   cifar_cusum_size[2, 4] <- mean(max_cusums > c95_cusum)
#   
#   cifar_cusum_size[1, 1] <- final_cifar_table[4, 7]
#   cifar_cusum_size[1, 2] <- final_cifar_table[4, 8]
#   cifar_cusum_size[2, 1] <- final_cifar_table[5, 7]
#   cifar_cusum_size[2, 2] <- final_cifar_table[5, 8]
#   saveRDS(cifar_cusum_size, "output/cifar/cifar_cusum_size.RData")
# }
