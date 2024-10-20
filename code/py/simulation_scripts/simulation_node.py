import numpy as np
import pickle, argparse, sys, random, json
from pathlib import Path
sys.path.insert(0, "./code/py")
from generate_data.mean_shift import get_dense_shift_normal_mean, get_sparse_shift_normal_mean, get_normal_mean
from generate_data.cov_shift import get_dense_shift_normal_cov, get_sparse_shift_normal_cov, \
    get_dense_diag_shift_normal_cov, get_sparse_diag_shift_normal_cov, get_dense_normal_cov, get_sparse_normal_cov
from generate_data.moment_shift import get_dense_shift_normal_moment, get_sparse_shift_normal_moment, get_exponential
from other_methods.node.node import node_wrapper

# RUN: python code/py/simulation_scripts/simulation_node.py -d 1 -n 1000 -p 100 -r 100 -g sparse_mean -l local -s 2024

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--delta", type=float)
parser.add_argument("-n", "--n", type=int)
parser.add_argument("-p", "--p", type=int)
parser.add_argument("-r", "--reps", type=int)
parser.add_argument("-g", "--dgp")
parser.add_argument("-l", "--location", default="hku")
parser.add_argument("-s", "--seed", type=int, default=int(np.round(np.random.random() * 1e7)))
args = parser.parse_args()
seed_ = np.arange(args.seed, args.seed + args.reps)

if args.location == 'hku':
    out_dir = "/scr/u/rohitisu/git_repos_data/changeAUC/output/"
elif args.location == "pronto":
    out_dir = "/work/LAS/zhanruic-lab/rohitk/git_repos_data/changeAUC/output/"
else:
    out_dir = "output/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

out_dir = out_dir + args.dgp.lower() + "/node/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

ch_pt = np.zeros(args.reps)
ari = np.zeros(args.reps)
max_gain = np.zeros(args.reps)
# pval = np.zeros(args.reps)
runtime = np.zeros(args.reps)

for m in np.arange(args.reps):
    random.seed(int(seed_[m]))
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
    elif args.dgp.lower() == "standard_null":
        s_ = get_normal_mean(args.n, args.p)
    elif args.dgp.lower() == "banded_null":
        s_ = get_sparse_normal_cov(args.n, args.p, rho=args.delta)
    elif args.dgp.lower() == "exp_null":
        s_ = get_exponential(args.n, args.p)
    else:
        print("Invalid Data Generating Process (DGP).")
        sys.exit(0)
    out_ = node_wrapper(sample=s_, tau=0.5)
    
    ch_pt[m] = out_['cp']
    ari[m] = out_['ari']
    max_gain[m] = out_['max_gain']
    runtime[m] = out_['runtime']
    # pval[m] = out_['pval']
    print(f"---- Change Point for {m+1} iteration with {args.dgp} signal, {args.delta} is {out_['cp']}.  ----")

out_dict = {
    "ch_pt": ch_pt, "ari": ari, "max_gain": max_gain, # "pval": pval,
    "dgp": args.dgp.lower(), "reps": args.reps, "p": args.p, "delta": args.delta, "n": args.n,
    "location": args.location, "seed": args.seed, "runtime": runtime
}

if args.delta == int(args.delta):
    delta = int(args.delta)
else:
    delta = args.delta
file_name = f"delta_{delta}_p_{args.p}_n_{int(args.n)}_seed_{args.seed}_.pkl"

with open(out_dir + file_name, "wb") as fp:
    pickle.dump(out_dict, fp)
