# NAME
# Brunner–Munzel test
# DESCRIPTION
# TODO
# REFERENCES
# Brunner, Edgar, and Ullrich Munzel. "The nonparametric Behrens‐Fisher problem: asymptotic theory and a small‐sample approximation." Biometrical Journal: Journal of Mathematical Methods in Biosciences 42.1 (2000): 17-25.
# END
library(lawstat)
Test<-function(db) {
  results<-brunner.munzel.test(db$y[db$group==1],db$y[db$group==2],
                               alternative="two.sided")
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

