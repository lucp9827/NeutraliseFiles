# NAME
# Brunner-Munzel test
# DESCRIPTION
# The Brunner--Munzel test for stochastic equality of two samples, which is also known as the Generalized Wilcoxon test.
# REFERENCES
# Brunner, Edgar, and Ullrich Munzel. "The nonparametric Behrens-Fisher problem: asymptotic theory and a small-sample approximation." Biometrical Journal: Journal of Mathematical Methods in Biosciences 42.1 (2000): 17-25.(Rfunction: https://www.rdocumentation.org/packages/lawstat/versions/3.4/topics/brunner.munzel.test)
# END
Test<-function(db) {
  results<-lawstat::brunner.munzel.test(db$y[db$group==1],db$y[db$group==2],
                               alternative="two.sided")
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

