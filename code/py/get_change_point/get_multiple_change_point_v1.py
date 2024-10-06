import sys
import numpy as np
from math import log
sys.path.insert(0, "./code/py")
from get_change_point.get_change_point_v1 import get_change_point


def seeded_intervals(n, decay=np.sqrt(2), unique_int=True, min_length=500):
    n = int(n)
    depth = np.ceil(log(n, decay))
    M = np.sum(np.power(2, np.arange(1, depth + 1)) - 1)
    boundary_mtx = np.array([0, n])
    for i in np.arange(2, depth + 1):
        int_length = int(n * np.power(1 / decay, i - 1))
        if int_length < min_length:
            break
        n_int = int(np.ceil(np.round(n / int_length, 14)) * 2 - 1)
        new_int_left = np.floor(np.linspace(0, n - int_length, n_int))
        new_int_right = np.ceil(np.linspace(int_length, n, n_int))
        new_int = np.column_stack((new_int_left, new_int_right))
        boundary_mtx = np.vstack((boundary_mtx, new_int))
    if unique_int:
        boundary_mtx = np.unique(boundary_mtx, axis=0)
    return boundary_mtx.astype(int)


def get_sbs_cp(sample, classifier="FNN",
               split_trim=0.15,
               auc_trim=0.05,
               no_of_perm=199,
               min_length=500, decay=np.sqrt(2)):
    n = sample.shape[0]
    seeded_intv = seeded_intervals(n, decay, True, min_length)
    sbs_output = []
    seeded_auc = np.zeros(seeded_intv.shape[0])
    seeded_cp = np.zeros(seeded_intv.shape[0])
    print(seeded_intv)
    for i in np.arange(seeded_intv.shape[0]):
        if len(seeded_intv.shape) == 2:
            intv = seeded_intv[i, :]
        else:
            intv = seeded_intv
        print(intv)
        output = {}
        out_ = get_change_point(sample=sample[np.arange(intv[0], intv[1])], classifier=classifier,
                                split_trim=split_trim, auc_trim=auc_trim, perm_pval=False)
        output['output'] = out_
        output['interval'] = intv
        seeded_auc[i] = out_['max_auc']
        seeded_cp[i] = out_['ch_pt']
        sbs_output.append(output)
    if len(seeded_intv.shape) == 1:
        intv = seeded_intv
    else:
        intv = seeded_intv[np.argmax(seeded_auc), :]
    out_dict = {'output': sbs_output, 'max_seeded_auc': np.max(seeded_auc),
                'seeded_cp': int(seeded_cp[np.argmax(seeded_auc)]),
                'seeded_interval': intv}
    return out_dict


def get_perm_cutoff(sample, classifier="FNN",
                    split_trim=0.15,
                    auc_trim=0.05,
                    no_of_perm=199):
    n = sample.shape[0]
    aucs = np.zeros(no_of_perm)
    for i in np.arange(no_of_perm):
        ind = np.random.permutation(np.arange(n))
        tmp = get_change_point(sample=sample[ind], classifier=classifier,
                               split_trim=split_trim, auc_trim=auc_trim, perm_pval=False)
        aucs[i] = tmp['max_auc']
    return np.quantile(aucs, 0.9)


def get_multiple_cp(sample, left, right, classifier="FNN", split_trim=0.15, auc_trim=0.05,
                    no_of_perm=199, min_length=500, decay=np.sqrt(2), return_output="all"):
    global multiple_cp, multiple_output
    print("------- Detecting CP between", left, right, "--------")
    if (right - left) >= min_length:
        cutoff = get_perm_cutoff(sample=sample, classifier=classifier, split_trim=split_trim, auc_trim=auc_trim,
                                 no_of_perm=no_of_perm)
        print("-------- Permutation Ended and SBS is started. ------------")
        out_ = get_sbs_cp(sample[left:(right + 1)], classifier=classifier,
                          split_trim=split_trim, auc_trim=auc_trim,
                          no_of_perm=no_of_perm, min_length=min_length, decay=decay)
        max_seeded_auc = out_['max_seeded_auc']
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
                         'max_seeded_auc': max_seeded_auc,
                         'perm_cutoff': cutoff,
                         'output': out_}
            multiple_output.append(temp_dict)

        if max_seeded_auc > cutoff:
            if return_output == "significant":
                temp_dict = {'interval': np.array([left, right]),
                             'seeded_interval': seeded_intv,
                             'seeded_cp': seeded_cp,
                             'cp': cp_,
                             'max_seeded_auc': max_seeded_auc,
                             'perm_cutoff': cutoff,
                             'output': out_}
                multiple_output.append(temp_dict)

            if (cp_ - left) >= min_length:
                cp1_ = get_multiple_cp(sample, left=left, right=cp_, classifier=classifier, split_trim=split_trim,
                                       auc_trim=auc_trim, no_of_perm=no_of_perm, min_length=min_length,
                                       decay=decay, return_output=return_output)
                multiple_cp = np.concatenate((multiple_cp, cp1_), axis=0)

            if (right - cp_) >= min_length:
                cp2_ = get_multiple_cp(sample, left=(cp_ + 1), right=right, classifier=classifier,
                                       split_trim=split_trim, auc_trim=auc_trim, no_of_perm=no_of_perm,
                                       min_length=min_length, decay=decay, return_output=return_output)
                multiple_cp = np.concatenate((multiple_cp, cp2_), axis=0)
            return multiple_cp
        return np.array([[left, right]])
    return np.array([[left, right]])


def get_multiple_change_point(sample, classifier="FNN", split_trim=0.15, auc_trim=0.05,
                              no_of_perm=199, min_length=500, decay=np.sqrt(2), return_output="all"):
    global multiple_cp, multiple_output
    multiple_cp = np.array([[0, 0]])
    multiple_output = []

    cp_ = get_multiple_cp(sample=sample, left=0, right=sample.shape[0], classifier=classifier,
                          split_trim=split_trim, auc_trim=auc_trim, no_of_perm=no_of_perm, min_length=min_length,
                          decay=decay, return_output=return_output)
    return np.unique(multiple_cp, axis=0)[1:, :], multiple_output
