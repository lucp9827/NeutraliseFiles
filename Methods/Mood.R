# NAME
# Mood's median test
# DESCRIPTION
# Performs a Mood's median test to compare medians of independent samples. A Fisher's exact test is used if the number of data values is < 200; otherwise a chi-square test is used, with Yates continuity correction if necessary
# HYPOTHESIS
# The null hypothesis is defined for testings equality of medians, while assuming that the distributions are otherwise the same. The alternative states that the medians are different in both groups.
# REFERENCES
# MOOD, A. M. (1954). On the asymptotic efficiency of certain non-parametric two-sample tests. Ann. Math.Statist. 25, 514 22. (Rfunction: https://www.rdocumentation.org/packages/RVAideMemoire/versions/0.9-81-2/topics/mood.medtest)
# END
Test<-function(db) {
  results<-RVAideMemoire::mood.medtest(db$y~db$group
                       )
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}

