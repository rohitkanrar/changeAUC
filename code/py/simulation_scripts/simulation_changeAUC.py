import numpy as np
import pickle, argparse, sys, random
from pathlib import Path

sys.path.insert(0, "./code/py")
from generate_data.mean_shift import get_dense_shift_normal_mean, get_sparse_shift_normal_mean
from generate_data.cov_shift import get_dense_shift_normal_cov, get_sparse_shift_normal_cov, \
    get_dense_diag_shift_normal_cov, get_sparse_diag_shift_normal_cov
from generate_data.moment_shift import get_dense_shift_normal_moment, get_sparse_shift_normal_moment
from get_change_point.get_change_point_v1 import get_change_point

# RUN: python -m simulation_scripts.simulation_changeAUC -d 1 -n 1000 -p 100 -r 100 -g sparse_mean
# python code/py/simulation_scripts/simulation_changeAUC.py -d 1 -n 1000 -p 100 -r 100 -g sparse_mean -l local

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--delta", type=float)
parser.add_argument("-n", "--n", type=int)
parser.add_argument("-p", "--p", type=int)
parser.add_argument("-r", "--reps", type=int)
parser.add_argument("-g", "--dgp")
parser.add_argument("-c", "--clf", default="FNN")
parser.add_argument("-e", "--epsilon", type=float, default=0.15)
parser.add_argument("-a", "--eta", type=float, default=0.05)
parser.add_argument("-t", "--test", type=bool, default=False)
parser.add_argument("-l", "--location", default="hku")
parser.add_argument("-s", "--seed", type=int, default=int(np.round(np.random.random() * 1e7)))
args = parser.parse_args()
seed_ = np.arange(args.seed, args.seed + args.reps)
if args.location == 'hku':
    out_dir = "/lustre1/u/rohitisu/git_repos_data/changeAUC/output/"
elif args.location == "pronto":
    out_dir = "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
else:
    out_dir = "output/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

if args.delta == 0:
    out_dir = out_dir + args.dgp.lower() + "/" + args.clf.lower() + "/" + "null/"
else:
    out_dir = out_dir + args.dgp.lower() + "/" + args.clf.lower() + "/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

aucs = np.zeros(args.reps)
ch_pt = np.zeros(args.reps)
ari = np.zeros(args.reps)
max_aucs = np.zeros(args.reps)
pval = np.zeros(args.reps)

for m in np.arange(args.reps):
    random.seed(seed_[m])
    if args.dgp.lower() == "dense_mean":
        s_ = get_dense_shift_normal_mean(args.delta, args.n, args.p)
    elif args.dgp.lower() == "sparse_mean":
        s_ = get_sparse_shift_normal_mean(args.delta, args.n, args.p)
    elif args.dgp.lower() == "dense_cov":
        s_ = get_dense_shift_normal_cov(args.delta, args.n, args.p)
    elif args.dgp.lower() == "sparse_cov":
        s_ = get_sparse_shift_normal_cov(args.delta, args.n, args.p)
    elif args.dgp.lower() == "dense_diag_cov":
        s_ = get_dense_diag_shift_normal_cov(args.delta, args.n, args.p)
    elif args.dgp.lower() == "sparse_diag_cov":
        s_ = get_sparse_diag_shift_normal_cov(args.delta, args.n, args.p)
    elif args.dgp.lower() == "dense_moment":
        s_ = get_dense_shift_normal_moment(args.n, args.p)
    elif args.dgp.lower() == "sparse_moment":
        s_ = get_sparse_shift_normal_moment(args.n, args.p)
    else:
        print("Invalid Data Generating Process (DGP).")
        sys.exit(0)
    out_ = get_change_point(sample=s_, classifier=args.clf, split_trim=args.epsilon, auc_trim=args.eta,
                            perm_pval=args.test, no_of_perm=199, tau=0.5)
    if m == 0:
        pred_ = out_['pred']
        pred = np.zeros((args.reps, len(pred_)))
        pred[m, :] = pred_
        aucs_ = out_['auc']
        aucs = np.zeros((args.reps, len(aucs_)))
        aucs[m, :] = aucs_
    else:
        pred[m, :] = out_['pred']
        aucs[m, :] = out_['auc']
    ch_pt[m] = out_['ch_pt']
    ari[m] = out_['ari']
    max_aucs[m] = out_['max_auc']
    if args.test:
        pval[m] = out_['pval']
        print(f"---- Change Point for {m+1} iteration with {args.dgp} signal, {args.delta} is {out_['ch_pt']}, and "
              f"pvalue {args.pval}. ----")
    else:
        print(f"---- Change Point for {m + 1} iteration with {args.dgp} signal, {args.delta} is {out_['ch_pt']}, with "
              f"maximum AUC {out_['max_auc']}. ----")

out_dict = {
    "aucs": aucs, "ch_pt": ch_pt, "ari": ari, "max_aucs": max_aucs, "pred": pred,
    "dgp": args.dgp.lower(), "reps": args.reps, "p": args.p, "delta": args.delta, "n": args.n,
    "clf": args.clf.lower(), "split_tril": args.epsilon, "auc_trim": args.eta, "prem_pval": args.test,
    "location": args.location, "seed": args.seed
}
if args.test:
    out_dict['pval'] = pval

file_name = f"p_{args.p}_n_{int(args.n)}_ep_{args.epsilon}_et_{args.eta}.pkl"

with open(out_dir + file_name, "wb") as fp:
    pickle.dump(out_dict, fp)
