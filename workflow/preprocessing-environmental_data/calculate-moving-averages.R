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

calculate.moving.avg <- function(data, k_vec, var_vec, head = FALSE) {
  # TCM's took 1 measurement every 1 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
  # Calculate the following variables:
  # ma01 = Calculating a rolling mean over 30 points, means over 1 min * 30 = over 30 minutes.
  # ma02 = Calculating a rolling mean over 120 points, means over 1 min * 120 = 2 hours.
  # ma03 = Calculating a rolling mean over 360 points, means over 1 min * 360 = over around 360 minutes = 6 hours.


  # Separate by device for rolling mean
  data <- split(data, list(data$Site, data$Serial), drop = TRUE)
  data <- lapply(data, function(df) {
    df %>%
      mutate(
        speed_ma01 = rollmean(Speed, k = 30, fill = NA),
        speed_ma02 = rollmean(Speed, k = 120, fill = NA),
        speed_ma03 = rollmean(Speed, k = 360, fill = NA),
        head_circ = circular(Heading, type = 'directions'))
  })
  TCM_current <- dplyr::bind_rows(TCM_current_split)

  TCM_temp_split <- split(TCM_temp, list(TCM_temp$Site,TCM_temp$Serial), drop = TRUE)
  TCM_temp_split <- lapply(TCM_temp_split, function(df) {
    df %>%
      mutate(temp_ma01 = zoo::rollmean(Temperature, k = 30, fill = NA),
             temp_ma02 = zoo::rollmean(Temperature, k = 120, fill = NA),
             temp_ma03 = zoo::rollmean(Temperature, k = 360, fill = NA))
  })
  TCM_temp <- dplyr::bind_rows(TCM_temp_split)

  star_split <- split(star, list(star$Site,star$Sensor), drop = TRUE)
  star_split <- lapply(star_split, function(df) {
    df %>%
      mutate(temp_ma01 = zoo::rollmean(Temp, k = 30, fill = NA),
             temp_ma02 = zoo::rollmean(Temp, k = 120, fill = NA),
             temp_ma03 = zoo::rollmean(Temp, k = 360, fill = NA),
             sal_ma01 = zoo::rollmean(Sal, k = 30, fill = NA),
             sal_ma02 = zoo::rollmean(Sal, k = 120, fill = NA),
             sal_ma03 = zoo::rollmean(Sal, k = 360, fill = NA))
  })
  star <- dplyr::bind_rows(star_split)

  aqua_split <- split(aqua, list(aqua$Site,aqua$Serial), drop = TRUE)
  aqua_split <- lapply(aqua_split, function(df) {
    df %>%
      mutate(temp_ma01 = zoo::rollmean(Temp, k = 30, fill = NA),
             temp_ma02 = zoo::rollmean(Temp, k = 120, fill = NA),
             temp_ma03 = zoo::rollmean(Temp, k = 360, fill = NA),
             sal_ma01 = zoo::rollmean(Sal, k = 30, fill = NA),
             sal_ma02 = zoo::rollmean(Sal, k = 120, fill = NA),
             sal_ma03 = zoo::rollmean(Sal, k = 360, fill = NA)
      )
  })
  aqua <- dplyr::bind_rows(aqua_split)

  return(data)
}


