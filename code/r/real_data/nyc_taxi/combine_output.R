library(reticulate)
# py_install("pandas")
pd <- import("pandas")

vgg16_taxi <- pd$read_pickle("output/real_data/nyc_taxi/vgg16_sbs_nyc_taxi.pkl")
vgg16_taxi_cp <- numeric(0)
vgg16_taxi_max_auc <- numeric(0)

for(i in 1:length(vgg16_taxi[[2]])){
  vgg16_taxi_cp <- c(vgg16_taxi_cp, vgg16_taxi[[2]][[i]]$cp)
  vgg16_taxi_max_auc <- c(vgg16_taxi_max_auc, 
                          vgg16_taxi[[2]][[i]]$max_seeded_auc)
}

orig_taxi <- readRDS("output/real_data/nyc_taxi/gseg_orig_sbs_nyc_taxi.RData")
orig_taxi_cp <- numeric(0)
orig_taxi_pval <- numeric(0)
for(i in 1:length(orig_taxi$output)){
  orig_taxi_cp <- c(orig_taxi_cp, orig_taxi$output[[i]]$cp)
  orig_taxi_pval <- c(orig_taxi_pval, orig_taxi$output[[i]]$pval)
}

wei_taxi <- readRDS("output/real_data/nyc_taxi/gseg_wei_sbs_nyc_taxi.RData")
wei_taxi_cp <- numeric(0)
wei_taxi_pval <- numeric(0)
for(i in 1:length(wei_taxi$output)){
  wei_taxi_cp <- c(wei_taxi_cp, wei_taxi$output[[i]]$cp)
  wei_taxi_pval <- c(wei_taxi_pval, wei_taxi$output[[i]]$pval)
}

gen_taxi <- readRDS("output/real_data/nyc_taxi/gseg_gen_sbs_nyc_taxi.RData")
gen_taxi_cp <- numeric(0)
gen_taxi_pval <- numeric(0)
for(i in 1:length(gen_taxi$output)){
  gen_taxi_cp <- c(gen_taxi_cp, gen_taxi$output[[i]]$cp)
  gen_taxi_pval <- c(gen_taxi_pval, gen_taxi$output[[i]]$pval)
}

maxt_taxi <- readRDS("output/real_data/nyc_taxi/gseg_maxt_sbs_nyc_taxi.RData")
maxt_taxi_cp <- numeric(0)
maxt_taxi_pval <- numeric(0)
for(i in 1:length(maxt_taxi$output)){
  maxt_taxi_cp <- c(maxt_taxi_cp, maxt_taxi$output[[i]]$cp)
  maxt_taxi_pval <- c(maxt_taxi_pval, maxt_taxi$output[[i]]$pval)
}

dates_ <- sort(list.files("data/fhv_nyc/daily_heatmaps/"))
dates_[sort(vgg16_taxi_cp)]
dates_[sort(orig_taxi_cp)]
dates_[sort(wei_taxi_cp)]
dates_[sort(maxt_taxi_cp)]
dates_[sort(gen_taxi_cp)]

