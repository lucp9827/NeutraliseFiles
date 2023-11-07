# DESCRIPTION
# Simulation of the Cauchy distribution

Data.Generator<-function(n1=10,n2=10,parameters=c(0,1,2)){
  
  delta<-parameters[1]
  scale1<-parameters[2]
  scale2<-parameters[3]

  y=c(rcauchy(n1,location=0,scale=scale1),rcauchy(n2,location=delta,scale=scale2))
  db<-data.frame(y=y, group=rep(c(1,2),c(n1,n2)))
  return(db)
}
