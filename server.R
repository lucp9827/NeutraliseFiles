library(shiny)
library(ggplot2)
library(dplyr)
library(grid)
library(scales)

source("help.R")

# Load file for parameter_explation 
load(file="parameter_explanation.RData")

# Load Neutralised table
load(file = "results/neutralisestatus.RData")

# load Power results
load(file="results_power_perdatagen_df.RData")
load(file="results_power_perdatagen.RData")

results_df = results_datagen_df
results_list = results_datagen
rm(results_datagen_df)
rm(results_datagen)

# load type I error rate results
load(file="results_type1_perdatagen_df.RData")
load(file="results_typeI_perdatagen.RData")


results_type1_list = results_datagen_type1
results_type1_df = results_datagen_df_type1
rm(results_datagen_type1)
rm(results_datagen_df_type1)

my_max <- 2

shinyServer(function(input, output,session) {
  
## Tab 1: Homepage
  # Shows DSI logo in Side bar
  output$Home1<-renderImage({
    (list(src="www/dsi_logo.png",width="100%",height=150))
  },deleteFile=F)
  
  # Shows DSI logo on HomePage
  output$picture<-renderImage({
    (list(src="www/test.png",width="25%",height=150))
  },deleteFile=F)
  
## Tab 2: Methods
  # Summary methods
  output$Methods <- renderTable({
    sum_methods()
  })
  
## Tab 3: Scenarios
  # Summary Simulation scenarios - Power and Type I error rate
  
  output$Scenarios<-renderTable({
    
    All_Neutralised_Scenarios(input$select_data_scenario)
    
     })
  
  output$typeI_scenarios<-renderTable({
    
    if (input$select_data_scenario=="Normal2Var"){
      All_Neutralised_Scenarios("Normal",type="typeI")} else{
        All_Neutralised_Scenarios(input$select_data_scenario,type="typeI")
      }
    
  })
  
  # Explanation data generation methods parameters
  output$parameter_description<-renderTable({
    parameter_explanation[[input$select_data_scenario]]
    
  })
  
  ## Reactive elements 
  # Reactive element to filter data (power and type I error rate) based on type I error rate on a nominal significance level
  data_power = eventReactive(c(input$checkbox_filter,input$select),{
                             
                             
                             if(input$checkbox_filter){
                             
                              res = filter_type1(results_type1_list,results_list,as.numeric(input$select))
                                    
                              list(
                                res_list = res$filter_list,
                                res_df = res$filter_df
                              )
                                    
                             } else {
                               
                               res = filter_significance(results_df,as.numeric(input$select))
                               
                              list(res_list = results_list,
                                   res_df = res
                                 )}
})
  
  data_typeI  = eventReactive(c(input$checkbox_filter,input$select),{
                              
                              
                              if(input$checkbox_filter){
                                
                                res = fil_for_type1(results_type1_list,as.numeric(input$select))
                                
                                list(res_list = res$filter_list,
                                     res_df = res$filter_df
                                )
                                
                              } else {
                                
                                res = filter_significance(results_type1_df,as.numeric(input$select))
                                
                                list(res_list = results_type1_list,
                                     res_df = res
                                )}
  })
  
  # Reactive elements for the plots in the Data tab
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
  
  results_type = reactive({
    
    if (input$check_yvar=="type1"){
      
      data_typeI()
      
    } else {
      data_power()
    }
    
    
  })
  
## Tab 4: Data
  waitress4 = waiter::Waitress$new("#general1", theme="overlay-percent",hide_on_render = TRUE) # Load process bar
  
  # Plot of Group 1
  output$general1<-renderPlot({
    
    waitress4$start()
    results = results_type()
    moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results=results$res_df,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$graph
    
    },height=800)
  
  # Table of Group 1
  output$click_data<-renderTable({
    
    results = results_type()
    
    data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results=results$res_df,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$data

      data_click= subset(data_click,select=-seed)
      data_click= subset(data_click,select=-N)
      data_click= subset(data_click,select=-n1)
      data_click= subset(data_click,select=-n2)
      data_click= subset(data_click,select=-n)
      data_click= subset(data_click,select=-cnt)
      if(input$checkbox_filter){data_click= subset(data_click,select=-control)}

      results_table=brushedPoints(data_click, input$plot_click1,xvar=paste0(input$check_moment,'_1'))
      results_table$power = format(round(results_table$power, 4), nsmall = 4)
      results_table$l_CI <- format(round(results_table$l_CI, 4), nsmall = 4)
      results_table$u_CI <- format(round(results_table$u_CI, 4), nsmall = 4)

      if (input$check_yvar=="type1"){
        colnames(results_table) = c("method","distribution","delta","Type I error rate","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")

      }else{
        colnames(results_table) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
      }
      results_table
    
  })
  
  # Plot of Group 2
  waitress5 = waiter::Waitress$new("#general2", theme="overlay-percent",hide_on_render = TRUE)  # Load process bar
  
  output$general2<-renderPlot({
    
    if(input$check_moment=='mom1'|input$check_moment=='mom2' ){
      
    }else{
      waitress5$start()
      results = results_type()
      moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results=results$res_df,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$graph
      }
    
  },height=800)
  
  # Table of Group 2
  output$click_data2<-renderTable({
    
    results = results_type()
    
      data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results=results$res_df,group=input$checkbox_group,filter=TRUE,ylabs(),ylim())$data
      data_click= subset(data_click,select=-seed)
      data_click= subset(data_click,select=-N)
      data_click= subset(data_click,select=-n1)
      data_click= subset(data_click,select=-n2)
      data_click= subset(data_click,select=-n)
      data_click= subset(data_click,select=-cnt)
      if(input$checkbox_filter){data_click= subset(data_click,select=-control)}
      
      
      results_table = brushedPoints(data_click, input$plot_click2,xvar=paste0(input$check_moment,'_2'))
      results_table$power = format(round(results_table$power, 4), nsmall = 4)
      results_table$l_CI <- format(round(results_table$l_CI, 4), nsmall = 4)
      results_table$u_CI <- format(round(results_table$u_CI, 4), nsmall = 4)
      
      if (input$check_yvar=="type1"){
        colnames(results_table ) = c("method","distribution","delta","Type I error rate","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
        
      }else{
        colnames(results_table ) = c("method","distribution","delta","power","lower_CI","upper_CI","id","mean_1","mean_2","var_1","var_2","skew_1",'skew2',"kurt_1","kurt_2")
      }
      results_table 
    
  })
  
## Tab 5: Type I error
  waitress = waiter::Waitress$new("#Type_1_error", theme="overlay-percent",hide_on_render = TRUE) # Load process bar
  
  # BoxPlot
  output$Type_1_error<- renderPlot({
    waitress$start()
    Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$graph
    
  },height=800)
  
  # Table
  output$brush_type1 <- renderTable({
    
    if(input$select_panel1==""){
      
      print("Select a panel if you want to use the brush function.")
      
    }else{
      
    data_brush = Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$data
    
    data_brush = subset(data_brush,select=-seed)
    data_brush = subset(data_brush,select=-N)
    data_brush = subset(data_brush,select=-n1)
    data_brush = subset(data_brush,select=-n2)
    data_brush = subset(data_brush,select=-cnt)
    
    
    results = brushedPoints(data_brush, input$plot_type1)
    
    results$power <- format(round(results$power, 4), nsmall = 4)
    results$power <- format(round(results$l_CI, 4), nsmall = 4)
    results$power <- format(round(results$u_CI, 4), nsmall = 4)
    
    colnames(results) = c('method','distribution','type I error rate','lower_CI','upper_CI',"n","id","mean_1","mean_2","var_1","var_2","skew_1","skew_2",'kurt_1','kurt_2')
    results}
    })

## Tab 6: Power-curve
  waitress1 = waiter::Waitress$new("#curvePower", theme="overlay-percent",hide_on_render = TRUE) # Load process bar
  
  # Parameter tab in box for inputs
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
  
  # Plot
  output$curve_Power <- renderPlot({
    
    waitress1$start()
    #req(input$select_data_scenario_power1)
    req(input$test_pwrcurve)
    unique_scen = unique_combinations(input$select_data_scenario_power1)
    val = as.numeric(unlist(strsplit(input$test_pwrcurve,"_")))
    par_fix = data.frame(t(val))
    colnames(par_fix) <- colnames(unique_scen)
   
    results = data_power()
    
    Power_curve_ALL(input$check_one1,results=results_type1_list,results_power=results$res_list,alpha=as.numeric(input$select),data=input$select_data_scenario_power1,CI=input$checkbox_ci1,par.fix=par_fix,group = input$checkbox_allmeth,neutralise.status=neutralise.status,n=input$check_sample)
  
    })

## Tab 7: Power-Power curve
  waitress2 = waiter::Waitress$new("#Power2", theme="overlay-percent",hide_on_render = TRUE) # Load process bar
  
  # Reactive elements for parameters
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
  
  
  # Reactive element for QQ-plot
  results_QQ = eventReactive(c(
    input$check[1],
    input$check[2],
    input$select,
    input$select_data,
    input$checkbox_filter,
    input$check_samplepp,
    input$checkbox,
    input$checkbox2,
    input$test
    ) ,{
    
    result = data_power()
    
    if (input$select_data!="All"){
      
      Power_QQ(input$check[1],input$check[2],result$res_list,alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter,n=input$check_samplepp)
    }else{
      
      Power_QQ(input$check[1],input$check[2],result$res_list,alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter,n=input$check_samplepp)
    }
    
  })
  
  # Plot
  output$Power2 <- renderPlot({
    
    req(input$check[1])
    req(input$check[2])
    
    waitress2$start()
    
    plot_qq =  results_QQ()
    
    plot_qq$graph

  })
  
  # Table - Results written 
  output$Power1<-renderText({
    req(input$check[1])
    req(input$check[2])
    
    plot_qq =  results_QQ()
    
    if (input$select_data!="All"){
      
      plot_qq$text
    }else{
      
      paste(plot_qq$text,collapse="<br>")
    }
    })
  
  # Table - Filtered scenarios
  output$Mis<-renderText({
    req(input$check[1])
    req(input$check[2])
    
    plot_qq =  results_QQ()
    if (input$select_data!="All"){
      
      
      plot_qq$text2
    }else{
      
      paste(plot_qq$text2,collapse="<br>")
    }
    
    
  })
  
  # Table - Brush function
  
  output$click_2power<-renderTable({
    req(input$check[1])
    req(input$check[2])
    
    plot_qq =  results_QQ()
    
    data_click = plot_qq$total

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
    
    if(input$checkbox_filter){
    data_click= subset(data_click,select=-control.y)
    data_click= subset(data_click,select=-control.x)}

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

## Tab 8:  Best method  
  waitress3 = waiter::Waitress$new("#Bestmethods_plot", theme="overlay-percent",hide_on_render = TRUE)
  
  # reactive element for best method
  
  results_bm = eventReactive(c(
    input$check_methodbest,
    input$checkbox_filter,
    input$select,
    input$check_size),{
    
    result = data_power()
    
    best_method(result$res_df,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size)
    
                             })
  
  
  result_bmp = eventReactive(c(input$comp_meth,
                               input$check_size,
                               input$select,
                               input$check_methodbest,
                               input$checkbox_filter),{
    
    result = data_power()
    best_method_plot(input$comp_meth,n=input$check_size, result$res_df,alpha=input$select,as.vector(input$check_methodbest))
  })
  
  
  # Table
  output$Bestmethods<-renderTable({
    dd=results_bm()
    dd$end
  })
  
  # BarPlot
  output$BM<-renderPlot({
    
    
    dd=results_bm()
    
    dda=dd$all
    ddn=dd$end
    ddn_a= unique(ddn[ddn$distribution==input$select_data_scenario_bm,"nscenarios"])
    xx=unique(dda[dda$distribution==input$select_data_scenario_bm,c("method","count")])
    xx=data.frame(method=xx$method,count=xx$count,n=ddn_a)
    
    ggplot(xx,aes(x=count/n,y=method))+
      geom_bar(stat='identity')+theme_grey(base_size = 20)+xlab(paste0("% highest power over all scenarios of ",input$select_data_scenario_bm))+ylab("Methods")
  })
  
  # Plot 
  output$Bestmethods_plot<-renderPlot({
    req(input$comp_meth)
    
    waitress3$start()
    res = result_bmp()
    res$graph
  })
  
  # Results Text
  output$Bestmethods_txt<-renderText({
    res = result_bmp()
    res$text
  })
  output$Bestmethods_txtmis<-renderText({
    res = result_bmp()
    res$text_mis
  })
  # BrushTable
  output$click_bestdata<-renderTable({
    req(input$comp_meth)
    res = result_bmp()
    data_bestclick=res$data
    
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
    if(input$checkbox_filter){
       data_bestclick= subset(data_bestclick,select=-control.x)
    data_bestclick= subset(data_bestclick,select=-control.y)}
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

