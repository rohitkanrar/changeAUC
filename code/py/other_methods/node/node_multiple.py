import sys
import numpy as np
from math import log
sys.path.insert(0, "./code/py")
from get_change_point.get_multiple_change_point_v1 import seeded_intervals
from other_methods.node.node import node_wrapper

def get_sbs_cp(sample, min_length=500, decay=np.sqrt(2)):
    n = sample.shape[0]
    seeded_intv = seeded_intervals(n, decay, True, min_length)
    sbs_output = []
    seeded_max_gain = np.zeros(seeded_intv.shape[0])
    seeded_cp = np.zeros(seeded_intv.shape[0])
    print(seeded_intv)
    for i in np.arange(seeded_intv.shape[0]):
        if len(seeded_intv.shape) == 2:
            intv = seeded_intv[i, :]
        else:
            intv = seeded_intv
        print(intv)
        output = {}
        out_ = node_wrapper(sample=sample[np.arange(intv[0], intv[1])])
        output['output'] = out_
        output['interval'] = intv
        seeded_max_gain[i] = out_['max_gain']
        seeded_cp[i] = out_['cp']
        sbs_output.append(output)
    if len(seeded_intv.shape) == 1:
        intv = seeded_intv
    else:
        intv = seeded_intv[np.argmax(seeded_max_gain), :]
    out_dict = {'output': sbs_output, 'max_seeded_max_gain': np.max(seeded_max_gain),
                'seeded_cp': int(seeded_cp[np.argmax(seeded_max_gain)]),
                'seeded_interval': intv}
    return out_dict


def get_perm_cutoff(sample, no_of_perm=199):
    n = sample.shape[0]
    aucs = np.zeros(no_of_perm)
    for i in np.arange(no_of_perm):
        ind = np.random.permutation(np.arange(n))
        tmp = node_wrapper(sample=sample[ind])
        aucs[i] = tmp['max_gain']
    return np.quantile(aucs, 0.9)


def get_multiple_cp(sample, left, right, no_of_perm=199, min_length=500, 
                    decay=np.sqrt(2), return_output="all"):
    global multiple_cp, multiple_output
    print("------- Detecting CP between", left, right, "--------")
    if (right - left) >= min_length:
        cutoff = get_perm_cutoff(sample=sample, no_of_perm=no_of_perm)
        print("-------- Permutation Ended and SBS is started. ------------")
        out_ = get_sbs_cp(sample[left:(right + 1)], min_length=min_length, decay=decay)
        max_seeded_max_gain = out_['max_seeded_max_gain']
        seeded_cp = out_['seeded_cp']
        seeded_intv = out_['seeded_interval']
        out_ = out_['output']

        if left == 1:
            cp_ = seeded_cp + seeded_intv[0]
        else:
            cp_ = left + seeded_cp + seeded_intv[0]

        if return_output == "all":
            temp_dict = {'interval': np.array([left, right]),
                         'seeded_interval': seeded_intv,
                         'seeded_cp': seeded_cp,
                         'cp': cp_,
                         'max_seeded_max_gain': max_seeded_max_gain,
                         'perm_cutoff': cutoff,
                         'output': out_}
            multiple_output.append(temp_dict)

        if max_seeded_max_gain > cutoff:
            if return_output == "significant":
                temp_dict = {'interval': np.array([left, right]),
                             'seeded_interval': seeded_intv,
                             'seeded_cp': seeded_cp,
                             'cp': cp_,
                             'max_seeded_max_gain': max_seeded_max_gain,
                             'perm_cutoff': cutoff,
                             'output': out_}
                multiple_output.append(temp_dict)

            if (cp_ - left) >= min_length:
                cp1_ = get_multiple_cp(sample, left=left, right=cp_, no_of_perm=no_of_perm, 
                                       min_length=min_length, decay=decay, 
                                       return_output=return_output)
                multiple_cp = np.concatenate((multiple_cp, cp1_), axis=0)

            if (right - cp_) >= min_length:
                cp2_ = get_multiple_cp(sample, left=(cp_ + 1), right=right, no_of_perm=no_of_perm,
                                       min_length=min_length, decay=decay, return_output=return_output)
                multiple_cp = np.concatenate((multiple_cp, cp2_), axis=0)
            return multiple_cp
        return np.array([[left, right]])
    return np.array([[left, right]])


def get_multiple_change_point(sample, no_of_perm=199, min_length=500, decay=np.sqrt(2), 
                              return_output="all"):
    global multiple_cp, multiple_output
    multiple_cp = np.array([[0, 0]])
    multiple_output = []

    cp_ = get_multiple_cp(sample=sample, left=0, right=sample.shape[0], 
                          no_of_perm=no_of_perm, min_length=min_length,
                          decay=decay, return_output=return_output)
    return np.unique(multiple_cp, axis=0)[1:, :], multiple_output