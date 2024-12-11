import numpy as np
from time import time
from sklearn import metrics
import sys
sys.path.insert(0, "./code/py")
from get_change_point.get_fnn import get_fnn_model
from get_change_point.get_cnn import get_vgg16_model, get_vgg19_model
from misc.misc_v1 import get_ari
from misc.misc_v1 import get_cusum


def get_trained_clf(sample_, n, p, classifier="FNN", split_trim=0.15, n_layers_dense=128):
    k = int(np.floor(n * split_trim))
    tr_ind = np.concatenate((np.arange(k), np.arange((n - k), n)), axis=0)
    x_train = sample_[tr_ind]
    y_train = np.concatenate((np.zeros(k), np.ones(k)), axis=0)
    x_test = sample_[np.arange(k, n-k)]

    if classifier.upper() == "FNN":
        model = get_fnn_model(p)
    elif classifier.upper() == "VGG16":
        model = get_vgg16_model(shape=p, n_layers_dense=n_layers_dense)
    elif classifier.upper() == "VGG19":
        model = get_vgg19_model(shape=p, n_layers_dense=n_layers_dense)
    elif classifier.upper() == "VGG16_BW":
        model = get_vgg16_model(shape=p, n_layers_dense=n_layers_dense)
    else:
        pass
    model.fit(x_train, y_train, epochs=32, batch_size=32, verbose=0)
    pred = model.predict(x_test)[:, 0]

    return pred


def get_change_point(sample, classifier="FNN",
                     split_trim=0.15,
                     auc_trim=0.05,
                     perm_pval=False,
                     no_of_perm=199,
                     tau=0.5, require_cusum=False, 
                     n_layers_dense=128):
    st_time = time()
    if len(sample.shape) > 2:
        n = sample.shape[0]
        p = sample.shape[1:]
    else:
        n, p = sample.shape
    k = int(np.floor(n * split_trim))
    x_test = sample[np.arange(k, n-k)]
    nte = x_test.shape[0]
    start_ = int(np.floor(auc_trim * n))
    end_ = nte - int(np.floor(auc_trim * n))
    auc_ = np.zeros(nte - 2 * start_)
    pred = get_trained_clf(sample, n, p, classifier, split_trim, n_layers_dense=n_layers_dense)

    for i, j in enumerate(np.arange(start_, end_)):
        y_test_ = np.concatenate((np.zeros(j), np.ones(nte - j)), axis=0)
        auc_[i] = metrics.roc_auc_score(y_test_, pred)
    if require_cusum:
        cusum_ = get_cusum(pred=pred, n=n, auc_trim=auc_trim)

    ch_pt_ = k + start_ + np.argmax(auc_)
    max_auc_ = np.max(auc_)
    if require_cusum:
        max_cusum_ = np.max(cusum_)
    ari_ = get_ari(n, int(np.floor(tau * n)), ch_pt_)
    en_time = time() - st_time
    print("Detection is finished in %s seconds" % en_time)
    out_dict = {
        "auc": auc_, "max_auc": max_auc_, "ch_pt": ch_pt_, "ari": ari_, "pred": pred
    }
    if require_cusum:
        out_dict["cusum"] = cusum_
        out_dict["max_cusum"] = max_cusum_
    if perm_pval:
        st_time_perm = time()
        print("Permutation is started...")
        null_auc_mat = np.zeros((len(auc_), no_of_perm))
        null_cusum_mat = np.zeros((len(auc_), no_of_perm))
        for b in np.arange(no_of_perm):
            perm_ind_ = np.random.permutation(np.arange(nte))
            for i, j in enumerate(np.arange(start_, end_)):
                y_test_ = np.concatenate((np.zeros(j), np.ones(nte - j)), axis=0)
                null_auc_mat[i, b] = metrics.roc_auc_score(y_test_, pred[perm_ind_])
            if require_cusum:
                null_cusum_mat[:, b] = get_cusum(pred=pred[perm_ind_], n=n, auc_trim=auc_trim)
        null_auc_max = null_auc_mat.max(axis=0)
        null_cusum_max = null_cusum_mat.max(axis=0)
        pval_ = (sum(null_auc_max >= max_auc_) + 1) / (no_of_perm + 1)
        if require_cusum:
            pval_cusum_ = (sum(null_cusum_max >= max_cusum_) + 1) / (no_of_perm + 1)
        en_time = time() - st_time
        print("Permutation is finished in %s seconds" % en_time)
        print("Change point is detected at", ch_pt_, "with p-value", pval_)
        out_dict['pval'] = pval_
        if require_cusum:
            out_dict['pval_cusum'] = pval_cusum_
    else:
        print("Change point is detected at", ch_pt_)
    print("Total time taken: %s seconds" % en_time)
    out_dict['runtime'] = en_time
    return out_dict
