# ===============================================================================
# Name   	: Create dataset of temperature and salinity from AM and TCM
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 04-21-2026
# Version	: 1
# URL		  :
# Aim    	: Calculate moving averages
# Input   : Dataframe data vector of files
#           year integer 2023 or 2024
# Output  : Dataframe
# ================================================================================

# Function to create environmental dataset (other than current)
create_envdataset <- function(data) {
  # Load AquaMeasure data
  source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
  temp1 <- load.aqua.data(
    here(data[1]),
    c(
      "No",
      "Type",
      "Time",
      "Model",
      "Serial",
      "Sal",
      "Temp",
      "Tilt",
      "Bat",
      "Details"
    )
  )
  temp2 <- load.aqua.data(
    here(data[2]),
    c(
      "No",
      "Type",
      "Time",
      "Model",
      "Serial",
      "Sal",
      "Temp",
      "Tilt",
      "Bat",
      "Details"
    )
  )
  # Load TCM temp data
  source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
  temp3 <- load.tcm.data(
    here(data[1]),
    "\\_Temperature.csv",
    c("Time", "Temperature", "Sensor", "Serial")
  )
  temp4 <- load.tcm.data(
    here(data[2]),
    "\\_Temperature.csv",
    c("Time", "Temperature", "Sensor", "Serial")
  )
  # Load metadata
  metadata <- read.csv(here(data[3]), sep = ";")

  # Separate into salinity and temperature
  salinity <- rbind(temp1 %>% select(-Temp), temp2 %>% select(-Temp))
  temperature <- rbind(temp1 %>% select(-Sal), temp2 %>% select(-Sal))
  temperature_tcm <- rbind(temp3, temp4)

  # Initial clean (merge with metadata, lubridate date/time, exclude based on deployment/recovery time)
  source(here(
    "workflow/preprocessing-environmental_data/clean-environmental.R"
  ))
  salinity$Serial <- as.character(salinity$Serial)
  temperature$Serial <- as.character(temperature$Serial)
  salinity <- initial.clean(salinity, metadata, by.x = "Serial", year = 2023)
  temperature <- initial.clean(
    temperature,
    metadata,
    by.x = "Serial",
    year = 2023
  )
  temperature_tcm <- initial.clean(temperature_tcm, metadata, year = 2023)

  # Round AquaMeasure Datetime to nearest ten min mark
  salinity$DateTimeRounded <- round_date(
    parse_date_time(salinity$DateTime, c("%Y-%m-%d %H:%M:%S", "%Y-%m-%d")),
    "10 minutes"
  )
  temperature$DateTimeRounded <- ceiling_date(
    temperature$DateTime,
    "10 minutes"
  )
  temperature <- temperature %>%
    select(
      Model,
      Serial,
      Site,
      Position,
      Lat,
      Long,
      Bottom_Depth_m,
      Date_recovered,
      DateTime_deployed,
      DateTimeRounded,
      Temp
    ) %>%
    rename(DateTime = DateTimeRounded)
  salinity <- salinity %>%
    select(
      Model,
      Serial,
      Site,
      Position,
      Lat,
      Long,
      Bottom_Depth_m,
      Date_recovered,
      DateTime_deployed,
      DateTimeRounded,
      Sal
    ) %>%
    rename(DateTime = DateTimeRounded)

  # Select every ten minute from TCM
  temp1 <- temperature_tcm[minute(temperature_tcm$DateTime) %% 10 == 0, ] %>%
    select(
      Serial,
      Site,
      Position,
      Lat,
      Long,
      Bottom_Depth_m,
      Date_recovered,
      DateTime_deployed,
      DateTime,
      Temperature
    ) %>%
    mutate(Model = "TCM") %>%
    relocate(Model, .before = 1) %>%
    rename(Temp = Temperature)

  # Bind rows of temperature and temp1 (every 10mins of TCM)
  temp2 <- rbind(temp1, temperature)

  # Separate temperature and salinity by site
  grouped_temperature <- split(temp2, temp2$Site)
  grouped_salinity <- split(salinity, salinity$Site)

  return(list(grouped_temperature, grouped_salinity))
}

# Function to average the rows that have data from the same DateTime
average_samedt <- function(df, col_name) {
  col_sym <- rlang::sym(col_name)
  new_col_sym <- rlang::sym(paste0("rollmean_", col_name))

  df %>%
    group_by(DateTime) %>%
    reframe(
      # average target column
      !!col_sym := mean(!!col_sym, na.rm = TRUE),

      # character columns → concatenate
      across(
        where(is.character) & !all_of(col_name),
        ~ paste(unique(.x), collapse = ", ")
      ),

      # all other columns → first value
      across(
        !where(is.character) & !all_of(col_name),
        dplyr::first
      )
    ) %>%
    mutate(!!new_col_sym := zoo::rollmean(!!col_sym, k = 3, fill = NA))
}
