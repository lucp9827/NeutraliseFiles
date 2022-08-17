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

All_Neutralised_Scenarios<-function(data) {
  dir<-dir(paste("Settings/",data,"_settings",sep=""))
  file<-paste("Settings/",data,
              "_settings.RData",
              sep="")
  load(file)
  settings<-settings[settings$null==0,]
  scenarios<-subset(settings,select=-null)
  id=c(1:nrow(scenarios))
  scenarios<-cbind(id,scenarios)
  return(scenarios)
}


# Function to plot the power of two methods

Power_QQ<-function(method1,method2,alpha=0.05,
                   par.fix=NULL,
                   data=NULL,
                   col="black", add.to.plot=NULL,group=FALSE,CI=FALSE) { 
  # data = data generation tool
  
  # Read finished file
  finished<-read.csv("Results/Finished.txt",sep=",",header=T)

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
  
  win2<-0
  cnt.scenarios<-0
  cnt<-1
  pwr1<-data.frame()
  pwr2<-data.frame()
  text_group=c()
  data.gen<-c()
  
  for(d in data.i) {
    
    # specify folder in results file
    dir1<-dir(paste("Results/SimRes_",method1,"_",d,sep=""))
    dir2<-dir(paste("Results/SimRes_",method2,"_",d,sep=""))
    
    
    file1<-paste("Results/SimRes_",method1,"_",d,
                 "/",dir1[grepl(".RData",dir1)&grepl(method1,dir1)],
                 sep="")
    
    file2<-paste("Results/SimRes_",method2,"_",d,
                 "/",dir2[grepl(".RData",dir2)&grepl(method2,dir2)],
                 sep="")
    
    load(file1)
    if(!is.null(data)) {
      results<-results[results$distribution==data,]
    }
    
    if(!is.null(par.fix))  {
      settings.fix<-results%>%dplyr::select(names(par.fix))
      results<-results[apply(settings.fix,1,
                             function(x) {
                               all(x==unlist(par.fix))
                             }),]
    }
    results1[[cnt]]<-results
    
    x= colnames(results)
    colnr = grep(as.numeric(alpha),x)
    pwr1.tmp<-results[(results$null==0),c(colnr,colnr+1,colnr+2)]
    
    load(file2)
    if(!is.null(data)) {
      results<-results[results$distribution==data,]
    }
    
    if(!is.null(par.fix)) {
      settings.fix<-results%>%dplyr::select(names(par.fix))
      results<-results[apply(settings.fix,1,
                             function(x) {
                               all(x==unlist(par.fix))
                             }),]
    }
    results2[[cnt]]<-results
    
    x= colnames(results)
    colnr = grep(as.numeric(alpha),x)
    
    pwr2.tmp<-results[(results$null==0),c(colnr,colnr+1,colnr+2)]
    
    cnt<-cnt+1
    
    win2<-win2+sum(pwr1.tmp[,1]<pwr2.tmp[,1])
    cnt.scenarios<-cnt.scenarios+nrow(pwr1.tmp)
    
    pwr1<-rbind(pwr1,pwr1.tmp)
    pwr2<-rbind(pwr2,pwr2.tmp)
    data.gen <-c(data.gen,rep(d,nrow(pwr1.tmp)))
    
    if (group==TRUE){
      win_tmp = sum(pwr1.tmp[,1]<pwr2.tmp[,1])
      text_group=c(text_group,paste(d,": ",method2," wins over ",method1, " in ", round(100*win_tmp/nrow(pwr1.tmp),1),
                "% of the ",nrow(pwr1.tmp), " scenarios\n",sep=""))
    }
  }
  powers<-data.frame(pwr1=pwr1[,1],lower_1=pwr1[,2],upper_1=pwr1[,3],pwr2=pwr2[,1],lower_2=pwr2[,2],upper_2=pwr2[,3],data.gen=data.gen)
  
  txt=(paste(method2," wins over ",method1, " in ", round(100*win2/cnt.scenarios,1),
            "% of the ", cnt.scenarios, " scenarios",sep=""))
  
  if (!group){
    if(is.null(add.to.plot)) {
      
      p<-ggplot(powers,aes(x=pwr1,y=pwr2))+
        geom_point(colour={{col}})+
        ylim(0,1)+xlim(0,1)+
        geom_abline()+
        xlab(paste("power of ",method1,sep=""))+
        ylab(paste("power of ",method2,sep=""))
    }
    else {
      p<-add.to.plot+
        geom_point(data=powers,aes(x=pwr1,y=pwr2),
                   colour={{col}})
    }
    
  }else{
    if(is.null(add.to.plot)) {
      p<-ggplot(powers,aes(x=pwr1,y=pwr2))+
        geom_point(aes(colour=factor(data.gen)),size=3)+
        geom_point(colour="grey90")+
        ylim(0,1)+xlim(0,1)+
        geom_abline()+
        xlab(paste("power of ",method1,sep=""))+
        ylab(paste("power of ",method2,sep=""))
    }
    else {
      p<-add.to.plot+
        geom_point(data=powers,aes(x=pwr1,y=pwr2),
                   colour={{col}})
    }}
  
  if (group){
    txt=text_group
  }
  
  if (CI){
    p+geom_smooth(method=lm)
  }else{
  p}
  
  (list(win.pct=win2/cnt.scenarios,
                power=powers,
                 results1=results1,
                 results2=results2,
                 graph=p,
                text=txt))
  
}


