# main script for data analysis

# libraries and scripts
library(geojsonio)
library(sf)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(tidyverse)

source('scripts/addresslocator.R')


# load in data
hotels <- read.csv('data/hotels_amsterdam.csv', stringsAsFactors = FALSE)

# Clean data
hotels <- hotels[1:nrow(hotels)-1,]
hotels[hotels=="P CORNELISZ HOOFTSTR"]<-"PIETER CORNELISZ HOOFTSTRAAT"
hotels[hotels=="PIETER JACOBSZOONDWARSSTRAAT"]<-"pieter jacobszdwarsstraat"
hotels[hotels=="PROVINCIALE WEG"]<-"provincialeweg"
hotels[hotels=="1054BV"]<-""
hotels[hotels=="1E C HUYGENSSTR"]<- "Eerste+Constantijn+Huygensstraat"
hotels[hotels=="103-105"]<- 103
hotels[hotels=="315-331"] <- 315
hotels[hotels=="387-390"] <- 387

nbr <- geojsonio::geojson_read("data/GEBIED_BUURTEN.json",what = "sp")
nbr <- st_as_sf(nbr)
#polygon_geometry <- st_geometry(nbr)


inhabs_raw <- read.csv('data/inwoners_amsterdam.csv',stringsAsFactors = FALSE)
inhabs <- inhabs_raw[3:(nrow(inhabs_raw)-2),]
inhabs$code <- substr(inhabs$X1.1a..Bevolking.buurten..1.januari.2014.2018, start=1, stop=4)
colnames(inhabs) <- c("neighbourhood","2014","2015", "2016", "2017", "2018_tot", "2018_men", "2018_wom", "Buurt_code")
inhabs$`2018_tot` <- replace(inhabs$`2018_tot`, inhabs$`2018_tot`=='-', 0)
inhabs$`2018_tot` <- as.numeric(inhabs$`2018_tot`)

nbr <- merge(nbr,inhabs)

keeps <- c("Buurt_code","Buurt","Stadsdeel_code", "2018_tot","geometry")
nbr<- nbr[keeps]
plot(nbr)



# # Geolocate hotels
# for (row in 1:nrow(hotels)){
#   address <- paste(hotels[row,"STRAAT_2014"],hotels[row,"HUISID_2014"], hotels[row,"POSTCODE_2014"], "Amsterdam")
#   coordinates <- locateAddress(address)
#   as.numeric(levels(coordinates))
#   print(coordinates$lat)
#   hotels[row,"lat"] <- as.numeric(coordinates$lat)
#   print(hotels[row,"lat"])
#   hotels[row,"lon"] <- coordinates$lon
# } 
# 
# write.csv(hotels, 'intermediate/geo_hotels.csv')

hotels <- read.csv('intermediate/geo_hotels.csv', stringsAsFactors = FALSE)
hotels <- st_as_sf(hotels, coords = c('lon', 'lat'), crs = 4326, na.fail=F)

joined <- st_join(hotels,nbr)

beds <- data.frame(matrix(ncol = 2, nrow = 0),stringsAsFactors = F)
x <- c("Buurt_code", "Beds")
colnames(beds) <- x

for (neighbourhood in unique(joined$Buurt_code)){
  localHotels <- joined[which(joined$Buurt_code == neighbourhood),]
  bedCount <- sum(localHotels$BED_2014)
  plusbeds <- data.frame(matrix(c(neighbourhood,bedCount),ncol=2),stringsAsFactors = F)
  colnames(plusbeds) <- x
  beds <- rbind(beds,plusbeds)
}
beds$Beds <- as.numeric(beds$Beds)


nbr <- merge(nbr,beds,all.x=T)
options(scipen = 999)
nbr$bed_pressure <- round((as.numeric(as.character(nbr$Beds))/(as.numeric(as.character(nbr$Beds))+as.numeric(as.character(nbr$`2018_tot` )))*100))
hist_data <- ifelse(nbr$bed_pressure > 150, 150, nbr$bed_pressure)


nbr$popup <- paste("<strong>", nbr$Buurt, "</strong><br/>Hotelbeds: ", 
                   nbr$Beds, "<br/>Inhabitants: ", nbr$`2018_tot`, "<br/>Bed pressure: ", nbr$bed_pressure )

st_write(nbr,dsn='data/neighbourhoods.geosjon', driver='GeoJSON')

hotels$popup <- paste("<strong>", hotels$ï..HOTELNAAM_2014, "</strong><br/>Beds: ",hotels$BED_2014)
# https://www.google.nl/search?q=IBIS+AMSTERDAM+CITY+WEST&oq=IBIS+AMSTERDAM+CITY+WEST



m <- leaflet() %>% setView(lng = 4.898940, lat = 52.382676, zoom = 11)
m %>% addProviderTiles(providers$OpenStreetMap.BlackAndWhite) %>%
addPolygons(data = nbr,color = "#444444", weight = 0.4, smoothFactor = 0.5,
            opacity = 1.0, fillOpacity = 0.2,
            fillColor = ~colorQuantile("YlOrRd", bed_pressure)(bed_pressure),
            highlightOptions = highlightOptions(color = "white", weight = 2,
                                                bringToFront = TRUE),  popup = ~popup) %>%
  addLegend("bottomright", pal = colorQuantile("YlOrRd",nbr$bed_pressure), values = nbr$bed_pressure,
            title = "Bed pressure",
            opacity = 0.5, na.label = "No beds", labels = c("a","b","c","d")
  ) %>%
  addMarkers(data=hotels, clusterOptions = markerClusterOptions(), popup = ~popup)






