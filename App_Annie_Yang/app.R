library(shiny)
library(ggplot2)
library (dplyr)
library(readr)
library(markdown)

library(choroplethr)
library(choroplethrMaps)
library(plotly)
library(countrycode)

glb_temp <- read_csv("data-raw/GlobalTemperatures.csv")
country_temp<- read_csv("data-raw/GlobalLandTemperaturesByCountry.csv")
state_temp<- read_csv("data-raw/GlobalLandTemperaturesByState.csv")
annual_aqi<- read_csv("data-raw/annual_aqi_by_cbsa_2000-2017.csv")

print(str(glb_temp)) # verify that app can successfully read the data
print(str(country_temp))
print(str(state_temp))
print(str(annual_aqi))

ui <- navbarPage("Temperatures and AQI",
                 tabPanel("Trend",
                          sidebarLayout(
                            sidebarPanel(
                              radioButtons("dataset", "Dataset Selection",
                                           choices = c("GlobalTemperature", "GlobalLandTemperaturesByCountry"),
                                           selected = "GlobalTemperature"), # Choose analysis with which dataset
                              
                              radioButtons("type", "Type",
                                           choices = c("Year", "Month", "Year and Month"),
                                           selected = "Year and Month"),
                              
                              radioButtons("ConfidenceInterval", "Confidence Interval",
                                           choices = c("TRUE", "FALSE"),
                                           selected = "FALSE"),
                              
                              sliderInput("year", "Year", min = 1743, max = 2013,
                                          value = c(2000, 2013)),
                              
                              sliderInput("month", "Month", min = 1, max = 12,
                                          value = c(1, 12)),
                              
                              selectizeInput("CountryInput", "Country", unique(country_temp$Country), selected = NULL, multiple = T)
                            ),
                            mainPanel(plotOutput("trendplot"))
                          )
                 ),
                 tabPanel("Map",
                          sidebarLayout(
                            sidebarPanel (radioButtons("datasetMap", "Dataset Selection",
                                                       choices = c("GlobalLandTemperaturesByCountry","GlobalLandTemperaturesByState"),
                                                       selected = "GlobalLandTemperaturesByCountry"), # Choose analysis with which dataset
                                          
                                          radioButtons("tempVar", "Temperature Variation",
                                                       choices = c("FALSE","TRUE"),
                                                       selected = "FALSE"),
                                          
                                          sliderInput("yearVar", "Year for Temperature Variation ", min = 1743, max = 2013,
                                                      value = c(2000, 2013)),
                                          
                                          numericInput("yearMap", "Year", min = 1743, max = 2013,
                                                       value = 2000)),
                            mainPanel(wellPanel(
                              conditionalPanel(
                                condition = "input.datasetMap == 'GlobalLandTemperaturesByState'",
                                plotOutput("plotMap")
                              ),
                              
                              conditionalPanel(
                                condition = "input.datasetMap == 'GlobalLandTemperaturesByCountry'",
                                plotlyOutput("plotMap2")
                              )                 
                            ))
                          )
                 ),
                 tabPanel("Air Quality Index",
                          sidebarLayout(
                            sidebarPanel(
                              radioButtons("AnalysisType", "Analysis Selection",
                                           choices = c("Boxplot of AQI","Health Concern By AQI"),
                                           selected = "Boxplot of AQI"),
                              
                              sliderInput("YearAQI", "Year", min=2000, max=2017, value= c(2000,2017)),
                              
                              selectizeInput("CBSA_aqi", "CBSA", unique(annual_aqi$CBSA), 
                                             selected = c("Providence-Warwick, RI-MA"), multiple = T),
                              
                              selectizeInput("categoryInput", "Health Concern Level", 
                                             c("Good","Moderate","UnhealthyForSensitiveGroup","Unhealthy",
                                               "VeryUnhealthy","Hazardous"), 
                                             selected = c("Good","Moderate"), multiple = T),
                              
                              radioButtons("PlotType", "Plot Selection",
                                           choices = c("line","bar"),
                                           selected = "line")
                            ),
                            
                            mainPanel(wellPanel(
                              conditionalPanel(
                                condition = "input.AnalysisType == 'Boxplot of AQI'",
                                plotOutput("BoxPlot")
                              ),
                              
                              conditionalPanel(
                                condition = "input.AnalysisType == 'Health Concern By AQI'",
                                plotOutput("HealthConcern")
                              )                 
                            ))
                          ))
)

server <- function(input, output) {
  source("R/avg_temp.R")
  source("R/map_temp.R")
  source("R/boxplot_aqi.R")
  source("R/aqi_healthconcern.R")
  
  output$trendplot <- renderPlot({
    
    if (input$dataset=="GlobalTemperature") {
      data <- glb_temp
      if (input$type=="Year") {
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]),type=1, con=input$ConfidenceInterval)
      } else if (input$type=="Month"){
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]),type=2, con=input$ConfidenceInterval)
      } else {
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]),type=c(1,2), con=input$ConfidenceInterval) 
      }
    } else { # When GlobalLandTemperaturesByCountry is selected.
      data <- country_temp
      if (input$type=="Year"){
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]) ,type=1, country = input$CountryInput, con=input$ConfidenceInterval)
      } else if (input$type=="Month") {
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]) ,type=2, country = input$CountryInput, con=input$ConfidenceInterval)
      } else {
        avg_temp(data, year = c(input$year[1]:input$year[2]) , month = c(input$month[1]:input$month[2]) ,type=c(1,2), country = input$CountryInput, con=input$ConfidenceInterval)
      }
    }
  }
  )
  
  output$plotMap2 <- renderPlotly({
    if (input$datasetMap=="GlobalLandTemperaturesByCountry"){
      data<-country_temp
      if (input$tempVar=="FALSE"){
        temp_country(data,input$yearMap)
      } else {
        temp_country(data, start=input$yearVar[1], end=input$yearVar[2], diff=input$tempVar)
      }
    }
  })
  
  output$plotMap <- renderPlot({
    if (input$datasetMap=="GlobalLandTemperaturesByState"){
      data<-state_temp
      temp_state(data,input$yearMap)
    }
  })
  
  output$BoxPlot<-renderPlot(
    {
      if (input$AnalysisType=="Boxplot of AQI"){
        boxplot_aqi(annual_aqi,year=c(input$YearAQI[1]:input$YearAQI[2]), cbsa=input$CBSA_aqi)
      }
    }
  )
  
  output$HealthConcern <- renderPlot({
    if (input$AnalysisType=="Health Concern By AQI"){
      aqi_healthconcern(annual_aqi, cbsa=input$CBSA_aqi, category=input$categoryInput,
                        year=c(input$YearAQI[1]:input$YearAQI[2]),plot=input$PlotType)
    }
  })
  
}

shinyApp(ui = ui, server = server)