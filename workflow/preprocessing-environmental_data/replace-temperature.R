# ===============================================================================
# Name   	: Clean temperature
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

library(dplyr)
library(lubridate)
library(zoo)
library(circular)
library(ggplot2)
library(tibble)
library(here)

setwd("C:/Users/shaoj/Documents/csrf_urchin/bc")

# Load metadata
metadata <- read.csv("./metadata_sensors_BC2023.csv", sep = ";")

# ===============================================================================
# Load TCM Temperature Data
# ===============================================================================

# List all files in child directories that have "\\_Temperature.csv"
temp <- list.files(path = ".", pattern = "\\_Temperature.csv", recursive = TRUE,
                   ignore.case = TRUE, include.dirs = TRUE)
# Read all files
myfiles <- lapply(temp, read.csv)

# Loop to fill in serial and sensor ID from file name
for (i in 1:length(temp)) {
  ## Note: For TCM (serial ID is in the file name)
  # Get serial ID
  sensor.id <- gsub(".*_(.*)_\\(.*", "\\1", temp[i])
  # Put serial ID in column
  myfiles[[i]]$Sensor <- sensor.id

  # Get serial ID
  serial.id <- gsub("^.*?/([0-9]{7})_.*$", "\\1", temp[i])
  # Put serial ID in column
  myfiles[[i]]$Serial <- serial.id
}

# Bind data
TCM_temp <- as_tibble(bind_rows(myfiles))
# Rename columns
colnames(TCM_temp) <- c("Time", "Temperature", "Sensor", "Serial")
# Description of data:
# time = time in ISO 8601 format (with 'T' separating date and time); in UTC.
# temp = temperature in degrees C
# sensor = unique file identifier containing both sensor serial number and deployment info.
# serial = serial number of sensor

# ===============================================================================
# Load TCM Current Data
# ===============================================================================

# List all files in child directories that have "\\_Current.csv"
temp <- list.files(path = ".", pattern = "\\_Current.csv", recursive = TRUE,
                   ignore.case = TRUE, include.dirs = TRUE)
# Read all files
myfiles <- lapply(temp, read.csv)

# Loop to fill in serial and sensor ID from file name
for (i in 1:length(temp)) {
  ## Note: For Quebec TCM (serial ID is in the file name)
  # Get serial ID
  sensor.id <- gsub(".*_(.*)_\\(.*", "\\1", temp[i])
  # Put serial ID in column
  myfiles[[i]]$Sensor <- sensor.id

  # Get serial ID
  serial.id <- gsub("^.*?/([0-9]{7})_.*$", "\\1", temp[i])
  # Put serial ID in column
  myfiles[[i]]$Serial <- serial.id
}

# Bind data
TCM_current <- as_tibble(bind_rows(myfiles))
# Rename columns
colnames(TCM_current) <- c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
# Description of data:
# time = time in ISO 8601 format (with 'T' separating date and time); in UTC.
# speed = current speed in cm.s, output by the Domino TCM software from raw data measurements (accelerations and tilt/heading)
# head = compass heading of output current in degrees (0-360)
# V_N = Velocity component - north. In cm.s
# V_E = Velocity component - east. In cm.s
# sensor = unique file identifier containing both sensor serial number and deployment info.
# serial = serial number of sensor

# ===============================================================================
# Load StarOddi Data
# ===============================================================================

temp <- list.files(path = ".", pattern = "\\_exported.csv", recursive = TRUE,
                   ignore.case = TRUE, include.dirs = TRUE)

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

# ===============================================================================
# Load AquaMeasure Data
# ===============================================================================

temp <- list.files(path = ".", pattern = "^aquaMeasure.*\\.csv$",, recursive = TRUE,
                   ignore.case = TRUE, include.dirs = TRUE)
myfiles <- lapply(temp, read.csv)

aqua <- as_tibble(bind_rows(myfiles))

colnames(aqua) <- c("No", "Type", "Time", "Model", "Serial", "Sal", "Temp", "Tilt", "Bat", "Details")
aqua$Serial <- as.character(aqua$Serial)

