# NAME
# Welch two-sample t-test
# DESCRIPTION
# Two sample t-test without equal variance assumption.
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
