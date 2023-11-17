# DESCRIPTION
# Simulation of the g-and-h distribution, with an equal scale parameter in both groups and a kurtosis parameter = 0 in both groups.

Data.Generator<-function(n1=10,n2=10,parameters=c(0,1,2,3,4)) {
  
  z2gh = function(z, A, B, g, h, c=0.8, type=c("generalised", "tukey")) {
    ##Essentially this function calculates
    ##x = A + B * (1+c*tanh(g*z/2)) * z*exp(0.5*h*z^2) (generalised) or
    ##x = A + B * ((exp(g*z) - 1)/g) * exp(0.5*h*z^2) (Tukey)
    ##but treats some edge cases carefully
    
    ##Recycle inputs to same length as output
    n = max(length(z), length(A), length(B), length(g), length(h), length(c))
    zeros = rep(0, n)
    z = z + zeros
    A = A + zeros
    B = B + zeros
    g = g + zeros
    h = h + zeros
    c = c + zeros
    
    if (type == "generalised") {
      ##Standard calculatations
      term1 = 1+c*tanh(g*z/2)
      term2 = z*exp(0.5*h*z^2)
      
      ##Correct edge cases
      ##(likely to be rare so no need for particularly efficient code)
      term1[g==0] = 1 ##Avoids possibility of 0*Inf
      term2[h==0] = z
      
      output = A + B*term1*term2
    } else if (type == "tukey") {
      ##Standard calculatations
      term1 = expm1(g*z)/g
      term2 = exp(0.5*h*z^2)
      
      ##Correct edge cases
      term1[g==0] = z
      
      output = A + B*term1*term2
    } else {
      stop("Only generalised and tukey type are implemented")
    }
    
    return(output)
  }
  
  
  
  
  
  rgh = function(n, A, B, g, h, c=0.8, type=c("generalised", "tukey")){
    type = match.arg(type)
    z2gh(stats::rnorm(n), A, B, g, h, c, type)
  }
  
  
  
  
  
  
  delta<-parameters[1]
  sd<-parameters[2]
  g1<-parameters[3]
  g2<-parameters[4]
  h<-parameters[5]

  
  y=c(rgh(n1,A=0,B=sd,g=g1,h=h),rgh(n2,A=delta,B=sd,g=g2,h=h))
  db<-data.frame(y=y, group=rep(c(1,2),c(n1,n2)))
  return(db)
}

