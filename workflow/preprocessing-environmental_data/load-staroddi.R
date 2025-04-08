# ===============================================================================
# Name   	: Load StarOddi Data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		  :
# Aim    	: Load and clean current data from StarOddi devices
# Input   : String folder
# Output  : Dataframe of .csv files in the input folder that hold data from
# StarOddi files, excluding files in folders named "Archive"
# ================================================================================

load.star.data <- function(folder) {
  temp <- list.files(path = folder, pattern = "\\_exported.csv", recursive = TRUE,
                     ignore.case = TRUE, full.names = TRUE)

  # Exclude paths that include "/Archive/" or end with "/Archive"
  temp <- temp[!grepl("/Archive(/|$)", temp)]

  myfiles <- lapply(temp, data.table::fread)

  # Loop to fill in serial and sensor ID from file name
  for (i in 1:length(myfiles)) {
    ## Note: For Quebec TCM (serial ID is in the file name)
    # Get serial ID
    sensor.id <- gsub(".*/([^/_]+)_.*", "\\1", temp[i])
    # Put serial ID in column
    myfiles[[i]]$sensor <- sensor.id
  }

  for (i in 1:length(myfiles)) {
    if (ncol(myfiles[[i]]) == 6) {
      # Add depth column with NA
      myfiles[[i]] <- myfiles[[i]] %>%
        add_column(depth = NA, .after = "Temp(\xb0C)")
    }
    colnames(myfiles[[i]]) <- c("Time", "Temp", "Depth", "Sal", "Conduct", "Vel_sound", "Sensor")
  }

  star <- as_tibble(bind_rows(myfiles))

  # Change time
  star$Time_conv <- star$Time * 86400

  # Description of data:
  # time = time of measurement in UTC (because DST units were set with UTC when deployed).
  # temp = temperature in degrees C
  # depth = depth in meters measured (only for CTD units, otherwise this is NA for CT units)
  # sal = Salinity in PSU
  # conduct = Conductivity in mS.cm
  # vel_sound = sound velocity in m.sec
  # serial = serial number of sensor

  return(star)
}




