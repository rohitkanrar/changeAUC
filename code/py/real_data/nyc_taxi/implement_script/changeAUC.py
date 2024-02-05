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
from get_change_point.get_multiple_change_point_v1 import get_multiple_change_point
from get_change_point.get_change_point_v1 import get_change_point

out_dir = root_dir + "output/real_data/nyc_taxi/"

with open(root_dir + "data/fhv_nyc/heatmaps_numeric.pkl", "rb") as f:
    heatmaps_array = pkl.load(f)

random.seed(100)

# date_list = sorted(os.listdir(heatmap_dir))
# oct_start = date_list.index("22-10-01-00.jpg")
# nov_start = date_list.index("22-11-01-00.jpg")
# dec_start = date_list.index("22-12-01-00.jpg")
# jan_start = date_list.index("23-01-01-00.jpg")
# jan_end = date_list.index("23-01-31-23.jpg")

detect_global_multiple = get_multiple_change_point(heatmaps_array[365:1461], classifier="VGG16", split_trim=0.15, auc_trim=0.05,
                                                   no_of_perm=199, min_length=500, decay=np.sqrt(2),
                                                   return_output="all")

with open(out_dir + "vgg16_sbs_nyc_taxi_short.pkl", "wb") as fp:
    pkl.dump(detect_global_multiple, fp)


# print(get_change_point(heatmaps_array, classifier='VGG16'))
