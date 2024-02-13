time_table <- matrix(0, 4, 5)
library(reticulate)
# py_install("pandas")
pd <- import("pandas")

out <- readRDS("output/dense_mean/gseg/delta_2_p_500_n_1000_rep_1000_seed_0_.RData")
time_table[1, 1] <- mean(out$runtime)
time_table[2, 1] <- sd(out$runtime)

out <- readRDS("output/dense_mean/gseg/delta_2_p_1000_n_1000_rep_1000_seed_0_.RData")
time_table[3, 1] <- mean(out$runtime)
time_table[4, 1] <- sd(out$runtime)



runtime <- numeric(0)
for(file in list.files("output/dense_mean/hddc/")){
  out <- readRDS(paste("output/dense_mean/hddc/", file, sep = ""))
  if(out$p == 500 && out$seed[1] > 401){
    runtime <- c(runtime, out$runtime * 60)
  }
}
time_table[1, 2] <- mean(runtime)
time_table[2, 2] <- sd(runtime)

runtime <- numeric(0)
for(file in list.files("output/dense_mean/hddc/")){
  out <- readRDS(paste("output/dense_mean/hddc/", file, sep = ""))
  if(out$p == 1000 && out$seed[1] > 401){
    runtime <- c(runtime, out$runtime * 60)
  }
}
time_table[3, 2] <- mean(runtime)
time_table[4, 2] <- sd(runtime)

out <- readRDS("output/dense_mean/reg_logis/delta_2_p_500_n_1000_ep_0.15_et_0.05_seed_0_.RData")
time_table[1, 3] <- mean(out$runtime[2:1001])
time_table[2, 3] <- sd(out$runtime[2:1001])

out <- readRDS("output/dense_mean/reg_logis/delta_2_p_1000_n_1000_ep_0.15_et_0.05_seed_0_.RData")
time_table[3, 3] <- mean(out$runtime[2:1001])
time_table[4, 3] <- sd(out$runtime[2:1001])


out <- pd$read_pickle("output/dense_mean/fnn/delta_2_p_500_n_1000_ep_0.15_et_0.05_seed_0_.pkl")
time_table[1, 4] <- mean(out$runtime[2:1001])
time_table[2, 4] <- sd(out$runtime[2:1001])

out <- pd$read_pickle("output/dense_mean/fnn/delta_2_p_1000_n_1000_ep_0.15_et_0.05_seed_0_.pkl")
time_table[3, 4] <- mean(out$runtime[2:1001])
time_table[4, 4] <- sd(out$runtime[2:1001])


out <- readRDS("output/dense_mean/rf/delta_2_p_500_n_1000_ep_0.15_et_0.05_seed_0_.RData")
time_table[1, 5] <- mean(out$runtime[2:1001])
time_table[2, 5] <- sd(out$runtime[2:1001])

out <- readRDS("output/dense_mean/rf/delta_2_p_1000_n_1000_ep_0.15_et_0.05_seed_0_.RData")
time_table[3, 5] <- mean(out$runtime[2:1001])
time_table[4, 5] <- sd(out$runtime[2:1001])

xtable::xtable(time_table, digits = 3)





time_table_cifar <- matrix(0, 2, 3)
library(reticulate)
# py_install("pandas")
pd <- import("pandas")

runtime <- numeric(0)
for(file_ in list.files("output/cifar/3-5/vgg16_cpu/")){
  out <- pd$read_pickle(paste("output/cifar/3-5/vgg16_cpu/", file_, sep = ""))
  runtime <- c(runtime, out$runtime)
}
time_table_cifar[1, 2] <- mean(runtime)
time_table_cifar[2, 2] <- sd(runtime)

runtime <- numeric(0)
for(file_ in list.files("output/cifar/3-5/vgg16_gpu/")){
  out <- pd$read_pickle(paste("output/cifar/3-5/vgg16_gpu/", file_, sep = ""))
  runtime <- c(runtime, out$runtime)
}
time_table_cifar[1, 3] <- mean(runtime)
time_table_cifar[2, 3] <- sd(runtime)

out <- readRDS("output/cifar/3-5/gseg/cifar_3-5_n_1000_seed_0.RData")
time_table_cifar[1, 1] <- mean(out$runtime)
time_table_cifar[2, 1] <- sd(out$runtime)

xtable::xtable(time_table_cifar, digits = 3)
