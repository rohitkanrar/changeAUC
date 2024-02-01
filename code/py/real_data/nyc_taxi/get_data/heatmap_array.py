from PIL import Image
import numpy as np
import os, sys
import pickle as pkl
sys.path.insert(0, "./code/py")
sys.path.insert(0, "./output")
sys.path.insert(0, "./data")

heatmap_dir = "data/fhv_nyc/daily_heatmaps"
img_res = 32

img = np.asarray(Image.open(heatmap_dir + '/' + '19-01-01.jpg').resize((img_res, img_res),
                                                               Image.LANCZOS))
heatmaps_array = np.zeros((len(os.listdir(heatmap_dir)), img.shape[0], img.shape[1], img.shape[2]))

for i, file in enumerate(sorted(os.listdir(heatmap_dir))):
    heatmaps_array[i, :, :, :] = np.asarray(Image.open(heatmap_dir + '/' + file).resize((img_res, img_res),
                                                                               Image.LANCZOS)) / 255.0
