import numpy as np
from math import floor


def get_dense_shift_normal_moment(n, p, prop=0.2, tau=0.5):
    t0 = int(np.floor(n * tau))
    d = int(np.floor(p * prop))
    mu1 = np.zeros(p)
    sigma = np.diag(np.ones(p))
    s1 = np.random.multivariate_normal(mu1, sigma, t0)
    s2 = np.random.multivariate_normal(mu1, sigma, n-t0)
    for i in np.arange(d):
        s2[:, i] = np.random.exponential(size=n-t0) - 1

    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_sparse_shift_normal_moment(n, p, prop=0.01, tau=0.5):
    t0 = int(np.floor(n * tau))
    d = int(np.floor(p * prop))
    mu1 = np.zeros(p)
    sigma = np.diag(np.ones(p))
    s1 = np.random.multivariate_normal(mu1, sigma, t0)
    s2 = np.random.multivariate_normal(mu1, sigma, n-t0)
    for i in np.arange(d):
        s2[:, i] = np.random.exponential(size=n-t0) - 1

    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_exponential(n, p):
    s = np.zeros((n, p))
    for j in np.arange(p):
        s[:, j] = np.random.exponential(size=n)

    return s