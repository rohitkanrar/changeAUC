# main power bwplots
source("code/r/misc/misc_v1.R")
library(tidyverse)
epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")

p <- c(30)
n <- c(300, 1000)
n_methods <- 7
reps_total <- 500
# dgp <- c("dense_mean", "sparse_mean", "dense_cov", "sparse_cov",
#          "dense_diag_cov", "sparse_diag_cov", "dense_moment", "sparse_moment")
# 
# DGP <- c("Dense Mean", "Sparse Mean", "Dense Cov", "Banded Cov",
#          "Dense Diag Cov", "Sparse Diag Cov", "Dense Distribution", 
#          "Sparse Distribution")
dgp <- c("dense_mean", "dense_cov", "sparse_cov", "dense_diag_cov", 
         "dense_moment")

DGP <- c("Dense Mean", "Dense Cov", "Banded Cov", "Dense Diag Cov", 
         "Dense Distribution")
delta <- c(2, 0.1, 0.8, 5, 1)
big_df <- data.frame()
k <- 0
for(regime in dgp){
  ari_bw <- vector(mode = "list", length = 2)
  ari_bw[[1]] <- matrix(0, reps_total, n_methods)
  ari_bw[[2]] <- ari_bw[[1]]
  k <- k + 1
  # RMNCP
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/rmncp/",
                       "delta_", delta[k], "_p_", p, "_n_", n_,
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    # print(paste(length(out$dval), regime, n_))
    if(length(out$dval) > 500){
      dval <- out$dval[c(1, 4:502)]
    } else{
      dval <- out$dval
    }
    
    ari_bw[[j]][, 1] <- out$ari * as.numeric(dval < 0.05)
    j <- j + 1
  }
  
  # hddc
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/hddc/",
                       "delta_", delta[k], "_p_", p, "_n_", n_, 
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_ <- out$ari
    ari_ <- ari_ * as.numeric(out$max_tstat > 0.642)
    ari_bw[[j]][, 2] <- ari_
    j <- j + 1
  }
  
  # gseg
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/gseg/",
                       "delta_", delta[k], "_p_", p, "_n_", n_, 
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    # ari_bw[[j]][, 3] <- out$orig$ari * as.numeric(out$orig$pval <= 0.05)
    ari_bw[[j]][, 3] <- out$wei$ari * as.numeric(out$wei$pval <= 0.05)
    ari_bw[[j]][, 4] <- out$maxt$ari * as.numeric(out$maxt$pval <= 0.05)
    # ari_bw[[j]][, 6] <- out$gen$ari * as.numeric(out$gen$pval <= 0.05)
    j <- j + 1
  }
  
  # changeforest
  library(reticulate)
  # py_install("pandas")
  pd <- import("pandas")
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/changeforest/",
                       "delta_", delta[k], "_p_", p, "_n_", n_, 
                       "_seed_1_.pkl", sep = "")
    out <- pd$read_pickle(file_path)
    ari_bw[[j]][, 5] <- out$ari
    j <- j + 1
  }
  
  # rf
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/rf/",
                       "delta_", delta[k], "_p_", p, "_n_", n_, 
                       "_ep_0.15_et_0.05_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_bw[[j]][, 6] <- out$ari * as.numeric(sqrt(n) * (out$max_aucs - 0.5) > q95)
    j <- j + 1
  }
  
  # NODE
  library(reticulate)
  # py_install("pandas")
  pd <- import("pandas")
  j <- 1
  for(n_ in n){
    file_path <- paste("output/", regime, "/node/",
                       "delta_", delta[k], "_p_", p, "_n_", n_, 
                       "_seed_1_.pkl", sep = "")
    out <- pd$read_pickle(file_path)
    ari_bw[[j]][, 7] <- out$ari
    j <- j + 1
  }
  
  test_df <- data.frame(ARI = as.vector(ari_bw[[1]]),
                        method = rep(c("RMNCP", "Hddc", "gseg_wei", "gseg_maxt",
                                       "changeforest", "Rf", "NODE"), 
                                     each = reps_total),
                        dgp = rep(paste(DGP[k], "(T = 300)"), 
                                  reps_total * n_methods))
  test_df <- rbind(test_df,
                   data.frame(ARI = as.vector(ari_bw[[2]]),
                              method = rep(c("RMNCP", "Hddc", "gseg_wei", 
                                             "gseg_maxt", "changeforest", 
                                             "Rf", "NODE"),
                                           each = reps_total),
                              dgp = rep(paste(DGP[k], "(T = 1000)"),
                                        reps_total * n_methods)))
  big_df <- rbind(big_df, test_df)
}

big_df$dgp <- factor(big_df$dgp)
# combined bwplot

custom_labels <- c(
  "Dense Mean (T = 300)" = "Mean Change (T = 300)", 
  "Dense Cov (T = 300)" = "Cov Change (T = 300)", 
  "Dense Diag Cov (T = 300)" = "Var Change (T = 300)",
  "Dense Distribution (T = 300)" = "Distribution Change (T = 300)", 
  "Banded Cov (T = 300)" = "Banded Cov Change (T = 300)",
  "Dense Mean (T = 1000)" = "Mean Change (T = 1000)", 
  "Dense Cov (T = 1000)" = "Cov Change (T = 1000)", 
  "Dense Diag Cov (T = 1000)" = "Var Change (T = 1000)",
  "Dense Distribution (T = 1000)" = "Distribution Change (T = 1000)", 
  "Banded Cov (T = 1000)" = "Banded Cov Change (T = 1000)"
)
big_df$dgp <- plyr::revalue(big_df$dgp, custom_labels)

color.choice <- c(Logis = "#0072B2", RMNCP = "#999999", Hddc = "#D55E00",
                  gseg_orig =  "#CC79A7", gseg_wei = "#E69F00",
                  gseg_maxt = "#56B4E9", gseg_gen = "#009E73", NODE = "#9999CC",
                  changeforest = "#F0E442", Fnn = "#C77CFF", Rf = "#7CAE00")
bw_ari <- ggplot(big_df, aes(x = method, y = ARI, group = method)) +
  geom_boxplot(aes(fill=method)) +
  facet_wrap(~ factor(dgp, 
                      levels = c("Mean Change (T = 300)", "Cov Change (T = 300)", 
                                 "Var Change (T = 300)",
                                 "Distribution Change (T = 300)", 
                                 "Banded Cov Change (T = 300)",
                                 "Mean Change (T = 1000)", "Cov Change (T = 1000)", 
                                 "Var Change (T = 1000)",
                                 "Distribution Change (T = 1000)", 
                                 "Banded Cov Change (T = 1000)")
  ), ncol = 5) +
  labs(fill = "Methods") +
  scale_x_discrete(limits = c("gseg_wei", "gseg_maxt", "Hddc", 
                              "NODE", "RMNCP", "changeforest", "Rf")) +
  scale_fill_manual(values = color.choice,
                    breaks = c("gseg_wei", "gseg_maxt", "Hddc", 
                               "NODE", "RMNCP", "changeforest", "Rf")) +
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
        legend.position = "top", legend.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        strip.text = element_text(size = 10)) +
  ylab("Adjusted Rand Index (ARI)") + xlab(NULL) 

ggsave("output/plots/power_bwplots/all_boxplots_small.png",
       dpi = 700, limitsize = F, scale = 1.5,
       width = 8.125, height = 3.25, units = "in")


