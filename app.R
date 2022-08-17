library(shiny)
library(ggplot2)
library(dplyr)
library(grid)

source("help.R")

load(file = "Results\\NeutraliseStatus.RData")

names_methods=(All_Neutralised(neutralise.status))

names_data_scenarios = All_Neutralised(neutralise.status,type='data')

names_data=c(All_Neutralised(neutralise.status,type='data'),"General")


ui <- fluidPage(
  
  titlePanel("Neutralise"),
  
  sidebarLayout(position = "right",
    
    sidebarPanel(width=2,
      
      radioButtons("select", label = h4("Siginificance level (alpha)"), 
                  choices = c("1%" = 0.01, "5%" = 0.05, "10%" = 0.10), 
                  selected = 0.05)
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("Power - Comparing 2 methods",plotOutput("Power2"),
                 br(),
                 br(),
                 
              fluidRow(
                 column(4,checkboxGroupInput("check",label=h4("Methods"),choices=names_methods)),
                 
                 column(3, radioButtons("select_data", label = h4("Data generation methods"),choices = names_data,selected="General")
                  ,uiOutput("setting")),
                 
                 column(5,uiOutput("parameters"),uiOutput("parameters_val"),textOutput("Power1"))
                          )),
        
        tabPanel("Type 1 error - One method", plotOutput("Type_1_error"),
                 
                 fluidRow(
                 column(4,radioButtons("check_one",label=h4("Methods"),choices=names_methods)),
                 
                 column(4,radioButtons("select_panel1", label = h4("Select panel"), 
                              choices = c("Data generation method"="distribution","Sample size"="n","None"=""),selected=""))     
                 
                 )), 
        
        tabPanel("Type I error - All methods",plotOutput("Multiple_Type_1_error"),
                 fluidRow(
                   column(3,offset=12,
                 radioButtons("select_panel2", label = h4("Select panel"), choices = c("Data generation method"="distribution","Sample size"="n","None"=""),selected="") )
        )),
        
        tabPanel("Power curve - One method",plotOutput("curve_Power"),
                 fluidRow(
                   column(4,radioButtons("check_one1",label=h4("Methods"),choices=names_methods)),
                   column(3,
                          radioButtons("select_data_scenario_power1", label = h4("Data generation methods"),choices = names_data_scenarios),uiOutput("parameters1"),uiOutput("parameters_val1") ),
                   column(3, checkboxInput("checkbox_ci1", label = "Confidence Interval", value = FALSE))
                 )),
        
        tabPanel("Power curve - All methods",plotOutput("Multiple_Power"),
                 fluidRow(
                   column(3,offset=12,
                          radioButtons("select_data_scenario_power", label = h4("Data generation methods"),choices = names_data_scenarios),uiOutput("parameters2"),uiOutput("parameters_val2")  ),
                   column(3,offset =12, checkboxInput("checkbox_ci", label = "Confidence Interval", value = FALSE))
                )),
        tabPanel("Extra figures",plotOutput("heat"),plotOutput("dendogram")),
        tabPanel("Data Scenarios", tableOutput("Scenarios"),
                 radioButtons("select_data_scenario", label = h4("Data generation methods"),choices = names_data_scenarios)),
        tabPanel("Methods", tableOutput("Methods"))
        
      )
    )
  )
)
# Define server logic ----
server <- function(input, output) {
  
  output$setting = renderUI({
    if (input$select_data!='General'){
      checkboxInput("checkbox2", label = "Fix Parameter setting", value = FALSE)
    }else{
      checkboxInput("checkbox", label = "Group Data generation methods", value = FALSE)
      
      }
    
  })

  output$parameters = renderUI({
    req(input$checkbox2) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
    
    if (input$select_data!='General'& input$checkbox2==TRUE ){
    scenarios_names = All_Neutralised_Scenarios(input$select_data)
    
    radioButtons("test", label = "Choose parameter", choices = c(names(scenarios_names),"None"=""),selected="")
    }
  })
  output$parameters_val = renderUI({
    req(input$test) 
    if (input$select_data!='General' & input$checkbox2==TRUE ){
    scenarios_names = All_Neutralised_Scenarios(input$select_data)
    
    radioButtons("test1", label = "Choose parameter value", choices = c(unique(scenarios_names[,c(input$test)]),"None"=""),selected="")
    }
  })
  
  x=reactive({
    
    if (input$select_data!='General' & input$checkbox2==TRUE){
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
  
  output$Power2 <- renderPlot({
    req(input$check[1])
    req(input$check[2])
    if (input$select_data!="General"){
      
      Power_QQ(input$check[1],input$check[2],alpha=as.numeric(input$select),data=input$select_data,par.fix=x())$graph
        }else{
      
      Power_QQ(input$check[1],input$check[2],alpha=as.numeric(input$select),group=input$checkbox)$graph
    } 
  
      })
  output$Power1<-renderText({
    req(input$check[1])
    req(input$check[2])
    if (input$select_data!="General"){
      
      Power_QQ(input$check[1],input$check[2],alpha=as.numeric(input$select),data=input$select_data,par.fix=x())$text
    }else{
      
      Power_QQ(input$check[1],input$check[2],alpha=as.numeric(input$select),group=input$checkbox)$text
    } 
    
  })
  
  
  output$Scenarios<-renderTable({
    
    All_Neutralised_Scenarios(input$select_data_scenario)
  })
  
  output$Type_1_error<-renderPlot({
    
    Boxplot_TypeI(input$check_one,alpha=as.numeric(input$select),panel=input$select_panel1)$graph
      
    })
  
 output$Multiple_Type_1_error <- renderPlot({
   Boxplot_TypeI_ALL(names_methods,alpha=as.numeric(input$select),panel=input$select_panel2)$graph
 },height=800) 
 
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
   
   
   Power_curve_ALL(input$check_one1,alpha=as.numeric(input$select),data=input$select_data_scenario_power1,CI=input$checkbox_ci1,par.fix=y())
 }) 
 
 output$parameters2 = renderUI({
   req(input$select_data_scenario_power) # this makes sure Shiny waits until input$state has been supplied. Avoids nasty error messages
   scenarios_names = All_Neutralised_Scenarios(input$select_data_scenario_power)
   scenarios_names=subset(scenarios_names,select=-delta)
   
   radioButtons("test_pwrcurve_all", label = "Choose parameter", choices = c(names(scenarios_names),"None"="None"),selected="None")
   
 })
 output$parameters_val2 = renderUI({
   req(input$test_pwrcurve_all) 
   scenarios_names = All_Neutralised_Scenarios(input$select_data_scenario_power)
   scenarios_names=subset(scenarios_names,select=-delta)
   if (input$test_pwrcurve_all!="None"){
     
     radioButtons("test_1pwrcurve_all", label = "Choose parameter value", choices = c(unique(scenarios_names[,c(input$test_pwrcurve_all)]),"None"=""),selected="")
   }
 })
 
 z=reactive({
   
   name=as.character(input$test_pwrcurve_all)
   
   if((name)=="None"){
     NULL
   }else{
     val=input$test_1pwrcurve_all
     df=data.frame(as.numeric(val))
     colnames(df)=c(input$test_pwrcurve_all)
     df
   }
   
 })
 output$Multiple_Power <- renderPlot({
   Power_curve_ALL(names_methods,alpha=as.numeric(input$select),data=input$select_data_scenario_power,CI=input$checkbox_ci,par.fix=z())
 },height=800) 
 
 output$heat <- renderPlot({
   mat_pwr=sum_res_mat(input$select,names_methods)
   distance_matrix=dist(mat_pwr,method="euclidian")
   heatmap(as.matrix(distance_matrix),scale='none')
  
 })
 
 output$dendogram <- renderPlot({
   mat_pwr=sum_res_mat(input$select,names_methods)
   distance_matrix=dist(mat_pwr,method="euclidian")
   eg3.hclust <- hclust(distance_matrix,method='average')
   plot(eg3.hclust, hang = -1)
 })
 
 output$Methods <- renderTable({
   sum_methods()
 })
}
# Run the app ----

shinyApp(ui = ui, server = server)
