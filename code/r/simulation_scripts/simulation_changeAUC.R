# Rscript code/r/simulation_scripts/simulation_changeAUC.R -d 1 -n 500 -p 500 -r 2 -g "dense_mean" -l "local"

source("code/r/get_change_point/get_change_point_v1.R")
source("code/r/generate_data/mean_shift.R")
source("code/r/generate_data/cov_shift.R")
source("code/r/generate_data/moment_shift.R")
library(optparse)

option_list = list(
  make_option(c("-d", "--delta"), type="double", default=NULL),
  make_option(c("-n", "--n"), type="integer", default=NULL),
  make_option(c("-p", "--p"), type="integer", default=NULL),
  make_option(c("-r", "--reps"), type="integer", default=NULL),
  make_option(c("-g", "--dgp"), type="character", default=NULL),
  make_option(c("-c", "--clf"), type="character", default="RF"),
  make_option(c("-e", "--epsilon"), type="double", default=0.15),
  make_option(c("-a", "--eta"), type="double", default=0.05),
  make_option(c("-t", "--test"), type="character", default="FALSE"),
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
clf_ <- opt$clf
epsilon_ <- opt$epsilon
eta_ <- opt$eta
test_ <- as.logical(opt$test)
loc_ <- opt$location
seed_ <- seq(opt$seed, length.out = reps_) 
no_of_perm_ <- 199

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

out_dir <- paste(out_dir, tolower(dgp_), "/",
                 tolower(clf_), "/", sep = "")


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
  } else if(dgp_ == "students_t"){
    s_ <- get_students_t(n_, p_, df = delta_)
  }
  else{
    stop("Invalid Data Generating Process (DGP).")
  }
  
  out_ <- get_change_point(sample_=s_, classifier=clf_,
                           split_trim = epsilon_,
                           auc_trim = eta_,
                           perm_pval = test_,
                           no_of_perm = no_of_perm_)
  
  if(m == 1){
    aucs <- out_$auc
    ch_pt <- out_$ch_pt
    ari <- out_$ari
    max_aucs <- out_$max_auc
    pred <- out_$pred
    runtime <- out_$runtime
    if(test_)
      pval <- out_$pval
  }
  else{
    aucs <- rbind(aucs, out_$auc)
    ch_pt <- c(ch_pt, out_$ch_pt)
    ari <- c(ari, out_$ari)
    max_aucs <- c(max_aucs, out_$max_auc)
    pred <- rbind(pred, out_$pred)
    runtime <- c(runtime, out_$runtime)
    if(test_)
      pval <- c(pval, out_$pval)
  }
}



out_list <- list(aucs = aucs, ch_pt = ch_pt, ari = ari, max_aucs = max_aucs,
                 pred = pred, dgp = tolower(dgp_), reps = reps_,
                 p = p_, delta = delta_, n = n_, 
                 clf = tolower(clf_), split_trim = epsilon_, auc_trim = eta_,
                 perm_pval = test_, location = loc_, seed = seed_,
                 runtime = runtime)

if(test_)
  out_list$pval <- pval


file.name <- paste("delta", delta_, "p", p_, "n", n_, "ep", epsilon_, 
                   "et", eta_, "seed", seed_[1], ".RData", sep = "_")

path.name <- paste(out_dir, file.name, sep = "")
saveRDS(out_list, file = path.name)