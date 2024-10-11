# Comparing Chakraborty, Zhang 2021: HD_DC paper
source("code/r/other_methods/rmncp/rmncp.R")
source("code/r/generate_data/mean_shift.R")
source("code/r/generate_data/cov_shift.R")
source("code/r/generate_data/moment_shift.R")
source("code/r/misc/misc_v1.R")
library(optparse)
# Rscript code/r/simulation_scripts/simulation_rmncp.R -d 2 -n 300 -p 30 -r 2 -g "dense_mean" -l "local"

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

out_dir <- paste(out_dir, tolower(dgp_), "/rmncp/", sep = "")

if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}

master_out <- vector(mode = "list", length = reps_)

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
  out_ <- get_rmncp_wrapper(dat = s_)
  master_out[[m]] <- out_
  if(m == 1){
    ch_pt <- out_$S[1]
    ari <- get_ari(n_, floor(n_ * 0.5), ch_pt)
    dval <- out_$Dval
    runtime <- out_$runtime
  }
  else{
    ch_pt <- c(ch_pt, out_$S[1])
    ari <- c(ari, get_ari(n_, floor(n_ * 0.5), ch_pt[m]))
    dval <- c(dval, max(out_$Dval))
    runtime <- c(runtime, out_$runtime)
  }
  print(paste("Detection is finished in", runtime[m], out_$runtime_units[m]))
  print(paste("Change Point is detected at", ch_pt[m], "with Dval", 
              dval[m]))
}

out_list <- list(ch_pt = ch_pt, ari = ari, dval = dval, master_out = master_out,
                 dgp = tolower(dgp_), reps = reps_, p = p_, delta = delta_, 
                 n = n_, location = loc_, seed = seed_, runtime = runtime)

file.name <- paste("delta", delta_, "p", p_, "n", n_, "rep", reps_,
                   "seed", seed_[1], ".RData", sep = "_")

path.name <- paste(out_dir, file.name, sep = "")
saveRDS(out_list, file = path.name)