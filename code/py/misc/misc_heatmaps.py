import pickle as pkl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
import sys, os
from datetime import datetime

sys.path.insert(0, "./output")
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
trip_max = np.quantile(trip_counts, 0.8)
# print(trip_min, trip_median, trip_max)
# print(np.quantile(trip_counts, [0.8, 0.90, 0.95, 0.99]))


def generate_daily_heatmaps_from_df(df, map, save_dir, plot_axis=False, plot_legend=False):
    divnorm = colors.TwoSlopeNorm(vmin=trip_min, vcenter=trip_median, vmax=trip_max)
    for i in df['year_month_day'].unique():
        one_day = df[df['year_month_day'] == i]
        if plot_legend:
            ax = map.merge(one_day, how='left', left_on='LocationID', right_on='DOlocationID').fillna(0).plot(
                column='trip',
                legend=True,
                #cmap='Greys',
                norm=divnorm)
        else:
            ax = map.merge(one_day, how='left', left_on='LocationID', right_on='DOlocationID').fillna(0).plot(
                column='trip',
                #cmap='Greys',
                norm=divnorm)
        if not plot_axis:
            plt.axis('off')
        ax.figure.savefig(save_dir + '/' + i + '.jpg', format='jpg',
                              bbox_inches='tight', pad_inches=0)

        plt.close()


def get_dates(dir_path):
    files = [f for f in os.listdir(dir_path) if f.endswith(".jpg")]
    files_sorted = sorted(files, key=lambda x: datetime.strptime(x[:8], "%y-%m-%d"))

    return files_sorted