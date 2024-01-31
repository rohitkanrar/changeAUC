source("code/r/misc/misc_v1.R")

get_trained_clf <- function(sample_, n, p, 
                            classifier = "RF",
                            split_trim = 0.15){
  k <- floor(n * split_trim)
  tr_ind <- c(1:k, (n - k + 1):n)
  x_train <- sample_[tr_ind, ]
  y_train <- c(rep(0, k), rep(1, k))
  x_test <- sample_[-tr_ind, ]
  
  trained_clf <- NULL
  
  if(classifier == "REG_LOGIS"){
    reg_logistic <- glmnet::glmnet(x_train, factor(y_train), 
                                   family = "binomial")
    trained_clf <- reg_logistic
    y_pred <- glmnet::predict.glmnet(reg_logistic, 
                                     newx = x_test, 
                                     s = 0.01,
                                     type = "response")
    y_pred <- as.numeric(y_pred)
  }
  else if(classifier == "LOGISTIC"){
    logistic <- glmnet::glmnet(x_train, factor(y_train), 
                               family = "binomial",
                               alpha = 0, 
                               lambda = 0)
    trained_clf <- logistic
    y_pred <- glmnet::predict.glmnet(logistic, 
                                     newx = x_test,
                                     type = "response")
    y_pred <- as.numeric(y_pred)
  }
  else if(classifier == "LOGIS"){
    logistic <- glm(y ~ ., family = "binomial",
                    data = data.frame(y = factor(y_train), x = x_train))
    trained_clf <- logistic
    y_pred <- predict(logistic, 
                      newx = data.frame(x = x_test),
                      type = "response")
    y_pred <- as.numeric(y_pred)
  }
  else if(classifier == "RF"){
    rf <- randomForest::randomForest(x = x_train, y = factor(y_train), 
                                     ntree = 200, maxnodes = 8)
    trained_clf <- rf
    y_pred <- predict(rf, newdata = x_test, type = "prob")
    y_pred <- as.numeric(y_pred[, 2])
  }
  else if(classifier == "LDA"){
    dat <- data.frame(y = factor(y_train), x = x_train)
    lda_fit <- MASS::lda(y ~ ., data = dat)
    trained_clf <- lda_fit
    pred <- predict(lda_fit, newdata = data.frame(x = x_test))
    y_pred <- as.numeric(pred$posterior[, 2])
  }
  else if(classifier == "SVM"){
    dat <- data.frame(y = factor(y_train), x = x_train)
    svm_fit <- e1071::svm(y ~ ., data = dat, probability = TRUE)
    trained_clf <- svm_fit
    pred <- predict(svm_fit, data.frame(x = x_test), probability = TRUE)
    y_pred <- attr(pred, "probabilities")[, 2]
  }
  else{
    return(NULL)
  }
  return(list(pred = y_pred, trained_clf = trained_clf))
}

get_change_point <- function(sample_, classifier = "RF",
                             split_trim = 0.15,
                             auc_trim = 0.05,
                             perm_pval = FALSE,
                             no_of_perm = 199,
                             tau = 0.5, verbose = TRUE){
  st.time <- Sys.time()
  n <- dim(sample_)
  p <- n[2]
  n <- n[1]
  k <- floor(n * split_trim)
  tr_ind <- c(1:k, (n - k + 1):n)
  x_test <- sample_[-tr_ind, ]
  nte <- dim(x_test)[1]
  start_ <- floor(auc_trim * n)
  end_ <- nte - floor(auc_trim * n)
  
  auc_ <- numeric(nte - 2 * start_)
  out_ <- get_trained_clf(sample_, n, p, classifier = classifier,
                          split_trim = split_trim)
  i <- 1
  for(j in start_:end_){
    y_test_ <- c(rep(0, j), rep(1, nte-j))
    auc_[i] <- as.numeric(Metrics::auc(y_test_, out_$pred))
    i <- i + 1
  }
  
  ch_pt_ <- k + start_ + which.max(auc_) - 1
  max_auc_ <- max(auc_)
  ari_ <- get_ari(n, floor(tau * n), ch_pt_)
  end.time <- Sys.time() - st.time
  if(verbose)
    print(paste("Detection is finished in", end.time, units(end.time)))
  out_list <- list(auc = auc_, max_auc = max_auc_,
                   ch_pt = ch_pt_, ari = ari_)
  out_list$pred <- out_$pred
  if(perm_pval){
    if(verbose)
      print("Permutation is started...")
    st.time <- Sys.time()
    pred_array <- out_$pred
    null_aucs_mat <- array(0, dim = c(nte, no_of_perm))
    for(b in 1:no_of_perm){
      perm_ind_ <- sample(1:nte, nte, replace = FALSE)
      for(j in start_:end_){
        y_test_ <- c(rep(0, j), rep(1, nte-j))
        null_aucs_mat[j, b] <- Metrics::auc(y_test_, 
                                            pred_array[perm_ind_])
      }
    }
    null_max_auc <- apply(null_aucs_mat, 2, max)
    pval_ <- (sum(null_max_auc > max_auc_) + 1) / 
      (no_of_perm + 1)
    end.time <- Sys.time() - st.time
    if(verbose){
      print(paste("Permutation is finished in", end.time, units(end.time)))
      print(paste("Change point is detected at", ch_pt_, "with p-value",
                  pval_))
    }
    out_list$pval <- pval_
  } else{
    if(verbose)
      print(paste("Change point is detected at", ch_pt_))
  }
  return(out_list)
}