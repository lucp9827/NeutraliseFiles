# DESCRIPTION
# The Generalized Tukey Lambda distribution -> generates skew distributions, consider only locationshift
Data.Generator<-function(n1=10,n2=10,parameters=c(0,1,2,3)) {
  
  delta <-parameters[1]
  scale <-parameters[2]
  lambda3 <-parameters[3]
  lambda4<-parameters[4]

  
  y=c(gld::rgl(n1,lambda2=scale,lambda3=lambda3,lambda4=lambda4),
      gld::rgl(n2,lambda1=delta,lambda2=scale,lambda3=lambda3,lambda4=lambda4))
  
  db<-data.frame(y=y, group=rep(c(1,2),c(n1,n2)))
  
  return(db)
}
