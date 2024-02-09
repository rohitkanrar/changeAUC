import os
import sys
import pickle as pkl
import numpy as np
from PIL import Image

sys.path.insert(0, "./code/py")
if os.getenv("SLURM_SUBMIT_HOST") == "pronto.las.iastate.edu":
    sys.path.insert(0, "/work/LAS/zhanruic-lab/rohitk/git_repo_data/changeAUC/output")
    sys.path.insert(0, "/work/LAS/zhanruic-lab/rohitk/git_repo_data/changeAUC/data")
elif os.getenv("SLURM_SUBMIT_HOST") == "hpc2021":
    sys.path.insert(0, "./code/py")
    sys.path.insert(0, "/lustre1/u/rohitisu/git_repos_data/changeAUC/output")
    sys.path.insert(0, "/lustre1/u/rohitisu/git_repos_data/changeAUC/data")
else:
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

with open("data/fhv_nyc/heatmaps_color_numeric.pkl", "wb") as fp:
    pkl.dump(heatmaps_array, fp)

