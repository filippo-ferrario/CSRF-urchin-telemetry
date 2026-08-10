# ===============================================================================
# Name   	: Clean Environmental Data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		:
# Aim    	: Clean environmental data from AquaMeasure, TCM, and StarOddi devices
# Input   : Dataframe data, Dataframe metadata, boolean star
# Output  : Dataframe
# ===============================================================================

initial.clean <- function(
  data,
  metadata,
  star = FALSE,
  by.x = "Sensor",
  by.y = "Sensor_ID",
  replace_comma = FALSE,
  year
) {
  require(dplyr)
  require(lubridate)

  # Combine metadata with datasets
  data <- data %>%
    left_join(metadata, by = setNames(by.y, by.x))

  if (star == TRUE) {
    data <- data %>%
      mutate(
        DateTime = lubridate::as_datetime(
          Time_conv,
          origin = "1900-01-01 00:00:00",
          tz = "UTC"
        )
      )
  } else {
    # Change date to POSIX
    data <- data %>%
      mutate(DateTime = lubridate::ymd_hms(Time))
  }

  if (replace_comma == TRUE) {
    # Replace all commas with dots in latitude/longitude columns
    data <- data %>%
      mutate(Lat = gsub(",", ".", Lat)) %>%
      mutate(Long = gsub(",", ".", Long))
  }

  if (year == 2023) {
    # Create column with DateTime deployed
    data$DateTime_deployed <- paste(data$Date_deployed, data$Time_deployed_UTC)

    # Cut sequence by deployment and recovery dates
    data <- data %>%
      filter(DateTime > lubridate::as_date(DateTime_deployed) + days(1)) %>%
      filter(DateTime < lubridate::as_date(Date_recovered) - days(1))
  } else if (year == 2024) {
    # Create column with DateTime recovered
    data$DateTime_recovered <- paste(data$recovery_date, data$recovery_time)

    # Cut sequence by deployment and recovery dates
    data <- data %>%
      filter(
        lubridate::as_datetime(Time) > lubridate::as_date(date) + days(1)
      ) %>%
      filter(
        lubridate::as_datetime(Time) <
          lubridate::ymd_hm(DateTime_recovered) - days(1)
      )
  }

  return(data)
}
