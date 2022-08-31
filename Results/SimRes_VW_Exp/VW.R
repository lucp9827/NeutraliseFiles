# NAME
# van der Waerden normal scores test
# DESCRIPTION
# Performs a van der Waerden test of the null hypothesis that the location parameters of the distribution of x are the same in each group (sample). The alternative is that they differ in at least one.
# REFERENCES
# van der Waerden, B.L. (1953). "Order tests for the two-sample problem. II, III", Proceedings of the Koninklijke Nederlandse Akademie van Wetenschappen, Serie A, 564, 303-310, 311-316. (Rfunction: https://search.r-project.org/CRAN/refmans/DescTools/html/VanWaerdenTest.html)
# END
library(DescTools)
Test<-function(db) {
  results<-VanWaerdenTest(db$y~db$group
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

