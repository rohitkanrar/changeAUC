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


def generate_df_from_record(dat):
    dat = dat[~dat['DOlocationID'].isna()]
    dat['year_month_day'] = dat['pickup_datetime'].dt.strftime("%y-%m-%d")
    del dat['pickup_datetime']
    dat['trip'] = 1
    dat['DOlocationID'] = dat['DOlocationID'].astype(int)
    dat_agg = dat.groupby(['year_month_day', 'DOlocationID']).agg({'trip': 'sum'})
    del dat
    dat_agg.reset_index(inplace=True)
    return dat_agg


with open("output/real_data/nyc_taxi/trip_counts.pkl", "rb") as fp:
    trip_counts = pkl.load(fp)
trip_min = int(np.min(trip_counts))
trip_median = int(np.median(trip_counts))


def generate_daily_heatmaps_from_df(df, map, save_dir):
    divnorm = colors.TwoSlopeNorm(vmin=trip_min, vcenter=trip_median)
    for i in df['year_month_day'].unique():
        one_day = df[df['year_month_day'] == i]
        ax = map.merge(one_day, how='left', left_on='LocationID', right_on='DOlocationID').fillna(0).plot(column='trip',
                                                                                                          cmap='Greys',
                                                                                                          norm=divnorm)
        plt.axis('off')
        ax.figure.savefig(save_dir + '/' + i + '.jpg', format='jpg',
                          bbox_inches='tight', pad_inches=0)
        plt.close()


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
