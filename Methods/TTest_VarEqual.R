# NAME
# Two-sample Student's t-Test
# DESCRIPTION
# Two sample t-test under equal variance assumption.
# HYPOTHESIS
# The null hypothesis states that both samples come from same underlying distribution, under the assumption of normality and equal variances. The alternative hypothesis is defined as a location shift (means differ between the groups). 
# REFERENCES
# None
# END

Test<-function(db) {
  results<-t.test(y~group,data = db,var.equal=TRUE)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}
