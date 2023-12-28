import numpy as np
from time import time
from sklearn import metrics
import sys
sys.path.insert(0, "./code/py")
from get_change_point.get_fnn import get_fnn_model
from misc.misc_v1 import get_ari


def get_trained_clf(sample_, n, p, classifier="FNN", split_trim=0.15):
    k = int(np.floor(n * split_trim))
    tr_ind = np.concatenate((np.arange(k), np.arange((n - k), n)), axis=0)
    x_train = sample_[tr_ind]
    y_train = np.concatenate((np.zeros(k), np.ones(k)), axis=0)
    x_test = sample_[np.arange(k, n-k)]

    # if classifier.upper() == "FNN":
    model = get_fnn_model(p)
    model.fit(x_train, y_train, epochs=32, batch_size=32, verbose=0)
    pred = model.predict(x_test)[:, 0]

    return pred, model


def get_change_point(sample, classifier="FNN",
                     split_trim=0.15,
                     auc_trim=0.05,
                     perm_pval=False,
                     no_of_perm=199,
                     tau=0.5):
    st_time = time()
    if classifier.upper() == "CNN":
        n = sample.shape[0]
        p = sample.shape[1:2]
    else:
        n, p = sample.shape
    k = int(np.floor(n * split_trim))
    x_test = sample[np.arange(k, n-k)]
    nte = x_test.shape[0]
    start_ = int(np.floor(auc_trim * n))
    end_ = nte - int(np.floor(auc_trim * n))
    auc_ = np.zeros(nte - 2 * start_)
    pred, model = get_trained_clf(sample, n, p, classifier, split_trim)

    for i, j in enumerate(np.arange(start_, end_)):
        y_test_ = np.concatenate((np.zeros(j), np.ones(nte - j)), axis=0)
        auc_[i] = metrics.roc_auc_score(y_test_, pred)

    ch_pt_ = k + start_ + np.argmax(auc_)
    max_auc_ = np.max(auc_)
    ari_ = get_ari(n, int(np.floor(tau * n)), ch_pt_)
    print("Detection is finished in %s seconds" % (time() - st_time))
    out_dict = {
        "auc": auc_, "max_auc": max_auc_, "ch_pt": ch_pt_, "ari": ari_, "pred": pred
    }
    if perm_pval:
        st_time_perm = time()
        print("Permutation is started...")
        null_auc_mat = np.zeros((nte, no_of_perm))
        for b in np.arange(no_of_perm):
            perm_ind_ = np.random.permutation(np.arange(nte))
            for j in np.arange(start_, end_):
                y_test_ = np.concatenate((np.zeros(j), np.ones(nte - j)), axis=0)
                null_auc_mat[j, b] = metrics.roc_auc_score(y_test_, pred[perm_ind_])
        null_auc_max = null_auc_mat.max(axis=0)
        pval_ = (sum(null_auc_max >= max_auc_) + 1) / (no_of_perm + 1)
        print("Permutation is finished in %s seconds" % (time() - st_time_perm))
        print("Change point is detected at", ch_pt_, "with p-value", pval_)
        out_dict['pval'] = pval_
    else:
        print("Change point is detected at", ch_pt_)
    print("Total time taken: %s seconds" % (time() - st_time))
    return out_dict


# n = 500
# p = 10
# mu1 = np.zeros(p)
# mu2 = np.ones(p)
#
# sigma = np.diag(np.ones(p))
# s1 = np.random.multivariate_normal(mu1, sigma, n)
# s2 = np.random.multivariate_normal(mu2, sigma, n)
# sample = np.concatenate((s1, s2), axis=0)
# a = get_change_point(sample, perm_pval=True)
