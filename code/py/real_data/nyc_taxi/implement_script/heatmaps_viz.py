import pyarrow.parquet as pq
import pandas as pd
from matplotlib import colors
import matplotlib.pyplot as plt
import sys, os
import pickle as pkl
import numpy as np
import geopandas as gpd

sys.path.insert(0, "./code/py")
sys.path.insert(0, "./data")
sys.path.insert(0, "./output")

from misc.misc_heatmaps import generate_df_from_record, generate_daily_heatmaps_from_df

nyc_map = gpd.read_file("data/fhv_nyc/taxi_zones.zip")

file_list = ["fhv_tripdata_2019-01.parquet", "fhv_tripdata_2019-02.parquet", "fhv_tripdata_2019-08.parquet",
             "fhv_tripdata_2019-09.parquet", "fhv_tripdata_2020-03.parquet", "fhv_tripdata_2020-04.parquet"]

for file_ in file_list:
    print(file_)
    df = pq.read_table("data/fhv_nyc/raw_records/" + file_)
    dat = pd.DataFrame()
    dat['DOlocationID'] = df['DOlocationID'].to_pandas()
    dat['pickup_datetime'] = df['pickup_datetime'].to_pandas()
    del df
    df = generate_df_from_record(dat)
    print("hi")
    generate_daily_heatmaps_from_df(df, nyc_map, "data/fhv_nyc/daily_heatmaps_with_legend",
                                    plot_axis=True, plot_legend=True)
