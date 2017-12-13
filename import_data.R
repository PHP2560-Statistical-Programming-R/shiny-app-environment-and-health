
# Install packages that the program need

install_packages = function(names)
{
  for(name in names)
  {
    if (!(name %in% installed.packages()))
      install.packages(name, repos="http://cran.us.r-project.org")
    
    library(name, character.only=TRUE)
  }
}

install_packages(c("devtools","dplyr", "ggplot2","reshape2",
                   "roxygen2","ggpubr", "readr", "rvest","XML", "testthat",
                   "choroplethr","choroplethrMaps","plotly","countrycode"))

# Our functions are based on the following datasets.

# load the rda file and import the air pollution data in US

# The pollution_us dataset contains four major pollutants (Nitrogen Dioxide, Sulphur Dioxide, Carbon Monoxide and Ozone) 
# for every day from 2000-2016.

load(file = "data/pollution_us.rda")

# load the annual AQI data from 2000 to 2017 by Core Based Statistical Area (CBSA)

load(file = "data/annual_aqi.rda")

# load the AQI categories. Understand each category corresponds to a different level of health concern.

load(file = "data/AQI.rda")

# Load GlobalTemperatures or GlobalLandTemperaturesByCountry dataset
# before using avg_temp function to analyse average monthly temperatures trend.

load(file = "data/GlobalTemperatures.rda")
load(file = "data/GlobalLandTemperaturesByCountry.rda")
load(file = "data/GlobalLandTemperaturesByState.rda")
load(file = "data/AirQuality_Tracking.rda")
