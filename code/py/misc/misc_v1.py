import numpy as np
from sklearn.metrics.cluster import adjusted_rand_score as ari
import sys, os

sys.path.insert(0, "./output")
sys.path.insert(0, "./data")
sys.path.insert(0, "./output")


def get_ari(n, true_ch_pt, ch_pt):
    truth = np.concatenate((np.zeros(true_ch_pt), np.ones((n - true_ch_pt))), axis=0)
    estimated = np.concatenate((np.zeros(ch_pt), np.ones((n - ch_pt))), axis=0)

    return ari(truth, estimated)

def get_cusum_k(pred, k, nte):
    cusum = np.sum(pred[(k):(nte)]) / (nte - k) - np.sum(pred[0:(k)]) / k
    cusum = cusum * np.sqrt(k * (nte - k) / nte)
    
    return cusum

def get_cusum(pred, n=1000, auc_trim=0.05):
    nte = len(pred)
    start_ = int(np.floor(auc_trim * n))
    end_ = nte - int(np.floor(auc_trim * n))
    cusums = np.zeros(nte - 2 * start_)
    
    for i, k in enumerate(range(start_, end_)):
        cusums[i] = get_cusum_k(pred, k, nte)
    
    return cusums