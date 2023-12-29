# Comparing gSeg: Chu, Chen 2019
source("code/r/other_methods/gseg/gseg.R")
source("code/r/generate_data/mean_shift.R")
source("code/r/generate_data/cov_shift.R")
source("code/r/generate_data/moment_shift.R")
library(optparse)

# Rscript code/r/simulation_scripts/simulation_gseg.R -d 2 -n 1000 -p 500 -r 2 -g "dense_mean" -l "local"

option_list = list(
  make_option(c("-d", "--delta"), type="double", default=NULL),
  make_option(c("-n", "--n"), type="integer", default=NULL),
  make_option(c("-p", "--p"), type="integer", default=NULL),
  make_option(c("-r", "--reps"), type="integer", default=NULL),
  make_option(c("-g", "--dgp"), type="character", default=NULL),
  make_option(c("-l", "--location"), type="character", default="hku"),
  make_option(c("-s", "--seed"), type="integer", 
              default=round(runif(1) * 1000000))
)
opt_parser <- OptionParser(option_list = option_list,
                           add_help_option = FALSE)
opt <- parse_args(opt_parser)

delta_ <- opt$delta
n_ <- opt$n
p_ <- opt$p
reps_ <- opt$reps
dgp_ <- opt$dgp
loc_ <- opt$location
seed_ <- seq(opt$seed, length.out = reps_) 

if(loc_ =='hku'){
  out_dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/"
} else if(loc_ == 'pronto'){
  out_dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
} else{
  out_dir <- "output/"
}

if(!dir.exists(out_dir)){
  dir.create(out_dir)
}

out_dir <- paste(out_dir, tolower(dgp_), "/gseg/", sep = "")

if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}


orig_ <- list(cp = numeric(0), maxZ = numeric(0),
              pval = numeric(0), ari = numeric(0))
wei_ <- orig_
maxt_ <- orig_
gen_ <- orig_

for(m in 1:reps_){
  set.seed(seed_[m])
  print(paste("Replication Number:", m, "----------------------------"))
  if(dgp_ == "dense_mean"){
    s_ <- get_dense_shift_normal_mean(delta_, n_, p_)
  } else if(dgp_ == "sparse_mean"){
    s_ <- get_sparse_shift_normal_mean(delta_, n_, p_)
  } else if(dgp_ == "dense_cov"){
    s_ <- get_dense_shift_normal_cov(delta_, n_, p_)
  } else if(dgp_ == "sparse_cov"){
    s_ <- get_sparse_shift_normal_cov(delta_, n_, p_)
  } else if(dgp_ == "dense_diag_cov"){
    s_ <- get_dense_diag_shift_normal_cov(delta_, n_, p_)
  } else if(dgp_ == "sparse_diag_cov"){
    s_ <- get_sparse_diag_shift_normal_cov(delta_, n_, p_)
  } else if(dgp_ == "dense_moment"){
    s_ <- get_dense_shift_normal_moment(n_, p_)
  } else if(dgp_ == "sparse_moment"){
    s_ <- get_sparse_shift_normal_moment(n_, p_)
  } else if(dgp_ == "standard_null"){
    s_ <- get_normal_mean(n_, p_)
  } else if(dgp_ == "banded_null"){
    s_ <- get_sparse_normal_cov(n_, p_, rho = delta_)
  } else if(dgp_ == "exp_null"){
    s_ <- get_exponential(n_, p_)
  }
  else{
    stop("Invalid Data Generating Process (DGP).")
  }
  out_ <- gseg_wrapper(s_)
  
  orig_$cp <- c(orig_$cp, out_$orig$cp)
  orig_$maxZ <- c(orig_$maxZ, out_$orig$maxZ)
  orig_$pval <- c(orig_$pval, out_$orig$pval)
  orig_$ari <- c(orig_$ari, out_$orig$ari)
  
  wei_$cp <- c(wei_$cp, out_$wei$cp)
  wei_$tstat <- rbind(wei_$tstat, out_$wei$tstat)
  wei_$maxZ <- c(wei_$maxZ, out_$wei$maxZ)
  wei_$pval <- c(wei_$pval, out_$wei$pval)
  wei_$ari <- c(wei_$ari, out_$wei$ari)
  
  maxt_$cp <- c(maxt_$cp, out_$maxt$cp)
  maxt_$tstat <- rbind(maxt_$tstat, out_$maxt$tstat)
  maxt_$maxZ <- c(maxt_$maxZ, out_$maxt$maxZ)
  maxt_$pval <- c(maxt_$pval, out_$maxt$pval)
  maxt_$ari <- c(maxt_$ari, out_$maxt$ari)
  
  gen_$cp <- c(gen_$cp, out_$gen$cp)
  gen_$tstat <- rbind(gen_$tstat, out_$gen$tstat)
  gen_$maxZ <- c(gen_$maxZ, out_$gen$maxZ)
  gen_$pval <- c(gen_$pval, out_$gen$pval)
  gen_$ari <- c(gen_$ari, out_$gen$ari)
}

out.list <- list(orig = orig_, wei = wei_, maxt = maxt_, gen = gen_,
                 dgp = dgp_, p = p_, delta = delta_, reps = reps_, n = n_, 
                 location = loc_, seed = seed_)

file.name <- paste("delta", delta_, "p", p_, "n", n_, "rep", reps_,
                   "seed", seed_[1], ".RData", sep = "_")
path.name <- paste(out_dir, file.name, sep = "")
saveRDS(out.list, file = path.name)