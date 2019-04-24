# Might need to spin up a docker container to init api via CLI?
# https://www.rplumber.io/docs/hosting.html#docker

library(plumber)
library(hash)

taxi_zones = read.csv("~/Downloads/tripdata/taxi+_zone_lookup.csv") 



green_nyc = read.csv("~/Downloads/tripdata/green_tripdata_2018-01.csv")
taxi_zones = read.csv("~/Downloads/tripdata/taxi+_zone_lookup.csv") 

buildAggregates <- function(nyc) {
  agg <-  hash() # (,1,5)
  
  # break data down into segments
  for (idx in 1:length(nyc)) 
  {
    i <- nyc[idx,]
    strKey <-paste(i["PULocationID"], i["DOLocationID"], sep = '-')
    if(exists(strKey, agg))
    {
      total_time <- agg[[strKey]][1] + difftime(i[["lpep_dropoff_datetime"]], i[["lpep_pickup_datetime"]])
      total_trips <- agg[[strKey]][2] + 1
      agg[[strKey]] <- c(total_time, total_trips,0)
    }
    else
    {
      total_time <- difftime(i[["lpep_dropoff_datetime"]], i[["lpep_pickup_datetime"]])
      total_trips <- 1
      agg[[strKey]] <- c(total_time, total_trips,0)
    }
  }
  
  # calculate averages
  for (idx in ls(agg))
  {
    #print(toString(idx))
    #print(agg[[idx]])
    #Average time per trip is total_time / total_trips
    avg_trip <- as.double(agg[[idx]][1]) / as.double(agg[[idx]][2])
    agg[[idx]][3] <- avg_trip
  }
  
  print(agg)
  return(agg)
}


agg <- buildAggregates(green_nyc)




#* @apiTitle NYC Traffic Data


#* Get the list of zones
#* @get /list
function() {
    as.data.frame(taxi_zones)
}

#* Grab the whole aggregate table
#* @get /table
function() {
    format(agg) 
}

#* Return the travel time between two zones
#* @param from_zone The starting zone
#* @param to_zone The ending zone
#* @post /trip
function(from_zone, to_zone) {
  
  segment_key <- paste(from_zone, to_zone, sep = '-')

  format(agg[[segment_key]][3])
  
}
