# NAME
# Yuen's test
# DESCRIPTION
# Bootstrap version of Yuen's test for trimmed means
# REFERENCES
# Yuen, K. K. (1974). The two sample trimmed t for unequal population variances. Biometrika, 61, 165-170 ((https://cran.r-project.org/web/packages/WRS2/vignettes/WRS2.pdf))
# END
library(WRS2)
Test<-function(db) {
  results<-yuenbt(db$y~db$group,side = TRUE)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}
