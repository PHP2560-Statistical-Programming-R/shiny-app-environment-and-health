# This dataset contains annual AQI information from 2000 to 2017 by Core Based Statistical Area (CBSA).

library(readr)

annual_aqi <- read_csv("data-raw/annual_aqi_by_cbsa.csv")
devtools::use_data(annual_aqi, overwrite = TRUE)