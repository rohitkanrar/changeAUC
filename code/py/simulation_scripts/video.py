import tensorflow as tf
import numpy as np
import random, sys, h5py
import pickle as pkl
import matplotlib.pyplot as plt
sys.path.insert(0, "./code/py")
from get_change_point.get_change_point_v1 import get_change_point
from misc.misc_video import get_file_counts, get_file_names, get_img_array
from other_methods.changeforest.change_forest import changeforest_wrapper 

data_dir = "data/monkey_data"
file_counts = get_file_counts(data_dir)
test_file_names = get_file_names(0, 1, file_counts, fps=12, duration=120, dir_path=data_dir)
test_img_array = get_img_array(test_file_names)

# with h5py.File("output/video/test_data.h5", "w") as f:
#     f.create_dataset("array", data=test_img_array, compression='gzip')

# output = get_change_point(test_img_array, classifier="vgg16")

# with open("output/video/test.pkl", "wb") as f:
#     pkl.dump(output, f)

output = changeforest_wrapper(test_img_array.reshape(test_img_array.shape[0], -1).astype(np.float64), tau=0.5)
with open("output/video/test_cf.pkl", "wb") as f:
    pkl.dump(output, f)