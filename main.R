# main script for data analysis

# libraries and scripts
library(geojsonio)
library(sf)

source('scripts/addresslocator.R')


# load in data
hotels <- read.csv('data/hotels_amsterdam.csv', stringsAsFactors = FALSE)
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


inhabs_raw <- read.csv('data/inwoners_amsterdam.csv',stringsAsFactors = FALSE)
inhabs <- inhabs_raw[3:(nrow(inhabs_raw)-2),]
inhabs$code <- substr(inhabs$X1.1a..Bevolking.buurten..1.januari.2014.2018, start=1, stop=4)
colnames(inhabs) <- c("neighbourhood","2014","2015", "2016", "2017", "2018_tot", "2018_men", "2018_wom", "Buurt_code")
inhabs$`2018_tot` <- replace(inhabs$`2018_tot`, inhabs$`2018_tot`=='-', 0)
inhabs$`2018_tot` <- as.numeric(inhabs$`2018_tot`)

nbr <- merge(nbr,inhabs)
nbr <- st_as_sf(nbr)
keeps <- c("Buurt_code","Buurt","Stadsdeel_code", "2018_tot","geometry")
nbr<- nbr[keeps]
plot(nbr)

start =1
for (row in 1:nrow(hotels)){
  address <- paste(hotels[row,"STRAAT_2014"],hotels[row,"HUISID_2014"], hotels[row,"POSTCODE_2014"], "Amsterdam")
  print(locateAddress(address))
  print(paste(start, "/", nrow(hotels)))
  start = start +1 
} 






