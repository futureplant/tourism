# main script for data analysis

# libraries and scripts
library(geojsonio)
library(sf)

source('scripts/addresslocator.R')


# load in data
hotels <- read.csv('data/hotels_amsterdam.csv')
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