# Description of data:
#   No = Record number. This does not necessarily start at 1 (depends how the aquaMeasure was launched/used previously). These numbers do increase sequentially with each new row/measurement.
# type = Record type. This is DATA for all data measurements, but can also be EVENT for system things that are logged.
# time = time in UTC
# model = model of sensor used. Here, this is always aquaM - SAL, but there are also dissolved oxygen models etc.
# serial = serial number of sensor
# sal = Salinity (calculated from conductivity) and reported in PSU
# temp = temperature in degrees C
# tilt = tilt of instrument in degrees (0 = vertical and 90 = horizontal)
# bat = battery voltage
# details = Event details (only contains information for EVENT rows and not DATA rows - for DATA rows this is NA).

# ===============================================================================
# Preprocess Datasets
# ===============================================================================

# Combine metadata with datasets
TCM_temp <- TCM_temp %>%
  left_join(metadata, by = c("Serial" = "Sensor_ID"))
TCM_current <- TCM_current %>%
  left_join(metadata, by = c("Serial" = "Sensor_ID"))
aqua <- aqua %>%
  left_join(metadata, by = c("Serial" = "Sensor_ID"))
star <- star %>%
  left_join(metadata, by = c("Sensor" = "Sensor_ID"))

# Change date to POSIX
TCM_temp <- TCM_temp %>%
  mutate(DateTime = lubridate::ymd_hms(Time))
TCM_current <- TCM_current %>%
  mutate(DateTime = lubridate::ymd_hms(Time))
aqua <- aqua %>%
  mutate(DateTime = lubridate::ymd_hms(Time))
star <- star %>%
  mutate(DateTime = lubridate::as_datetime(Time_conv, origin = "1900-01-01 00:00:00", tz = "UTC"))


# Cut sequence by deployment and recovery dates
TCM_temp <- TCM_temp %>%
  filter(DateTime > ymd(Date_deployed) + days(1)) %>%
  filter(DateTime < ymd(Date_recovered) - days(1))
TCM_current <- TCM_current %>%
  filter(DateTime > ymd(Date_deployed) + days(1)) %>%
  filter(DateTime < ymd(Date_recovered) - days(1))
aqua <- aqua %>%
  filter(DateTime > ymd(Date_deployed) + days(1)) %>%
  filter(DateTime < ymd(Date_recovered) - days(1))
star <- star %>%
  filter(DateTime > ymd(Date_deployed) + days(1)) %>%
  filter(DateTime < ymd(Date_recovered) - days(1))

# Export preprocessed and cleaned copies of data files
# library(readr)
# write_csv(TCM_current, file = ("./R_output/datasets/TCM_current.csv"))
# write_csv(TCM_temp, file = ("./R_output/datasets/TCM_temp.csv"))
# write_csv(aqua, file = ("./R_output/datasets/aqua.csv"))
# write_csv(star, file = ("./R_output/datasets/star.csv"))

# ===============================================================================
# Calculate moving averages of time series
# ===============================================================================

# TCM's took 1 measurement every 1 minute (and that measurement is already based on a burst of measurements, averaged during the export procedure from the Domino program).
# Calculate the following variables:
# ma01 = Calculating a rolling mean over 30 points, means over 1 min * 30 = over 30 minutes.
# ma02 = Calculating a rolling mean over 120 points, means over 1 min * 120 = 2 hours.
# ma03 = Calculating a rolling mean over 360 points, means over 1 min * 360 = over around 360 minutes = 6 hours.

# Separate by device for rolling mean
TCM_current_split <- split(TCM_current, list(TCM_current$Site,TCM_current$Serial), drop = TRUE)
TCM_current_split <- lapply(TCM_current_split, function(df) {
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

# ===============================================================================
# Plots for TCM Current
# ===============================================================================

# Rolling mean plotted over original datapoints showing direction
TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_point(aes(y = speed_ma01), color = "black", alpha = 0.1, shape = 16) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_30mins.png")

TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_2hours.png")

TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_point(aes(y = speed_ma03), color = "black", alpha = 0.1, shape = 16) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
TCM_current %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma01), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom1_rollmean_30mins.png")

# Second zoom
TCM_current %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma01), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom2_rollmean_30mins.png")

