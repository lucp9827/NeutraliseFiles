library(shiny)
library(ggplot2)
library(dplyr)
library(grid)
library(shinydashboard)
library(rintrojs)

source("help.R")

load(file = "Results/neutralisestatus.RData")

names_methods=(All_Neutralised(neutralise.status))

names_data_scenarios = All_Neutralised(neutralise.status,type='data')

names_data=c(names_data_scenarios,All="All")




shinyUI(
  dashboardPage(
  dashboardHeader(title="Neutralise"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("HomePage",tabName="Home"),
      menuItem("Methods",tabName="Methods"),
      menuItem("Scenarios",tabName="Scenarios"),
      menuItem("Data",tabName = "Data"),
      menuItem("Type I error",tabName="TypeIerror"),
      menuItem("Power curve",tabName="Powercurve"),
      menuItem("Power-Power curve",tabName="PowerPowercurve"),
      menuItem("Best Method",tabName = "BM"),
      introBox(menuItem(radioButtons("select", label = h5("Select significance level (alpha):"), 
                            choices = c("1%" = 0.01, "5%" = 0.05, "10%" = 0.10), 
                            selected = 0.05)),data.step = 1,data.intro = "In this box you can select the significance level. Default = 5%"),
      introBox(menuItem(checkboxInput("checkbox_filter", label = "Filter on Type I error control", value = TRUE)),data.step=2,data.intro = "The results (power) are filtered based on the Type I error rate. When the Type I error rate is greater than the tolerated margin, the results are filtered out. This is visualised in the tab Type I error with boxplots."),
      menuItem(imageOutput("Home1"))
    )
  ),
  
  dashboardBody(
    
    introjsUI(),
    tabItems(
      tabItem(
        tabName = "Home",
        box(width=12,h1("Neutralise: An open source initiative for neutral comparison of
two-sample tests"),br(),"The two-sample problem is one of the earliest problems in statistics: given two samples, the question is whether or not the observations were sampled from the same distribution. The Neutralise initiative is a framework that makes it possible to compare two sample tests in many different scenarios in a neutral way. For more details on this initiative we refer to https://github.com/lucp9827/Neutralise. All the results from this initiative can be consulted on the Github page of NeutraliseFiles. This app aims to explore and visualise the results with some extra featers to help understand the results. "),
        
        box(solidHeader = TRUE,status="primary",title=strong("General information"),"On the left side, you can find different tabs which you can select:",br(),br(),
            " 1.", strong("Methods:"), "a summary of the included methods",br(),
            " 2.", strong("Scenarios:"), "a summary of the included scenarios per data generation method for the power and type I error",br(),
            " 3.", strong("Data:"), "Visualisation of the moments per data generation method in relation to the power or type I error of each method",br(),
            " 4.", strong("Type I error:"), "Boxplot of the type I error per method",br(),
            " 5.", strong("Power curve:"), "Power curve of each method per data generation method and parameter scenario",br(),
            " 6.", strong("Power-Power curve:"), "Power-Power curve of two methods over all settings or per data generation method and parameter scenario",br(),
            " 7.", strong("Best Method:"), "A summary and visualistion on methods that have the highest power in the most scenarios and compare results to these best methods",br(),br(),
            
            "Under the tabs you can",br(),br(), "1. Select the", strong("signficance level") ,"you are interested in",br(),
            "2. Select the box",strong( 'Filter on Type I error control'), "if you want that only the results are shown of the scenarios in which the methods control the type I error at the significance level(recommended)"
            ,br(),actionButton("help", "Press for instructions"),br(), "Important note: some plots may take some time to load."),
        box(solidHeader = TRUE,status="primary",title="Contact",
            "Leyla ",HTML(paste0("Kodalci",tags$sup("1"))), "email: leyla.kodalci@uhasselt.be",br(),
            "Olivier ",HTML(paste0("Thas",tags$sup("1,2,3"))),br(),br(),
            HTML(paste0("",tags$sup("1"))),"Interuniversity Institute for Biostatistics and Statistical Bioinformatics, Data Science Institute, Hasselt University, Hasselt, Belgium",br(),
            HTML(paste0("",tags$sup("2"))),"Department of Applied Mathematics, Computer Science and Statistics, Ghent University, Gent, Belgium ",br(),
            HTML(paste0("",tags$sup("3"))),"National Institute for Applied Statistics Research Australia (NIASRA), University of Wollongong, Wollongong, Australia",
            imageOutput("picture")
        )
      ),
      
      tabItem(tabName="Methods", 
              fluidRow(
                box(width=12,solidHeader = TRUE,status="primary",
                  title = strong("Summary of the included methods"),tableOutput("Methods")))),
      
      tabItem(tabName = "Scenarios",
              fluidRow(
              
              box(solidHeader = TRUE,status="primary",title=strong("Summary of the scenarios (power), per data generation method:"), tableOutput("Scenarios")),
              
              box(solidHeader = TRUE,status="danger",title="Data generation methods",column(4,radioButtons("select_data_scenario",label="",choices = names_data_scenarios)),helpText("Select a data generation method and the table will show the parameter settings for that data generation method. The scenarios under the nullhypothesis for that specific data generation method are shown below, as well as a brief description of the parameters. The id for each scenario corresponds between the different tabs. For each scenario, 4 sample size settings are tested (total sample size: 20, 40, 110,200). ")),
              
              box(solidHeader = TRUE,status="primary",title=strong("Type I error scenarios"),tableOutput("typeI_scenarios")),
              
              box(solidHeader = TRUE,status="primary",title=strong("Parameter Description"),tableOutput("parameter_description")),
              #box(h4("Filtered out scenarios"),tableOutput("Filtered_Scenarios"))
              )),
      
      tabItem(tabName="TypeIerror",
              fluidRow(
                box(solidHeader = TRUE,status="primary",title=strong("Boxplot of Type I error"),waiter::useWaitress(),plotOutput("Type_1_error", brush="plot_type1",height = "800px")),
                box(solidHeader = TRUE,status="danger",title="Inputs for Boxplot",column(4,radioButtons("check_one",label=h4("Methods"),choices=names_methods)),column(4,radioButtons("select_panel1", label = h4("Select panel"), 
                                                                                                   choices = c("Data generation method"="distribution","Sample size"="n","None"=""),selected=""), checkboxInput("all_m1",label="All methods", value=FALSE)),helpText("Select a method to show the boxplot of the type I error rate. By selecting a panel, the results will be subdivided by that panel. The brush function is activated for the boxplots when the panel 'Data generation method' or 'Sample size' is selected. Information on the selected points by the brush function will appear in the table below.")),
                fluidRow(box(solidHeader = TRUE,status="primary",title=strong("Table of selected scenarios in the Boxplot of Type I error"),width=12,tableOutput('brush_type1'),collapsible=TRUE))
              )
                
              ),
      tabItem(tabName = "Powercurve",
              fluidRow(
                box(solidHeader = TRUE,status="primary",title=strong("Power curve"),waiter::useWaitress(),plotOutput("curve_Power", height = "800px")),
                box(solidHeader = TRUE,status="danger",title="Inputs for Power curve",
                  column(4,radioButtons("check_one1",label=h4("Methods"),choices=names_methods)),
                  column(3,radioButtons("select_data_scenario_power1", label = h4("Data generation methods"),choices = names_data_scenarios),uiOutput("parameters1"),uiOutput("parameters_val1")),
                 column(3, checkboxInput("checkbox_ci1", label = "Confidence Interval", value = FALSE), checkboxInput("checkbox_allmeth", label = "All methods", value = FALSE),radioButtons("check_sample", label=h4("Sample size"),choices=c("All"="","20"=20,"40"=40,"110"=110,"200"=200),selected="")),
                 helpText("Power curves are displayed for the selected method and data generation method. You can choose to compare all sample sizes (total) per method (sample size = All), or fix the sample size and compare methods within the power curve plot.  You can also choose between scenarios that are unique for delta. And it's is also possible to display the confidence interval of the power results. The results are filtered based on the type I error rate as default.", span("These plots take time to render, so don't be alarmed by the red error message.",style="color:red"))))
                )
              
      ,
      tabItem(tabName="PowerPowercurve",
              fluidRow(
                box(solidHeader = TRUE,status="primary",title=strong("Power-Power curve"),waiter::useWaitress(),plotOutput("Power2", brush="plot_2power")),
                box(solidHeader = TRUE,status="danger",title="Inputs for Power-Power curve",column(3,checkboxGroupInput("check",label=h4("Methods"),choices=names_methods)),
                    column(3, radioButtons("select_data", label = h4("Data generation methods"),choices = names_data,selected="All")
                           ,uiOutput("setting")),
                    column(3,radioButtons("check_samplepp", label=h4("Sample size"),choices=c("All"="","20"=20,"40"=40,"110"=110,"200"=200),selected=""),uiOutput("parameters"),uiOutput("parameters_val")),helpText("The power-power plot is displayed when two methods are selected. To change the selected methods, you can deselect the methods. It's possible to define specific distributions and parameter settings by selecting the relevant box. The brushfunction is activated and displays the results of the selected points below the table. "))
              ),
              fluidRow(
                box(solidHeader = TRUE,status="primary",title=strong("Results of Power-Power curve"),htmlOutput("Power1"),collapsible = TRUE),
                box(solidHeader = TRUE,status="primary",title=strong("Number of Filtered out scenarios based on the type I error rate control."),htmlOutput("Mis"))
              ),
              fluidRow(
                box(solidHeader = TRUE,status="primary",title=strong("Table of selected scenarios in Power-Power curve"),width=12,tableOutput("click_2power")))
              ),
      tabItem(tabName = "BM",
              fluidRow(
                tabBox(id="tabse1",
                  tabPanel("Best Method",(tableOutput("Bestmethods")), helpText("The best method table and plot (below) are displayed against all available methods.",span("These plots take time to render!.",style="color:red") ,"By selecting and/or deslecting methods, you can select a subset of methods to choose the best method from. Best methods are defined as the methods that have the highest power in the most scenarios. These results are dependent on sample size. The plot has a brush function and the information is displayed in the table below. For the 'Compare to best methods' plot, different methods can be selected ('Input to compare to best methods plot' box) to be compared to the best methods (or a subset of those methods- by selecting the methods in the top box). Finally, a barplot is displayed per data generation method to present all methods that have the highest power in at least one scenario.  ")),
                  tabPanel("Barplot of all best Methods per data generation method",plotOutput("BM",height='800px'))
                ),
                
                box(solidHeader = TRUE,status="danger",title="Inputs for best method table and barplot",column(3,checkboxGroupInput("check_methodbest",label=h4("Methods"),choices=names_methods)),
                    column(4,radioButtons("check_size",label=h4("Sample Size"),choices=c("20" =20,"40" =40, "110" =110,"200" =200))),
                    column(3,radioButtons("select_data_scenario_bm", label = h4("Data generation methods"),choices = names_data_scenarios))
                   
                ))
              ,
              fluidRow(
                #box(tableOutput("Bestmethods")),
                box(solidHeader = TRUE,status="primary",title="Compare to best methods plot (per scenario & sample size)",waiter::useWaitress(),plotOutput("Bestmethods_plot", brush="plot_bestclick", height = "800px")),
                box(solidHeader = TRUE,status="danger",title="Input to compare to best methods plot (per scenario & sample size)",column(4,radioButtons("comp_meth",label="",choices=names_methods)))
                ,box(solidHeader = TRUE,status="primary",title="Result of Compare to best methods (per scenario & sample size)",textOutput("Bestmethods_txt"),textOutput("Bestmethods_txtmis"))
            
                ),
              
              fluidRow(box(width=12,solidHeader = TRUE,status="primary",title="Table of selected scenarios in Compare to best methods (per scenario & sample size)",tableOutput("click_bestdata")))
              ),
      tabItem(tabName = "Data",
              fluidRow(
        
                box(solidHeader = TRUE,status="danger",title="Inputs for scatterplots per group ", column(4,radioButtons("check_one_general",label=h4("Methods"),choices=names_methods)),
                     column(4,radioButtons("check_yvar",label=h4(""),choices=c("Power"="power","Type 1 error rate"="type1")),radioButtons("check_moment",label=h4("Standardized Moment"),choices=c("Difference in means" ="mom1","Ratio of Variances" ="mom2","Skewness" ="mom3","Kurtosis" ="mom4")))
                     ,column(4,radioButtons("check_n",label=h4("Sample Size"),choices=c("20" =20,"40" =40, "110" =110,"200" =200))
                             ,checkboxInput("checkbox_group", label = "Visualize all methods", value = FALSE))),
                
                box(solidHeader=TRUE,helpText("These plots show the relation between the standardized moments (per group) of the distribution and the results (type I error rate or power). The standardized moments are empirically determined, and are not dependent on the sample size. The results (power, type I error rate) are dependent on the sample size. The brush function is activated for these plots and the specific information is displayed in the tables below per group.",br(),span("When the standardize moment 'Difference in means' or 'Ratio of Variances' is selected, 1 plot is displayed in the Group 1 box and no plot in the Group 2 box.",style="color:blue")))
                ),
                
              fluidRow(
               box(title="Group 1",solidHeader = TRUE,status="primary",waiter::useWaitress(),plotOutput("general1", brush="plot_click1", height = "800px")),
               box(title="Group 2",solidHeader = TRUE,status="primary",waiter::useWaitress(),plotOutput("general2", brush="plot_click2", height = "800px"))),
              
              fluidRow(
                box(title="Table of selected scenarios in the scatterplot of Group 1",solidHeader = TRUE,status="primary",width=12,tableOutput("click_data"), collapsible = TRUE),
                box(title="Table of selected scenarios in the scatterplot of Group 2",solidHeader = TRUE,status="primary",width=12,tableOutput("click_data2"), collapsible = TRUE))
              ))
      
      
    )))
  



                