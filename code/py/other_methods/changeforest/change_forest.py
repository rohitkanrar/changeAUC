import numpy as np
from time import time
from changeforest import changeforest
import sys
sys.path.insert(0, "./code/py")
from misc.misc_v1 import get_ari
from generate_data.mean_shift import get_dense_shift_normal_mean

def changeforest_wrapper(sample, tau=0.5):
    n = sample.shape[0]
    st_time = time()
    out = changeforest(sample, "random_forest", "bs")
    en_time = time() - st_time
    print("Detection is finished in %s seconds" % en_time)
    cp = out.best_split
    max_gain = out.max_gain
    pval = out.p_value
    if pval <= 0.05:
        ari = get_ari(n, int(np.floor(tau * n)), cp)
    else:
        ari = 0

    out_dict = {
        "cp": cp, "max_gain": max_gain, "pval": pval, "ari": ari, "runtime": en_time
    }
    return out_dict

sample = get_dense_shift_normal_mean(delta=2, n=1000, p=100, prop=0.5)
print(changeforest_wrapper(sample=sample))