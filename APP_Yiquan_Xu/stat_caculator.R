library(shiny)
aqi <- read_csv("data-raw/annual_aqi_by_cbsa_2000-2017.csv")
ui <- fluidPage(headerPanel("Summary Statistics AQI by CBSA"),
                sidebarPanel(
                  selectInput("city","City",unique(aqi$CBSA),
                              selected = "Providence-Warwick, RI-MA")
                              ),
                mainPanel(tableOutput("stat"))
                )
server <- function(input, output) {
  source("R/stat.R")
  output$stat <- renderTable(stat_func(data = aqi, cbsa = input$city))
}
shinyApp(ui = ui, server = server)

