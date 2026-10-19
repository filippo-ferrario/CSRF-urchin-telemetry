# ===============================================================================
# Name   	: Load TCM Data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		  :
# Aim    	: Load and clean current data from TCM devices
# Input   : String folder, String file_pattern, vector col_names
# Output  : Dataframe of .csv files in the input folder that hold data from TCM files
# ================================================================================

load.tcm.data <- function(
  folder,
  file_pattern,
  col_names,
  rewrite_sensor = FALSE
) {
  require(dplyr)

  # List all files in child directories that end in the file_pattern
  temp <- list.files(
    path = folder,
    pattern = file_pattern,
    recursive = TRUE,
    ignore.case = TRUE,
    full.names = TRUE
  )
  # Read all files
  myfiles <- lapply(temp, read.csv)

  # Loop to fill in serial and sensor ID from file name
  for (i in 1:length(temp)) {
    # Get serial ID
    serial.id <- gsub("^.*?/([0-9]{7})_.*$", "\\1", temp[i])
    # Put serial ID in column
    myfiles[[i]]$Serial <- serial.id
  }

  if (rewrite_sensor == TRUE) {
    for (i in 1:length(temp)) {
      sensor.id <- gsub(".*_(TCM[0-9]+)_.*", "\\1", temp[i])
      myfiles[[i]]$Sensor <- sensor.id
    }
  } else {
    ## Note: For TCM (serial ID is in the file name)
    for (i in 1:length(temp)) {
      # Get sensor ID
      sensor.id <- gsub(".*_(.*)_\\(.*", "\\1", temp[i])
      # Put sensor ID in column
      myfiles[[i]]$Sensor <- sensor.id
    }
  }

  # Bind data
  TCM_data <- as_tibble(bind_rows(myfiles))
  # Rename columns
  colnames(TCM_data) <- col_names
  # Description of data:
  # time = time in ISO 8601 format (with 'T' separating date and time); in UTC.
  # speed = current speed in cm.s, output by the Domino TCM software from raw data measurements (accelerations and tilt/heading)
  # head = compass heading of output current in degrees (0-360)
  # V_N = Velocity component - north. In cm.s
  # V_E = Velocity component - east. In cm.s
  # sensor = unique file identifier containing both sensor serial number and deployment info.
  # serial = serial number of sensor

  return(TCM_data)
}