# Function to plot the Type I error rate of one method

Boxplot_TypeI<-function(method,alpha=0.05,tol=0.02,panel="",ylim=c(0,0.07)) {
  
  finished<-read.csv("Results/Finished.txt",sep=",",header=T)
  
  data<-finished$data[finished$method==method]
  
  cnt.scenarios<-0
  cnt<-1
  pwr<-c()
  distr<-c()
  n<-c()
  results1<-list()
  for(d in data) {
    dir1<-dir(paste("Results/SimRes_",method,"_",d,sep=""))
    file1<-paste("Results/SimRes_",method,"_",d,
                 "/",dir1[grepl(".RData",dir1)&grepl(method,dir1)],
                 sep="")
    
    load(file1)
    results1[[d]]<-results
    
    x= colnames(results)
    colnr = grep(alpha,x)
    
    
    pwr<-c(pwr,results[results$null==1,colnr])
    distr<-c(distr,results$distribution[results$null==1])
    n<-c(n,results$n1[results$null==1]+results$n2[results$null==1])
    
    cnt<-cnt+1
    cnt.scenarios<-cnt.scenarios+length(pwr)
    
    db_tmp<-data.frame(pwr=pwr,distribution=distr,n=n)
    
    cat(paste(d," with a total sample size of ",db_tmp[db_tmp$distribution==d,'n'],":\n",method," has on average a type I error rate of ",
              round(100*db_tmp[db_tmp$distribution==d,'pwr']/cnt.scenarios,2),"% at the nominal ",
              alpha," level.\n",sep=""))
  }
  
  #boxplot(pwr,
  #        ylab=paste("Type I error rate of ",
  #                   deparse(substitute(method)),sep=""))
  
  
  cat(paste("On average (over all scenarios) :",method," has a type I error rate not larger than ",
            alpha," + ",tol," in ",
            round(100*mean(pwr<alpha+tol),1),
            "% of the scenarios.\n",sep=""))
  
  db<-data.frame(pwr=pwr,distribution=distr,n=n)
  invisible(list(results=results1)) #power=db,
  
  if(panel=="") {
    p0<-ggplot(db,aes(x="",y=pwr))
  }
  if(panel=="distribution") {
    p0<-ggplot(db,aes(x=distribution,y=pwr))
  }
  if(panel=="n") {
    p0<-ggplot(db,aes(x=factor(n),y=pwr))
  }
  graph=p0+
    geom_boxplot()+
    geom_jitter(alpha=0.6,width = 0.2, aes(colour=n))+
    lims(y=ylim)+
    ylab(paste("Type I error rate of ",
               {{method}},sep=""))+
    geom_hline(yintercept=alpha, linetype="dotted", colour="red")+
    xlab("")
  return(list(graph=graph))
}

