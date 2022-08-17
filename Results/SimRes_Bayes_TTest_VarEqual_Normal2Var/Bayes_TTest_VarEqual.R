# NAME
# Bayesian t-test
# DESCRIPTION
# Performs one and two sample t-tests (in the Bayesian hypothesis testing framework) on vectors of data
# REFERENCES
# TODO
# END
library(Bolstad)
Test<-function(db) {
  results<-bayes.t.test(db$y~db$group,var.equal = TRUE
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

