import pyarrow.parquet as pq
import pandas as pd
import sys, os
import geopandas as gpd
sys.path.insert(0, "./code/py")
sys.path.insert(0, "./data")
from misc.misc_v1 import generate_df_from_record
from misc.misc_v1 import generate_daily_heatmaps_from_df


nyc_map = gpd.read_file("data/fhv_nyc/taxi_zones.zip")

for file_ in os.listdir('data/fhv_nyc/raw_records'):
    print(file_)
    df = pq.read_table("data/fhv_nyc/raw_records/" + file_)
    dat = pd.DataFrame()
    dat['DOlocationID'] = df['DOlocationID'].to_pandas()
    dat['pickup_datetime'] = df['pickup_datetime'].to_pandas()
    del df
    df = generate_df_from_record(dat)
    generate_daily_heatmaps_from_df(df, nyc_map, "data/fhv_nyc/daily_heatmaps")
