# NAME
# Asymptotic Anderson-Darling test
# DESCRIPTION
# Two sample Anderson-Darling test . P-values based on asymptotic approximation
# REFERENCES
# Scholz, F. W., & Stephens, M. A. (1987). K-Sample Anderson-Darling Tests. Journal of the American Statistical Association, 82(399), 918-924. https://doi.org/10.2307/2288805
# END

Test<-function(db) {
  results<-kSamples::ad.test(db$y[db$group==1],db$y[db$group==2],
                   method="asymptotic")
  return(list(
    stat=results$ad[1,1],
    p.value=results$ad[1,3]
  ))
}

