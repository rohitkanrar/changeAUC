stable_comp <- read.csv("data/us_stocks/combined_tickers.csv")
err_comp <<- character(0)
new_comp <- character(0)
incl_comp <- character(0)

library(quantmod)
i <- 1
dat <- numeric(0)

for(comp in stable_comp$Tickers){
  tryCatch(expr = {
    prc <- getSymbols(comp, from = '2005-01-01',
                      to = "2010-12-31",warnings = FALSE,
                      auto.assign = FALSE)
    if(i == 1){
      n <- dim(prc)[1]
      i <- i + 1
    }
    rtn <- periodReturn(prc, "daily", type = "log")
    if(length(as.numeric(rtn$daily.returns)) != n){
      new_comp <- c(new_comp, comp)
      print(paste("New", comp, sep = "-"))
      next
    }
    dat <- cbind(dat, as.numeric(rtn$daily.returns))
    incl_comp <- c(incl_comp, comp)
  }, error = function(e){
    err_comp <<- c(err_comp, comp)
    print(paste("Non Existent", comp, sep = "-"))
  })
}

colnames(dat) <- incl_comp
dat.df <- data.frame(dat, row.names = zoo::index(rtn))
rm(dat)

write.csv(dat.df, "data/us_stocks/stable_stocks.csv")
rm(dat.df)

# dat <- read.csv("stock_example/stable_stocks.csv", row.names = 1, header = TRUE)
