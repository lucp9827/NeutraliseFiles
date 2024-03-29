# NAME
# Percentile Modified Wilcoxon-Mann-Whitney test
# DESCRIPTION
# The Percentile Modified Asymptotic Wilcoxon-Mann-Whitney test of Gastwirth (1965) with P = R = (15% * total sample size)+ 1. P-values are calculated from the normal approximation.
# HYPOTHESIS
# The null hypothesis is defined as P(X<=Y)= 0.5, which coincides with the equality of distributions under the assumption of symmetry and equal shape. The alternative hypothesis is that P(X<=Y) is not equal to 0.5, which can be interpreted as a location shift. 
# REFERENCES
# Gastwirth, J. L. (1965). Percentile modifications of two sample rank tests. Journal of the American Statistical Association, 60(312), 1127-1141.
# END
Test<-function(db) {
  frac<-0.15
  N<-nrow(db)
  d<-db$group-1
  P<-R<-floor(frac*N)+1
  odd<-(N%%2)!=0
  r<-rank(db$y)
  if(odd) {
    T.stat<-sum(((r-(N-P))*d)[r>=N-P+1])
    B.stat<-sum(((R-r+1)*d)[r<=R])
  }
  if(!odd){
    T.stat<-sum(((r-(N-P)-0.5)*d)[r>=N-P+1])
    B.stat<-sum(((R-r+0.5)*d)[r<=R])
  }
  
  lambda<-mean(db$group==2)
  sigma<-sqrt((1-lambda)/(lambda*N)*(4*frac^3)/6)
  
  test.stat<-(T.stat-B.stat)/(sigma*N*sum(db$group==2))
  p<-2*(1-pnorm(abs(test.stat)))

  return(list(
    stat=test.stat,
    p.value=p
  ))
}

