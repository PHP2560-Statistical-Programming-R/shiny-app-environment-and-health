library(shiny)

# install necessary packages

source("R/install_packages.R")

annual_aqi <- get(load(file = "data/annual_aqi.rda"))

AirQuality_Tracking <- get(load(file = "data/AirQuality_Tracking.rda"))

aqi <- annual_aqi%>%mutate(Per_CO = `Days CO`/sum(`Days CO`), Per_NO2 = `Days NO2`/sum(`Days NO2`),
                           Per_Ozone = `Days Ozone`/sum(`Days Ozone`), Per_SO2 = `Days SO2`/sum(`Days SO2`))
ui <- navbarPage("Environment and Health",
                            tabPanel("Cluster", fluidPage(
                              headerPanel('k-means clustering'),
                              tabsetPanel(
                                tabPanel(title="Pollution",
                                         selectInput('xcol', 'X Variable', names(aqi)[20:23]),
                                         selectInput('ycol', 'Y Variable', names(aqi)[20:23],
                                                     selected = names(aqi)[22]),
                                         numericInput('clusters', 'Cluster count', 3,
                                                      min = 1, max = 9),
                                         plotOutput('pollution')
                                ),
                                tabPanel(title="Health",
                                         selectInput('x',"X Variable",names(annual_aqi)[5:10]),
                                         selectInput('y',"Y Variable",names(annual_aqi)[5:10],
                                                     selected = names(annual_aqi)[6]),
                                         numericInput('clus', 'Cluster count', 3,
                                                      min = 1, max = 9),
                                         plotOutput('health')
                                )
                              )
                            )
                            ),
                            tabPanel(title = "Air Quality Map",
                                     fluidPage(headerPanel("Air Quality"),
                                               sidebarPanel(
                                                 numericInput("yearaqm", "Year", 2005, min = 1999, max = 2013), #Choosing year you want to observe
                                                 radioButtons("color","Color",choices = c('Blues','Reds','Purples'), 
                                                              selected = 'Purples') #Choosing different state background color
                                               ),
                                               mainPanel(plotlyOutput("AQImap"))
                                     )
                            ),
                 tabPanel("Calculator",
                          fluidPage(headerPanel(title = "Calculator"),
                                    sidebarLayout(
                                      sidebarPanel(
                                        tabPanel(title="Summary Statistic",
                                                 selectInput("city","City",unique(annual_aqi$CBSA),
                                                             selected = "Providence-Warwick, RI-MA")
                                        ),
                                        tabPanel(title = "health",
                                                 radioButtons("smoke","Smoking",
                                                              choices = c("Yes","No"),
                                                              selected = "Yes"),
                                                 radioButtons("exercise","Exercise",
                                                              choices = c("Yes","No"),
                                                              selected = "Yes"),
                                                 radioButtons("gene","Gene",
                                                              choices = c("Yes","No"),
                                                              selected = "Yes"),
                                                 numericInput("yearcal", "Year", 2010, min = 2000, max = 2017)
                                        )
                                      ),
                                      mainPanel(
                                        tabsetPanel(
                                          tabPanel("Summary Statistic",tags$h3(tableOutput("stat"))),
                                          br(),
                                          br(),
                                          tabPanel("Health",tags$em(tags$strong(tags$h3(textOutput("health_text")))),
                                                   br(),
                                                   hr(),
                                                   br(),
                                                   br(),
                                                   htmlOutput("picture"))
                                        )
                                      )
                                    )
                          )
                 )
) 
                 
                 
server <- function(input, output) {
  selectedData <- reactive({
    aqi[, c(input$xcol, input$ycol)]
  })
  Data <- reactive(
    annual_aqi[,c(input$x,input$y)]
  )
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  clus <- reactive({
    kmeans(Data(), input$clus)
  })
  output$pollution <- renderPlot({
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
  output$health <- renderPlot({
    par(mar = c(5.1, 4.1, 0, 1))
    plot(Data(),
         col = clus()$cluster,
         pch = 20, cex = 3)
    points(clus()$centers, pch = 4, cex = 4, lwd = 4)
  })
  
  source("R/statemap.R")
  output$AQImap <- renderPlotly(checkAirQuality(data = AirQuality_Tracking,year=input$yearaqm, 
                                                Color = input$color))
  
  source("R/stat.R")
  source("R/health_status.R")
  output$stat <- renderTable(stat_func(data = annual_aqi, cbsa = input$city))
  output$health_text <- renderText(health_status(data = annual_aqi, cbsa = input$city, year = input$yearcal,
                                                 smoke = input$smoke, exercise = input$exercise,
                                                 gene = input$gene))
  
  output$picture <-renderText({
    c(
      '<img src="',
      "http://drive.google.com/uc?export=view&id=0By6SOdXnt-LFaDhpMlg3b3FiTEU",
      '">'
    )
  })
}

shinyApp(ui = ui, server = server)