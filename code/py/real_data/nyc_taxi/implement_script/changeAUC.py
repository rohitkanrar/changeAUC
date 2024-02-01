import os
import pickle as pkl
import random
import sys
import numpy as np
sys.path.insert(0, "./code/py")
sys.path.insert(0, "./output")
sys.path.insert(0, "./data")
from get_change_point.get_multiple_change_point_v1 import get_multiple_change_point
from real_data.nyc_taxi.get_data.heatmap_array import heatmaps_array

out_dir = "output/real_data/nyc_taxi/"

random.seed(100)

# date_list = sorted(os.listdir(heatmap_dir))
# oct_start = date_list.index("22-10-01-00.jpg")
# nov_start = date_list.index("22-11-01-00.jpg")
# dec_start = date_list.index("22-12-01-00.jpg")
# jan_start = date_list.index("23-01-01-00.jpg")
# jan_end = date_list.index("23-01-31-23.jpg")

detect_global_multiple = get_multiple_change_point(heatmaps_array, classifier="VGG16", split_trim=0.15, auc_trim=0.05,
                                                   no_of_perm=199, min_length=500, decay=np.sqrt(2),
                                                   return_output="all")

with open(out_dir + "vgg16_sbs_nyc_taxi.pkl", "wb") as fp:
    pkl.dump(detect_global_multiple, fp)
