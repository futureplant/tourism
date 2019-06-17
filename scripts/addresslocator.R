# Function that takes in address string and returns dataframe containing longitude and latitude in WGS84

# load libraries
library(httr)
library(jsonlite)

locateAddress <- function(address){
  # Construct Query
  prefix <- "https://nominatim.openstreetmap.org/search?q="
  address <- gsub(" ", "+", address)
  postfix <- '&format=json'
  query <- paste0(prefix,address,postfix)
  
  # Make request
  response <- as.data.frame(content(GET(query)))
  
  # Format response
  keep <- c("lat","lon")
  response <- response[keep]
  
  return(response)
}




