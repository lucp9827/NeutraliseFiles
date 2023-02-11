# NAME
# Asymptotic Hogg-Fisher-Randles adaptive test
# DESCRIPTION
# Two sample Hogg-Fisher-Randles adaptive test. P-values based on asymptotic approximation.
# REFERENCES
# Hogg, R. V., Fisher, D. M., & Randles, R. H. (1975). A two-sample adaptive distribution-free test. Journal of the American Statistical Association, 70(351a), 656-661.
# END
rank.stat<-function(y,trt,scores="wilcoxon") {
  # y: vector with response observations
  # trt: 0/1 indicator referring to the two treatment groups
  
  r<-rank(y)
  n<-length(r)
  n1<-sum(trt==1)
  n0<-n-n1
  
  if(scores=="wilcoxon") {
    # heavier-tailed model
    a<-r
  }
  if(scores=="median") {
    # very heavy tailed distribution
    a<-rep(0,n)
    a[r>(n+1)/2]<-1
  }
  if(scores=="LT") {
    # light-tailed symmetric model
    a<-rep(0,n)
    a[r<=floor((n+1)/4)]<-r[r<=floor((n+1)/4)]-floor((n+1)/4)-0.5
    a[r>=n-floor((n+1)/4)+1]<-r[r>=n-floor((n+1)/4)+1]-n+floor((n+1)/4)-0.5
  }
  if(scores=="RS") {
    # right-skewed
    a<-rep(0,n)
    a[r<=floor((n+1)/2)]<-r[r<=floor((n+1)/2)]-floor((n+1)/2)-1
  }
  
  stat<-sum(a*trt) # linear rank statistic
  Estat<-mean(a)*n1 # expectation under H0
  Vstat<-n0*n1/(n^2*(n-1))*(n*sum(a^2)-(sum(a)^2)) # variance under H0
  z<-(stat-Estat)/sqrt(Vstat) # standardised test statistic
  
  return(z)
}

selectors<-function(db) {
  # computes the two selector statistics
  Z<-sort(db$y)
  n<-length(Z)
  
  L05<-mean(Z[1:round(n*0.05)])
  M5<-mean(Z[round(n*0.25):round(n*0.75)])
  U05<-mean(Z[round(n*0.95):n])
  L5<-mean(Z[1:round(n*0.5)])
  U5<-mean(Z[round(n*0.5):n])
  Q1<-(U05-M5)/(M5-L05)
  Q2<-(U05-L05)/(U5-L5)
  
  return(list(Q1=Q1,
              Q2=Q2))
}

Test<-function(db) {
  Q<-selectors(db)
  
  if((Q$Q1<2)&(Q$Q2<2)) {
    stat<-rank.stat(y=db$y,
                       trt = db$group-1,
                       scores = "LT")
  }
  if((Q$Q1<2)&(Q$Q2<7)&(Q$Q2>=2)) {
    stat<-rank.stat(y=db$y,
                       trt = db$group-1,
                       scores = "wilcoxon")
  }
  if((Q$Q1>=2)&(Q$Q2<7)) {
    stat<-rank.stat(y=db$y,
                       trt = db$group-1,
                       scores = "RS")
  }
  if(Q$Q2>=7) {
    stat<-rank.stat(y=db$y,
                       trt = db$group-1,
                       scores = "median")
  }
  
  p<-2*(1-pnorm(abs(stat)))
  
  return(list(
    stat=stat,
    p.value=p
  ))
}

