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
from other_methods.node.node_multiple import get_multiple_change_point
from misc.misc_heatmaps import get_dates

out_dir = root_dir + "output/real_data/nyc_taxi/"

with open(root_dir + "data/fhv_nyc/heatmaps_color_numeric.pkl", "rb") as f:
    heatmaps_array = pkl.load(f)

heatmaps_array_vec = heatmaps_array.reshape(heatmaps_array.shape[0], -1)
random.seed(100)



taxi_node = get_multiple_change_point(sample=heatmaps_array_vec, 
                                                   no_of_perm=199, min_length=500, 
                                                   decay=np.sqrt(2),
                                                   return_output="all")

with open(out_dir + "node_sbs_nyc_taxi.pkl", "wb") as fp:
    pkl.dump(taxi_node, fp)

files_sorted = get_dates("data/fhv_nyc/daily_heatmaps")
cps = []
for i in range(5):
  print(taxi_node[1][i]['cp'])
  print(taxi_node[1][i]['max_seeded_max_gain'])
  print(taxi_node[1][i]['perm_cutoff'])
  cps.append(taxi_node[1][i]['cp'])
  print(files_sorted(cps[i]))

  # detected cps: [464, 693, 887, 1291, 1425]