# Function to plot the Type I error rate of all methods
Boxplot_TypeI_ALL<-function(methods,alpha=0.05,tol=0.02,panel="",ylim=c(0,0.07)) {
  
  finished<-read.csv("Results/Finished.txt",sep=",",header=T)
  
  end=data.frame()
  results1<-list()
  cnt<-1
  for (method in methods){
    data<-finished$data[finished$method==method]
    
    cnt.scenarios<-0
    pwr<-c()
    distr<-c()
    n<-c()
    for(d in data) {
      dir1<-dir(paste("Results/SimRes_",method,"_",d,sep=""))
      file1<-paste("Results/SimRes_",method,"_",d,
                   "/",dir1[grepl(".RData",dir1)&grepl(method,dir1)],
                   sep="")
      
      load(file1)
      results1[[method]]<-results
      
      x= colnames(results)
      colnr = grep(alpha,x)
      
      
      pwr<-c(pwr,results[results$null==1,colnr])
      distr<-c(distr,results$distribution[results$null==1])
      n<-c(n,results$n1[results$null==1]+results$n2[results$null==1])
      
      cnt<-cnt+1
      cnt.scenarios<-cnt.scenarios+length(pwr)
      
      db_tmp<-data.frame(pwr=pwr,distribution=distr,n=n)
      
      cat(paste(d," with a total sample size of ",db_tmp[db_tmp$distribution==d,'n'],":\n",method," has on average a type I error rate of ",
                round(100*db_tmp[db_tmp$distribution==d,'pwr']/cnt.scenarios,2),"% at the nominal ",
                alpha," level.\n",sep=""))
    }
    
    
    #boxplot(pwr,
    #        ylab=paste("Type I error rate of ",
    #                   deparse(substitute(method)),sep=""))
    
    
    cat(paste("On average (over all scenarios) :",method," has a type I error rate not larger than ",
              alpha," + ",tol," in ",
              round(100*mean(pwr<alpha+tol),1),
              "% of the scenarios.\n",sep=""))
    db<-data.frame(pwr=pwr,distribution=distr,n=n,method=rep(method,length(pwr)))
    end=rbind(end,db)
  }
  
  invisible(list(results=results1)) #power=db,
  
  if(panel=="") {
    p0<-ggplot(end,aes(x="",y=pwr))
  }
  if(panel=="distribution") {
    p0<-ggplot(end,aes(x=distribution,y=pwr))
  }
  if(panel=="n") {
    p0<-ggplot(end,aes(x=factor(n),y=pwr))
  }
  graph=p0+
    geom_boxplot()+
    geom_jitter(alpha=0.6,width = 0.2, aes(colour=n))+
    lims(y=ylim)+
    ylab(paste("Type I error rate of ",
               {{method}},sep=""))+
    geom_hline(yintercept=alpha, linetype="dotted", colour="red")+
    xlab("")+
    facet_wrap(~method,ncol=3)
  return(list(graph=graph))
}

# Function to plot the power in a curve, in function of delta
Power_curve_ALL<-function(methods,alpha=0.05,
                          par.fix=NULL,
                          data=NULL,
                          col="black", add.to.plot=NULL,group=FALSE,CI=FALSE) { 
  # data = data generation tool
  
  # Read finished file
  if (is.null(data)){
    load(file = "Results\\NeutraliseStatus.RData")
    data.i<-neutralise.status[neutralise.status$type=='data'&neutralise.status$to.run==FALSE,'name']
  }else{
    data.i=data
  }
  
  end=data.frame()
  
  for(d in data.i) {
    
    
    #results1<-list()
    results1<-data.frame()
    win2<-0
    cnt.scenarios<-0
    pwr1<-data.frame()
    data.gen<-c()
    
    for (m in methods){
      
      # specify folder in results file
      dir1<-dir(paste("Results/SimRes_",m,"_",d,sep=""))
      
      
      file1<-paste("Results/SimRes_",m,"_",d,
                   "/",dir1[grepl(".RData",dir1)&grepl(m,dir1)],
                   sep="")
      
      
      load(file1)
      if(!is.null(data)) {
        results<-results[results$distribution==data,]
      }
      
      if(!is.null(par.fix)) {
        settings.fix<-results%>%dplyr::select(names(par.fix))
        results<-results[apply(settings.fix,1,
                               function(x) {
                                 all(x==unlist(par.fix))
                               }),]
      }
      results$n=results$n1+results$n2
      results1<-rbind(results1,results)
      
    }
    x= colnames(results1)
    colnr = grep(as.numeric(alpha),x)
    end_tmp=data.frame(method=results1$method,
                       data.gen=results1$distribution,n=results1$n,delta=results1$delta,power=results1[,colnr],l_CI=results1[,colnr+1],u_CI=results1[,colnr+2],null=results1$null)
    
    end=rbind(end,end_tmp)
    
  }
  
  end_power=end[end$null==0,]
  end_power$n=as.factor(end_power$n)
  if (CI){
    graph=ggplot(end_power,aes(x=delta,y=power, group=n))+
      geom_line(aes(col=n))+
      geom_point(aes(col=n))+
      geom_errorbar(aes(ymin = l_CI, ymax = u_CI,col=n), width = 0.2)+
      ylim(0:1)+
      facet_wrap(~method,ncol=3)}
  else{  graph=ggplot(end_power,aes(x=delta,y=power, group=n))+
    geom_line(aes(col=n))+
    geom_point(aes(col=n))+
    ylim(0:1)+
    facet_wrap(~method,ncol=3)
  
  }
  
  return(list(graph))
}

