# NAME
# Asymptotic Anderson-Darling test
# DESCRIPTION
# Two sample Anderson-Darling test. P-values based on asymptotic approximation. 
# HYPOTHESIS
# The null hypothesis states that two independent samples have the same underlying distribution. The alternative hypothesis states that two independent samples have different underlying distributions. 
# REFERENCES
# Scholz, F. W., & Stephens, M. A. (1987). K-Sample Anderson-Darling Tests. Journal of the American Statistical Association, 82(399), 918-924. https://doi.org/10.2307/2288805 (Rfunction: https://www.rdocumentation.org/packages/kSamples/versions/1.2-9/topics/ad.test)
# END
Test<-function(db) {
  results<-kSamples::ad.test(db$y[db$group==1],db$y[db$group==2],
                   method="asymptotic")
  return(list(
    stat=results$ad[1,1],
    p.value=results$ad[1,3]
  ))
}

