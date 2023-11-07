# DESCRIPTION
# Simulation of the g-and-h distribution, with an equal scale parameter in both groups and a kurtosis parameter = 0 in both groups.

Data.Generator<-function(n1=10,n2=10,parameters=c(0,1,2,3,4)) {
  
  delta<-parameters[1]
  sd<-parameters[2]
  g1<-parameters[3]
  g2<-parameters[4]
  h<-parameters[5]

  
  y=c(gk::rgh(n1,A=0,B=sd,g=g1,h=h),gk::rgh(n2,A=delta,B=sd,g=g2,h=h))
  db<-data.frame(y=y, group=rep(c(1,2),c(n1,n2)))
  return(db)
}

