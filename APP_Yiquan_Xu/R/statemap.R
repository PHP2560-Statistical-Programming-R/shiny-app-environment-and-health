#' @title Check and plot air quality by state
#'
#' @description 
#' @param data A data.frame. The default dataset is AirQuality_Tracking.
#' @param year A numeric vector.
#' @examples
#' checkAirQuality(year=2010)
#'
#' @export
checkAirQuality <- function(data = AirQuality_Tracking, year){
  map <- data%>%
    filter(Value<=1000 & Unit != "%" & ReportYear == year)%>%
    group_by(StateName)%>%
    summarise(AirQuality = mean(Value))
  code <- state.abb[match((map$StateName),state.name)] #convert long state name to abbreviation
  code <- as.factor(code)
  map$CODE <- code
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = TRUE,
    lakecolor = toRGB('white')
  )
  map_state <- plot_geo(map, locationmode = 'USA-states') %>%
    add_trace(
      z = ~AirQuality, text = ~StateName, locations = ~code,
      color = ~AirQuality, colors = 'Purples'
    ) %>%
    colorbar(title = "AirQuality") %>%
    layout(
      title = paste("AirQuality","of","year",year),
      geo = g)
  print(map_state)
}

