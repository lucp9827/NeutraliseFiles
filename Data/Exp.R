# DESCRIPTION
# Simulation of the exponential distribution

Data.Generator<-function(n1=10,n2=10,parameters=c(0,1)) {
  delta<-parameters[1]
  rate1<-parameters[2]
  
  y<-c(rexp(n1,rate = rate1),
       rexp(n2,rate = rate1)+delta)
  db<-data.frame(y=y, group=rep(c(1,2),c(n1,n2)))
  return(db)
}
