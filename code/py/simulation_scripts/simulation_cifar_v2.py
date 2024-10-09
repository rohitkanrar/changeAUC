import numpy as np
import pickle, argparse, sys, random, json
from pathlib import Path
import tensorflow as tf
import random, argparse
from datetime import datetime
sys.path.insert(0, "./code/py")
from get_change_point.get_change_point_v1 import get_change_point

# RUN: python code/py/simulation_scripts/simulation_cifar_v2.py -r 10 -n 1000 -g 35 -c VGG16 -l local -t True -s 1

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--reps", type=int)
parser.add_argument("-n", "--n", type=int)
parser.add_argument("-g", "--dgp", type=int, default=35)
parser.add_argument("-c", "--clf", default="VGG16")
parser.add_argument("-l", "--location", default="hku")
parser.add_argument("-t", "--test", default=False)
parser.add_argument("-s", "--seed", type=int, default=int(np.round(np.random.random() * 1e7)))
args = parser.parse_args()
seed_ = np.arange(args.seed, args.seed + args.reps)
case_ = f"{args.dgp//10}-{args.dgp%10}"  # like "1-7", "1-1"
repl_ = args.reps
n = args.n
if args.test == "True":
    args.test = True
else:
    args.test = False

require_cusum = True

if args.location == 'hku':
    out_dir = "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/"
elif args.location == "pronto":
    out_dir = "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
else:
    out_dir = "output/"

Path(out_dir).mkdir(parents=True, exist_ok=True)

out_dir = out_dir + "cifar/" + case_ + "/" + args.clf.lower() + "/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

ch_pt = np.zeros(args.reps)
ari = np.zeros(args.reps)
max_aucs = np.zeros(args.reps)
max_cusums = np.zeros(args.reps)
pval = np.zeros(args.reps)
pval_cusums = np.zeros(args.reps)
runtime = np.zeros(args.reps)

cifar10 = tf.keras.datasets.cifar10
(x_train, y_train), (x_test, y_test) = cifar10.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0
seq_ = np.arange(x_train.shape[0])

for i in np.arange(repl_):
    random.seed(int(seed_[i]))
    if int(case_[0]) != int(case_[2]):
        ind_1 = (y_train == int(case_[0]))[:, 0]
        ind_2 = (y_train == int(case_[2]))[:, 0]
        i1 = random.sample(list(seq_[ind_1]), int(n/2))
        i2 = random.sample(list(seq_[ind_2]), int(n/2))
    else:
        ind = (y_train == int(case_[0]))[:, 0]
        i12 = random.sample(list(seq_[ind]), n)
        i1 = i12[:int(n/2)]
        i2 = i12[int(n/2):]

    x = x_train[i1 + i2, :, :]
    output = get_change_point(x, classifier=args.clf.upper(),
                              split_trim=0.15,
                              auc_trim=0.05,
                              perm_pval=args.test,
                              no_of_perm=199,
                              tau=0.5, require_cusum=require_cusum
                              )
    if i==0:
        pred_ = output['pred']
        pred = np.zeros((args.reps, len(pred_)))
        pred[i, :] = pred_
        aucs_ = output['auc']
        aucs = np.zeros((args.reps, len(aucs_)))
        aucs[i, :] = aucs_
        if require_cusum:
            cusums_ = output['cusum']
            cusums = np.zeros((args.reps, len(cusums_)))
            cusums[i, :] = cusums_
    else:
        pred[i, :] = output["pred"]
        aucs[i, :] = output["auc"]
        if require_cusum:
            cusums[i, :] = cusums_
    ch_pt[i] = output['ch_pt']
    ari[i] = output['ari']
    max_aucs[i] = output['max_auc']
    if require_cusum:
        max_cusums[i] = output['max_cusum']
    runtime[i] = output['runtime']
    if args.test:
        pval[i] = output['pval']
        if require_cusum:
            pval_cusums[i] = output['pval_cusum']


    filename = f"cifar_{case_}_n_{n}_seed_{int(seed_[i])}.pkl"
    # filename = f"mnist_{case_}_test.pkl"

    with open(out_dir + filename, "wb") as fp:
        pickle.dump(output, fp)

out_dict = {
    "aucs": aucs, "ch_pt": ch_pt, "ari": ari, "max_aucs": max_aucs, "pred": pred,
    "dgp": args.dgp, "reps": args.reps, "n": args.n,
    "clf": args.clf.lower(), "split_trim": 0.15, "auc_trim": 0.05, "perm_pval": args.test,
    "location": args.location, "seed": args.seed, "runtime": runtime
}
if require_cusum:
    out_dict['cusums'] = cusums
    out_dict['max_cusums'] = max_cusums
if args.test:
    out_dict['pval'] = pval
    if require_cusum:
        out_dict['pval_cusum'] = pval_cusums

filename = f"cifar_{case_}_n_{n}_rep_{args.reps}.pkl"
with open(out_dir + filename, "wb") as fp:
    pickle.dump(out_dict, fp)