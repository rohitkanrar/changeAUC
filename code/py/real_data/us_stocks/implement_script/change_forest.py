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
from changeforest import changeforest, Control


dat = pd.read_csv("data/us_stocks/stable_stocks.csv",
                  dtype=float, index_col=0, parse_dates=True)

random.seed(100)
stock_multiple = changeforest(dat.values, "random_forest", "sbs",
                              Control(minimal_relative_segment_length=0.15))

dates = dat.index[stock_multiple.split_points()]

out_dir = 'output/real_data/us_stocks/'
with open(out_dir + 'changeforest_sbs_us_stocks.pkl', "wb") as fp:
    pkl.dump(dates, fp)

print(stock_multiple)