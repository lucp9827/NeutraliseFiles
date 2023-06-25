library(shiny)
library(ggplot2)
library(dplyr)
library(grid)
library(scales)

source("help.R")

load(file = "results/neutralisestatus.RData")

names_methods=(All_Neutralised(neutralise.status))

names_data_scenarios = All_Neutralised(neutralise.status,type='data')

names_data=c(names_data_scenarios,All="All")

load(file="results_power_perdatagen_df.RData")
load(file="results_power_perdatagen.RData")

load(file="results_type1_perdatagen_df.RData")
load(file="results_typeI_perdatagen.RData")

results_df = results_datagen_df
results_list = results_datagen

results_type1_list = results_datagen_type1
results_type1_df = results_datagen_df_type1

my_min <- 2
my_max <- 2

load(file="parameter_explanation.RData")

shinyServer(function(input, output,session) {

  output$Home1<-renderImage({
    (list(src="www/dsi_logo.png",width="100%",height=150))
  },deleteFile=F)

  output$picture<-renderImage({
    (list(src="www/test.png",width="50%",heighy=150))
  },deleteFile=F)

  # Summary methods
  output$Methods <- renderTable({
    sum_methods()
  });

  # Summary scenarios Power

  output$Scenarios<-renderTable({

    All_Neutralised_Scenarios(input$select_data_scenario)



  })

  # Filtered out scenarios (Method specific)

  #output$Filtered_Scenarios<-renderTable({

  #  if (input$checkbox_filter==TRUE){
  #    filtered_data_scenarios(results_type1_list,data=input$select_data_scenario,alpha=as.numeric(input$select))$filter_data
  #  }
  #})

  # Type I error scenarios
  output$typeI_scenarios<-renderTable({

    if (input$select_data_scenario=="Normal2Var"){
    All_Neutralised_Scenarios("Normal",type="typeI")} else{
      All_Neutralised_Scenarios(input$select_data_scenario,type="typeI")
    }

  })
  
  output$parameter_description<-renderTable({
    parameter_explanation[[input$select_data_scenario]]
    
  })
  

  # General data comparison

  filter_df = reactive({
    if (input$checkbox_filter){
      results_df1 = filter_type1(results=results_type1_list,results_power = results_list,alpha = as.numeric(input$select))$filter_df
      results_df1
    }else{
      results_df1 = results_df
      results_df1
    }
  })
  
  
  ylabs = reactive({
    
    if (input$check_yvar=="type1"){
      c("Type I error rate")
    } else{
      c("Power")
    }
  })
  
  ylim = reactive({
    
    if (input$check_yvar=="type1"){
      c(0,0.15)
    } else{
      c(0,1)
    }
  })

      ## Group 1
  waitress4 = waiter::Waitress$new("#general1", theme="overlay-percent",hide_on_render = TRUE)
      output$general1<-renderPlot({
        
        
        if (input$check_yvar=="type1"){
          if(input$checkbox_filter){
            results = fil_for_type1(results_type1_list,alpha=as.numeric(input$select))$filter_df
          }else{
            results= results_type1_df
          }
        }else{
          results = filter_df()
        }
        if (input$checkbox_filter==FALSE){
          waitress4$start()
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,ylabs(),ylim())$graph

          }else{
            waitress4$start()
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$graph
        }

      },height=800)
      
      
      output$click_data<-renderTable({
        if (input$check_yvar=="type1"){
          if(input$checkbox_filter){
            results = fil_for_type1(results_type1_list,alpha=as.numeric(input$select))$filter_df
          }else{
            results= results_type1_df
          }
        }else{
          results = filter_df()
        }
        if (input$checkbox_filter==FALSE){
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,ylabs(),ylim())$data

          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)
          
          
          results = brushedPoints(data_click, input$plot_click1,xvar=paste0(input$check_moment,'_1'))
          results$power = format(round(results$power, 4), nsmall = 4)
          results$l_CI <- format(round(results$l_CI, 4), nsmall = 4)
          results$u_CI <- format(round(results$u_CI, 4), nsmall = 4)
          
          if (input$check_yvar=="type1"){
            colnames(results) = c("method","distribution","delta","Type I error rata","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
            
          }else{
          colnames(results) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
          }
          results
        }else{
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$data

          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)
          data_click= subset(data_click,select=-cnt)
          data_click= subset(data_click,select=-control)
          
          

          results=brushedPoints(data_click, input$plot_click1,xvar=paste0(input$check_moment,'_1'))
          results$power = format(round(results$power, 4), nsmall = 4)
          results$l_CI <- format(round(results$l_CI, 4), nsmall = 4)
          results$u_CI <- format(round(results$u_CI, 4), nsmall = 4)
          
          if (input$check_yvar=="type1"){
            colnames(results) = c("method","distribution","delta","Type I error rate","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
            
          }else{
            colnames(results) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
          }
          results
        }
      })

      ## Group 2
      
      waitress5 = waiter::Waitress$new("#general2", theme="overlay-percent",hide_on_render = TRUE)
      output$general2<-renderPlot({
        waitress5$start()
        if(input$check_moment=='mom1'|input$check_moment=='mom2' ){
          
        }else{
        if (input$check_yvar=="type1"){

          if(input$checkbox_filter){
            results = fil_for_type1(results_type1_list,alpha=as.numeric(input$select))$filter_df
          }else{
            results= results_type1_df
          }
        }else{

          results = filter_df()
        }
        if (input$checkbox_filter==FALSE){
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,ylabs(),ylim())$graph
        }else{
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$graph
        }
        }

      },height=800)
      output$click_data2<-renderTable({
        if (input$check_yvar=="type1"){

          if(input$checkbox_filter){
            results = fil_for_type1(results_type1_list,alpha=as.numeric(input$select))$filter_df
          }else{
            results= results_type1_df
          }
        }else{

          results = filter_df()
        }
        if (input$checkbox_filter==FALSE){
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,ylabs(),ylim())$data
          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)
         
        

          results =brushedPoints(data_click, input$plot_click2,xvar=paste0(input$check_moment,'_2'))
          
          results$power = format(round(results$power, 4), nsmall = 4)
          results$l_CI <- format(round(results$l_CI, 4), nsmall = 4)
          results$u_CI <- format(round(results$u_CI, 4), nsmall = 4)
          
          if (input$check_yvar=="type1"){
            colnames(results) = c("method","distribution","delta","Type I error rate","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
            
          }else{
            colnames(results) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
          }
          results
          
          
        }else{
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$data
          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)
          data_click= subset(data_click,select=-cnt)
          data_click= subset(data_click,select=-control)
   

          results = brushedPoints(data_click, input$plot_click2,xvar=paste0(input$check_moment,'_2'))
          results$power = format(round(results$power, 4), nsmall = 4)
          results$l_CI <- format(round(results$l_CI, 4), nsmall = 4)
          results$u_CI <- format(round(results$u_CI, 4), nsmall = 4)
          
          if (input$check_yvar=="type1"){
            colnames(results) = c("method","distribution","delta","Type I error rate","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
            
          }else{
            colnames(results) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
          }
          results
        }
      })


  # Type I error boxplot
  waitress = waiter::Waitress$new("#Type_1_error", theme="overlay-percent",hide_on_render = TRUE)
    
  output$Type_1_error<- renderPlot({
    waitress$start()
    Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$graph
   
  },height=800)
  
  output$brush_type1 <- renderTable({

    data_brush = Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$data

    data_brush = subset(data_brush,select=-seed)
    data_brush = subset(data_brush,select=-N)
    data_brush = subset(data_brush,select=-n1)
    data_brush = subset(data_brush,select=-n2)
    data_brush = subset(data_brush,select=-cnt)
    
    

    if(input$select_panel1==""){
    results = brushedPoints(data_brush, input$plot_type1,xvar = input$plot_type1)}else{
      results = brushedPoints(data_brush, input$plot_type1)}
      
      results$power <- format(round(results$power, 4), nsmall = 4)
      results$power <- format(round(results$l_CI, 4), nsmall = 4)
      results$power <- format(round(results$u_CI, 4), nsmall = 4)
      
      colnames(results) = c('method','distribution','type I error rate','lower_CI','upper_CI',"n","id","mean_1","mean_2","var_1","var_2","skew_1","skew_2",'kurt_1','kurt_2')
      results
    
  })


  # Power-curve

  output$parameters1 = renderUI({
# this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
    req(input$select_data_scenario_power1) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
    req(input$select_data_scenario_power1)
    unique_scen = unique_combinations(input$select_data_scenario_power1)
    
    par = colnames(unique_scen)
    par = paste0(c(par),collapse='_')
    end_df=as.vector(apply(unique_scen, 1, paste0, collapse="_"))

    radioButtons("test_pwrcurve", label = paste0("Choose scenario:\t",par), choices = c(end_df ))

  })

  waitress1 = waiter::Waitress$new("#curvePower", theme="overlay-percent",hide_on_render = TRUE)
  
  output$curve_Power <- renderPlot({
    
    #req(input$select_data_scenario_power1)
    req(input$test_pwrcurve)
     unique_scen = unique_combinations(input$select_data_scenario_power1)
     val = as.numeric(unlist(strsplit(input$test_pwrcurve,"_")))
     par_fix = data.frame(t(val))
     colnames(par_fix) <- colnames(unique_scen)
     waitress1$start()
    Power_curve_ALL(input$check_one1,results=results_type1_list,results_power=results_list,alpha=as.numeric(input$select),data=input$select_data_scenario_power1,CI=input$checkbox_ci1,par.fix=par_fix,group = input$checkbox_allmeth,neutralise.status=neutralise.status,n=input$check_sample)
  })


  ## Power-Power curve

  observe({
    if(length(input$check) > my_max){
      updateCheckboxGroupInput(session, "check", selected= tail(input$check,my_max))
    }
  })

  output$setting = renderUI({
    if (input$select_data!='All'){
      checkboxInput("checkbox2", label = "Fix Parameter setting", value = FALSE)
    }else{
      checkboxInput("checkbox", label = "Group Data generation methods", value = FALSE)

    }

  })

  output$parameters = renderUI({
    req(input$checkbox2) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages

    if (input$select_data!='All'& input$checkbox2 ){

      unique_scen = unique_combinations(input$select_data)

      par = colnames(unique_scen)
      par = paste0(c(par),collapse='_')
      end_df=as.vector(apply(unique_scen, 1, paste0, collapse="_"))

      radioButtons("test", label = paste0("Choose scenario:\t",par), choices = end_df)
    }
  })


  filter_list = reactive({
    if (input$checkbox_filter==TRUE){
      results_list1 = filter_type1(results=results_type1_list,results_power = results_list,alpha = as.numeric(input$select))$filter_list
      results_list1
    }else{
      results_list1 = results_list
      results_list1
    }
  })


  par_fix_pp = reactive({

    if (input$checkbox2){
    unique_scen = unique_combinations(input$select_data)
    val = as.numeric(unlist(strsplit(input$test,"_")))
    par_fix = data.frame(t(val))
    colnames(par_fix) <- colnames(unique_scen)
    par_fix
    }else{
      NULL
    }
  })
  
  waitress2 = waiter::Waitress$new("#Power2", theme="overlay-percent",hide_on_render = TRUE)
  
  output$Power2 <- renderPlot({
    
    req(input$check[1])
    req(input$check[2])

    waitress2$start()
    if (input$select_data!="All"){


      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter,n=input$check_samplepp)$graph
    }else{

      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter,n=input$check_samplepp)$graph
    }

  })
  output$Power1<-renderText({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter,n=input$check_samplepp)$text
    }else{

      paste(Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter,n=input$check_samplepp)$text,collapse="<br>")
    }

  })

  output$click_2power<-renderTable({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      data_click=Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter,n=input$check_samplepp)$total
    }else{

      data_click=Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter,n=input$check_samplepp)$total
    }
    data_click= subset(data_click,select=-mom1_1.x)
    data_click= subset(data_click,select=-mom2_1.x)
    data_click= subset(data_click,select=-mom3_1.x)
    data_click= subset(data_click,select=-mom4_1.x)
    data_click= subset(data_click,select=-mom1_2.x)
    data_click= subset(data_click,select=-mom2_2.x)
    data_click= subset(data_click,select=-mom3_2.x)
    data_click= subset(data_click,select=-mom4_2.x)

    data_click= subset(data_click,select=-distribution.x)
    data_click= subset(data_click,select=-delta.x)
    data_click= subset(data_click,select=-delta.y)
    data_click= subset(data_click,select=-n1.x)
    data_click= subset(data_click,select=-n2.x)
    data_click= subset(data_click,select=-n1.y)
    data_click= subset(data_click,select=-n2.y)
    data_click= subset(data_click,select=-id.x)
    data_click= subset(data_click,select=-N.x)
    data_click= subset(data_click,select=-N.y)
    data_click= subset(data_click,select=-seed.x)
    data_click= subset(data_click,select=-seed.y)
    data_click= subset(data_click,select=-distribution.y)
    data_click= subset(data_click,select=-id.y)
    data_click= subset(data_click,select=-cnt.y)
    data_click= subset(data_click,select=-cnt.x)
    data_click= subset(data_click,select=-control.y)
    data_click= subset(data_click,select=-control.x)

    names(data_click)[names(data_click)=='mom1_1.y'] <- 'mom1_grp1'
    names(data_click)[names(data_click)=='mom2_1.y'] <- 'mom2_grp1'
    names(data_click)[names(data_click)=='mom3_1.y'] <- 'mom3_grp1'
    names(data_click)[names(data_click)=='mom4_1.y'] <- 'mom4_grp1'
    names(data_click)[names(data_click)=='mom1_2.y'] <- 'mom1_grp2'
    names(data_click)[names(data_click)=='mom2_2.y'] <- 'mom2_grp2'
    names(data_click)[names(data_click)=='mom3_2.y'] <- 'mom3_grp2'
    names(data_click)[names(data_click)=='mom4_2.y'] <- 'mom4_grp2'
    names(data_click)[names(data_click)=='n'] <- 'n'
    


    results = brushedPoints(data_click,input$plot_2power)
    results$power.x <- format(round(results$power.x, 4), nsmall = 4)
    results$power.y <- format(round(results$power.y, 4), nsmall = 4)
    
    colnames(results) = c("method.x","power.x","lower_CI.x","upper_CI.x","method.y","power.y","lower_CI.y","upper_CI.y","n","mean_grp1","mean_grp2","var_grp1","var_grp2","skew_grp1",'skew_grp2',"kurt_grp1","kurt_grp2","Scenario")
    
    results
  })


  output$Mis<-renderText({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter,n=input$check_samplepp)$text2
    }else{

      paste(Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter,n=input$check_samplepp)$text2,collapse="<br>")
    }


  })
  ## Best Method

  output$Bestmethods<-renderTable({
    if (input$checkbox_filter!=TRUE){
      best_method(results_df,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size)$end
    }else{
      results_filter = filter_type1(results=results_type1_list,results_power=results_list,alpha=as.numeric(input$select))$filter_df
      best_method(results_filter,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size,filter=FALSE)$end
    }
  })

  waitress3 = waiter::Waitress$new("#BM", theme="overlay-percent",hide_on_render = TRUE)
  output$BM<-renderPlot({
    
    if (input$checkbox_filter!=TRUE){
      dd=best_method(results_df,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size)
    }else{
      results_filter = filter_type1(results=results_type1_list,results_power=results_list,alpha=as.numeric(input$select))$filter_df
      dd=best_method(results_filter,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size,filter=FALSE)
    }

    dda=dd$all
    ddn=dd$end
    ddn_a= unique(ddn[ddn$distribution==input$select_data_scenario_bm,"nscenarios"])
    xx=unique(dda[dda$distribution==input$select_data_scenario_bm,c("method","count")])
    xx=data.frame(method=xx$method,count=xx$count,n=ddn_a)
    
    ggplot(xx,aes(x=count/n,y=method))+
      geom_bar(stat='identity')+theme_grey(base_size = 20)+xlab(paste0("% highest power over all scenarios of ",input$select_data_scenario_bm))+ylab("Methods")
  })
  waitress3 = waiter::Waitress$new("#Bestmethods_plot", theme="overlay-percent",hide_on_render = TRUE)
  output$Bestmethods_plot<-renderPlot({
    req(input$comp_meth)
    if (input$checkbox_filter==TRUE){
      waitress3$start()
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=FALSE,alpha=input$select,as.vector(input$check_methodbest))$graph
    }else{
      waitress3$start()
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=TRUE,alpha=input$select,as.vector(input$check_methodbest))$graph
    }
  })
  output$Bestmethods_txt<-renderText({
    req(input$comp_meth)
    if (input$checkbox_filter==TRUE){
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=FALSE,alpha=input$select,as.vector(input$check_methodbest))$text
    }else{
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=TRUE,alpha=input$select,as.vector(input$check_methodbest))$text
    }
  })
  output$Bestmethods_txtmis<-renderText({
    req(input$comp_meth)
    if (input$checkbox_filter==TRUE){
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=FALSE,alpha=input$select,as.vector(input$check_methodbest))$text_mis
    }else{
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=TRUE,alpha=input$select,as.vector(input$check_methodbest))$text_mis
    }
  })
  output$click_bestdata<-renderTable({
    req(input$comp_meth)

    data_bestclick=best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=(!input$checkbox_filter),alpha=input$select,as.vector(input$check_methodbest))$data

    data_bestclick= subset(data_bestclick,select=-mom1_1.x)
    data_bestclick= subset(data_bestclick,select=-mom2_1.x)
    data_bestclick= subset(data_bestclick,select=-mom3_1.x)
    data_bestclick= subset(data_bestclick,select=-mom4_1.x)
    data_bestclick= subset(data_bestclick,select=-mom1_2.x)
    data_bestclick= subset(data_bestclick,select=-mom2_2.x)
    data_bestclick= subset(data_bestclick,select=-mom3_2.x)
    data_bestclick= subset(data_bestclick,select=-mom4_2.x)
    data_bestclick= subset(data_bestclick,select=-n.x)
    data_bestclick= subset(data_bestclick,select=-n.y)
    data_bestclick= subset(data_bestclick,select=-distribution.y)
    data_bestclick= subset(data_bestclick,select=-delta.x)
    data_bestclick= subset(data_bestclick,select=-n1.x)
    data_bestclick= subset(data_bestclick,select=-n2.x)
    data_bestclick= subset(data_bestclick,select=-id.x)
    data_bestclick= subset(data_bestclick,select=-id.y)
    data_bestclick= subset(data_bestclick,select=-seed.x)
    data_bestclick= subset(data_bestclick,select=-seed.y)
    data_bestclick= subset(data_bestclick,select=-cnt.x)
    data_bestclick= subset(data_bestclick,select=-cnt.y)
    data_bestclick= subset(data_bestclick,select=-N.x)
    data_bestclick= subset(data_bestclick,select=-N.y)
    data_bestclick= subset(data_bestclick,select=-control.x)
    data_bestclick= subset(data_bestclick,select=-control.y)
    data_bestclick= subset(data_bestclick,select=-n1.y)
    data_bestclick= subset(data_bestclick,select=-n2.y)
    data_bestclick= subset(data_bestclick,select=-distribution.x)
    
    names(data_bestclick)[names(data_bestclick)=='mom1_1.y'] <- 'mom1_grp1'
    names(data_bestclick)[names(data_bestclick)=='mom2_1.y'] <- 'mom2_grp1'
    names(data_bestclick)[names(data_bestclick)=='mom3_1.y'] <- 'mom3_grp1'
    names(data_bestclick)[names(data_bestclick)=='mom4_1.y'] <- 'mom4_grp1'
    names(data_bestclick)[names(data_bestclick)=='mom1_2.y'] <- 'mom1_grp2'
    names(data_bestclick)[names(data_bestclick)=='mom2_2.y'] <- 'mom2_grp2'
    names(data_bestclick)[names(data_bestclick)=='mom3_2.y'] <- 'mom3_grp2'
    names(data_bestclick)[names(data_bestclick)=='mom4_2.y'] <- 'mom4_grp2'
    names(data_bestclick)[names(data_bestclick)=='delta.y'] <- 'delta'
   
    
    data_bestclick$l_CI.y= round(as.numeric(data_bestclick$l_CI.y),digits=2)
    data_bestclick$u_CI.y= round(as.numeric(data_bestclick$u_CI.y),digits=2)
    
    results=brushedPoints(data_bestclick, input$plot_bestclick)
    
    results$power.x <- format(round(results$power.x, 3), nsmall = 3)
    results$power.y <- format(round(results$power.y, 3), nsmall = 3)
    results$l_CI.x <- format(round(results$l_CI.x, 3), nsmall = 3)
    results$l_CI.y <- format(round(results$l_CI.y, 3), nsmall = 3)
    results$u_CI.x <- format(round(results$u_CI.x, 3), nsmall = 3)
    results$u_CI.y <- format(round(results$u_CI.y, 3), nsmall = 3)
    
    colnames(results) = c("Sceanrio","method.x","power.x","lower_CI.x","upper_CI.x","method.y","delta","power.y","lower_CI.y","upper_CI.y","mean_grp1","mean_grp2","var_grp1","var_grp2","skew_grp1","skew_grp2","kurt_grp1","kurt_grp2")
    
    results

  })
 

  observeEvent(input$help,
               introjs(session, options = list("nextLabel"="Next",
                                               "prevLabel"="Previous",
                                               "skipLabel"="Help Information"),
                       events = list("oncomplete"=I('alert("Completed initial help instuctions")')))
  )
 

})
