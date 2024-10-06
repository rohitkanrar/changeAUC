import pyarrow.parquet as pq
import pandas as pd
import sys, os
import numpy as np
import pickle as pkl
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
from misc.misc_v1 import generate_df_from_record

trip_counts = np.zeros(1)

for file_ in os.listdir('data/fhv_nyc/raw_records'):
    print(file_)
    df = pq.read_table("data/fhv_nyc/raw_records/" + file_)
    dat = pd.DataFrame()
    dat['DOlocationID'] = df['DOlocationID'].to_pandas()
    dat['pickup_datetime'] = df['pickup_datetime'].to_pandas()
    del df

    df = generate_df_from_record(dat)
    trip_counts = np.concatenate((trip_counts, df['trip'].values), axis=0)

trip_counts = trip_counts[1:]

with open("output/real_data/nyc_taxi/trip_counts.pkl", "wb") as fp:
    pkl.dump(trip_counts, fp)

trip_min = int(np.min(trip_counts))
trip_median = int(np.median(trip_counts))

print(trip_min, trip_median)
