# NAME
# Asymptotic Wilcoxon-Mann-Whitney test
# DESCRIPTION
# Two sample Wilcoxon-Mann-Whitney test. P-values based on asymptotic approximation
# HYPOTHESIS
# The null hypothesis is defined as P(X<=Y)= 0.5, which coincides to equality of distributions under the assumption of symmetry and equal shape. The alternative hypothesis that P(X<=Y) is not equal to 0.5. 
# REFERENCES
# Wilcoxon, F. (1945). Individual comparisons by ranking methods. Biom. Bull., 1, 80-83.
# END

Test<-function(db) {
  results<-wilcox.test(y~group,data = db, exact=FALSE)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}
