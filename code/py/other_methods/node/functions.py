# The code in this file is copied from the following URL:
# https://github.com/xiuheng-wang/NODE_release/blob/main/utils/functions.py 

# The codes of variational continual learning are partly from:
# https://github.com/PierreAlexSW/VariationalContinualLearning

from __future__ import division
import torch
import numpy as np
import time
import matplotlib.pyplot as plt
# MODIFICATION ---
import sys
sys.path.insert(0, "./code/py")
from other_methods.node.multihead_models import Vanilla_NN, MFVI_NN
# MODIFICATION ---
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
import os

def CPD_NDE(Y, swl = 64, hidden_size = [32, 32, 32], ML_epochs = 50, VCL_epochs = 1, p_lambda = 5, single_head = True, single_test = False, batch_size = None):
    T, N = np.shape(Y)
    stat = np.zeros(T)
    train_label = np.concatenate((np.zeros([swl, 1]), np.ones([swl, 1])), axis = 0)
    for t in range(2*swl, T):
        train_data = Y[t - 2*swl : t]
        x_train = torch.from_numpy(train_data).float()
        y_train = torch.from_numpy(train_label).float()
        task_id = t - 2*swl
        # Set the readout head to train
        head = 0 if single_head else task_id
        bsize = x_train.shape[0] if (batch_size is None) else batch_size
        # print('task_id:  ', task_id)
        # Train network with maximum likelihood to initialize first model
        if task_id == 0:
            ml_model = Vanilla_NN(N, hidden_size, 1, x_train.shape[0])
            ml_model.train(x_train, y_train, task_id, ML_epochs, bsize)
            mf_weights = ml_model.get_weights()
            mf_model = MFVI_NN(N, hidden_size, 1, x_train.shape[0],
            no_train_samples=10, no_pred_samples=100, single_head = single_head, prev_means=mf_weights) 
        mf_model.train(x_train, y_train, head, VCL_epochs, bsize, p_lambda = p_lambda)
    #   mf_model.train_only_head(x_train, y_train, head, ML_epochs, bsize)
        mf_model.update_prior()
        # single test sample
        if single_test == True:
            test_data = Y[t]
            test_data = torch.from_numpy(test_data).float().unsqueeze(0).to(device = device)
        # multi test samples
        else:
            test_data = Y[t - swl : t]
            test_data = torch.from_numpy(test_data).float().to(device = device) 
        pred = mf_model.prediction_prob(test_data, head)
        stat[t] = (pred / (1-pred) - 1).mean()
    return stat