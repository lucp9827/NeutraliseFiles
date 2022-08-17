# NAME
# Yuen's test
# DESCRIPTION
# Yuen's test for trimmed means
# REFERENCES
# Yuen, K. K. (1974). The two sample trimmed t for unequal population variances. Biometrika, 61, 165-170
# END
library(WRS2)
Test<-function(db) {
  results<-yuen(db$y~db$group)
  return(list(
    stat=results$statistic,
    p.value=results$p.value
  ))
}


