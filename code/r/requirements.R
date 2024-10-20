pkgs <- c(
  "glmnet", "randomForest", "MASS", "e1071",
  "Metrics", "pdfCluster", "optparse",
  "expm", "mvtnorm", "ade4", "gSeg",
  "ks", "kdensity"
)

# Install RMNCP if needed.
if(FALSE){
  devtools::install_github("hernanmp/RMNCP")
}

install.packages(pkgs)
