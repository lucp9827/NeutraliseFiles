# NAME
# Cramer-Von Mises test 
# DESCRIPTION
# A two-sample permutation based test on the Cramer-Von Mises test statistic. With default bootstraps: 2000
# HYPOTHESIS
# The null hypothesis is defined as two samples that come from the same distribution, against the alternative the samples differ in location.
# REFERENCES
# Brown, B. M. (1982). Cramer-von Mises Distributions and Permutation Tests.  Biometrika, 69(3), 619-624. https://doi.org/10.2307/2335997 (Rfunction: https://search.r-project.org/CRAN/refmans/twosamples/html/cvm_test.html)
# END
Test<-function(db) {
  results<-twosamples::cvm_test(db$y[db$group==1],db$y[db$group==2])
  return(list(
    stat=as.numeric(results[1]),
    p.value=as.numeric(results[2])
  ))
}

