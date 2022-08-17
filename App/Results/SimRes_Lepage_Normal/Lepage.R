# NAME
# Lepage Test
# DESCRIPTION
# Performs the Lepage test for the two-sample location scale problem.
# REFERENCES
# Lepage, Y. (1971). A combination of Wilcoxon's and Ansari-Bradley's statistics. Biometrika, 58(1): 213-217
# END
library(nonpar)
Test<-function(db) {
  results<-lepage.test(db$y[db$group==1],db$y[db$group==2]
                       )
  return(list(
    stat=results$obs.stat,
    p.value=results$p.value
  ))
}

