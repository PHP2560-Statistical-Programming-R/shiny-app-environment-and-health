# Air Quality Index (AQI): each AQI category corresponds to a different level of health concern

library(rvest)

AQI_url<-"https://cfpub.epa.gov/airnow/index.cfm?action=aqibasics.aqi"
AQI_data<-AQI_url%>%html()%>%html_nodes(xpath='//*[@id="pageContent"]/div[4]/table')%>%html_table()
AQI<-AQI_data[[1]]
write.csv(AQI,file="data-raw/AQI.csv")
devtools::use_data(AQI, overwrite = TRUE)
