library(sf)
library(sp)
library(FNN)
library(rgdal)
library(leaflet)


# https://stackoverflow.com/questions/27782488/r-calculating-the-shortest-distance-between-two-point-layers

hotels <- st_read('output/hotels.geoJSON')
airbnb2019 <- st_read('data/products_airbnb/AirbnbPoints_20190408.geojson')
nbr <- st_read('output/neighbourhoods.geojson')
hotels <- st_intersection(hotels,nbr)

hotels <- st_transform(hotels,28992)
hotels <- as(hotels, 'Spatial')

airbnb2019 <- st_transform(airbnb2019,28992)
airbnb2019 <- as(airbnb2019, 'Spatial')
 
distances <- get.knnx(coordinates(hotels), coordinates(airbnb2019), k=1)
airbnb2019 <- st_as_sf(airbnb2019)
airbnb2019$dist2hot <- distances$nn.dist
airbnb2019 <- st_transform(airbnb2019,4326)

join <- st_join(airbnb2019, nbr)
keeps <- c('id', 'Buurt_code', 'dist2hot')
join <- join[keeps]
test <- join[which(join$Buurt_code == 'M32a'),]

st_write(join,'intermediate/airbnbdist.geojson', driver='GeoJSON')

mean_distance <- aggregate(join, list(as.factor(join$Buurt_code)), FUN=mean)
st_geometry(mean_distance) <- NULL
mean_distance <- mean_distance[,-which(names(mean_distance) == "Buurt_code")]
names(mean_distance) <- c("Buurt_code", "id", "dist2hot")

nbr <- merge(nbr,mean_distance)

bins <- c(0, 250, 500, 1000, 2500)
pal <- colorBin("YlOrRd", domain = nbr$dist2hot, bins = bins)

m <- leaflet() %>% setView(lng = 4.898940, lat = 52.382676, zoom = 11)
m %>% addProviderTiles(providers$OpenStreetMap.BlackAndWhite) %>%
  addMarkers(data=hotels, clusterOptions = markerClusterOptions(), popup = ~hotelpopup) %>%
  addPolygons(data = nbr,color = "#444444", weight = 0.4, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.3,
              fillColor = ~pal(dist2hot),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE)) 
  