# Comparing methods - distance metric 

sum_res_mat = function(alpha,methods){
  finished<-read.csv("Results/Finished.txt",sep=",",header=T)
  # source("help.R")

  
  end=data.frame()
  results1<-list()
  cnt<-1
  for (method in methods){
    data<-finished$data[finished$method==method]
    
    cnt.scenarios<-0
    pwr<-c()
    distr<-c()
    n<-c()
    for(d in data) {
      dir1<-dir(paste("Results/SimRes_",method,"_",d,sep=""))
      file1<-paste("Results/SimRes_",method,"_",d,
                   "/",dir1[grepl(".RData",dir1)&grepl(method,dir1)],
                   sep="")
      
      load(file1)
      results=cbind(results,id=rep(1:nrow(results)))
      results1[[d]]<-rbind(results1[[d]],results)
      
      cnt<-cnt+1
    }
  }
  
  save(results1,file="Results\\Results.RData")
  
  results_power=list()
  
  for (i in (1:length(results1))){
    results_power[[i]]=results1[[i]][results1[[i]]$null!=1,]
  }
  
  
  power_dataframe=data.frame()
  
  for (i in (1:length(results_power))){
    power_dataframe_tmp=data.frame(method=results_power[[i]]$method,distribution=results_power[[i]]$distribution,id=results_power[[i]]$id,power0.01=results_power[[i]]$power0.01,power0.05=results_power[[i]]$power0.05,power0.10=results_power[[i]]$power0.10)
    power_dataframe=rbind(power_dataframe,power_dataframe_tmp)
  }
  
  
  power_dataframe$scenario <- paste(power_dataframe$distribution,power_dataframe$id)
  
  power_dataframe=remove_missing(power_dataframe)
  
  if (alpha==0.05){
    mat_pwr=xtabs(power0.05~method+scenario,power_dataframe)}
  if (alpha==0.01){
    mat_pwr=xtabs(power0.01~method+scenario,power_dataframe)}
  if (alpha==0.10){
    mat_pwr=xtabs(power0.10~method+scenario,power_dataframe)}
  
  return(mat_pwr)
}

## Function to summarize methods 
sum_methods = function(){
  
  method.files<-dir(path=paste("Methods",sep=""))
  load(paste("Results/NeutraliseStatus.RData",sep=""))
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
    
    des_id = which(tmp=="# DESCRIPTION")
    des_txt = tmp[des_id+1]
    des_txt = gsub('#','',des_txt)
    
    ref_id = which(tmp=="# REFERENCES")
    ref_txt = tmp[ref_id+1]
    ref_txt = gsub('#','',ref_txt)
    
    abbriv_txt=gsub('.R','',filename_temp)
    
    text_tmp= data.frame(Abbriviation=abbriv_txt,Name=name_txt,Description=des_txt,References=ref_txt)
    
    text=rbind(text,text_tmp)
  }
  
  return(text)
}