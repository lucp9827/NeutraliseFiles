# NAME
# Cucconi Test
# DESCRIPTION
# Performs the Cucconi test for the two-sample location-scale problem, to determine whether the location and or scale of two univariate population distributions differ. (Permutations used to estimate the distribution of the test statistic under the null hypothesis)
# REFERENCES
# Cucconi, O. (1968). Un nuovo test non parametrico per il confronto tra due gruppi campionari. Giornale degli Economisti e Annali di Economia, XXVII: 225-248. Marozzi, M. (2013). Nonparametric simultaneous tests for location and scale testing: A comparison of several methods. Communications in Statistics - Simulation and Computation, 42(6): 1298-1317. (R-function:https://rdrr.io/github/tpepler/nonpar/man/cucconi.test.html)
# END
library(nonpar)
Test<-function(db) {
  
  hush=function(code){
    sink("NUL") # use /dev/null in UNIX
    tmp = code
    sink()
    return(tmp)
  }
  
  results<-hush(cucconi.test(db$y[db$group==1],db$y[db$group==2]
                       ))
  return(list(
    stat=results$C,
    p.value=results$p.value
  ))
}

