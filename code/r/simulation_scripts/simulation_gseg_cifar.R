# Comparing gSeg: Chu, Chen 2019
source("code/r/other_methods/gseg/gseg.R")
source("code/r/other_methods/gseg/gseg_cifar.R")
library("optparse")
# Rscript code/r/simulation_scripts/simulation_gseg_cifar.R -r 10 -n 1000 -g 35 -l local -s 1

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

if(loc_ =='hku'){
  out_dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/"
} else if(loc_ == 'pronto'){
  out_dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
} else{
  out_dir <- "output/"
}

out_dir <- paste(out_dir, "cifar/", labels_[1], "-", labels_[2], "/gseg/", sep = "")

if(!dir.exists(out_dir)){
  dir.create(out_dir, recursive = TRUE)
}


orig_ <- list(cp = numeric(0), tstat = numeric(0), maxZ = numeric(0),
              pval = numeric(0), ari = numeric(0))
wei_ <- orig_
maxt_ <- orig_
gen_ <- orig_
for(m in 1:reps_){
  print(paste("Replication Number:", m, "----------------------------"))
  set.seed(seed_[m])
  s_ <- generate_cifar_cp(n1 = n_ %/% 2,
                          n2 = n_ %/% 2,
                          labels = labels_)
  
  out_ <- gseg_wrapper(s_)
  
  orig_$cp <- c(orig_$cp, out_$orig$cp)
  orig_$tstat <- rbind(orig_$tstat, out_$orig$tstat)
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


file_name <- paste("cifar_", labels_[1], "-", labels_[2], "_n_", n_, "_seed_",
                   seed_[1], ".RData", sep = "")

out_list <- list(orig = orig_, wei = wei_, maxt = maxt_, gen = gen_,
                 reps = reps_, n = n_)

path_name <- paste(out_dir, file_name, sep = "")
saveRDS(out_list, file = path_name)