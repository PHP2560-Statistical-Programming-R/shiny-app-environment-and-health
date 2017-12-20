#' @title Plot Temperature Geographic Maps by States in USA
#'
#' @description This function plots temperature geographic maps for States in USA in specific year
#' @param data A data.frame. The defalt dataset is GlobalLandTemperaturesByState.
#' @param year numeric
#' @examples
#' temp_state(year=2012)
#' 
#' @export


temp_state<-function(data=GlobalLandTemperaturesByState,year){
  
  map <- data %>%
    mutate(Month=as.numeric(format(data$dt,"%m")), # Create new column month (decimal number)
           Month.String=format(data$dt,"%B"), # Create string month (full name)
           Year=as.numeric(format(data$dt,"%Y"))) %>% # Create new column year (4 digit)
    na.omit() %>% filter(Country=="United States")
  
  map$State <- as.character(map$State)  
  map$State[map$State=="Georgia (State)"] <- "Georgia" # Changing Georgia (State)
  map$State<- as.factor(map$State)                    
  
  # select columns of interest
  map_select <- map %>% 
    select(Year,AverageTemperature,State) %>%
    dplyr::group_by(Year, State) %>%
    dplyr::summarise(AvgTemp=mean(AverageTemperature))%>%
    ungroup()
  
  map_state<-map_select %>%
    filter(Year==year)
  
  code <- state.abb[match((map_state$State),state.name)] # Convert long state name to abbreviation
  code <- as.factor(code)
  map_state$CODE <- code
  
  # give state boundaries a white border
  l <- list(color = toRGB("white"), width = 2)
  # specify some map projection/options
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = TRUE,
    lakecolor = toRGB('white')
  )
  
  plot_map <- plot_geo(map_state, locationmode = 'USA-states') %>%
    add_trace(
      z = ~AvgTemp, text = ~State, locations = ~code,
      color = ~AvgTemp, colors = 'Reds'
    ) %>%
    colorbar(title = "Temperature") %>%
    layout(
      title = paste(year,"Temperature Map",sep=" "),
      geo = g
    )
  
  print(plot_map)
  
}

#' @title Plot Temperature Geographic Maps by Country
#'
#' @description This function plots temperature geographic maps for countries in specific year. You can use this
#'     function to get a temperature geographic map showing the temperature change from the start year to end year.
#' @param data A data.frame. The defalt dataset is GlobalLandTemperaturesByCountry.
#' @param year A numeric. You can get temperature geographic maps for countries in this year.
#' @param start A numeric. The start year you want to do temperature comparison.
#' @param end A numeric. Then end year you want to do temperature comparison.
#' @param diff A character. If diff=="TRUE", you will get a temperature geographic map showing the temperature
#'     change from the start year to end year. (Default value is "FALSE")
#' @examples
#' temp_country(year=2012)
#' temp_country(start=1990,end=2000,diff="TRUE")

temp_country<-function(data=GlobalLandTemperaturesByCountry, year, start, end, diff="FALSE"){
  # light grey boundaries
  l <- list(color = toRGB("grey"), width = 0.5)
  
  # specify map projection/options
  g <- list(
    showframe = FALSE,
    showcoastlines = FALSE,
    projection = list(type = 'Mercator')
  )
 
  map_country <- data %>%
    mutate(Month=as.numeric(format(data$dt,"%m")), # Create new column month (decimal number)
           Month.String=format(data$dt,"%B"), # Create string month (full name)
           Year=as.numeric(format(data$dt,"%Y"))) %>% # Create new column year (4 digit)
    na.omit()%>%
    select(Year,AverageTemperature,Country) %>%
    dplyr::group_by(Year, Country) %>%
    dplyr::summarise(AvgTemp=mean(AverageTemperature))
  
  code<-countrycode(map_country$Country,'country.name', 'iso3c') # Converts long country name into country codes
  
  map_country$CODE<-code # Create new column in map_country named "CODE"
  
  if(diff=="FALSE"){
  temp<-map_country%>%filter(Year==year)
  
  map_temp <- plot_geo(temp) %>%
    add_trace(
      z = ~AvgTemp, color = ~AvgTemp, colors = 'Reds',
      text = ~Country, locations = ~CODE, marker = list(line = l)
    ) %>%
    colorbar(title = 'Temperature') %>%
    layout(
      title = paste(year,"Temperature Map",sep=" "),
      geo = g
    )
  
  map_temp
  } else if (diff=="TRUE") {
    
    temp_diff<-map_country %>% 
      filter(Year==start | Year==end) %>% 
      tidyr::spread(Year, AvgTemp)
    
    temp_diff$Difference<-unlist(temp_diff[,4]-temp_diff[,3]) # Calculate temperature variation from start year to end year
    
    map_temp <- plot_geo(temp_diff) %>%
      add_trace(
        z = ~Difference, color = ~Difference, colors = 'Reds',
        text = ~Country, locations = ~CODE, marker = list(line = l)
      ) %>%
      colorbar(title = 'Temperature Variation') %>%
      layout(
        title = paste(start,"-",end,"Temperature Variation Map", sep=" "),
        geo = g
      )
    print(map_temp)
  }
  
}
