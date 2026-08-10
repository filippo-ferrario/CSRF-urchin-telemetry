# ===============================================================================
# Name   	: Info from Metadata
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		:
# Aim    	: Gather extra info from metadata to help compare data from devices
# ===============================================================================

library(here)

# Load metadata
metadata_qc <- read.csv(here("./data/metadata_sensors_QC2022.csv"), sep = ";")
metadata_bc <- read.csv(here("./data/metadata_sensors_BC2023.csv"), sep = ";")

# Columns to keep
keep <- c("Sensor_ID", "Type", "Site", "Position")
metadata_qc <- subset(metadata_qc, select = keep)
metadata_bc <- subset(metadata_bc, select = keep)

# Pair on Sensor_ID
metadata <- metadata_qc %>%
  left_join(metadata_bc, by = "Sensor_ID")



# ===============================================================================
# Map of Devices
# ===============================================================================

library(sf)

## Prep devices
# Get unique rows based on columns Site, Position, Lat, Long
unique_star <- star %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_star$DeviceType <- "StarOddi"
unique_star$SP <- paste(unique_star$DeviceType, unique_star$Position, sep='-')

unique_aqua <- aqua %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_aqua$DeviceType <- "AquaMeasure"
unique_aqua$SP <- paste(unique_aqua$DeviceType, unique_aqua$Position, sep='-')

unique_TCM <- TCM_temp %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_TCM$DeviceType <- "TCM"
unique_TCM$SP <- paste(unique_TCM$DeviceType, unique_TCM$Position, sep='-')

all_unique <- rbind(unique_star, unique_aqua, unique_TCM)
all_unique$Location <- paste(all_unique$Site, all_unique$SP, sep='-')
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), ~ gsub(",", ".", .)))

library(mapview)

## Plot devices on map
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), as.numeric)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

unique_split <- split(all_unique, all_unique$Site)

# Plot the base layer (marina) and overlay marina1 points
mapview(unique_split[["Baleine"]], zcol = "SP", cex = 4, alpha = 0.7) +  # Light base map
  mapview(unique_split[["Pilotes"]], zcol = "SP", cex = 4, alpha = 0.7)+  # Light base map
  mapview(unique_split[["NE"]], zcol = "SP", cex = 4, alpha = 0.7)+  # Light base map
  mapview(unique_split[["SW"]], zcol = "SP", cex = 4, alpha = 0.7)


# All devices on same map with labels written above points
all_unique_qc <- all_unique
all_unique <- rbind(all_unique_qc, all_unique)

library(leaflet)

leaflet(all_unique) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(
    radius = 6,
    stroke = FALSE,
    fillColor = "cornflowerblue",
    fillOpacity = 1.0,
    label = ~Location,         # Label as text next to each dot
    labelOptions = labelOptions(
      noHide = TRUE,           # <- Always show
      direction = "top",       # <- Place above point
      textOnly = TRUE,
      style = list(
        "color" = "black",
        "font-size" = "12px",
        "font-weight" = "bold"
      )
    )
  )
