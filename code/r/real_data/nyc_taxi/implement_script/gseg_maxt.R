source("code/r/other_methods/gseg/gseg_multiple.R")

if(Sys.getenv("SLURM_SUBMIT_HOST") == "pronto.las.iastate.edu"){
  out.dir <- "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/"
} else if(Sys.getenv("SLURM_SUBMIT_HOST") == "hpc2021"){
  out.dir <- "/lustre1/u/rohitisu/git_repos_data/changeAUC/"
} else{
  out.dir <- ""
}

dat <- readRDS(paste(out.dir,
                     "data/fhv_nyc/heatmaps_color_vectorized.RData", sep = ""))
n <- nrow(dat)
set.seed(100)
output_maxt <- multiple_changepoint_gseg(dat, 1, nrow(dat), no_of_perm = 199, 
                                         n_min_sample = 500, statistics = "m")
saveRDS(output_maxt,
        paste(out.dir, "output/real_data/nyc_taxi/gseg_maxt_sbs_nyc_taxi.RData", 
              sep = ""))