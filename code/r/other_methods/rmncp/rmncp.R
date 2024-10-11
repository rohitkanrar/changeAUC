library(RMNCP)
library(MASS)
library(ks)
library(kdensity)

get_rmncp_wrapper <- function(dat){
  p <- dim(dat)[2]; N <- dim(dat)[1]
  K_max = 30
  h = 5*(K_max*log(N)/N)^{1/p}
  st.time <- Sys.time()
  out <- new_MWBS(y = dat, z = dat, s = 1, e = N, flag = 0, S = NULL, 
                  Dval = NULL, pos = 1, alpha = 1, beta = N, h = 8*h)
  end.time <- Sys.time() - st.time
  out["runtime"] = end.time
  out["runtime_units"] = units(end.time)
  return(out)
}