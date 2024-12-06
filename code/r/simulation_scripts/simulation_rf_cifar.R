source("code/r/other_methods/gseg/gseg.R")
source("code/r/other_methods/gseg/gseg_cifar.R")
source("code/r/get_change_point/get_change_point_v1.R")
library(optparse)
# Rscript code/r/simulation_scripts/simulation_rf_cifar.R -r 10 -n 1000 -g 35 -l local -s 1

option_list = list(
  make_option(c("-r", "--reps"), type = "integer", default=NULL),
  make_option(c("-n", "--n"), type = "integer", default=NULL),
  make_option(c("-g", "--dgp"), type = "integer", default=35),
  make_option(c("-l", "--location"), type = "character", default = "local"),
  make_option(c("-s", "--seed"), type = "integer", 
              default = round(runif(1) * 1000000))
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
reps_ <- opt$reps
n_ <- opt$n
case_ <- opt$dgp
loc_ <- opt$location
seed_ <- seq(opt$seed, length.out = reps_)
labels_ <- unique(c(case_ %/% 10, case_ %% 10))
epsilon_ <- 0.15
eta_ <- 0.05
test_ <- FALSE
no_of_perm_ <- 199

if(loc_ =='hku'){
  out_dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/"
} else if(loc_ == 'pronto'){
  out_dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
} else{
  out_dir <- "output/"
}

if(length(labels_) == 2){
  out_dir <- paste(out_dir, "cifar/", labels_[1], "-", labels_[2], "/rf/", sep = "")
} else{
  out_dir <- paste(out_dir, "cifar/", labels_[1], "-", labels_[1], "/rf/", sep = "")
}


if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}


for(m in 1:reps_){
  print(paste("Replication Number:", m, "----------------------------"))
  set.seed(seed_[m])
  s_ <- generate_cifar_cp(n1 = n_ %/% 2,
                          n2 = n_ %/% 2,
                          labels = labels_)
  out_ <- get_change_point(sample_=s_, classifier="RF",
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
                 n = n_, clf = "rf", split_trim = epsilon_, auc_trim = eta_,
                 perm_pval = test_, location = loc_, seed = seed_,
                 runtime = runtime)

if(test_)
  out_list$pval <- pval


if(length(labels_) == 2){
  file_name <- paste("cifar_", labels_[1], "-", labels_[2], "_n_", n_, "_seed_",
                     seed_[1], ".RData", sep = "")
} else{
  file_name <- paste("cifar_", labels_[1], "-", labels_[1], "_n_", n_, "_seed_",
                     seed_[1], ".RData", sep = "")
}

path.name <- paste(out_dir, file.name, sep = "")
saveRDS(out_list, file = path.name)