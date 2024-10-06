import sys, random
import pandas as pd
import pickle as pkl
import os
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
from get_change_point.get_multiple_change_point_v1 import get_multiple_change_point, get_sbs_cp


dat = pd.read_csv("data/us_stocks/stable_stocks.csv",
                  dtype=float, index_col=0, parse_dates=True)

random.seed(100)
stock_multiple = get_multiple_change_point(dat.values, classifier="FNN", no_of_perm=199, min_length=500)

out_dir = 'output/real_data/us_stocks/'
with open(out_dir + 'fnn_sbs_us_stocks.pkl', "wb") as fp:
    pkl.dump(stock_multiple, fp)