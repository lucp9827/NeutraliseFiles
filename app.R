library(shiny)
library(ggplot2)
library(dplyr)
library(grid)

source("help.R")

load(file = "Results\\NeutraliseStatus.RData")

names_methods=(All_Neutralised(neutralise.status))

names_data_scenarios = All_Neutralised(neutralise.status,type='data')

names_data=c(names_data_scenarios,All="All")

load(file="Results_power_perdatagen_df.RData")
load(file="Results_power_perdatagen.RData")

load(file="Results_type1_perdatagen_df.RData")
load(file="Results_typeI_perdatagen.RData")

results_df = results_datagen_df
results_list = results_datagen

results_type1_list = results_datagen_type1
results_type1_df = results_datagen_df_type1

ui <- fluidPage(
  
  titlePanel("Neutralise"),
  
  sidebarLayout(position = "right",
    
    sidebarPanel(width=2,
      
      radioButtons("select", label = h5("Select siginificance level (alpha):"), 
                  choices = c("1%" = 0.01, "5%" = 0.05, "10%" = 0.10), 
                  selected = 0.05),
      checkboxInput("checkbox_filter", label = "Filter on Type I error control", value = FALSE)
      
    ),
    
    mainPanel(h3("An open source initiative for neutral comparison of
two-sample tests"),
      tabsetPanel(
        
        tabPanel("Methods",helpText(br(),h4(strong("Summary of the included methods:")),br()) ,tableOutput("Methods")),
        
        tabPanel("Data Scenarios",helpText(br(),h4(strong("Summary of the scenarios (power), per data generation method:"),br(),h5("If you check the box on 'Filter on Type I error control', the methods and specific scenarios (Type I error) that are filtered out appear below the table"))), tableOutput("Scenarios"),
                 radioButtons("select_data_scenario", label = h4("Data generation methods"),choices = names_data_scenarios) ,tableOutput("Filtered_Scenarios")),
        
        
        tabPanel("Type 1 error", plotOutput("Type_1_error", brush="plot_type1",height = "800px"),tableOutput('brush_type1'),
                 helpText("You can select a 'box' on the boxplot and the specific scenario and method information will apear in the table under the plot (only possible if panel 'data generation' or 'sample size' is checked)."),
                 fluidRow(
                   column(4,radioButtons("check_one",label=h4("Methods"),choices=names_methods)),
                   
                   column(4,radioButtons("select_panel1", label = h4("Select panel"), 
                                         choices = c("Data generation method"="distribution","Sample size"="n","None"=""),selected=""), checkboxInput("all_m1",label="All methods", value=FALSE))
                   
                   
                 )), 
        
        
        tabPanel("Power curve",plotOutput("curve_Power", height = "800px"),
                 helpText("Choose a parameter setting for the specified data generation method that has repetitons of parameter delta (see tab 'Data scenarios'), to get a 'proper' power curve per sample size. "),
                 fluidRow(
                   column(4,radioButtons("check_one1",label=h4("Methods"),choices=names_methods)),
                   column(3,
                          radioButtons("select_data_scenario_power1", label = h4("Data generation methods"),choices = names_data_scenarios),uiOutput("parameters1"),uiOutput("parameters_val1") ),
                   column(3, checkboxInput("checkbox_ci1", label = "Confidence Interval", value = FALSE), checkboxInput("checkbox_allmeth", label = "All methods", value = FALSE))
                 )),
        
        
        tabPanel("Power - Power curve",plotOutput("Power2", brush="plot_2power"),tableOutput("click_2power"),
                 br(),
                 br(),
                 helpText("Choose two methods to compare the power per scenario. You can specify a data generation method by selecting the specific box, it's also possible to fix a parameter setting for the specified data generation method. (see tab 'Data scenarios' for the possible parameter settings per data generation method)",br(),"You can select a 'box' on the graph and the specific scenario and method information will apear in the table under the graph."),  
              fluidRow(
                 column(3,checkboxGroupInput("check",label=h4("Methods"),choices=names_methods)),
                 
                 column(3, radioButtons("select_data", label = h4("Data generation methods"),choices = names_data,selected="All")
                  ,uiOutput("setting")),
                 
                 column(3,uiOutput("parameters"),uiOutput("parameters_val")),
                 
                 column(3,textOutput("Power1"))
                          )),
        
        
        
        
        
        tabPanel("General comparison Data.gen.",plotOutput("general", brush="plot_click", height = "800px"),tableOutput("click_data"),
                 helpText("The moments are numerically determined from a simulated dataset of the data generation methods (10 000 observations per group - seed = 9827).",br(),"You can select a 'box' on the graph and the specific scenario and method/data generation method information will apear in the table under the graph."),fluidRow(
                   column(4,radioButtons("check_one_general",label=h4("Methods"),choices=names_methods)),
                   column(4,radioButtons("check_yvar",label=h4(""),choices=c("Power"="power","Type 1 error"="type1")),radioButtons("check_moment",label=h4("Moment"),choices=c("Moment 1 (group 1)" ="mom1_1","Moment 2 (group 1)" ="mom2_1","Moment 3 (group 1)" ="mom3_1","Moment 4 (group 1)" ="mom4_1","Moment 1 (group 2)" ="mom1_2","Moment 2 (group 2)" ="mom2_2","Moment 3 (group 2)" ="mom3_2","Moment 4 (group 2)" ="mom4_2")))
                 ,column(4,radioButtons("check_n",label=h4("Sample Size"),choices=c("20" =20,"40" =40, "110" =110,"200" =200))
                 ,checkboxInput("checkbox_group", label = "Visualize all methods", value = FALSE)))
        
                 
        
      ),
      tabPanel("Best method",br(),helpText("A table of the 'best method(s)' per data generation method. The 'best method' is chosen based on having the highest power in most scenarios, per data generation method and sample size. The default mode uses all methods to chose the 'best method', it's also possible to select a subset of methods. "),tableOutput("Bestmethods"),
               fluidRow(
        column(3,checkboxGroupInput("check_methodbest",label=h4("Methods"),choices=names_methods)),
        column(4,radioButtons("check_size",label=h4("Sample Size"),choices=c("20" =20,"40" =40, "110" =110,"200" =200)))
        ,column(4,radioButtons("comp_meth",label=h4("Compare to best methods (per scenario and sample size"),choices=names_methods)))
        ,helpText("A plot that compares a specified method to the best methods per scenario and sample size. You can select a 'box' on the graph and the specific scenario and method/data generation method information will apear in the table under the graph.") ,plotOutput("Bestmethods_plot", brush="plot_bestclick", height = "800px")  , h4(textOutput("Bestmethods_txt")),tableOutput("click_bestdata") )
      
    
    )
  )
)
)
# Define server logic ----
server <- function(input, output) {
  
  output$setting = renderUI({
    if (input$select_data!='All'){
      checkboxInput("checkbox2", label = "Fix Parameter setting", value = FALSE)
    }else{
      checkboxInput("checkbox", label = "Group Data generation methods", value = FALSE)
      
      }
    
  })

  output$parameters = renderUI({
    req(input$checkbox2) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
    
    if (input$select_data!='All'& input$checkbox2==TRUE ){
    scenarios_names = All_Neutralised_Scenarios(input$select_data)
    
    radioButtons("test", label = "Choose parameter", choices = c(names(scenarios_names),"None"=""),selected="")
    }
  })
  output$parameters_val = renderUI({
    req(input$test) 
    if (input$select_data!='All' & input$checkbox2==TRUE ){
    scenarios_names = All_Neutralised_Scenarios(input$select_data)
    
    radioButtons("test1", label = "Choose parameter value", choices = c(unique(scenarios_names[,c(input$test)]),"None"=""),selected="")
    }
  })
  
  x=reactive({
    
    if (input$select_data!='All' & input$checkbox2==TRUE){
    name=as.character(input$test)
    val=input$test1
    
    if((name)==""){
      NULL
      }else{
        df=data.frame(as.numeric(val))
        colnames(df)=c(input$test)
        df
      }} else{
      NULL
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
  
  output$Power2 <- renderPlot({
    req(input$check[1])
    req(input$check[2])
    
    
    if (input$select_data!="All"){
      
      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=x(),filter=input$checkbox_filter)$graph
        }else{
      
      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter)$graph
    } 
  
      })
  output$Power1<-renderText({
    req(input$check[1])
    req(input$check[2])
    
    
    if (input$select_data!="All"){
      
      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=x(),filter=input$checkbox_filter)$text
    }else{
      
      Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),group=input$checkbox,filter=input$checkbox_filter)$text
    } 
    
  })
  
  output$click_2power<-renderTable({
    req(input$check[1])
    req(input$check[2])
    
    
    if (input$select_data!="All"){
      
      data_click=Power_QQ(input$check[1],input$check[2],filter_list(),alpha=as.numeric(input$select),data=input$select_data,par.fix=x(),filter=input$checkbox_filter)$total
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
    data_click= subset(data_click,select=-n1.x)
    data_click= subset(data_click,select=-n2.x)
    data_click= subset(data_click,select=-id.x)
    data_click= subset(data_click,select=-id.y)
    
    names(data_click)[names(data_click)=='distribution.y'] <- 'datagen'
    names(data_click)[names(data_click)=='mom1_1.y'] <- 'mom1_group1'
    names(data_click)[names(data_click)=='mom2_1.y'] <- 'mom2_group1'
    names(data_click)[names(data_click)=='mom3_1.y'] <- 'mom3_group1'
    names(data_click)[names(data_click)=='mom4_1.y'] <- 'mom4_group1'
    names(data_click)[names(data_click)=='mom1_2.y'] <- 'mom1_group2'
    names(data_click)[names(data_click)=='mom2_2.y'] <- 'mom2_group2'
    names(data_click)[names(data_click)=='mom3_2.y'] <- 'mom3_group2'
    names(data_click)[names(data_click)=='mom4_2.y'] <- 'mom4_group2'
    names(data_click)[names(data_click)=='delta.y'] <- 'delta'
    names(data_click)[names(data_click)=='n1.y'] <- 'n1'
    names(data_click)[names(data_click)=='n2.y'] <- 'n2'
    
    brushedPoints(data_click,input$plot_2power)
    
    
  })
  
  
  output$Scenarios<-renderTable({
    
    All_Neutralised_Scenarios(input$select_data_scenario)
    
    
    
  })
  
  output$Filtered_Scenarios<-renderTable({
    
    if (input$checkbox_filter==TRUE){
      filtered_data_scenarios(results_type1_list,data=input$select_data_scenario,alpha=as.numeric(input$select))$filter_data
    }
  })
  
  output$Type_1_error<-renderPlot({
    
    Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$graph
   
    },height=800)
  
 output$brush_type1 <- renderTable({
   
   data_brush = Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1,results=results_type1_list,group=input$all_m1)$data
   brushedPoints(data_brush, input$plot_type1) 
 })
  
 output$parameters1 = renderUI({
   req(input$select_data_scenario_power1) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
     scenarios_names = All_Neutralised_Scenarios(input$select_data_scenario_power1)
     scenarios_names=subset(scenarios_names,select=-delta)
     
     radioButtons("test_pwrcurve", label = "Choose parameter", choices = c(names(scenarios_names),"None"="None"),selected="None")
   
 })
 output$parameters_val1 = renderUI({
   req(input$test_pwrcurve) 
     scenarios_names = All_Neutralised_Scenarios(input$select_data_scenario_power1)
     scenarios_names=subset(scenarios_names,select=-delta)
     if (input$test_pwrcurve!="None"){
     
     radioButtons("test_1pwrcurve", label = "Choose parameter value", choices = c(unique(scenarios_names[,c(input$test_pwrcurve)]),"None"=""),selected="")
 }
     })
 
 y=reactive({
   
     name=as.character(input$test_pwrcurve)
     
     if((name)=="None"){
       NULL
     }else{
       val=input$test_1pwrcurve
       df=data.frame(as.numeric(val))
       colnames(df)=c(input$test_pwrcurve)
       df
     }
   
 })
 
 output$curve_Power <- renderPlot({
   
   Power_curve_ALL(input$check_one1,results=filter_list(),alpha=as.numeric(input$select),data=input$select_data_scenario_power1,CI=input$checkbox_ci1,par.fix=y(),group = input$checkbox_allmeth,filter=input$checkbox_filter)
 }) 
 
 
 
 output$Methods <- renderTable({
   sum_methods()
 })
 
 filter_df = reactive({
   if (input$checkbox_filter){
     results_df1 = filter_type1(results=results_type1_list,results_power = results_list,alpha = as.numeric(input$select))$filter_df
     results_df1
   }else{
     results_df1 = results_df
     results_df1
   }
 })
 output$general<-renderPlot({
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
   moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=input$check_moment,n=as.numeric(input$check_n),results,group=input$checkbox_group)$graph
   }else{
    moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=input$check_moment,n=as.numeric(input$check_n),results,group=input$checkbox_group,filter=TRUE)$graph
   }
     
     },height=800)
 
 output$click_data<-renderTable({
   # if (input$check_yvar=="power"){
   #   results = results_df
   # }else{
   #   results = results_type1_df
   # }
   # 
   if (input$checkbox_filter==FALSE){
   data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=input$check_moment,n=as.numeric(input$check_n),results=filter_df(),group=input$checkbox_group)
   brushedPoints(data_click$data, input$plot_click,xvar=input$check_moment)
   }else{
     data_click=moments_curve(method=input$check_one_general,alpha=as.numeric(input$select),moment=input$check_moment,n=as.numeric(input$check_n),results=filter_df(),group=input$checkbox_group,filter=TRUE)
     brushedPoints(data_click$data, input$plot_click,xvar=input$check_moment)
   }
   
 })
 
 output$Bestmethods<-renderTable({
   if (input$checkbox_filter!=TRUE){
   best_method(results_df,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size)$end
   }else{
   results_filter = filter_type1(results=results_type1_list,results_power=results_list,alpha=as.numeric(input$select))$filter_df
   best_method(results_filter,name_methods=as.vector(input$check_methodbest),alpha=input$select,n=input$check_size,filter=FALSE)$end
   }
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
       
       names(data_bestclick)[names(data_bestclick)=='distribution.x'] <- 'datagen'
       names(data_bestclick)[names(data_bestclick)=='mom1_1.y'] <- 'mom1_group1'
       names(data_bestclick)[names(data_bestclick)=='mom2_1.y'] <- 'mom2_group1'
       names(data_bestclick)[names(data_bestclick)=='mom3_1.y'] <- 'mom3_group1'
       names(data_bestclick)[names(data_bestclick)=='mom4_1.y'] <- 'mom4_group1'
       names(data_bestclick)[names(data_bestclick)=='mom1_2.y'] <- 'mom1_group2'
       names(data_bestclick)[names(data_bestclick)=='mom2_2.y'] <- 'mom2_group2'
       names(data_bestclick)[names(data_bestclick)=='mom3_2.y'] <- 'mom3_group2'
       names(data_bestclick)[names(data_bestclick)=='mom4_2.y'] <- 'mom4_group2'
       names(data_bestclick)[names(data_bestclick)=='delta.y'] <- 'delta'
       names(data_bestclick)[names(data_bestclick)=='n1.y'] <- 'n1'
       names(data_bestclick)[names(data_bestclick)=='n2.y'] <- 'n2'
       names(data_bestclick)[names(data_bestclick)=='n.y'] <- 'n'
       
       brushedPoints(data_bestclick, input$plot_bestclick)

   }) 
   
}
# Run the app ----

shinyApp(ui = ui, server = server)
