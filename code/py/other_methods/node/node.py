import numpy as np
from time import time
import sys
sys.path.insert(0, "./code/py")
from other_methods.node.functions import CPD_NDE
from misc.misc_v1 import get_ari
from generate_data.mean_shift import get_dense_shift_normal_mean

def node_wrapper(sample, tau=0.5):
    n = sample.shape[0]
    st_time = time()
    out = CPD_NDE(Y=sample)
    en_time = time() - st_time
    print("Detection is finished in %s seconds" % en_time)
    max_gain = np.max(out)
    cp = np.argmax(out)
    ari = get_ari(n, int(np.floor(tau * n)), cp)
    
    out_dict = {
        "cp": cp, "max_gain": max_gain, "ari": ari, "runtime": en_time
    }
    return out_dict

# sample = get_dense_shift_normal_mean(delta=2, n=1000, p=10, prop=0.5)
# print(node_wrapper(sample=sample))

