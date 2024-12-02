import numpy as np
import pickle, argparse, sys, random, json
from pathlib import Path
import tensorflow as tf
import random, argparse
from datetime import datetime
sys.path.insert(0, "./code/py")
from other_methods.changeforest.change_forest import changeforest_wrapper 

# RUN: python code/py/simulation_scripts/simulation_change_forest_cifar.py -r 10 -n 1000 -g 35 -l local -t True -s 2024

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--reps", type=int)
parser.add_argument("-n", "--n", type=int)
parser.add_argument("-g", "--dgp", type=int, default=35)
# parser.add_argument("-c", "--clf", default="VGG16")
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

out_dir = out_dir + "cifar/" + case_ + "/" + "changeforest" + "/"
Path(out_dir).mkdir(parents=True, exist_ok=True)

ch_pt = np.zeros(args.reps)
ari = np.zeros(args.reps)
max_gain = np.zeros(args.reps)
pval = np.zeros(args.reps)
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
    x_vec = x.reshape(x.shape[0], -1)
    output = changeforest_wrapper(x_vec, tau=0.5)
    ch_pt[i] = output['cp']
    ari[i] = output['ari']
    max_gain[i] = output['max_gain']
    runtime[i] = output['runtime']
    if args.test:
        pval[i] = output['pval']

    filename = f"cifar_{case_}_n_{n}_seed_{int(seed_[i])}.pkl"
    # filename = f"mnist_{case_}_test.pkl"

    with open(out_dir + filename, "wb") as fp:
        pickle.dump(output, fp)

out_dict = {
    "ch_pt": ch_pt, "ari": ari, "max_gain": max_gain,
    "dgp": args.dgp, "reps": args.reps, "n": args.n,
    "clf": "changeforest", "perm_pval": args.test,
    "location": args.location, "seed": args.seed, "runtime": runtime
}
if args.test:
    out_dict['pval'] = pval

filename = f"cifar_{case_}_n_{n}_rep_{args.reps}.pkl"
with open(out_dir + filename, "wb") as fp:
    pickle.dump(out_dict, fp)