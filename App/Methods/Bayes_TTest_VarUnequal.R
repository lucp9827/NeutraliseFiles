# NAME
# Bayesian t-test
# DESCRIPTION
# Performs two sample t-tests in the Bayesian hypothesis testing framework, without equal variance assumption.
# REFERENCES
# Introduction to Bayesian Statistics, Bolstad, W.M. (2017), John Wiley & Sons ISBN 978-1-118-09156-2. (Package: https://cran.r-project.org/web/packages/Bolstad/Bolstad.pdf)(Rfunction: https://www.rdocumentation.org/packages/Bolstad/versions/0.2-41/topics/bayes.t.test )
# END
library(Bolstad)
Test<-function(db) {
  results<-bayes.t.test(db$y~db$group,var.equal = FALSE
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

