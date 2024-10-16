# main power bwplots
source("code/r/misc/misc_v1.R")
library(tidyverse)
epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")

p <- c(30)
n <- 300
n_methods <- 8
reps_total <- 500
dgp <- c("dense_mean", "sparse_mean", "dense_cov", "sparse_cov",
         "dense_diag_cov", "sparse_diag_cov", "dense_moment", "sparse_moment")

DGP <- c("Dense Mean", "Sparse Mean", "Dense Cov", "Banded Cov",
         "Dense Diag Cov", "Sparse Diag Cov", "Dense Distribution", 
         "Sparse Distribution")
delta <- c(2, 2, 0.1, 0.8, 5, 5, 1, 1)
big_df <- data.frame()
k <- 0
for(regime in dgp){
  ari_bw <- vector(mode = "list", length = 2)
  ari_bw[[1]] <- matrix(0, reps_total, n_methods)
  ari_bw[[2]] <- ari_bw[[1]]
  k <- k + 1
  # RMNCP
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/rmncp/",
                       "delta_", delta[k], "_p_", p_, "_n_", n,
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    dval <- out$dval[c(1, 4:502)]
    ari_bw[[j]][, 1] <- out$ari * as.numeric(dval < 0.05)
    j <- j + 1
  }
  
  # hddc
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/hddc/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_ <- out$ari
    ari_ <- ari_ * as.numeric(out$max_tstat > 0.642)
    ari_bw[[j]][, 2] <- ari_
    j <- j + 1
  }
  
  # gseg
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/gseg/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_rep_500_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_bw[[j]][, 3] <- out$orig$ari * as.numeric(out$orig$pval <= 0.05)
    ari_bw[[j]][, 4] <- out$wei$ari * as.numeric(out$wei$pval <= 0.05)
    ari_bw[[j]][, 5] <- out$maxt$ari * as.numeric(out$maxt$pval <= 0.05)
    ari_bw[[j]][, 6] <- out$gen$ari * as.numeric(out$gen$pval <= 0.05)
    j <- j + 1
  }
  
  # changeforest
  library(reticulate)
  # py_install("pandas")
  pd <- import("pandas")
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/changeforest/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_seed_1_.pkl", sep = "")
    out <- pd$read_pickle(file_path)
    ari_bw[[j]][, 7] <- out$ari
    j <- j + 1
  }
  
  # rf
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/rf/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_ep_0.15_et_0.05_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_bw[[j]][, 8] <- out$ari * as.numeric(sqrt(n) * (out$max_aucs - 0.5) > q95)
    j <- j + 1
  }
  
  test_df <- data.frame(ARI = as.vector(ari_bw[[1]]),
                        method = rep(c("RMNCP", "Hddc", "gseg_orig",
                                       "gseg_wei", "gseg_maxt", "gseg_gen",
                                       "changeforest", "Rf"), 
                                     each = reps_total),
                        dgp = rep(paste(DGP[k], "(p = 30)"), 
                                  reps_total * n_methods))
  # test_df <- rbind(test_df,
  #                  data.frame(ARI = as.vector(ari_bw[[2]]),
  #                             method = rep(c("RMNCP", "Hddc", "gseg_orig",
  #                                            "gseg_wei", "gseg_maxt", "gseg_gen",
  #                                            "changeforest", "Rf"), 
  #                                          each = reps_total),
  #                             dgp = rep(paste(DGP[k], "(p = 1000)"), 
  #                                       reps_total * n_methods)))
  big_df <- rbind(big_df, test_df)
}

# combined bwplot


color.choice <- c(Logis = "#0072B2", RMNCP = "#999999", Hddc = "#D55E00",
                  gseg_orig =  "#CC79A7", gseg_wei = "#E69F00",
                  gseg_maxt = "#56B4E9", gseg_gen = "#009E73",
                  changeforest = "#F0E442", Fnn = "#C77CFF", Rf = "#7CAE00")
bw_ari <- ggplot(big_df, aes(x = method, y = ARI, group = method)) +
  geom_boxplot(aes(fill=method)) +
  facet_wrap(~ factor(dgp, 
                      levels = c("Dense Mean (p = 30)", "Dense Cov (p = 30)", "Dense Diag Cov (p = 30)",
                                 "Dense Distribution (p = 30)", "Sparse Mean (p = 30)", 
                                 "Banded Cov (p = 30)", "Sparse Diag Cov (p = 30)", 
                                 "Sparse Distribution (p = 30)")
  ), ncol = 4) +
  labs(fill = "Methods") +
  scale_x_discrete(limits = c("gseg_orig", "gseg_wei", 
                              "gseg_maxt", "gseg_gen",
                              "Hddc", "RMNCP", "changeforest", "Rf")) +
  scale_fill_manual(values = color.choice,
                    breaks = c("gseg_orig", "gseg_wei", 
                               "gseg_maxt", "gseg_gen",
                               "Hddc", "RMNCP", "changeforest", "Rf")) +
  theme(axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
        legend.position = "top", legend.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        strip.text = element_text(size = 10)) +
  ylab("Adjusted Rand Index (ARI)") + xlab(NULL) 

ggsave("output/plots/power_bwplots/all_boxplots_small.png",
       dpi = 700, limitsize = F, scale = 1.5,
       width = 6.5, height = 3.25, units = "in")


