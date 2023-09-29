# Function to return all method names ran in Neutralise

All_Neutralised<-function(neutralise.status,
                          type="method") {
  names<-neutralise.status$name[
    (neutralise.status$type==type)&
      (neutralise.status$neutralised)]
  names(names)=names

  return(names)
}

# Function to return all scenarios ran in Neutralise

All_Neutralised_Scenarios<-function(data, type='power') {
  dir<-dir(paste("settings/",data,"_settings",sep=""))
  file<-paste("settings/",data,
              "_settings.RData",
              sep="")
  load(file)

  if (type=='power'){
  settings<-settings[settings$null==0,]
  scenarios<-subset(settings,select=-null)
  id=c(1:nrow(scenarios))
  scenarios<-cbind(id,scenarios)
  
  if(data=='Exp'){
    scenarios[scenarios$rate1==0.12,'rate1']=0.125
  }
  
  }else{
    settings<-settings[settings$null!=0,]
    scenarios<-subset(settings,select=-null)
    id=c(1:nrow(scenarios))
    scenarios<-cbind(id,scenarios)
    
    if(data=='Exp'){
      
    }
    
  }
  return(scenarios)
}


# Function to plot the power of two methods

Power_QQ<-function(method1,method2,results_list,alpha=0.05,
                   par.fix=NULL,
                   data=NULL,
                   col="black",group=FALSE,CI=FALSE, filter=TRUE,n="") {
  # data = data generation tool
  dis = c("Normal","Normal2Var","Cauchy","Exp","ghEqual","ghEqualK","GLDLS","Logistic")
  scen  = c(18,18,36,30,35,35,25,28)
  scen_al = scen*4
  scen_per = scen_al/c(3,3,6,5,7,7,5,4)
  scen_tt = scen_per/4
  
  hope = data.frame(distribution=dis, scenarios=scen, scenarios_sample=scen_al,scen_per=scen_per,scen_tt=scen_tt)
  # Read finished file
  finished<-read.csv("results/Finished.txt",sep=",",header=T)

  # Save data generation methods ran per specified method

  if (is.null(data)){

    data1<-finished$data[finished$method==method1]
    data2<-finished$data[finished$method==method2]
    data.i<-intersect(data1,data2)

  }else {

    data.i=data
  }

  results1<-list()
  results2<-list()
  total_tmp=data.frame()
  win2<-0
  cnt.scenarios<-0
  cnt<-1
  text_group=c()
  text_mis1=c()
  for(d in data.i) {

    results1_tmp = results_list[[d]][results_list[[d]]$method==method1,]
    results2_tmp = results_list[[d]][results_list[[d]]$method==method2,]


    if(!is.null(data)) {
      results1_tmp<-results1_tmp[results1_tmp$distribution==d,]
      results2_tmp<-results2_tmp[results2_tmp$distribution==d,]
    }

    if(!is.null(par.fix))  {
      settings.fix<-results1_tmp%>%dplyr::select(names(par.fix))
      results1_tmp<-results1_tmp[apply(settings.fix,1,
                                       function(x) {
                                         all(x==unlist(par.fix))
                                       }),]

      settings.fix<-results2_tmp%>%dplyr::select(names(par.fix))
      results2_tmp<-results2_tmp[apply(settings.fix,1,
                                       function(x) {
                                         all(x==unlist(par.fix))
                                       }),]
    }

    results1[[d]]<-results1_tmp
    results2[[d]]<-results2_tmp

    if (!filter){
    results1_tmp = filter_significance(results1_tmp,alpha)
    results2_tmp = filter_significance(results2_tmp,alpha)
    }
    cnt<-cnt+1

    results1_tmp$scenario = paste(results1_tmp$distribution,results1_tmp$id)
    results2_tmp$scenario = paste(results2_tmp$distribution,results2_tmp$id)

    results1_tmp = results1_tmp[,c(1:7,which(colnames(results1_tmp)=='power'):length(colnames(results1_tmp)))]
    results2_tmp = results2_tmp[,c(1:7,which(colnames(results2_tmp)=='power'):length(colnames(results2_tmp)))]

    if (!length(results1_tmp$scenario)==length(results2_tmp$scenario)){
      rownames(results1_tmp$scenario)=NULL
      rownames(results2_tmp$scenario)=NULL
    tt1 = merge(results1_tmp,results2_tmp,by=c('scenario','n'))
    }else{
      colnames(results1_tmp) = paste0(colnames(results1_tmp),".x")
      colnames(results2_tmp) = paste0(colnames(results2_tmp),".y")
      names(results2_tmp)[names(results2_tmp)=='n.y'] <- 'n'
      results1_tmp= subset(results1_tmp,select=-n.x)
      names(results2_tmp)[names(results2_tmp)=='scenario.y'] <- 'scenario'
      results1_tmp= subset(results1_tmp,select=-scenario.x)

      tt1=cbind(results1_tmp,results2_tmp)
    }


    tt2 = remove_missing(tt1)
      
      
      if (n!=""){
        tt2=tt2[tt2$n==n,]
        hope$number = hope$scenarios
      }else{
        hope$number = hope$scenarios_sample
      }
    
    if((!is.null(par.fix))&(n=="")){
      hope$number = hope$scen_per
    }
    if((!is.null(par.fix))&(n!="")){
      hope$number = hope$scen_tt
    }
    
    

    win2<-win2+sum(tt2[,'power.x'] < tt2[,'power.y'])
    cnt.scenarios<-cnt.scenarios+length(tt2[,'power.x'] < tt2[,'power.y'])

    if (group){
      win_tmp = sum(tt2[,'power.x'] < tt2[,'power.y'])
      text_group=c(text_group,paste(d,": ",method2," has higher power than ",method1, " in ", round(100*win_tmp/length(tt2[,'power.x'] < tt2[,'power.y']),2),
                                    "% of the ",length(tt2[,'power.x'] < tt2[,'power.y']), " scenarios where both methods control the type I error rate.\n",sep=""))
    
      
      
      text_mis1 = c(text_mis1,paste(d,": in ", hope[hope$distribution==d,'number']-length(tt2[,'power.x'] < tt2[,'power.y']), " scenarios at least one method did not control the type I error rate." ))
      
      
      }

    total_tmp = rbind(total_tmp,tt2)
  }


  txt=(paste(method2," has higher power than ",method1, " in ", round(100*win2/cnt.scenarios,2),
             "% of the ", cnt.scenarios, " scenarios where both methods control the type I error rate.\n",sep=""))

  if (length(data.i)==1){
    text_mis = c(paste("In ",sum(hope[hope$distribution==data.i,'number'])-cnt.scenarios, " scenarios at least one method did not control the type I error rate." ))
  }else{
  text_mis = c(paste("In ",sum(hope$number)-cnt.scenarios, " scenarios at least one method did not control the type I error rate." ))
  }
  
  
  
  if (!group){
    p<-ggplot(total_tmp,aes(x=power.x,y=power.y))+
      geom_point(colour=col)+
      ylim(0,1)+xlim(0,1)+
      geom_abline()+
      xlab(paste("power of ",method1,sep=""))+
      ylab(paste("power of ",method2,sep=""))+ theme(axis.text.x = element_text(size = 15),
                                                     axis.text.y = element_text(size = 15),
                                                     axis.title = element_text(size = 20),
                                                     legend.key.size = unit(1, 'cm'),
                                                     legend.title = element_text(size=15),legend.text = element_text(size=15))
  }else{
    p<- ggplot(total_tmp,aes(x=power.x,y=power.y))+
        geom_point(aes(colour=factor(distribution.x)),size=3)+
        ylim(0,1)+xlim(0,1)+
        geom_abline()+
        xlab(paste("power of ",method1,sep=""))+
        ylab(paste("power of ",method2 ,sep=""))+
        labs(colour='Data generation method')+ theme(axis.text.x = element_text(size = 15),
                                                     axis.text.y = element_text(size = 15),
                                                     axis.title = element_text(size = 18),
                                                     legend.key.size = unit(1, 'cm'),
                                                     legend.title = element_text(size=15),legend.text = element_text(size=15))
  }

  if (group){
    txt=text_group
    text_mis=text_mis1
  }

  if (CI){
    p+geom_smooth(method=lm)
  }else{
    p}

  (list(win.pct=win2/cnt.scenarios,
        results1=results1,
        results2=results2,
        total=total_tmp,
        graph=p,
        text=txt,
        text2=text_mis
        ))#text2=text_mis

}
# Function to plot the Type I error rate of one method

