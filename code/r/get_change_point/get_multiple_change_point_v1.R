source("code/r/get_change_point/get_change_point_v1.R")
seeded_intervals <- function(n, decay = sqrt(2), unique_int = F, 
                             min_length = 500){
  n	<- as.integer(n)
  depth	<- log(n, base = decay)
  depth	<- ceiling(depth)
  M	<- sum(2^(1:depth)-1)
  
  boundary_mtx           <- matrix(NA, ncol = 2)
  colnames(boundary_mtx) <- c("st", "end")
  boundary_mtx[1, ]      <- c(1, n)
  
  for(i in 2:depth){
    int_length	<- n * (1/decay)^(i-1)
    if(int_length < min_length)
      break
    n_int		<- ceiling(round(n/int_length, 14))*2-1		# sometimes very slight numerical inaccuracies
    
    boundary_mtx	<- rbind(boundary_mtx,
                          cbind(floor(seq(1, n-int_length, length.out = (n_int))), 
                                ceiling(seq(int_length, n, length.out = (n_int)))))
  }
  
  if(unique_int){return(unique(boundary_mtx))}
  boundary_mtx
}

get_sbs_cp <- function(sample_, classifier = "RF",
                            split_trim = 0.15,
                            auc_trim = 0.05,
                            no_of_perm = 199,
                            min_length = 500, decay = sqrt(2)){
  n <- nrow(sample_)
  seeded_intv <- seeded_intervals(n, decay, T, min_length)
  output <- vector(mode = "list", length = nrow(seeded_intv))
  seeded_auc <- numeric(nrow(seeded_intv))
  seeded_cp <- numeric(nrow(seeded_intv))
  
  for(i in 1:nrow(seeded_intv)){
    intv <- seeded_intv[i, ]
    out_ <- get_change_point(sample_ = sample_[intv[1]:intv[2], ], 
                                    classifier = classifier,
                                    split_trim = split_trim, 
                                    auc_trim = auc_trim,
                                    perm_pval = FALSE, verbose = FALSE)
    output[[i]]$output <- out_
    output[[i]]$interval <- seeded_intv[i, ]
    seeded_auc[i] <- out_$max_auc
    seeded_cp[i] <- out_$ch_pt
  }
  return(list(output = output, max_seeded_auc = max(seeded_auc),
              seeded_cp = seeded_cp[which.max(seeded_auc)],
              seeded_interval = seeded_intv[which.max(seeded_auc), ]))
}

get_perm_cutoff <- function(sample_, classifier = "RF",
                            split_trim = 0.15,
                            auc_trim = 0.05,
                            no_of_perm = 199){
  n <- nrow(sample_)
  aucs <- numeric(no_of_perm)
  for(i in 1:no_of_perm){
    ind <- sample(1:n, n, replace = FALSE)
    tmp <- get_change_point(sample_[ind, ], classifier = classifier,
                            split_trim = split_trim, auc_trim = auc_trim,
                            perm_pval = FALSE, verbose = FALSE)
    aucs[i] <- tmp$max_auc
  }
  return(quantile(aucs, 0.9))
}

get_multiple_cp <- function(sample_, left,  right,
                            classifier = "RF",
                            split_trim = 0.15,
                            auc_trim = 0.05,
                            no_of_perm = 199,
                            min_length = 500, decay = sqrt(2),
                            return_output = "all"){
  # browser()
  print(paste("----- Detecting cp between", left, right, sep = " "))
  if((right - left) >= min_length){
    print("Permutation Started to Obtain SBS Cutoff.")
    cutoff <- get_perm_cutoff(sample_ = sample_, classifier = classifier,
                              split_trim = split_trim, auc_trim = auc_trim,
                              no_of_perm = no_of_perm)
    print("Permutation Ended and SBS is started.")
    out_ <- get_sbs_cp(sample_ = sample_[left:right, ], classifier = classifier,
                       split_trim = split_trim, auc_trim = auc_trim,
                       no_of_perm = no_of_perm, min_length = min_length,
                       decay = decay)
    max_seeded_auc <- out_$max_seeded_auc
    seeded_cp <- out_$seeded_cp
    seeded_intv <- out_$seeded_interval
    out_ <- out_$output
    # browser()
    if(left == 1){
      cp_ <- seeded_intv[1] + seeded_cp - 1
    }
    else{
      cp_ <- left + seeded_intv[1] + seeded_cp - 1
    }
    if(return_output == "all"){
      output_counter <<- output_counter + 1
      multiple_cp_output[[output_counter]] <<- list(interval = c(left, right),
                                                    seeded_interval = seeded_intv,
                                                    seeded_cp = seeded_cp,
                                                    cp = cp_,
                                                    max_seeded_auc = max_seeded_auc,
                                                    perm_cutoff = cutoff,
                                                    output = out_)
    }
    
    if(max_seeded_auc >= cutoff){
      if(return_output == "significant"){
        print(paste("Significant change point is detected at", cp_,
                    "with Maximum AUC", max_seeded_auc, "in", (seeded_intv+left)[1]-1,
                    (seeded_intv+left)[2]-1))
        output_counter <<- output_counter + 1
        multiple_cp_output[[output_counter]] <<- list(interval = c(left, right),
                                                      seeded_interval = seeded_intv,
                                                      seeded_cp = seeded_cp,
                                                      cp = cp_,
                                                      max_seeded_auc = max_seeded_auc,
                                                      perm_cutoff = cutoff,
                                                      output = out_)
      }
      
      if((cp_ - left) >= min_length){
        multiple_cp <<- rbind(multiple_cp,
                              get_multiple_cp(sample_ = sample_,
                                              left = left, right = cp_,
                                              classifier = classifier,
                                              split_trim = split_trim,
                                              auc_trim = auc_trim, 
                                              no_of_perm = no_of_perm,
                                              min_length = min_length,
                                              decay = decay, 
                                              return_output = return_output))
      }
      if((right - cp_) >= min_length){
        multiple_cp <<- rbind(multiple_cp, 
                              get_multiple_cp(sample_ = sample_,
                                              left = (cp_+1), right = right,
                                              classifier = classifier,
                                              split_trim = split_trim,
                                              auc_trim = auc_trim, 
                                              no_of_perm = no_of_perm,
                                              min_length = min_length,
                                              decay = decay, 
                                              return_output = return_output))
      }
      return(multiple_cp)
    } 
    return(c(left, right))
  }
  return(c(left, right))
}

# This is a wrapper function over a recursive function, get_multiple_cp
get_multiple_change_point <- function(sample_, left,  right,
                                      classifier = "RF",
                                      split_trim = 0.15,
                                      auc_trim = 0.05,
                                      no_of_perm = 199,
                                      min_length = 500, decay = sqrt(2),
                                      return_output = "all"){
  assign("multiple_cp", numeric(0), .GlobalEnv)
  assign("output_counter", 0, .GlobalEnv)
  assign("multiple_cp_output", list(), .GlobalEnv)
  out_ <- get_multiple_cp(sample_ = sample_, left = left, right = right,
                          classifier = classifier,
                          split_trim = split_trim, auc_trim = auc_trim,
                          no_of_perm = no_of_perm, min_length = min_length,
                          decay = decay, return_output = return_output)
  # rm(multiple_cp)
  return(list(intervals = unique(out_), output = multiple_cp_output))
}