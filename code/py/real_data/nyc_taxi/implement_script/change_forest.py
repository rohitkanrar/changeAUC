import os
import pickle as pkl
import random
import sys
import numpy as np
sys.path.insert(0, "./code/py")
if os.getenv("SLURM_SUBMIT_HOST") == "pronto.las.iastate.edu":
    root_dir = "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/"
    sys.path.insert(0, "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output")
    sys.path.insert(0, "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/data")
elif os.getenv("SLURM_SUBMIT_HOST") == "hpc2021":
    root_dir = "/lustre1/u/rohitisu/git_repos_data/changeAUC/"
    sys.path.insert(0, "/lustre1/u/rohitisu/git_repos_data/changeAUC/output")
    sys.path.insert(0, "/lustre1/u/rohitisu/git_repos_data/changeAUC/data")
else:
    root_dir = ""
    sys.path.insert(0, "./output")
    sys.path.insert(0, "./data")
from changeforest import changeforest, Control
from misc.misc_heatmaps import get_dates

out_dir = root_dir + "output/real_data/nyc_taxi/"

with open(root_dir + "data/fhv_nyc/heatmaps_color_numeric.pkl", "rb") as f:
    heatmaps_array = pkl.load(f)

heatmaps_array_vec = heatmaps_array.reshape(heatmaps_array.shape[0], -1)
random.seed(100)



cf_taxi_multiple = changeforest(heatmaps_array_vec, "random_forest", "sbs",
                              Control(minimal_relative_segment_length=0.15))

dates = get_dates("data/fhv_nyc/daily_heatmaps")
cps_index = cf_taxi_multiple.split_points()
detected_cps = [dates[i] for i in cps_index]
print(detected_cps)
# dates = dat.index[]

with open(out_dir + "changeforest_sbs_nyc_taxi.pkl", "wb") as fp:
    pkl.dump(detected_cps, fp)

