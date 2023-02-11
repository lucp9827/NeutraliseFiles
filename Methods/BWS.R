# NAME
# Asymptotic Baumgartner-Weiss-Schindler test test
# DESCRIPTION
# Two sample Baumgartner-Weiss-Schindler test test. P-values based on asymptotic approximation.
# REFERENCES
# W. Baumgartner, P. Weiss, H. Schindler, ’A nonparametric test for the general two-sample problem’, Biometrics 54, no. 3 (Sep., 1998): pp. 1129-1135.
# END
Test<-function(db) {
  results<-BWStest::bws_test(db$y[db$group==1],db$y[db$group==2],
                             method="BWS",
                             alternative = "two.sided")
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

