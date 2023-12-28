import numpy as np
from sklearn.metrics.cluster import adjusted_rand_score as ari


def get_ari(n, true_ch_pt, ch_pt):
    truth = np.concatenate((np.zeros(true_ch_pt), np.ones((n - true_ch_pt))), axis=0)
    estimated = np.concatenate((np.zeros(ch_pt), np.ones((n - ch_pt))), axis=0)

    return ari(truth, estimated)