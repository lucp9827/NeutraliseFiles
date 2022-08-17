# NAME
# Mood's median test
# DESCRIPTION
# Performs a Mood's median test to compare medians of independent samples.
# REFERENCES
# MOOD, A. M. (1954). On the asymptotic efficiency of certain non-parametric two-sample tests. Ann. Math.Statist. 25, 514 22. (Rfunction: https://www.rdocumentation.org/packages/RVAideMemoire/versions/0.9-81-2/topics/mood.medtest)
# END
library(RVAideMemoire)
Test<-function(db) {
  results<-mood.medtest(db$y~db$group
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

