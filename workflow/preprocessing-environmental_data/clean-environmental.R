# ===============================================================================
# Name   	: Clean Environmental Data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		:
# Aim    	: Clean environmental data from AquaMeasure, TCM, and StarOddi devices
# ===============================================================================

initial.clean <- function(data, metadata, star = FALSE) {
  library(dplyr)
  library(lubridate)

  if (star == TRUE) {
    # Combine metadata with datasets
    data <- data %>%
      left_join(metadata, by = c("Sensor" = "Sensor_ID"))

    data <- data %>%
      mutate(DateTime = lubridate::as_datetime(Time_conv, origin = "1900-01-01 00:00:00", tz = "UTC"))
  } else {
    # Combine metadata with datasets
    data <- data %>%
      left_join(metadata, by = c("Serial" = "Sensor_ID"))

    # Change date to POSIX
    data <- data %>%
      mutate(DateTime = lubridate::ymd_hms(Time))
  }

  # Cut sequence by deployment and recovery dates
  data <- data %>%
    filter(DateTime > ymd(Date_deployed) + days(1)) %>%
    filter(DateTime < ymd(Date_recovered) - days(1))

  return(data)
}