TCM_current %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom1_rollmean_2hours.png")

TCM_current %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for TCM Temperature
# ===============================================================================

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position)) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_30mins.png")

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma03, color = Position)) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_6hours.png")

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_2hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
TCM_temp %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position)) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom1_rollmean_30mins.png")

# Second zoom
TCM_temp %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position)) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom2_rollmean_30mins.png")

TCM_temp %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom1_rollmean_2hours.png")

TCM_temp %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for AquaMeasure Temperature
# ===============================================================================

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_30mins.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_6hours.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_2hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom1_rollmean_30mins.png")

# Second zoom
aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom2_rollmean_30mins.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom1_rollmean_2hours.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for AquaMeasure Salinity
# ===============================================================================

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_30mins.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  #scale_color_gradientn(colours = terrain.colors(16)) +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_2hours.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom1_rollmean_30mins.png")

# Second zoom
aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom2_rollmean_30mins.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom1_rollmean_2hours.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for StarOddi Temperature
# ===============================================================================

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_30mins.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_2hours.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom1_rollmean_30mins.png")

# Second zoom
star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom2_rollmean_30mins.png")

star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom1_rollmean_2hours.png")

star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom2_rollmean_2hours.png")


# ===============================================================================
# Plots for StarOddi Salinity
# ===============================================================================

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_30mins.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_2hours.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom1_rollmean_30mins.png")

# Second zoom
star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom2_rollmean_30mins.png")

star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom1_rollmean_2hours.png")

star %>%
  filter(DateTime >= as.POSIXct("2023-09-01 00:00:00") & DateTime <= as.POSIXct("2023-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for Series & Positions
# ===============================================================================

star %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temp), alpha = 0.1) +
  geom_path(aes(y = Temp), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/StarTemp_all.png", width = 8, height = 10)

star %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Sal), alpha = 0.1) +
  geom_path(aes(y = Sal), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/StarSal_all.png", width = 8, height = 10)

aqua %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temp), alpha = 0.1) +
  geom_path(aes(y = Temp), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/AquaTemp_all.png", width = 8, height = 10)

aqua %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Sal), alpha = 0.1) +
  geom_path(aes(y = Sal), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/AquaSal_all.png", width = 8, height = 10)

TCM_temp %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temperature), alpha = 0.1) +
  geom_path(aes(y = Temperature), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/TCMTemp_all.png", width = 8, height = 10)

TCM_current %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Speed), alpha = 0.1) +
  geom_path(aes(y = Speed), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/TCMCurSpeed_all.png", width = 8, height = 10)

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
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), ~ gsub(",", ".", .)))

# ## Cut world map
# sf::sf_use_s2(FALSE)
#
# world <- st_read("C:/Users/shaoj/Documents/land_polygons_shp/land_polygons.shp")
#
# # Check for invalid geometries
# invalid_geoms <- !st_is_valid(world)
# if (any(invalid_geoms)) {
#   cat("Fixing", sum(invalid_geoms), "invalid geometries...\n")
#   world <- st_make_valid(world)  # Fix invalid geometries
# }
#
# xmin <- as.numeric(min(all_unique$Long)) - 0.1  # Min Longitude
# xmax <- as.numeric(max(all_unique$Long)) + 0.1  # Max Longitude
# ymin <- as.numeric(min(all_unique$Lat)) - 0.1   # Min Latitude
# ymax <- as.numeric(min(all_unique$Lat)) + 0.1   # Max Latitude
#
# bbox <- st_bbox(c(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), crs = st_crs(world))
# world_cropped <- st_crop(world, bbox)

## Plot devices on cropped map
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), as.numeric)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

unique_split <- split(all_unique, all_unique$DeviceType)

lapply(names(unique_split), function(name) {
  p <- ggplot(data = unique_split[[name]]) +
    geom_sf(aes(color = SP), size = 2, alpha = 0.5) +
    theme_bw()

  # Save the plot with a unique filename
  ggsave(filename = paste0("./R_output/maps/", name, "_deviceloc.png"), plot = p, width = 8, height = 6, dpi = 300)
})


