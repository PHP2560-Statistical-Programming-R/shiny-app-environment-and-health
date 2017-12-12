library(readr)

# GlobalTemperatures.csv contains data about Global Land and Ocean-and-Land Temperatures. 
# Starts in 1750 for average land temperature and 1850 for max and min land temperatures and global ocean and land temperatures.

GlobalTemperatures <- read_csv("data-raw/GlobalTemperatures.csv")
devtools::use_data(GlobalTemperatures, overwrite = TRUE)

# GlobalLandTemperaturesByCountry.csv contains data about Global Average Land Temperature by Country.

GlobalLandTemperaturesByCountry<- read_csv("data-raw/GlobalLandTemperaturesByCountry.csv")
devtools::use_data(GlobalLandTemperaturesByCountry, overwrite = TRUE)

# GlobalLandTemperaturesByState.csv contains data about Global Average Land Temperature by State.

GlobalLandTemperaturesByState<- read_csv("data-raw/GlobalLandTemperaturesByState.csv")
devtools::use_data(GlobalLandTemperaturesByState, overwrite = TRUE)
