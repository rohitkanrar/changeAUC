import numpy as np


def get_dense_shift_normal_mean(delta, n, p, prop=0.2, tau=0.5):
    d = int(np.floor(p * prop))
    shift = delta / np.sqrt(d)
    t0 = int(np.floor(n * tau))
    mu1 = np.zeros(p)
    mu2 = np.zeros(p)
    mu2[np.arange(d)] = shift
    sigma = np.diag(np.ones(p))
    s1 = np.random.multivariate_normal(mu1, sigma, t0)
    s2 = np.random.multivariate_normal(mu2, sigma, n - t0)
    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_sparse_shift_normal_mean(delta, n, p, prop=0.01, tau=0.5):
    d = int(np.floor(p * prop))
    shift = delta / np.sqrt(d)
    t0 = int(np.floor(n * tau))
    mu1 = np.zeros(p)
    mu2 = np.zeros(p)
    mu2[np.arange(d)] = shift
    sigma = np.diag(np.ones(p))
    s1 = np.random.multivariate_normal(mu1, sigma, t0)
    s2 = np.random.multivariate_normal(mu2, sigma, n - t0)
    sample = np.concatenate((s1, s2), axis=0)

    return sample
