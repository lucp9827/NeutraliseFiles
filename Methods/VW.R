# NAME
# van der Waerden normal scores test
# DESCRIPTION
# Performs a van der Waerden test of the null hypothesis that the location parameters of the distribution of x are the same in each group (sample). The alternative is that they differ in at least one.
# HYPOTHESIS
# The null hypothesis is defined as P(X<=Y)= 0.5, which coincides with the equality of distributions under the assumption of symmetry and equal shape. The alternative hypothesis is that P(X<=Y) is not equal to 0.5, which can be interpreted as a location shift. 
# REFERENCES
# van der Waerden, B.L. (1953). "Order tests for the two-sample problem. II, III", Proceedings of the Koninklijke Nederlandse Akademie van Wetenschappen, Serie A, 564, 303-310, 311-316. (Rfunction: https://search.r-project.org/CRAN/refmans/DescTools/html/VanWaerdenTest.html)
# END
Test<-function(db) {
  results<-DescTools::VanWaerdenTest(db$y~db$group
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

