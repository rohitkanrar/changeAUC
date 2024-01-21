if(Sys.getenv("SLURM_SUBMIT_HOST") == "pronto.las.iastate.edu"){
  out_dir <- "/work/LAS/zhanruic-lab/git_repos_data/changeAUC/"
} else{
  out_dir <- ""
}
out_dir <- paste(out_dir, "output/cifar/data/", sep = "")
if(!dir.exists(out_dir)){
  library(keras)
  cifar10 <- dataset_cifar10()
  saveRDS(cifar10, paste(out_dir, "cifar10.RData", sep = ""))
  cifar10 <- readRDS(paste(out_dir, "cifar10.RData", sep = ""))
  
  cifar <- cifar10$train
  saveRDS(cifar, paste(out_dir, "cifar.RData", sep = ""))
}
cifar <- readRDS(paste(out_dir, "cifar.RData", sep = ""))

generate_cifar_cp <- function(n1 = 500, n2 = 500, labels = c(3, 8)){
  if(length(labels) == 2){
    ind1 <- which(cifar$y == labels[1])
    ind2 <- which(cifar$y == labels[2])
    s1 <- cifar$x[sample(ind1, n1, replace = FALSE), , , ]
    s2 <- cifar$x[sample(ind2, n2, replace = FALSE), , , ]
    
    s1  <- t(apply(s1, 1, as.vector))
    s2 <- t(apply(s2, 1, as.vector))
    
    return(rbind(s1, s2))
  }
  else if(length(labels) == 1){
    ind <- which(cifar$y == labels)
    s <- cifar$x[sample(ind, (n1 + n2), replace = FALSE), , , ]
    s <- t(apply(s, 1, as.vector))
    
    return(s)
  }
  else{
    print("not supported")
    return(NULL)
  }
  
}