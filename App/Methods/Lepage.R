# NAME
# Lepage Test
# DESCRIPTION
# Performs the Asymptotic Lepage test for the two-sample location scale problem.
# REFERENCES
# Lepage, Y. (1971). A combination of Wilcoxon's and Ansari-Bradley's statistics. Biometrika, 58(1): 213-217 (Rfunction: https://rdrr.io/github/tpepler/nonpar/man/lepage.test.html)
# END
library(nonpar)
Test<-function(db) {
  
  hush=function(code){
    sink("NUL") # use /dev/null in UNIX
    tmp = code
    sink()
    return(tmp)
  }
  
  results<-hush(lepage.test(db$y[db$group==1],db$y[db$group==2],method="Asymptotic"
                       ))
  return(list(
    stat=results$obs.stat,
    p.value=results$p.value
  ))
}

