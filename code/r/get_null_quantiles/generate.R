# Rscript code/r/get_null_quantiles/generate.R -e 0.15 -a 0.05 -n 100000 -k 100000 -l "local" -o "auc"

source("code/r/misc/misc_v1.R")
library(optparse)

option_list = list(
  make_option(c("-e", "--epsilon"), type="double", default=NULL),
  make_option(c("-a", "--eta"), type="double", default=NULL),
  make_option(c("-n", "--n"), type="integer", default=100000),
  make_option(c("-k", "--knots"), type="integer", default=100000),
  make_option(c("-l", "--location"), type="character", default="hku"),
  make_option(c("-o", "--option"), type="character", default="auc")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

epsilon_ <- opt$epsilon
eta_ <- opt$eta
n_ <- opt$n
knots_ <- opt$k
loc_ <- opt$location
option_ <- opt$option

if(option_ == "auc"){
  dir_name <- "null_quantiles/"
} else{
  dir_name <- "null_quantiles_cusum/"
}

if(loc_ =='hku'){
  out_dir <- paste("/lustre1/u/rohitisu/git_repos_data/changeAUC/output/", 
                   dir_name, sep = "")
} else if(loc_ == 'pronto'){
  out_dir <- paste("/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/", 
                   dir_name, sep = "")
} else{
  out_dir <- paste("output/", dir_name, sep = "")
}

out_dir <- paste(out_dir, "epsilon_", epsilon_,
                 "_eta_", eta_, "/", sep = "")

if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}
print(out_dir)
set.seed(100)
for(i in 1:100){
  print(i)
  if(option_ == "auc"){
    samp_ <- get_sample_gr_max(n = (n_/100), T_ = knots_,
                               epsilon = epsilon_, eta = eta_)
    saveRDS(samp_, paste(out_dir, "/gr_sample_", round(runif(1) * 1e8, 0),
                         ".RData", sep = ""))
  } else{
    samp_ <- get_sample_hr_max(n = (n_/100), T_ = knots_,
                               epsilon = epsilon_, eta = eta_)
    saveRDS(samp_, paste(out_dir, "/hr_sample_", round(runif(1) * 1e8, 0),
                         ".RData", sep = ""))
  }
  
  rm(samp_)
}
