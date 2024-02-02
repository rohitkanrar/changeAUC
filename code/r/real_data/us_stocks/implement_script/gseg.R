source("code/r/other_methods/gseg/gseg_multiple.R")

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
output_orig <- multiple_changepoint_gseg(dat, 1, nrow(dat), no_of_perm = 199, 
                                    n_min_sample = 500, statistics = "o")
saveRDS(output_orig,
        paste(out.dir, "output/real_data/us_stocks/gseg_orig_sbs_us_stocks.RData", 
              sep = ""))

output_wei <- multiple_changepoint_gseg(dat, 1, nrow(dat), no_of_perm = 199, 
                                         n_min_sample = 500, statistics = "w")
saveRDS(output_wei,
        paste(out.dir, "output/real_data/us_stocks/gseg_wei_sbs_us_stocks.RData", 
              sep = ""))

output_gen <- multiple_changepoint_gseg(dat, 1, nrow(dat), no_of_perm = 199, 
                                         n_min_sample = 500, statistics = "g")
saveRDS(output_gen,
        paste(out.dir, "output/real_data/us_stocks/gseg_gen_sbs_us_stocks.RData", 
              sep = ""))

output_maxt <- multiple_changepoint_gseg(dat, 1, nrow(dat), no_of_perm = 199, 
                                         n_min_sample = 500, statistics = "m")
saveRDS(output_maxt,
        paste(out.dir, "output/real_data/us_stocks/gseg_maxt_sbs_us_stocks.RData", 
              sep = ""))
