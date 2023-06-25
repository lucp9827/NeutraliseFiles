# NAME
# Yuen's test
# DESCRIPTION
# Yuen's test for trimmed means
# HYPOTHESIS
# The null hypothesis states that both samples come from the same underlying distribution.  The alternative hypothesis is defined as a location shift (trimmed means differ between the groups).
# REFERENCES
# Yuen, K. K. (1974). The two sample trimmed t for unequal population variances. Biometrika, 61, 165-170 (https://cran.r-project.org/web/packages/WRS2/vignettes/WRS2.pdf)
# END

Test<-function(db) {
  results<-WRS2::yuen(db$y~db$group)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}


