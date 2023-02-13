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

      ## Group 1
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
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group)$graph

          }else{
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE)$graph
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
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group)$data

          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)


          brushedPoints(data_click, input$plot_click1,xvar=paste0(input$check_moment,'_1'))
        }else{
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_1'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE)$data

          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)

          brushedPoints(data_click, input$plot_click1,xvar=paste0(input$check_moment,'_1'))
        }
      })

      ## Group 2
      output$general2<-renderPlot({
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
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group)$graph
        }else{
          moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE)$graph
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
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group)$data
          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)
          data_click= subset(data_click,select=-n)

          brushedPoints(data_click, input$plot_click2,xvar=paste0(input$check_moment,'_2'))
        }else{
          data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=paste0(input$check_moment,'_2'),n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE)$data
          data_click= subset(data_click,select=-seed)
          data_click= subset(data_click,select=-N)
          data_click= subset(data_click,select=-n1)
          data_click= subset(data_click,select=-n2)

          brushedPoints(data_click, input$plot_click2,xvar=paste0(input$check_moment,'_2'))
        }
      })


  # Type I error boxplot


  output$Type_1_error<-renderPlot({

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
    brushedPoints(data_brush, input$plot_type1,xvar = input$plot_type1)}else{
      brushedPoints(data_brush, input$plot_type1)
    }
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


  output$curve_Power <- renderPlot({
    req(input$select_data_scenario_power1)
    unique_scen = unique_combinations(input$select_data_scenario_power1)
    val = as.numeric(unlist(strsplit(input$test_pwrcurve,"_")))
    par_fix = data.frame(t(val))
    colnames(par_fix) <- colnames(unique_scen)

    Power_curve_ALL(input$check_one1,results=results_list,alpha=as.numeric(input$select),data=input$select_data_scenario_power1,CI=input$checkbox_ci1,par.fix=par_fix,group = input$checkbox_allmeth,neutralise.status=neutralise.status)
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

  output$Power2 <- renderPlot({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter)$graph
    }else{

      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter)$graph
    }

  })
  output$Power1<-renderText({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter)$text
    }else{

      paste(Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter)$text,collapse="<br>")
    }

  })

  output$click_2power<-renderTable({
    req(input$check[1])
    req(input$check[2])


    if (input$select_data!="All"){


      data_click=Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=par_fix_pp(),filter=input$checkbox_filter)$total
    }else{

      data_click=Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter)$total
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
    


    brushedPoints(data_click,input$plot_2power)


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

  output$Bestmethods_plot<-renderPlot({
    req(input$comp_meth)
    if (input$checkbox_filter==TRUE){
      best_method_plot(input$comp_meth,n=input$check_size, filter_df(),filter=FALSE,alpha=input$select,as.vector(input$check_methodbest))$graph
    }else{
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
    names(data_bestclick)[names(data_bestclick)=='n.y'] <- 'n'
    
    data_bestclick$l_CI.y= round(as.numeric(data_bestclick$l_CI.y),digits=2)
    data_bestclick$u_CI.y= round(as.numeric(data_bestclick$u_CI.y),digits=2)
    
    brushedPoints(data_bestclick, input$plot_bestclick)

  })
 

  observeEvent(input$help,
               introjs(session, options = list("nextLabel"="Onwards and Upwards",
                                               "prevLabel"="Did you forget something?",
                                               "skipLabel"="Don't be a quitter"),
                       events = list("oncomplete"=I('alert("Glad that is over")')))
  )
 

})
