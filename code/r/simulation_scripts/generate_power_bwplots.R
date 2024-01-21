# main power bwplots
source("code/r/misc/misc_v1.R")
epsilon <- 0.15
eta <- 0.05
source("code/r/get_null_quantiles/combine.R")

p <- c(500, 1000)
n <- 1000
n_methods <- 8
reps_total <- 500
dgp <- c("dense_mean", "sparse_mean", "dense_cov", "sparse_cov",
            "dense_diag_cov", "sparse_diag_cov", "dense_moment", "sparse_moment")
delta <- c(2, 2, 0.1, 0.8, 5, 5, 1, 1)

k <- 0
for(regime in dgp){
  ari_bw <- vector(mode = "list", length = 2)
  ari_bw[[1]] <- matrix(0, reps_total, n_methods)
  ari_bw[[2]] <- ari_bw[[1]]
  k <- k + 1
  # reg_logistic
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/reg_logis/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_ep_0.15_et_0.05_seed_1_.RData", sep = "")
    out <- readRDS(file_path)
    ari_bw[[j]][, 1] <- out$ari * as.numeric(sqrt(n) * (out$max_aucs - 0.5) > q95)
    j <- j + 1
  }
  
  # hddc
  j <- 1
  for(p_ in p){
    ari_ <- numeric(0)
    for(s in seq(1, 500, 100)){
      file_path <- paste("output/", regime, "/hddc/",
                         "delta_", delta[k], "_p_", p_, "_n_", n, 
                         "_rep_100_seed_", s, "_.RData", sep = "")
      # out <- readRDS(file_path)
      tryCatch({
        out <- readRDS(file_path)
        ari_ <- c(ari_, out$ari * as.numeric(out$max_tstat > 0.642))
      }, warning = function(w){
        print(paste(file_path, "not found in", regime))
      })
    }
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
  
  
  # fnn
  library(reticulate)
  # py_install("pandas")
  pd <- import("pandas")
  j <- 1
  for(p_ in p){
    file_path <- paste("output/", regime, "/fnn/",
                       "delta_", delta[k], "_p_", p_, "_n_", n, 
                       "_ep_0.15_et_0.05_seed_1_.pkl", sep = "")
    out <- pd$read_pickle(file_path)
    ari_bw[[j]][, 7] <- out$ari * as.numeric(sqrt(n) * (out$max_aucs - 0.5) > q95)
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
  
  
  root_dir <- "output/plots/power_bwplots/"
  
  bwplots <- vector(mode = "list", length = 2)
  
  library(tidyverse)
  ari_bw_p500_df <- data.frame(ari_bw[[1]])
  colnames(ari_bw_p500_df) <- c("Logis", "Hddc", "gseg_orig",
                                "gseg_wei", "gseg_maxt", "gseg_gen",
                                "Fnn", "Rf")
  tidy.df <- ari_bw_p500_df %>%
    select(Logis, Hddc, Fnn, Rf, gseg_orig, gseg_wei, 
           gseg_maxt, gseg_gen) %>%
    gather(key = "Methods", value = "ARI") %>%
    mutate(name = fct_relevel(Methods, "gseg_orig","gseg_wei", 
                              "gseg_maxt", "gseg_gen",
                              "Hddc", "Logis", "Fnn", "Rf"))
  
  color.choice <- c(Logis = "#0072B2", Hddc = "#D55E00", 
                    gseg_orig =  "#CC79A7", gseg_wei = "#E69F00",
                    gseg_maxt = "#56B4E9", gseg_gen = "#009E73",
                    Fnn = "#C77CFF", Rf = "#7CAE00")
  
  bwplots[[1]] <- 
    ggplot(tidy.df, aes(x = Methods, y = ARI, fill = Methods)) +
    geom_boxplot() +
    scale_x_discrete(limits = c("gseg_orig", "gseg_wei", 
                                "gseg_maxt", "gseg_gen",
                                "Hddc", "Logis", "Fnn", "Rf")) +
    scale_fill_manual(values = color.choice,
                      breaks = c("gseg_orig", "gseg_wei", 
                                 "gseg_maxt", "gseg_gen",
                                 "Hddc", "Logis", "Fnn", "Rf")) +
    theme(axis.text.x = element_text(size = 8, angle = 45, hjust = 1))
  
  ggsave(paste(root_dir,"/", regime, "_boxplot_p_", 500,
               ".png", sep = ""), width = 6, height = 4)
  
  
  
  ari_bw_p1000_df <- data.frame(ari_bw[[2]])
  colnames(ari_bw_p1000_df) <- c("Logis", "Hddc", "gseg_orig",
                                 "gseg_wei", "gseg_maxt", "gseg_gen", 
                                 "Fnn", "Rf")
  tidy.df <- ari_bw_p1000_df %>%
    select(Logis, Hddc, Fnn, Rf, gseg_orig, gseg_wei, 
           gseg_maxt, gseg_gen) %>%
    gather(key = "Methods", value = "ARI")
  
  bwplots[[2]] <- 
    ggplot(tidy.df, aes(x = Methods, y = ARI, fill = Methods)) +
    geom_boxplot() +
    scale_x_discrete(limits = c("gseg_orig", "gseg_wei", 
                                "gseg_maxt", "gseg_gen",
                                "Hddc", "Logis", "Fnn", "Rf")) +
    scale_fill_manual(values = color.choice,
                      breaks = c("gseg_orig", "gseg_wei", 
                                 "gseg_maxt", "gseg_gen",
                                 "Hddc", "Logis", "Fnn", "Rf")) +
    theme(axis.text.x = element_text(size = 8, angle = 45, hjust = 1))
  
  ggsave(paste(root_dir,"/", regime, "_boxplot_p_", 1000,
               ".png", sep = ""), width = 6, height = 4)
  if(regime == "dense_mean"){
    dense_mean_boxplot = bwplots
  } else if(regime == "sparse_mean"){
    sparse_mean_boxplot = bwplots
  } else if(regime == "dense_cov"){
    dense_cov_boxplot = bwplots
  } else if(regime == "sparse_cov"){
    sparse_cov_boxplot = bwplots
  } else if(regime == "dense_diag_cov"){
    dense_diag_cov_boxplot = bwplots
  } else if(regime == "sparse_diag_cov"){
    sparse_diag_cov_boxplot = bwplots
  } else if(regime == "dense_moment"){
    dense_moment_boxplot = bwplots
  } else if(regime == "sparse_moment"){
    sparse_moment_boxplot = bwplots
  } 
}

# combined bwplot

library(ggpubr)
all_bwplot <- 
  ggarrange(dense_mean_boxplot[[1]] + rremove("ylab") + rremove("xlab"),
            dense_cov_boxplot[[1]] + rremove("ylab") + rremove("xlab"), 
            dense_diag_cov_boxplot[[1]] + rremove("ylab") + rremove("xlab"),
            dense_moment_boxplot[[1]] + rremove("ylab") + rremove("xlab"),
            dense_mean_boxplot[[2]] + rremove("ylab") + rremove("xlab"),
            dense_cov_boxplot[[2]] + rremove("ylab") + rremove("xlab"), 
            dense_diag_cov_boxplot[[2]] + rremove("ylab") + rremove("xlab"),
            dense_moment_boxplot[[2]] + rremove("ylab") + rremove("xlab"),
            sparse_mean_boxplot[[1]] + rremove("ylab") + rremove("xlab"), 
            sparse_cov_boxplot[[1]] + rremove("ylab") + rremove("xlab"),
            sparse_diag_cov_boxplot[[1]] + rremove("ylab") + rremove("xlab"), 
            sparse_moment_boxplot[[1]] + rremove("ylab") + rremove("xlab"),
            sparse_mean_boxplot[[2]] + rremove("ylab") + rremove("xlab"), 
            sparse_cov_boxplot[[2]] + rremove("ylab") + rremove("xlab"),
            sparse_diag_cov_boxplot[[2]] + rremove("ylab") + rremove("xlab"), 
            sparse_moment_boxplot[[2]] + rremove("ylab") + rremove("xlab"),
            nrow = 4, ncol = 4, common.legend = TRUE,
            labels = list("Dense Mean (p = 500)","Dense Cov (p = 500)", 
                          "Dense Diag Cov (p = 500)", "Dense Distribution (p = 500)",
                          "Dense Mean (p = 1000)","Dense Cov (p = 1000)", 
                          "Dense Diag Cov (p = 1000)", "Dense Distribution (p = 1000)",
                          "Sparse Mean (p = 500)", "Banded Cov (p = 500)", 
                          "Sparse Diag Cov (p = 500)", "Sparse Distribution (p = 500)",
                          "Sparse Mean (p = 1000)", "Banded Cov (p = 1000)", 
                          "Sparse Diag Cov (p = 1000)", "Sparse Distribution (p = 1000)"), 
            label.x = 0, label.y = 1.025, 
            font.label = list(size=8)) 
annotate_figure(all_bwplot, 
                left = text_grob("Adjusted Rand index (ARI)", rot = 90,
                                 vjust = 1, size = 12),
                bottom = text_grob("Methods"))
ggsave("output/plots/power_bwplots/all_boxplots.png",
       dpi = 700, limitsize = F, scale = 1.5,
       width = 6.75, height = 5.5, units = "in")
