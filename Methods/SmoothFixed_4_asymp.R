# NAME
# Asymptotic smooth test of order 4 with Legendre polynomials
# DESCRIPTION
# Two sample smooth test with fixed order 4 and Legendre polynomials. P-values based on asymptotic approximation. The implementation is adapted from the R code from Thas (2010).
# HYPOTHESIS
# The null hypothesis states that two independent samples have the same underlying distribution. The alternative hypothesis states that two independent samples have different underlying distributions based on the first 4 (or 6) moments. 
# REFERENCES
# Janic‐Wróblewska A., & Ledwina, T. (2000). Data driven rank test for two‐sample problem. Scandinavian Journal of Statistics, 27(2), 281-297.
# Thas, O. (2010). Comparing distributions (Vol. 233). New York: Springer.
# 
# END

Lg <-
  function(k,a=0,b=1) {
    # Legendre polynomials
    n<-k
    h<-function(x){
      z<-(x-a)/(b-a)
      y<-0
      for (i in 0:n) {
        y<-y + ((-1)^(n)*(-z)^(i)*choose(n,i)*choose(n+i,i))
      }
      y<-y*sqrt(2*n+1)
      return(y)
    }
    return(h)
  }



Fourier <-
  function(k) {
    # Fourier basis functions
    even<-(k/2)==round(k/2,0)
    n<-k
    if(even) {
      h<-function(x) {
        y<-sqrt(2)*cos(2*pi*n*x)
        return(y)
      }
    }
    if(!even) {
      h<-function(x) {
        y<-sqrt(2)*sin(2*pi*n*x)
        return(y)
      }
    }
    if(k==0) {
      h<-function(x) {
        y<-1
        return(y)
      }
    }
    return(h)
  }



cdk <-
  function(x,g,order=4,basis="Lg",B=NULL,criterion="AIC",horizon="order",stat.only=F) {
    n<-length(x)
    ns<-as.numeric(table(g))
    k<-length(ns)
    r<-(rank(x)-0.5)/n
    comp<-matrix(nrow=k,ncol=order)
    cmp<-comp
    v<-comp
    order.select<-1:order
    
    x1<-x[1:ns[1]]
    x2<-x[(ns[1]+1):(ns[2]+ns[1])]
    for(i in 1:order) {
      fn<-switch(basis,Lg=Lg(i),Four=Fourier(i))
      ind<-1
      for(s in 1:k) {
        comp[s,i]<-sqrt(ns[s])*mean(fn(r[ind:(ns[s]+ind-1)]))
        cmp[s,i]<-comp[s,i]*sqrt(n/ns[s]) # where does this factor come from?
        ind<-ind+ns[s]
      }
    }
    stat<-sum(cmp^2)
    comps2<-colMeans(cmp^2)
    stat<-sum(comps2)
    
    # adaptive : only order implemented
    if(!is.null(criterion)) {
      penalty=switch(criterion,
                     AIC=2*(k-1),
                     BIC=(k-1)*log(n))
      crit<-cumsum(comps2-penalty*(1:order)) 
      order.select<-1:((1:order)[crit==max(crit)])
      stat<-cumsum(comps2)[crit==max(crit)]
    }
    
    
    if(is.null(B)) {
      p<-1-pchisq(comps2,df=k-1)
      p.stat<-1-pchisq(stat,df=order*(k-1)) 
      PMETHOD<-"the asymptotic approximation"
    }
    if(!is.null(B)) {
      PMETHOD<-"the approximate permutation null distribution"
      nd<-matrix(nrow=(order+1),ncol=B)
      for(i in 1:B) {
        x.B<-sample(x)
        tmp<-cdk(x=x.B,g=g,order=order,basis=basis,B=NULL,criterion=criterion,horizon=horizon,stat.only=T)
        nd[,i]<-c(tmp$stat,tmp$comp)
      }
      p.stat<-mean(stat<=nd[1,],na.rm=T)
      p<-sapply(2:(order+1),function(i,d,e) {mean(d[i-1]<=e[i,],na.rm=T)},d=comps2,e=nd)
    }
    
    tmp<-list(coefficients=comp,components=comps2,statistic=stat,p.values=c(p,p.stat),order=order,basis=basis,horizon=horizon,criterion=criterion,method.p.value=PMETHOD,K=k,order.selected=order.select,min.order=1)
    
    return(tmp)
}



Test<-function(db) {
  results<-cdk(x=db$y,g=db$group, order=4, basis="Lg", criterion = NULL, B=NULL)

  return(list(
    stat=results$statistic,
    p.value=results$p.values[5]
  ))
}

