# NAME
# Asymptotic Kolmogorov-Smirnov test
# DESCRIPTION
# Two sample Kolmogorov-Smirnov test . P-values based on asymptotic approximation
# HYPOTHESIS
# The null hypothesis states that two independent samples have the same underlying distribution. The alternative hypothesis states that two independent samples have different underlying distributions. 
# REFERENCES
# Kolmogorov, A. N., Sulla Determinazione Empirica di Una Legge di Distribuzione, Giornale dell'Istituto Italiano degli Attuari, 4. 83-91. 1933. Smirnoff, N. "Sur les ?carts de la courbe de distribution empirique." Matematicheskii Sbornik 48.1 (1939): 3-26.
# END

Test<-function(db) {
    results<-ks.test(db$y[db$group==1],db$y[db$group==2],
                     alternative="two.sided")
    return(list(
      stat=results$statistic,
      p.value=results$p.value
    ))
}
  
