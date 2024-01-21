if(!dir.exists("output/cifar/data")){
  library(keras)
  cifar10 <- dataset_cifar10()
  saveRDS(cifar10, "output/cifar/data/cifar10.RData")
  cifar10 <- readRDS("cifar_example/data/cifar10.RData")
  
  cifar <- cifar10$train
  saveRDS(cifar, "output/cifar/data/cifar.RData")
}
cifar <- readRDS("output/cifar/data/cifar.RData")

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