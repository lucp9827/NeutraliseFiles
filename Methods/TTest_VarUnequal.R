# NAME
# Welch two-sample t-test
# DESCRIPTION
# Two sample t-test without equal variance assumption.
# HYPOTHESIS
# The null hypothesis states that both samples come from the same underlying distribution, restricted under the assumption of normality.  The alternative hypothesis is defined as a location shift (means differ between the groups).
# REFERENCES
# Welch, Bernard L. "The significance of the difference between two means when the population variances are unequal." Biometrika 29.3/4 (1938): 350-362.
# END

Test<-function(db) {
  results<-t.test(y~group,data = db,var.equal=FALSE)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}