Boxplot_TypeI<-function(method,results,alpha=0.05,tol=0.02,panel="",ylim=c(0,0.10),group=TRUE) {

  if(alpha==0.01){
    ylim=c(0,0.08)
  }
  if(alpha==0.10){
    ylim=c(0.04,0.13)
  }
  if(alpha==0.05){
    ylim=c(0,0.13)
  }

  data = names(results)
  lowlim = optimise(function(p){(p+sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
  uplim = optimise(function(p){(p-sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
  if (!group){

    cnt.scenarios<-0
    cnt<-1
    pwr<-c()
    distr<-c()
    n<-c()
    results1<-data.frame()

    for(d in data) {

      if (d=='Normal2Var'){
        d='Normal'
      }

      results_method = results[[d]][results[[d]]$method==method,]

      results_method = filter_significance(results_method,alpha)

      results_method$n = results_method$n1+results_method$n2

      n<-c(n,results_method$n)

      cnt<-cnt+1

      cnt.scenarios<-cnt.scenarios+nrow(results_method)

      results1 = rbind(results1,results_method[,c(1:6,(ncol(results_method)-13):ncol(results_method))])

      # cat(paste(d,results_method[results_method$distribution==d,'id']," with a total sample size of ",results_method[results_method$distribution==d,'n'],":\n",method," has a type I error rate of ",
      #           round(results_method[results_method$distribution==d,'power'],2)," at the nominal ",
      #           alpha," level.\n",sep=""))
    }

    #boxplot(pwr,
    #        ylab=paste("Type I error rate of ",
    #                   deparse(substitute(method)),sep=""))


    txt =c(paste("On average (over all scenarios) :",method," has a type I error rate not larger than ",
                alpha," + ",tol," in ",
                round(100*mean(results_method[,'power']<alpha+tol,na.rm = TRUE),1),
                "% of the scenarios.\n",sep=""))


    if(panel=="") {
      p0<-ggplot(results1,aes(x="",y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=n),size=3)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = 'dotted',size=1)+
        geom_hline(yintercept= uplim, linetype = 'dotted',size=1)+
        xlab("")+ theme(axis.text.x = element_text(size = 20, angle = 90),
                        axis.text.y = element_text(size = 20),
                        axis.title = element_text(size = 19),
                        strip.text.x = element_text(size = 15),
                        legend.key.size = unit(1.5, 'cm'),
                        legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Sample size (total)')
    }
    if(panel=="distribution") {
      results1$n=factor(results1$n)
      p0<-ggplot(results1,aes(x=distribution,y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=n),size=3)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = 'dotted',size=1)+
        geom_hline(yintercept= uplim, linetype = 'dotted',size=1)+
        xlab("")+ theme(axis.text.x = element_text(size = 20, angle = 90),
                        axis.text.y = element_text(size = 20),
                        axis.title = element_text(size = 19),
                        strip.text.x = element_text(size = 15),
                        legend.key.size = unit(1.5, 'cm'),
                        legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Sample size (total)')
    }
    if(panel=="n") {
      results1$n=factor(results1$n)
      p0<-ggplot(results1,aes(x=n,y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=distribution),size=3)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = 'dotted',size=1)+
        geom_hline(yintercept= uplim, linetype = 'dotted',size=1)+
        xlab("")+ theme(axis.text.x = element_text(size = 20, angle = 90),
                        axis.text.y = element_text(size = 20),
                        axis.title = element_text(size = 19),
                        strip.text.x = element_text(size = 15),
                        legend.key.size = unit(1.5, 'cm'),
                        legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Data generation method')
    }
   
  }else{


    txt=c()
    results1<-data.frame()
      cnt.scenarios<-0
      cnt<-1


      for(d in data) {

        if (d=='Normal2Var'){
          d='Normal'
        }

        results_data= results[[d]]
        method=unique(results_data$method)

        for (m in method){

        results_method = results_data[results_data$method==m,]

        results_method = filter_significance(results_method,alpha)

        results_method$n = results_method$n1+results_method$n2

        n<-c(n,results_method$n)

        cnt<-cnt+1

        cnt.scenarios<-cnt.scenarios+nrow(results_method)

        results1 = rbind(results1,results_method[,c(1:6,(ncol(results_method)-13):ncol(results_method))])

        # cat(paste(d,results_method[results_method$distribution==d,'id']," with a total sample size of ",results_method[results_method$distribution==d,'n'],":\n",method," has a type I error rate of ",
        #           round(results_method[results_method$distribution==d,'power'],2)," at the nominal ",
        #           alpha," level.\n",sep=""))

        }

      #boxplot(pwr,
      #        ylab=paste("Type I error rate of ",
      #                   deparse(substitute(method)),sep=""))

      }

      for (m in method){
      txt =c(txt,paste("On average (over all scenarios) :",m," has a type I error rate not larger than ",
                       alpha," + ",tol," in ",
                       round(100*mean(results1[results1$method==m,'power']<alpha+tol,na.rm = TRUE),1),
                       "% of the scenarios.\n",sep=""))
      }
    if(panel=="") {
      p0<-ggplot(results1,aes(x="",y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=n),size=2)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = "dotted",size=1)+
        geom_hline(yintercept= uplim, linetype = "dotted",size=1) +
        xlab("")+
        facet_wrap(~method,ncol=3)+ theme(axis.text.x = element_text(size = 20, angle = 90),
                                          axis.text.y = element_text(size = 20),
                                          axis.title = element_text(size = 18),
                                          strip.text.x = element_text(size = 15),
                                          legend.key.size = unit(1.5, 'cm'),
                                          legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Sample size (total)')
    }
    if(panel=="distribution") {
      results1$n=factor(results1$n)
      p0<-ggplot(results1,aes(x=distribution,y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=n),size=2)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = "dotted",size=1)+
        geom_hline(yintercept= uplim, linetype = "dotted",size=1) +
        xlab("")+
        facet_wrap(~method,ncol=3)+ theme(axis.text.x = element_text(size = 20, angle = 90),
                                          axis.text.y = element_text(size = 20),
                                          axis.title = element_text(size = 18),
                                          strip.text.x = element_text(size = 15),
                                          legend.key.size = unit(1.5, 'cm'),
                                          legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Sample size (total)')
    }
    if(panel=="n") {
      results1$n=factor(results1$n)
      p0<-ggplot(results1,aes(x=n,y=power))
      graph=p0+
        geom_boxplot()+
        geom_jitter(alpha=0.6,width = 0.2, aes(colour=distribution),size=2)+
        lims(y=c(0,0.13))+
        ylab(paste("Type I error rate of ",
                   {{method}},sep=""))+
        geom_hline(yintercept=alpha, linetype="dotted", colour="red",size=1)+
        geom_hline(yintercept= lowlim,linetype = "dotted",size=1)+
        geom_hline(yintercept= uplim, linetype = "dotted",size=1) +
        xlab("")+
        facet_wrap(~method,ncol=3)+ theme(axis.text.x = element_text(size = 20, angle = 90),
                                          axis.text.y = element_text(size = 20),
                                          axis.title = element_text(size = 18),
                                          strip.text.x = element_text(size = 15),
                                          legend.key.size = unit(1.5, 'cm'),
                                          legend.title = element_text(size=18),legend.text = element_text(size=20))+
        labs(colour='Sample size (total)')
    }
    

  }

  return(list(graph=graph,text=txt,data=results1))
}

# Function to plot the power in a curve, in function of delta


unique_combinations = function(data_gen){

  df = All_Neutralised_Scenarios(data_gen)
  df = subset(df,select=-id)
  df = subset(df,select=-delta)
  unique(df)

}

Power_curve_ALL<-function(methods,results,results_power,alpha=0.05,n=40,
                          par.fix=NULL,
                          data=NULL,
                          col="black",group=FALSE,CI=FALSE,neutralise.status) {#,filter

  alpha=alpha
  N=10000
  # load('results_typeI_perdatagen.RData')
  # results = results_datagen_type1
  
  #load('results_power_perdatagen.RData')
  results_list = results_power
  rm(results_power)
  
  #results_list = filter_type1(results,results_power=results_list,alpha)$filter_list
  
  
  end = list()
  datgen = c(names(results_list))
  for (d in datgen){
    
    data_power_dist = results_list[[d]]
    
    if (d=='Normal2Var'){
      data_type1_dist = results[['Normal']]
    }else{
      data_type1_dist = results[[d]]}
    data_type1_dist = filter_significance(data_type1_dist,alpha)
    
    uplim = optimise(function(p){(p-sqrt(p*(1-p)/N)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
    
    data_type1_dist$control= data_type1_dist$power<=uplim
    data_type1_dist = data_type1_dist[data_type1_dist$control==TRUE,]
    
    ind=c()
    colnr_1 = grep('delta',colnames(data_power_dist))+1
    colnr_2 = grep('power',colnames(data_power_dist))-1
    colnr_n = grep('cnt',colnames(data_power_dist))+1
    #colnr_m = grep('method', colnames(data_type1_dist))
    if(colnr_2-colnr_1>2){
      ind=c(colnr_1,colnr_1+1,colnr_n)
    }else{ind = c(colnr_1,colnr_n)}
    
    
    data_type1_dist = remove_missing(data_type1_dist)
    data_power_dist = remove_missing(data_power_dist)
    data_power_dist_orig = data_power_dist

    
    
    for (i in (1:nrow(unique(data_power_dist[,ind])))){
      
      if(d=="Normal2Var"){
        df1= data.frame(unique(data_power_dist[,c(ind[1],ind[2])])[i,])
      }else{
        df1= data.frame(unique(data_power_dist[,ind])[i,])}
      settings.fix<-data_power_dist%>%dplyr::select(names(df1))
      data_power_dist_1<-data_power_dist[apply(settings.fix,1,
                                               function(x) {
                                                 all(x==unlist(df1))
                                               }),]
      
      methodstt = unique(data_power_dist_1$method)
      for (m in methodstt){
        if(m=='Gastwirth'){next}
        
        data_tt = data_power_dist_1[data_power_dist_1$method==m,]
        
        if(colnr_1==colnr_2){
          extra_0 = data.frame(unique(data_tt[,colnr_1]))
          rownames(extra_0) = rownames(data_tt)[1]
        }else{
          if(colnr_2-colnr_1>2){
            extra_0 = data.frame(unique(data_tt[,c(colnr_1,colnr_1+1,colnr_1+2)]))
          }else{
            extra_0 = data.frame(unique(data_tt[,c(colnr_1,colnr_2)]))
          }
          
        }
        
        t1 = data.frame(rn=rownames(data_tt))
        
        t2= c(rownames(extra_0))
        data_extra= data_tt[match(t2, t1$rn),]
        
        data_extra$delta=0
        
        if ((colnr_2-colnr_1)<=2){
          data_typeI_meth = data_type1_dist[data_type1_dist$method==m,]
          power_add = data_typeI_meth[data_typeI_meth[,c(colnr_1)] == data_extra[1,colnr_1],]
          if(d=="Normal2Var"){power_add= power_add[power_add[,colnr_n-1]==data_extra$n[1],]}else{
            power_add= power_add[power_add[,colnr_n]==data_extra$n[1],]}
        }else{
          
          data_typeI_meth = data_type1_dist[data_type1_dist$method==m,]
          power_add = data_typeI_meth[data_typeI_meth[,c(colnr_1)] == data_extra[1,colnr_1],]
          power_add = power_add[power_add[,c(colnr_1+1)] == data_extra[1,colnr_1+1],]
          power_add= power_add[power_add[,colnr_n]==data_extra$n[1],]
        }
        
        if (nrow(power_add)!=0){
        data_extra$power = power_add$power
        data_extra$l_CI = power_add$l_CI
        data_extra$u_CI = power_add$u_CI
        data_power_dist_orig = rbind(data_power_dist_orig, data_extra)
        }else{next}
      }
      
    }
    end[[d]]= data_power_dist_orig
  }
  
  
  results = end
  
  
  # Read finished file
  if (is.null(data)){
data.i<-names(results)
  }else{
    data.i=data
  }


  if (group){
    #load(file = "results\\neutralisestatus.RData")
    methods=neutralise.status[neutralise.status$type=='method','name']
  }

  end=data.frame()

  for(d in data.i) {


    #results1<-list()
    results1<-data.frame()
    win2<-0
    cnt.scenarios<-0
    pwr1<-data.frame()
    data.gen<-c()
    methods=unlist(c(methods))
    for (m in methods){

      # specify folder in results file
      results_dm = results[[d]][results[[d]]$method==m,]


      if(!is.null(par.fix)) {
        settings.fix<-results_dm%>%dplyr::select(names(par.fix))
        results_dm<-results_dm[apply(settings.fix,1,
                                     function(x) {
                                       all(x==unlist(par.fix))
                                     }),]
      }

      results1<-rbind(results1,results_dm)

    }

    # if (!filter){
    # results1 = filter_significance(results1,alpha)
    # }
    end_tmp=data.frame(method=results1$method,
                       data.gen=results1$distribution,n=results1$n,delta=results1$delta,power=results1$power,l_CI=results1$l_CI,u_CI=results1$u_CI)

    end=rbind(end,end_tmp)

  }

  end$n=as.factor(end$n)
  end=remove_missing(end)
  
  end1= end[end$n==n,]
  
  if (n==""){
  if (CI){
    graph=ggplot(end,aes(x=delta,y=power, group=n))+
      geom_line(aes(col=n),linewidth=1.3)+
      geom_point(aes(col=n))+
      geom_errorbar(aes(ymin = l_CI, ymax = u_CI,col=n), width = 0.2)+
      ylim(0:1)+facet_wrap(~method,ncol=3)+
      xlab("Difference in means")+
      theme(axis.text.x = element_text(size = 15),
                                        axis.text.y = element_text(size = 15),
                                        axis.title = element_text(size = 18),
                                        strip.text.x = element_text(size = 15),
                                        legend.key.size = unit(1.5, 'cm'),
                                        legend.title = element_text(size=15),legend.text = element_text(size=15))+
      labs(colour='Sample size (total)')}
  else{  graph=ggplot(end,aes(x=delta,y=power, group=n))+
    geom_line(aes(col=n),linewidth=1.3)+
    geom_point(aes(col=n))+
    ylim(0:1)+ facet_wrap(~method,ncol=3)+
    xlab("Difference in means")+
    theme(axis.text.x = element_text(size = 15),
                                      axis.text.y = element_text(size = 15),
                                      axis.title = element_text(size = 18),
                                      strip.text.x = element_text(size = 15),
                                      legend.key.size = unit(1.5, 'cm'),
                                      legend.title = element_text(size=15),legend.text = element_text(size=15))+
    labs(colour='Sample size (total)')
  }
    }else{ if (CI){
    graph=ggplot(end1,aes(x=delta,y=power, group=method))+
      geom_line(aes(col=method),linewidth=1.3)+
      geom_point(aes(col=method))+
      geom_errorbar(aes(ymin = l_CI, ymax = u_CI,col=method), width = 0.2)+
      xlab("Difference in means")+
      ylim(0:1)+#facet_wrap(~method,ncol=3)
      theme(axis.text.x = element_text(size = 15),
            axis.text.y = element_text(size = 15),
            axis.title = element_text(size = 18),
            strip.text.x = element_text(size = 15),
            legend.key.size = unit(1.5, 'cm'),
            legend.title = element_text(size=15),legend.text = element_text(size=15))+
      labs(colour='Data generation method')}
    else{  graph=ggplot(end1,aes(x=delta,y=power, group=method))+
      geom_line(aes(col=method),linewidth=1.3)+
      xlab("Difference in means")+
      geom_point(aes(col=method))+
      ylim(0:1)+ #facet_wrap(~method,ncol=3)
      theme(axis.text.x = element_text(size = 15),
            axis.text.y = element_text(size = 15),
            axis.title = element_text(size = 18),
            strip.text.x = element_text(size = 15),
            legend.key.size = unit(1.5, 'cm'),
            legend.title = element_text(size=15),legend.text = element_text(size=15))+
      labs(colour='Data generation method')
    
  }

  }

  return(list(graph))
}

## Function to summarize methods
sum_methods = function(){

  method.files<-dir(path=paste("Methods",sep=""))
  load(paste("Results/neutralisestatus.RData",sep=""))
  method.exists<-method.files%in%neutralise.status$file.name[
    (neutralise.status$type=="method")&
      (neutralise.status$check==TRUE)]

  text=data.frame()

  for (i in (1:length(method.files))){

    filename_temp=method.files[i]

    filename<-paste("Methods/",filename_temp,sep="")

    con=file(filename,"r")
    tmp<-readLines(con,n=-1)
    close(con)

    name_id = which(tmp=="# NAME")
    name_txt = tmp[name_id+1]
    name_txt = gsub('#','',name_txt)
    
    hep_id = which(tmp=="# HYPOTHESIS")
    hep_txt = tmp[hep_id+1]
    hep_txt = gsub('#','',hep_txt)
    

    des_id = which(tmp=="# DESCRIPTION")
    des_txt = tmp[des_id+1]
    des_txt = gsub('#','',des_txt)

    ref_id = which(tmp=="# REFERENCES")
    ref_txt = tmp[ref_id+1]
    ref_txt = gsub('#','',ref_txt)

    abbriv_txt=gsub('.R','',filename_temp)

    text_tmp= data.frame(Abbriviation=abbriv_txt,Name=name_txt,Hypotheses=hep_txt,Description=des_txt,References=ref_txt)

    text=rbind(text,text_tmp)
  }

  return(text)
}

## Function to generate graph based on moments of distribution

filter_significance = function(results,alpha){

  x= colnames(results)

  if (alpha==0.05){

    x_0.10 = 0.10
    colnr = grep(as.numeric(x_0.10 ),x)
    results_tmp=results[,-c(colnr)]

    x= colnames(results_tmp)
    x_0.01 = 0.01

    colnr = grep(as.numeric(x_0.01 ),x)
    results_tmp=results_tmp[,-c(colnr)]
  }
  if (alpha==0.01){

    x_0.10 = 0.10
    colnr = grep(as.numeric(x_0.10 ),x)
    results_tmp=results[,-c(colnr)]

    x= colnames(results_tmp)
    x_0.05 = 0.05

    colnr = grep(as.numeric(x_0.05 ),x)
    results_tmp=results_tmp[,-c(colnr)]
  }
  if (alpha==0.10){

    x_0.01 = 0.01
    colnr = grep(as.numeric(x_0.01 ),x)
    results_tmp=results[,-c(colnr)]

    x= colnames(results_tmp)
    x_0.05 = 0.05

    colnr = grep(as.numeric(x_0.05 ),x)
    results_tmp=results_tmp[,-c(colnr)]

  }
  x= colnames(results_tmp)
  colnr = grep(as.numeric(alpha),x)
  colnames(results_tmp)[colnr]=c("power","l_CI","u_CI","cnt")

  return(results_tmp)
}

moments_curve = function(method,alpha,moment='mom3_1',n=n,results,group=FALSE,filter=FALSE,ylabs,ylim=c(0,1)){

  
  results = results[results$distribution!="Cauchy",]
  
  if (filter==FALSE){
    results_tmp = filter_significance(results,alpha)
  }else{
    results_tmp=results
  }


    if (group==TRUE){
      results_tmp_method = results_tmp[(results_tmp$n==n) ,]
      } else{
      results_tmp_method = results_tmp[(results_tmp$method==method & results_tmp$n==n) ,]

    }

   results_end = results_tmp_method[,moment]
   
   
   if(moment=='mom1_1'){
     tekst = "Difference in means"
     results_end = results_tmp_method[,'mom1_2']-results_tmp_method[,'mom1_1']
   }
   
   if(moment=='mom1_2'){
     tekst = "Difference in means"
     results_end = results_tmp_method[,'mom1_2']-results_tmp_method[,'mom1_1']
   }
   
   
   if(moment=='mom2_1'){
     tekst = "Ratio of Variances"
     results_end = results_tmp_method[,'mom2_1']/results_tmp_method[,'mom2_2']
     
   }
   
   if(moment=='mom2_2'){
     tekst = "Ratio of Variances"
     results_end = results_tmp_method[,'mom2_1']/results_tmp_method[,'mom2_2']
   }

   
   if(moment=='mom3_1'){
     tekst = "Skewness"
   }
   
   if(moment=='mom3_2'){
     tekst = "Skewness"
   } 
   
   if(moment=='mom4_1'){
     tekst = "Kurtosis"
   }
   
   if(moment=='mom4_2'){
     tekst = "Kurtosis"
   } 
   
   

  graph = ggplot(results_tmp_method,aes(x=results_end,y=power,group=distribution))+
    geom_point(aes(col=distribution),size=3)+
    xlab(tekst)+
    ylab(ylabs)+
    ylim(ylim)+
  facet_wrap(~method,ncol=3)+ theme(axis.text.x = element_text(size = 15),
                                    axis.text.y = element_text(size = 15),
                                    axis.title = element_text(size = 18),
                                    strip.text.x = element_text(size = 15))



  return(list(graph=graph,data=results_tmp_method))
}

filter_type1 = function(results,results_power,alpha){
  # which scenarios to filter out?
  lowlim = optimise(function(p){(p+sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
  uplim = optimise(function(p){(p-sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum

  filter_data_list = list()
  filter_data_df = data.frame()

  data = names(results_power)

  for (d in data){
    
    if (d=='Exp'){
      results_power[['Exp']][results_power[['Exp']]$rate1==0.12,'rate1']=0.125
    }

    if (d!='Normal2Var'){
    results_id = results[[d]]
    }else{
      results_id = results[['Normal']]
    }

    results_tmp=filter_significance(results_id,alpha)
    rm(results_id)


    results_tmp$control= results_tmp$power<=uplim
    results_tmp[is.na(results_tmp$control),'control']<-FALSE

    filter_data = results_tmp[results_tmp$control==FALSE,]


    filter_data = subset(filter_data, select=-N)
    filter_data = subset(filter_data, select=-seed)
    filter_data = subset(filter_data, select=-delta)
    filter_data = subset(filter_data, select=-control)
    filter_data = subset(filter_data, select=-id)
    filter_data = subset(filter_data, select=-power)
    filter_data = subset(filter_data, select=-l_CI)
    filter_data = subset(filter_data, select=-u_CI)
    filter_data = subset(filter_data, select=-mom1_1)
    filter_data = subset(filter_data, select=-mom1_2)
    filter_data = subset(filter_data, select=-mom2_1)
    filter_data = subset(filter_data, select=-mom2_2)
    filter_data = subset(filter_data, select=-mom3_1)
    filter_data = subset(filter_data, select=-mom3_2)
    filter_data = subset(filter_data, select=-mom4_1)
    filter_data = subset(filter_data, select=-mom4_2)
    filter_data = subset(filter_data, select=-cnt)

    methods_test = unique(filter_data$method )
    itt=which(colnames(filter_data)=='n2')+1
    settng_cols= filter_data[,c(1,itt:(length(filter_data)))]

    if(d=='Normal2Var'){
      settng_cols=data.frame(method=settng_cols$method,sd1=settng_cols$sd,sd2=settng_cols$sd,n=settng_cols$n)
    }

    Results_power = results_power[[d]]
    Results_power = filter_significance(Results_power,alpha)
    Results_power$control=TRUE

    for (m in methods_test){
      for (i in colnames(settng_cols)[-c(1,length(settng_cols))]){

        val =  unique(settng_cols[settng_cols$method==m,c(i,'n')])

        for (j in (1:nrow(val))){


          n=val[j,'n']

          keep =  Results_power[Results_power$method==m&Results_power$n==n,'control']

          for (l in (1:length(keep))){

            Results_power[Results_power$method==m&Results_power$n==n,'control'][l]= ifelse((( Results_power[Results_power$method==m&Results_power$n==n,c(i)][l]==val[j,1])& Results_power[Results_power$method==m&Results_power$n==n,'control'][l]==TRUE),FALSE,keep[l])

          }


        }
      }
    }




    end_power_data = Results_power[Results_power$control==TRUE,]

    filter_data_list[[d]] = end_power_data

    # convert in a data frame
    if (d=='Normal2Var'){
      scenarios = All_Neutralised_Scenarios(d,type="power")
    }else{
    scenarios = All_Neutralised_Scenarios(d,type="type1")
    }
    scenario_filter = scenarios[,-c(1:2)]
    scenario_filter = data.frame(scenario_filter)
    names(scenario_filter ) <- names(scenarios)[-c(1:2)]

    end_power_data_tmp = end_power_data[,!names(end_power_data)%in% names(scenario_filter )]
    filter_data_df = rbind(filter_data_df,end_power_data_tmp )

  }

  return(list(filter_list=filter_data_list, filter_df=filter_data_df))
}

fil_for_type1 = function(results,alpha){

  lowlim = optimise(function(p){(p+sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
  uplim = optimise(function(p){(p-sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum

  # which scenarios to filter out?
  filter_data_list = list()
  filter_data_df = data.frame()

  data = names(results)

  for (d in data){

    results_id = results[[d]]

    results_tmp=filter_significance(results_id,alpha)

    #results_tmp$control= results_tmp$power>=lowlim&results_tmp$power<=uplim
    results_tmp$control= results_tmp$power<=uplim

    filter_data = results_tmp[results_tmp$control==FALSE,]


    filter_data = subset(filter_data, select=-N)
    filter_data = subset(filter_data, select=-seed)
    filter_data = subset(filter_data, select=-delta)
    filter_data = subset(filter_data, select=-control)
    filter_data = subset(filter_data, select=-id)
    filter_data = subset(filter_data, select=-power)
    filter_data = subset(filter_data, select=-l_CI)
    filter_data = subset(filter_data, select=-u_CI)
    filter_data = subset(filter_data, select=-mom1_1)
    filter_data = subset(filter_data, select=-mom1_2)
    filter_data = subset(filter_data, select=-mom2_1)
    filter_data = subset(filter_data, select=-mom2_2)
    filter_data = subset(filter_data, select=-mom3_1)
    filter_data = subset(filter_data, select=-mom3_2)
    filter_data = subset(filter_data, select=-mom4_1)
    filter_data = subset(filter_data, select=-mom4_2)
    filter_data = subset(filter_data, select=-cnt)
    #Results_power = results_power[[d]]


    end_power_data = anti_join( results_tmp ,filter_data)

    filter_data_list[[d]] = end_power_data

    # convert in a data frame
    scenarios = All_Neutralised_Scenarios(d,type="type1")
    scenario_filter = scenarios[,-c(1:2)]
    scenario_filter = data.frame(scenario_filter)
    names(scenario_filter ) <- names(scenarios)[-c(1:2)]

    end_power_data_tmp = end_power_data[,!names(end_power_data)%in% names(scenario_filter )]
    filter_data_df = rbind(filter_data_df,end_power_data_tmp )

  }

  return(list(filter_list=filter_data_list, filter_df=filter_data_df))
}

filtered_data_scenarios = function(results,data,alpha){
  lowlim = optimise(function(p){(p+sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum
  uplim = optimise(function(p){(p-sqrt(p*(1-p)/10000)*qnorm(alpha/2, mean = 0, sd = 1, lower.tail = FALSE)-alpha)^2}, interval=c(0,1))$minimum


    for (d in data){

      if (d == 'Normal2Var'){
        d='Normal'
      }

    results_id = results[[d]]

    results_tmp=filter_significance(results_id,alpha)

    #results_tmp$control= results_tmp$power>=lowlim&results_tmp$power<=uplim
    results_tmp$control= results_tmp$power<=uplim
    
    filter_data = results_tmp[results_tmp$control==FALSE,]

    filter_data = subset(filter_data, select=-control)
    filter_data = subset(filter_data, select=-id)
    filter_data = subset(filter_data, select=-distribution)
    filter_data = subset(filter_data, select=-seed)
    filter_data = subset(filter_data, select=-N)


  }

  return(list(filter_data=filter_data))


}

best_method = function(results_df,name_methods=NULL,name_extra=NULL,alpha=0.01,n=20,filter=TRUE){
  results=results_df
  # results=subset(results,select=-mom1_1)
  # results=subset(results,select=-mom2_1)
  # results=subset(results,select=-mom3_1)
  # results=subset(results,select=-mom4_1)

  # if (filter){
  #   results = filter_significance(results_df,alpha)}

  if (is.null(name_methods)){
    name_methods = unique(results$method)
  }

  if (!is.null(name_extra)){
    if (name_extra %in% name_methods){
      name_methods = name_methods[-which(name_methods==name_extra)]
    }else{
      name_methods=name_methods
    }
  }

  results = results[results$method%in%c(name_methods),]
  data = unique(results$distribution)


  # Per scenario
  tmp_end=data.frame()
  tmp_all = data.frame()
  for (d in (data)){

    results_data = results[results$distribution==d,]
    ind=length(unique(results_data$id))

    for (i in (1:ind)){
      #tmp = results_data[results_data$id==i,]
      tmp = results_data[results_data$id==i&results_data$n==n,]
      tmp_scenario_n = tmp[which(tmp$power==max(tmp$power,na.rm=TRUE)),]
      tmp_scenario_nn = tmp_scenario_n

      if (nrow(tmp_scenario_nn)>1){
        tmp_scenario_n1 = tmp_scenario_nn[1,]
        tmp_scenario_n1$method[1] = paste(tmp_scenario_nn$method,collapse='-')
        tmp_scenario_n1$seed[1] = paste(tmp_scenario_nn$seed,collapse='-')
        tmp_scenario_n1$l_CI[1] = paste(tmp_scenario_nn$l_CI,collapse='-')
        tmp_scenario_n1$u_CI[1] = paste(tmp_scenario_nn$u_CI,collapse='-')
        tmp_scenario_nn = tmp_scenario_n1
      }


      tmp_end = rbind(tmp_end,tmp_scenario_n)
      tmp_all = rbind(tmp_all,tmp_scenario_nn)
    }


  }
  tmp_end_tmp = add_count(tmp_end, method,distribution,name="count")
  # Per data generation op basis van meest voorkomend hoogste power
  tmp_end=add_count(tmp_end, method,distribution,name="count")
  test1=data.frame()
  for (d in data){
    tmp_end_dis= tmp_end[tmp_end$distribution==d,]
    if (nrow(tmp_end_dis)==0){
      tmp_end_dis[1,]=NA
      tmp_end_dis[,'distribution']=d
      tmp_end_dis$nscenarios = 0
      test=tmp_end_dis
    }else{

      test=tmp_end_dis[which(tmp_end_dis$count==max(tmp_end_dis$count)),]
      n_scenarios=length(unique(tmp_end_dis$id))
      test$nscenarios=n_scenarios

    }


    test1=rbind(test1,test)
  }

  end = unique(test1[,c('method','distribution','count',"nscenarios")])


  return(list(end=end,all= tmp_end_tmp, all_one=tmp_all))
}


best_method_plot = function(name_extra,n=20,results_df,filter=TRUE,alpha=0.05,name_methods=NULL){

  results_1_method = results_df[results_df$method==name_extra &results_df$n==n,]
  # if (filter==TRUE){
  #   results_1_method =filter_significance(results_1_method,alpha)
  # }

  df = best_method(results_df,name_methods,name_extra=name_extra ,alpha,n,filter)$all_one

  df$scenario = paste(df$distribution,df$id)
  results_1_method$scenario = paste(results_1_method$distribution,results_1_method$id)

  tt = merge(results_1_method,df,by='scenario')
  tt1=remove_missing(tt)

  txt=paste(name_extra,'has higher power in ',sum(tt1$power.x>tt1$power.y,na.rm=TRUE),'of the ',length(tt1$power.x),'scenarios where the type I error rate is controlled.')
  txt_mis = paste("In ", 225-length(tt1$power.x)," scenarios the type I error rate is not contolled at the nominal level.")
  p <- ggplot(tt1,aes(x=power.y,y=power.x))+
    geom_point(aes(colour=factor(distribution.x)),size=3)+
    ylim(0,1)+xlim(0,1)+
    geom_abline()+
    xlab(paste("power of ",'the best method',sep=""))+
    ylab(paste("power of ",name_extra ,sep=""))+
    labs(colour='Data generation method')+ theme(axis.text.x = element_text(size = 15),
                                                 axis.text.y = element_text(size = 15),
                                                 axis.title = element_text(size = 18),
                                                 legend.key.size = unit(1, 'cm'),
                                                 legend.title = element_text(size=15),legend.text = element_text(size=15))

  return(list(graph=p,data=tt1,text=txt,text_mis = txt_mis))
}

