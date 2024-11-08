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
from other_methods.changeforest.change_forest import changeforest_wrapper

out_dir = root_dir + "output/real_data/nyc_taxi/"

with open(root_dir + "data/fhv_nyc/heatmaps_color_numeric.pkl", "rb") as f:
    heatmaps_array = pkl.load(f)

heatmaps_array_vec = heatmaps_array.reshape(heatmaps_array.shape[0], -1)
random.seed(100)



detect_global_multiple = changeforest_wrapper(sample=heatmaps_array_vec, 
                                              tau=0.5, segment_method='sbs')

with open(out_dir + "changeforest_sbs_nyc_taxi.pkl", "wb") as fp:
    pkl.dump(detect_global_multiple, fp)

