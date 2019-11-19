library(dplyr)
library(lubridate)
library(readr)
library(xts)

setwd("/run/media/z/Z/Linux files/Desktop/GIS-work/Project_4/Data/")

#Import data and remove unnecessary subheadings
tide <- read_csv("Tide_data.csv", col_names = T)
tide <- tide[-c(1),]

#Format Date/time
tide$Date_time <- ymd_hms(tide$time) 

#Formatting and prepping other variables
tide$Water_Level     <- as.numeric(tide$Water_Level)
tide$stationID       <- gsub('_', ' ', tide$stationID)

tide$longitude <- as.character(tide$longitude)
tide$latitude  <- as.character(tide$latitude)
tide$longitude <- as.numeric(tide$longitude)
tide$latitude  <- as.numeric(tide$latitude)

#Filter for select data
tide_modelled        <- tide[grepl("MODELLED", tide$stationID), ]
tide_normal          <- tide[!grepl("MODELLED", tide$stationID), ]
tide_latlon_modelled <- unique(subset(tide_modelled, select = c(stationID,latitude,longitude)))
tide_latlon          <- unique(subset(tide_normal, select = c(stationID, latitude, longitude)))
modelled_list        <- split(tide_modelled, tide_modelled$stationID)
normal_list          <- split(tide_normal, tide_normal$stationID)

#Filtering and exporting modelled data
modelled_xts <- lapply(modelled_list, function(i) xts(i[, -1], 
                                      order.by = i$Date_time))

modelled_filtered <- lapply(modelled_xts, function(i) subset(i, select = c("Water_Level")))

setwd("/run/media/z/Z/Linux files/Desktop/GIS-work/Project_4/Data/Modelled")

lapply(1:length(modelled_filtered), function(i) saveRDS(modelled_filtered[[i]], 
                                                file = paste0(names(modelled_filtered[i]), ".rds"),
                                                compress = T))
saveRDS(tide_latlon_modelled, file = "tide_latlon.rds", compress = T)

#Filtering and exporting non-modelled data
normal_xts <- lapply(normal_list, function(i) xts(i[, -1], 
                                                      order.by = i$Date_time))

normal_filtered <- lapply(normal_xts, function(i) subset(i, select = c("Water_Level")))

setwd("/run/media/z/Z/Linux files/Desktop/GIS-work/Project_4/Data/Non-modelled")

lapply(1:length(normal_filtered), function(i) saveRDS(normal_filtered[[i]], 
                                                        file = paste0(names(normal_filtered[i]), ".rds"),
                                                        compress = T))
saveRDS(tide_latlon, file = "tide_latlon.rds", compress = T)
