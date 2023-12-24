# Rscript code/r/get_null_quantiles/generate.R -e 0.15 -a 0.05 -n 100000 -k 100000 -l "local"

source("code/r/misc/misc_v1.R")
library(optparse)

option_list = list(
  make_option(c("-e", "--epsilon"), type="double", default=NULL),
  make_option(c("-a", "--eta"), type="double", default=NULL),
  make_option(c("-n", "--n"), type="integer", default=100000),
  make_option(c("-k", "--knots"), type="integer", default=100000),
  make_option(c("-l", "--location"), type="character", default="hku")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

epsilon_ <- opt$epsilon
eta_ <- opt$eta
n_ <- opt$n
knots_ <- opt$k
loc_ <- opt$location

samp_ <- get_sample_gr_max(n = n_, T_ = knots_,
                           epsilon = epsilon_, eta = eta_)

if(loc_ =='hku'){
  out_dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/null_quantiles"
} else if(loc_ == 'pronto'){
  out_dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/null_quantiles"
} else{
  out_dir <- "output/null_quantiles/"
}


if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}
saveRDS(samp_, paste(out_dir, "epsilon_", epsilon_,
                       "_eta_", eta_, "_.RData", sep = ""))
