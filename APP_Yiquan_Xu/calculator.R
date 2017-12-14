library(shiny)
aqi <- read_csv("data-raw/annual_aqi_by_cbsa_2000-2017.csv")
ui <- navbarPage(title = "Caculator",
                 tabPanel(title="Summary Statistic",
                  selectInput("city","City",unique(aqi$CBSA),
                              selected = "Providence-Warwick, RI-MA"),
                  tableOutput("stat")
                ),
                tabPanel(title = "health",
                         selectInput("city2","City",unique(aqi$CBSA),
                                     selected = "Providence-Warwick, RI-MA"),
                         radioButtons("smoke","Smoking",
                                      choices = c("Yes","No"),
                                      selected = "Yes"),
                         radioButtons("exercise","Exercise",
                                      choices = c("Yes","No"),
                                                  selected = "Yes"),
                         radioButtons("gene","Gene",
                                      choices = c("Yes","No"),
                                                  selected = "Yes"),
                         numericInput("year", "Year", 2010, min = 2000, max = 2017),
                         textOutput("health")
                         )
)
server <- function(input, output) {
  source("R/stat.R")
  source("R/health_status.R")
  output$stat <- renderTable(stat_func(data = aqi, cbsa = input$city))
  output$health <- renderText(health_status(data = aqi, cbsa = input$city2, year = input$year,
                                            smoke = input$smoke, exercise = input$exercise,
                                            gene = input$gene))
}
shinyApp(ui = ui, server = server)

