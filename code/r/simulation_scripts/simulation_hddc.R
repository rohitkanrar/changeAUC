# Comparing Chakraborty, Zhang 2021: HD_DC paper
source("code/r/other_methods/hddc/hddc.R")
source("code/r/generate_data/mean_shift.R")
source("code/r/generate_data/cov_shift.R")
source("code/r/generate_data/moment_shift.R")
source("code/r/misc/misc_v1.R")
library(optparse)
# Rscript code/r/simulation_scripts/simulation_hddc.R -d 2 -n 1000 -p 500 -r 2 -g "dense_mean" -l "local"

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
skip_t_ <- 10

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

out_dir <- paste(out_dir, tolower(dgp_), "/hddc/", sep = "")

if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}

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
  out_ <- single.changepoint(xmat = s_, skip_t = skip_t_,
                             return.acc.only = TRUE)
  if(m == 1){
    iter_t_ <- out_$iter_t
    tstat_mat_ <- out_$accur
    ch_pt <- out_$iter_t[which.max(out_$accur)]
    ari <- get_ari(n_, floor(n_ * 0.5), ch_pt)
    max_tstat <- max(out_$accur)
  }
  else{
    tstat_mat_ <- rbind(tstat_mat_, out_$accur)
    ch_pt <- c(ch_pt, out_$iter_t[which.max(out_$accur)])
    ari <- c(ari, get_ari(n_, floor(n_ * 0.5), ch_pt[m]))
    max_tstat <- c(max_tstat, max(out_$accur))
  }
  print(paste("Change Point is detected at", ch_pt[m], "with maximum Tstat", 
              max_tstat[m]))
}

out_list <- list(tstat_mat = tstat_mat_, ch_pt = ch_pt, ari = ari, 
                 max_tstat = max_tstat, dgp = tolower(dgp_), reps = reps_,
                 p = p_, delta = delta_, n = n_, skip_t = skip_t_, 
                 location = loc_, seed = seed_, iter_t = iter_t_)

file.name <- paste("delta", delta_, "p", p_, "n", n_, "rep", reps_,
                   "seed", seed_[1], ".RData", sep = "_")

path.name <- paste(out_dir, file.name, sep = "")
saveRDS(out_list, file = path.name)