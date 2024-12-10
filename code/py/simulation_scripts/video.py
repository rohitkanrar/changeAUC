import tensorflow as tf
import numpy as np
import random, sys
import pickle as pkl
import matplotlib.pyplot as plt
sys.path.insert(0, "./code/py")
from get_change_point.get_change_point_v1 import get_change_point
from misc.misc_video import get_file_counts, get_file_names, get_img_array

data_dir = "data/monkey_data"
file_counts = get_file_counts(data_dir)
test_file_names = get_file_names(0, 1, file_counts, fps=12, duration=120, dir_path=data_dir)
test_img_array = get_img_array(test_file_names)

output = get_change_point(test_img_array, classifier="vgg16")

with open("output/video/test.pkl", "rb") as f:
    pkl.dump(output, f)