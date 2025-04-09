# ===============================================================================
# Name   	: Calculate Moving Averages
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		  :
# Aim    	: Calculate moving averages
# Input   : Dataframe data, vector of Strings k_vec, vector of Strings var_vec,
#           boolean head
# Output  : Dataframe
# ================================================================================

calculate.moving.avg <- function(data, device_type) {
  if (device_type == "staroddi") {
    # StarOddi's took 1 measurement every 10 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
    # Calculate the following variables:
    # ma01 = Calculating a rolling mean over 3 points, means over 10 min * 3 = over 30 minutes.
    # ma02 = Calculating a rolling mean over 12 points, means over 10 min * 12 = 2 hours.
    # ma03 = Calculating a rolling mean over 18 points, means over 10 min * 18 = 3 hours.
    # ma04 = Calculating a rolling mean over 36 points, means over 10 min * 36 = over around 360 minutes = 6 hours.
    data <- split(data, list(data$Site,data$Sensor), drop = TRUE)
    data <- lapply(data, function(df) {
      df %>%
        mutate(temp_ma01 = zoo::rollmean(Temp, k = 3, fill = NA),
               temp_ma02 = zoo::rollmean(Temp, k = 12, fill = NA),
               temp_ma03 = zoo::rollmean(Temp, k = 18, fill = NA),
               temp_ma04 = zoo::rollmean(Temp, k = 36, fill = NA),
               sal_ma01 = zoo::rollmean(Sal, k = 3, fill = NA),
               sal_ma02 = zoo::rollmean(Sal, k = 12, fill = NA),
               sal_ma03 = zoo::rollmean(Sal, k = 18, fill = NA),
               sal_ma04 = zoo::rollmean(Sal, k = 36, fill = NA))
    })
    data <- dplyr::bind_rows(data)
  } else if (device_type == "tcm-current") {
    # TCM's took 1 measurement every 1 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
    # Calculate the following variables:
    # ma01 = Calculating a rolling mean over 30 points, means over 1 min * 30 = over 30 minutes.
    # ma02 = Calculating a rolling mean over 120 points, means over 1 min * 120 = 2 hours.
    # ma03 = Calculating a rolling mean over 180 points, means over 1 min * 180 = 3 hours.
    # ma04 = Calculating a rolling mean over 360 points, means over 1 min * 360 = over around 360 minutes = 6 hours.
    # Separate by device for rolling mean
    data <- split(data, list(data$Site, data$Serial), drop = TRUE)
    data <- lapply(data, function(df) {
      df %>%
        mutate(
          speed_ma01 = rollmean(Speed, k = 30, fill = NA),
          speed_ma02 = rollmean(Speed, k = 120, fill = NA),
          speed_ma03 = rollmean(Speed, k = 180, fill = NA),
          speed_ma04 = rollmean(Speed, k = 360, fill = NA),
          head_circ = circular(Heading, type = 'directions'))
    })
    data <- dplyr::bind_rows(data)
  } else if (device_type == "aquameasure") {
    # AquaMeasure's took 1 measurement every 10 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
    # Calculate the following variables:
    # Calculate the following variables:
    # ma01 = Calculating a rolling mean over 3 points, means over 10 min * 3 = over 30 minutes.
    # ma02 = Calculating a rolling mean over 12 points, means over 10 min * 12 = 2 hours.
    # ma03 = Calculating a rolling mean over 18 points, means over 10 min * 18 = 3 hours.
    # ma04 = Calculating a rolling mean over 36 points, means over 10 min * 36 = over around 360 minutes = 6 hours.
    data <- split(data, list(data$Site,data$Serial), drop = TRUE)
    data <- lapply(data, function(df) {
      df %>%
        mutate(temp_ma01 = zoo::rollmean(Temp, k = 3, fill = NA),
               temp_ma02 = zoo::rollmean(Temp, k = 12, fill = NA),
               temp_ma03 = zoo::rollmean(Temp, k = 18, fill = NA),
               temp_ma04 = zoo::rollmean(Temp, k = 36, fill = NA),
               sal_ma01 = zoo::rollmean(Sal, k = 3, fill = NA),
               sal_ma02 = zoo::rollmean(Sal, k = 12, fill = NA),
               sal_ma03 = zoo::rollmean(Sal, k = 18, fill = NA),
               sal_ma04 = zoo::rollmean(Sal, k = 36, fill = NA))
    })
    data <- dplyr::bind_rows(data)
  } else if (device_type == "tcm-temperature") {
    # TCM's took 1 measurement every 1 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
    # Calculate the following variables:
    # Calculate the following variables:
    # ma01 = Calculating a rolling mean over 30 points, means over 1 min * 30 = over 30 minutes.
    # ma02 = Calculating a rolling mean over 120 points, means over 1 min * 120 = 2 hours.
    # ma03 = Calculating a rolling mean over 180 points, means over 1 min * 180 = 3 hours.
    # ma04 = Calculating a rolling mean over 360 points, means over 1 min * 360 = over around 360 minutes = 6 hours.
    data <- split(data, list(data$Site,data$Serial), drop = TRUE)
    data <- lapply(data, function(df) {
      df %>%
        mutate(temp_ma01 = zoo::rollmean(Temperature, k = 30, fill = NA),
               temp_ma02 = zoo::rollmean(Temperature, k = 120, fill = NA),
               temp_ma03 = zoo::rollmean(Temperature, k = 180, fill = NA),
               temp_ma04 = zoo::rollmean(Temperature, k = 360, fill = NA))
    })
    data <- dplyr::bind_rows(data)
  } else {
    stop("Invalid device type. Choose 'staroddi', 'tcm-current', 'tcm-temperature', or 'aquameasure'.")
  }

  return(data)
}


