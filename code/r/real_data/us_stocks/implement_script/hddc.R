source("code/r/other_methods/hddc/hddc.R")

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
n <- nrow(dat)
output <- multiple.changepoint(dat, left = 1, right = nrow(dat), skip_t = 10,
                               skim = 0.05, n_min_sample = 300)


saveRDS(output,
        paste(out.dir, "output/real_data/us_stocks/hddc_sbs_us_stocks.RData", 
              sep = ""))
