# Atmpspheric carbon dioxide data from Mauna Loa Observatory since 1958

library(readr)

co2level <- read_csv("data-raw/co2level.csv")
devtools::use_data(co2level, overwrite = TRUE)