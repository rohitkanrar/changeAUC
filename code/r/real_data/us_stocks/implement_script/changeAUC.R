source("code/r/get_change_point/get_multiple_change_point_v1.R")

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
set.seed(100)
output_rf <- get_multiple_change_point(as.matrix(dat), left = 1, right = nrow(dat),
                                    classifier = "RF", 
                                    split_trim = 0.15,
                                    auc_trim = 0.05,
                                    no_of_perm = 199,
                                    min_length = 500, decay = sqrt(2),
                                    return_output = "all")

saveRDS(output_rf,
        paste(out.dir, "output/real_data/us_stocks/rf_sbs_us_stocks.RData", 
              sep = ""))

set.seed(100)
output_reg_logis <- get_multiple_change_point(as.matrix(dat), left = 1, 
                                              right = nrow(dat),
                                       classifier = "REG_LOGIS", 
                                       split_trim = 0.15,
                                       auc_trim = 0.05,
                                       no_of_perm = 199,
                                       min_length = 500, decay = sqrt(2),
                                       return_output = "all")

saveRDS(output_reg_logis,
        paste(out.dir, "output/real_data/us_stocks/rf_sbs_us_stocks.RData", 
              sep = ""))
