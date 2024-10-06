import numpy as np


def get_dense_shift_normal_cov(delta, n, p, tau=0.5):
    t0 = int(np.floor(n * tau))
    mu = np.zeros(p)
    sigma1 = np.diag(np.ones(p))
    sigma2 = np.ones((p, p)) * delta
    np.fill_diagonal(sigma2, 1)
    s1 = np.random.multivariate_normal(mu, sigma1, t0)
    s2 = np.random.multivariate_normal(mu, sigma2, n - t0)
    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_sparse_shift_normal_cov(delta, n, p, tau=0.5):
    t0 = int(np.floor(n * tau))
    mu = np.zeros(p)
    sigma1 = np.diag(np.ones(p))
    sigma2 = np.diag(np.ones(p))
    for i in np.arange(p):
        for j in np.arange(p):
            if i == j:
                continue
            else:
                sigma2[i, j] = np.power(delta, np.abs(i - j))
    s1 = np.random.multivariate_normal(mu, sigma1, n)
    s2 = np.random.multivariate_normal(mu, sigma2, n)
    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_dense_normal_cov(n, p, rho=0.1):
    sigma = np.ones((p, p)) * rho
    np.fill_diagonal(sigma, 1)
    s = np.random.multivariate_normal(np.zeros(p), sigma, n)

    return s


def get_sparse_normal_cov(n, p, rho=0.8):
    sigma = np.diag(np.ones(p))
    for i in np.arange(p):
        for j in np.arange(p):
            if i == j:
                continue
            elif i < j:
                sigma[i, j] = np.power(rho, np.abs(i - j))
            else:
                sigma[i, j] = sigma[j, i]
    s = np.random.multivariate_normal(np.zeros(p), sigma, n)

    return s


def get_dense_diag_shift_normal_cov(delta, n, p, prop=0.2, tau=0.5):
    t0 = int(np.floor(n * tau))
    d = int(np.floor(p * prop))
    shift = 1 + delta / np.sqrt(d)
    mu = np.zeros(p)
    sigma1 = np.diag(np.ones(p))
    sigma2 = np.diag(np.ones(p))
    sigma2_diag = np.ones(p)
    sigma2_diag[np.arange(d)] = shift
    np.fill_diagonal(sigma2, sigma2_diag)
    s1 = np.random.multivariate_normal(mu, sigma1, t0)
    s2 = np.random.multivariate_normal(mu, sigma2, n - t0)
    sample = np.concatenate((s1, s2), axis=0)

    return sample


def get_sparse_diag_shift_normal_cov(delta, n, p, prop=0.01, tau=0.5):
    t0 = int(np.floor(n * tau))
    d = int(np.floor(p * prop))
    shift = 1 + delta / np.sqrt(d)
    mu = np.zeros(p)
    sigma1 = np.diag(np.ones(p))
    sigma2 = np.diag(np.ones(p))
    sigma2_diag = np.ones(p)
    sigma2_diag[np.arange(d)] = shift
    np.fill_diagonal(sigma2, sigma2_diag)
    s1 = np.random.multivariate_normal(mu, sigma1, t0)
    s2 = np.random.multivariate_normal(mu, sigma2, n - t0)
    sample = np.concatenate((s1, s2), axis=0)

    return sample
