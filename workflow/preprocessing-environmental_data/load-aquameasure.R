# ===============================================================================
# Name   	: Load AquaMeasure Data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		  :
# Aim    	: Load and clean current data from AquaMeasure devices
# Input   : String folder
# Output  : Dataframe of .csv files in the input folder that hold data from AquaMeasure files
# ================================================================================

load.aqua.data <- function(folder, col_names, rewrite_sensor = FALSE) {
  require(dplyr)

  temp <- list.files(
    path = folder,
    pattern = "*aquaMeasure.*\\.csv$",
    recursive = TRUE,
    ignore.case = TRUE,
    full.names = TRUE
  )
  myfiles <- lapply(temp, read.csv)

  # Get sensor ID
  if (rewrite_sensor == TRUE) {
    for (i in 1:length(temp)) {
      sensor.id <- gsub(".*[\\\\/]([^\\\\/-]+)-.*", "\\1", temp[i])
      myfiles[[i]]$Sensor <- sensor.id
    }
  }

  # Bind tibble
  aqua <- as_tibble(bind_rows(myfiles))
  # Rename columns
  colnames(aqua) <- col_names

  # Description of data:
  # No = Record number. This does not necessarily start at 1 (depends how the aquaMeasure was launched/used previously). These numbers do increase sequentially with each new row/measurement.
  # type = Record type. This is DATA for all data measurements, but can also be EVENT for system things that are logged.
  # time = time in UTC
  # model = model of sensor used. Here, this is always aquaM - SAL, but there are also dissolved oxygen models etc.
  # sensor = unique sensor ID
  # sal = Salinity (calculated from conductivity) and reported in PSU
  # temp = temperature in degrees C
  # tilt = tilt of instrument in degrees (0 = vertical and 90 = horizontal)
  # bat = battery voltage
  # details = Event details (only contains information for EVENT rows and not DATA rows - for DATA rows this is NA).
  # serial = serial number, found in file name

  return(aqua)
}
