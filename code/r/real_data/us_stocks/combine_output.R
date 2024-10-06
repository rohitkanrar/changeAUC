if(Sys.getenv("SLURM_SUBMIT_HOST") == "pronto.las.iastate.edu"){
  out.dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/"
} else if(Sys.getenv("SLURM_SUBMIT_HOST") == "hpc2021"){
  out.dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/"
} else{
  out.dir <- ""
}


dat <- read.csv(paste(out.dir,
                      "data/us_stocks/stable_stocks.csv", sep = ""), 
                row.names = 1, header = TRUE)

dates_ <- rownames(dat)
rm(dat)

library(reticulate)
# py_install("pandas")
pd <- import("pandas")
fnn_stock <- pd$read_pickle("output/real_data/us_stocks/fnn_sbs_us_stocks.pkl")
fnn_stock_cp <- numeric(0)
fnn_stock_max_auc <- numeric(0)

for(i in 1:length(fnn_stock[[2]])){
  fnn_stock_cp <- c(fnn_stock_cp, fnn_stock[[2]][[i]]$cp)
  fnn_stock_max_auc <- c(fnn_stock_cp, fnn_stock[[2]][[i]]$max_seeded_auc)
}

rf_stock <- readRDS("output/real_data/us_stocks/rf_sbs_us_stocks.RData")
rf_stock_cp <- numeric(0)
rf_stock_max_auc <- numeric(0)

for(i in 1:length(rf_stock[[2]])){
  rf_stock_cp <- c(rf_stock_cp, rf_stock[[2]][[i]]$cp)
  rf_stock_max_auc <- c(rf_stock_cp, rf_stock[[2]][[i]]$max_seeded_auc)
}

orig_stock <- readRDS("output/real_data/us_stocks/gseg_orig_sbs_us_stocks.RData")
orig_stock_cp <- numeric(0)
orig_stock_pval <- numeric(0)

for(i in 1:length(orig_stock[[2]])){
  orig_stock_cp <- c(orig_stock_cp, orig_stock[[2]][[i]]$cp)
  orig_stock_pval <- c(orig_stock_pval, orig_stock[[2]][[i]]$pval)
}

wei_stock <- readRDS("output/real_data/us_stocks/gseg_wei_sbs_us_stocks.RData")
wei_stock_cp <- numeric(0)
wei_stock_pval <- numeric(0)

for(i in 1:length(wei_stock[[2]])){
  wei_stock_cp <- c(wei_stock_cp, wei_stock[[2]][[i]]$cp)
  wei_stock_pval <- c(wei_stock_pval, wei_stock[[2]][[i]]$pval)
}

maxt_stock <- readRDS("output/real_data/us_stocks/gseg_maxt_sbs_us_stocks.RData")
maxt_stock_cp <- numeric(0)
maxt_stock_pval <- numeric(0)

for(i in 1:length(maxt_stock[[2]])){
  maxt_stock_cp <- c(maxt_stock_cp, maxt_stock[[2]][[i]]$cp)
  maxt_stock_pval <- c(maxt_stock_pval, maxt_stock[[2]][[i]]$pval)
}

gen_stock <- readRDS("output/real_data/us_stocks/gseg_gen_sbs_us_stocks.RData")
gen_stock_cp <- numeric(0)
gen_stock_pval <- numeric(0)

for(i in 1:length(gen_stock[[2]])){
  gen_stock_cp <- c(gen_stock_cp, gen_stock[[2]][[i]]$cp)
  gen_stock_pval <- c(gen_stock_pval, gen_stock[[2]][[i]]$pval)
}

hddc_stock <- readRDS("output/real_data/us_stocks/hddc_sbs_us_stocks.RData")
hddc_stock_cp <- numeric(0)
hddc_stock_max_stat <- numeric(0)

for(i in 1:length(hddc_stock[[2]])){
  hddc_stock_cp <- c(hddc_stock_cp, hddc_stock[[2]][[i]]$cp)
  hddc_stock_max_stat <- c(hddc_stock_max_stat, 
                           hddc_stock[[2]][[i]]$pval)
}

dates_[sort(fnn_stock_cp)]
dates_[sort(rf_stock_cp)]
dates_[sort(hddc_stock_cp)]
dates_[sort(orig_stock_cp)]
dates_[sort(wei_stock_cp)]
dates_[sort(maxt_stock_cp)]
dates_[sort(gen_stock_cp)]
