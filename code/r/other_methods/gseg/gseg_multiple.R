source("code/r/other_methods/gseg/gseg.R")
source("code/r/get_change_point/get_multiple_change_point_v1.R") # to import seeded_interval

sbs_cp_gseg <- function(dat, statistics = "o", n_min_sample = 300, 
                        decay = sqrt(2)){
  # browser()
  n <- nrow(dat)
  seeded_intv <- seeded_intervals(n, decay, T, n_min_sample)
  output <- vector(mode = "list", length = nrow(seeded_intv))
  seeded_tstat <- numeric(nrow(seeded_intv))
  seeded_cp <- numeric(nrow(seeded_intv))
  
  for(i in 1:nrow(seeded_intv)){
    intv <- seeded_intv[i, ]
    out <- gseg_wrapper(dat, statistics = statistics)
    output[[i]]$output <- out
    output[[i]]$interval <- seeded_intv[i, ]
    if(statistics == "o"){
      seeded_tstat[i] <- out$orig$maxZ
      seeded_cp[i] <- out$orig$cp
    }
    if(statistics == "w"){
      seeded_tstat[i] <- out$wei$maxZ
      seeded_cp[i] <- out$wei$cp
    }
    if(statistics == "m"){
      seeded_tstat[i] <- out$maxt$maxZ
      seeded_cp[i] <- out$maxt$cp
    }
    if(statistics == "g"){
      seeded_tstat[i] <- out$gen$maxZ
      seeded_cp[i] <- out$gen$cp
    }
  }
  return(list(output = output[[which.max(seeded_tstat)]], 
              max_seeded_tstat = max(seeded_tstat),
              seeded_cp = seeded_cp[which.max(seeded_tstat)],
              seeded_interval = seeded_intv[which.max(seeded_tstat), ]))
}

perm_cutoff_gseg <- function(dat, statistics = "o", no_of_perm = 199){
  n <- nrow(dat)
  tstats <- numeric(no_of_perm)
  for(i in 1:no_of_perm){
    ind <- sample(1:n, n, replace = FALSE)
    tmp <- gseg_wrapper(dat[ind, ], statistics = statistics, pval_perm = FALSE)
    if(statistics == "o"){
      tstats[i] <- tmp$orig$maxZ
    }
    if(statistics == "w"){
      tstats[i] <- tmp$wei$maxZ
    }
    if(statistics == "m"){
      tstats[i] <- tmp$maxt$maxZ
    }
    if(statistics == "g"){
      tstats[i] <- tmp$gen$maxZ
    }
  }
  return(max(tstats))
}

multiple_cp_gseg <- function(dat, left, right, no_of_perm = 199,
                             n_min_sample = 500, statistics = "o"){
  # browser()
  print(paste("----- Detecting cp between", left, right, sep = " "))
  if((right - left) >= n_min_sample){
    print("Permutation Started to Obtain SBS Cutoff.")
    cutoff <- perm_cutoff_gseg(dat, statistics = statistics, 
                               no_of_perm = no_of_perm)
    print("Permutation Ended and SBS is started.")
    out <- sbs_cp_gseg(dat[left:right, ], statistics = statistics,
                       n_min_sample = n_min_sample)
    max_seeded_tstat <- out$max_seeded_tstat
    seeded_cp <- out$seeded_cp
    seeded_intv <- out$seeded_interval
    out <- out$output$output
    if(statistics == "o"){
      cp_ <- out$orig$cp
      pval <- out$orig$pval
    } else if(statistics == "w"){
      cp_ <- out$wei$cp
      pval <- out$wei$pval
    } else if(statistics == "g"){
      cp_ <- out$gen$cp
      pval <- out$gen$pval
    } else{
      cp_ <- out$maxt$cp
      pval <- out$maxt$pval
    }
    if(left == 1){
      cp_ <- seeded_intv[1] + seeded_cp - 1
    } else{
      cp_ <- left + seeded_intv[1] + seeded_cp - 1
    }
    output_counter <<- output_counter + 1
    multiple_cp_output[[output_counter]] <<- list(interval = c(left, right),
                                                  seeded_interval = seeded_intv,
                                                  seeded_cp = seeded_cp,
                                                  cp = cp_,
                                                  pval = pval,
                                                  output = out)
    if(max_seeded_tstat >= cutoff){
      if((cp_ - left) >= n_min_sample){
        multiple_cp <<- rbind(multiple_cp, 
                              multiple_cp_gseg(dat = dat, left = left, 
                                               right = cp_, 
                                               no_of_perm = no_of_perm,
                                               n_min_sample = n_min_sample, 
                                               statistics = statistics))
      }
      if((right - cp_) >= n_min_sample){
        multiple_cp <<- rbind(multiple_cp, 
                              multiple_cp_gseg(dat = dat, left = (cp_+1), 
                                               right = right, 
                                               no_of_perm = no_of_perm,
                                               n_min_sample = n_min_sample, 
                                               statistics = statistics))
      }
      return(multiple_cp)
    } else{
      return(c(left, right))
    }
  } else{
    return(c(left, right))
  }
}


multiple_changepoint_gseg <- function(dat, left, right, no_of_perm = 199,
                                      n_min_sample = 500, statistics = "o"){
  assign("multiple_cp", numeric(0), .GlobalEnv)
  assign("output_counter", 0, .GlobalEnv)
  assign("multiple_cp_output", list(), .GlobalEnv)
  
  out_ <- multiple_cp_gseg(dat, left, right, no_of_perm = no_of_perm,
                           n_min_sample, statistics)
  
  return(list(intervals = unique(out_), output = multiple_cp_output))
}
