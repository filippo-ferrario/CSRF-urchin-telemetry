# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: To create CSV files of environmental data - ONLY NEED TO RUN SECTION
#           #### Final Environmental Datasets
# ===============================================================================

library(here)

library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)
library(circular)
library(purrr)

#### For Quebec ####
# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
# TCM current data
temp1 <- load.tcm.data(
  here("data/raw_data_downloads_bic_2022/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
)
temp2 <- load.tcm.data(
  here("data/raw_data_downloads_cacouna_2022/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
)
TCM_current <- rbind(temp1, temp2)

# TCM temperature data
temp1 <- load.tcm.data(
  here("data/raw_data_downloads_bic_2022/"),
  "\\_Temperature.csv",
  c("Time", "Temperature", "Sensor", "Serial")
)
temp2 <- load.tcm.data(
  here("data/raw_data_downloads_cacouna_2022/"),
  "\\_Temperature.csv",
  c("Time", "Temperature", "Sensor", "Serial")
)
TCM_temp <- rbind(temp1, temp2)

# Load StarOddi data
source(here("workflow/preprocessing-environmental_data/load-staroddi.R"))
temp1 <- load.star.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.star.data(here("data/raw_data_downloads_cacouna_2022/"))
star <- rbind(temp1, temp2)

# Load AquaMeasure data
source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
temp1 <- load.aqua.data(
  here("data/raw_data_downloads_bic_2022/"),
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
  here("data/raw_data_downloads_cacouna_2022/"),
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
aqua <- rbind(temp1, temp2)
aqua$Serial <- as.character(aqua$Serial)

# Load metadata
metadata <- read.csv(here("data/metadata_sensors_QC2022.csv"), sep = ";")

# Initial clean - merge with metadata, lubridate date/time, exclude deployment/recovery date/times
source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
TCM_current <- initial.clean(TCM_current, metadata, year = 2023)
TCM_temp <- initial.clean(TCM_temp, metadata, year = 2023)
aqua <- initial.clean(aqua, metadata, by.x = "Serial", year = 2023)
star <- initial.clean(star, metadata, star = TRUE, year = 2023)

# Calculate moving averages
source(here(
  "workflow/preprocessing-environmental_data/calculate-moving-averages.R"
))
TCM_current <- calculate.moving.avg(TCM_current, 'tcm-current')
TCM_temp <- calculate.moving.avg(
  TCM_temp,
  'tcm-temperature',
  site_col = "Site",
  sensor_col = "Sensor"
)
aqua <- calculate.moving.avg(aqua, 'aquameasure')
star <- calculate.moving.avg(star, 'staroddi')

### Quebec Plots ####

# Generate plots and save to 'output/plots/'
source(here("workflow/preprocessing-environmental_data/generate-plots.R"))
generate.plots(
  TCM_temp2,
  var_vec = c("temp_ma01", "temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "QC_TCMTemp_rollmean_30mins.png",
    "QC_TCMTemp_rollmean_2hours.png",
    "QC_TCMTemp_rollmean_3hours.png",
    "QC_TCMTemp_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)"
  ),
  save_loc = here("output/plots/")
)
generate.plots(
  aqua2,
  var_vec = c(
    "temp_ma01",
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma01",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_AquaTemp_rollmean_30mins.png",
    "QC_AquaTemp_rollmean_2hours.png",
    "QC_AquaTemp_rollmean_3hours.png",
    "QC_AquaTemp_rollmean_6hours.png",
    "QC_AquaSal_rollmean_30mins.png",
    "QC_AquaSal_rollmean_2hours.png",
    "QC_AquaSal_rollmean_3hours.png",
    "QC_AquaSal_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  save_loc = here("output/plots/")
)
generate.plots(
  star2,
  var_vec = c(
    "temp_ma01",
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma01",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_StarTemp_rollmean_30mins.png",
    "QC_StarTemp_rollmean_2hours.png",
    "QC_StarTemp_rollmean_3hours.png",
    "QC_StarTemp_rollmean_6hours.png",
    "QC_StarSal_rollmean_30mins.png",
    "QC_StarSal_rollmean_2hours.png",
    "QC_StarSal_rollmean_3hours.png",
    "QC_StarSal_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  save_loc = here("output/plots/")
)

source(here("workflow/preprocessing-environmental_data/generate-plots-zoom.R"))
# One Week Zoom
generate.plots.zoom(
  TCM_temp2,
  origvar_vec = c("Temperature", "Temperature", "Temperature"),
  roundvar_vec = c("temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "QC_TCMTemp_rollmean_2hours_week.png",
    "QC_TCMTemp_rollmean_3hours_week.png",
    "QC_TCMTemp_rollmean_6hours_week.png"
  ),
  y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)"),
  time_vec = c("2022-09-01 00:00:00", "2022-09-07 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  aqua2,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_AquaTemp_rollmean_2hours_week.png",
    "QC_AquaTemp_rollmean_3hours_week.png",
    "QC_AquaTemp_rollmean_6hours_week.png",
    "QC_AquaSal_rollmean_2hours_week.png",
    "QC_AquaSal_rollmean_3hours_week.png",
    "QC_AquaSal_rollmean_6hours_week.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-07 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  star2,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_StarTemp_rollmean_2hours_week.png",
    "QC_StarTemp_rollmean_3hours_week.png",
    "QC_StarTemp_rollmean_6hours_week.png",
    "QC_StarSal_rollmean_2hours_week.png",
    "QC_StarSal_rollmean_3hours_week.png",
    "QC_StarSal_rollmean_6hours_week.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-07 00:00:00"),
  save_loc = here("output/plots/")
)

# Two Day Zoom
generate.plots.zoom(
  TCM_temp2,
  origvar_vec = c("Temperature", "Temperature", "Temperature"),
  roundvar_vec = c("temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "QC_TCMTemp_rollmean_2hours_2days.png",
    "QC_TCMTemp_rollmean_3hours_2days.png",
    "QC_TCMTemp_rollmean_6hours_2days.png"
  ),
  y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)"),
  time_vec = c("2022-09-01 00:00:00", "2022-09-02 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  aqua2,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_AquaTemp_rollmean_2hours_2days.png",
    "QC_AquaTemp_rollmean_3hours_2days.png",
    "QC_AquaTemp_rollmean_6hours_2days.png",
    "QC_AquaSal_rollmean_2hours_2days.png",
    "QC_AquaSal_rollmean_3hours_2days.png",
    "QC_AquaSal_rollmean_6hours_2days.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-02 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  star2,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "QC_StarTemp_rollmean_2hours_2days.png",
    "QC_StarTemp_rollmean_3hours_2days.png",
    "QC_StarTemp_rollmean_6hours_2days.png",
    "QC_StarSal_rollmean_2hours_2days.png",
    "QC_StarSal_rollmean_3hours_2days.png",
    "QC_StarSal_rollmean_6hours_2days.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-02 00:00:00"),
  save_loc = here("output/plots/")
)


source(here(
  "workflow/preprocessing-environmental_data/generate-current-plots.R"
))
generate.current.plots(
  TCM_current2,
  var_vec = c("speed_ma01", "speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "QC_TCMCurr_rollmean_30mins.png",
    "QC_TCMCurr_rollmean_2hours.png",
    "QC_TCMCurr_rollmean_3hours.png",
    "QC_TCMCurr_rollmean_6hours.png"
  ),
  save_loc = here("output/plots/")
)

source(here(
  "workflow/preprocessing-environmental_data/generate-current-plots-zoom.R"
))
generate.current.plots.zoom(
  TCM_current2,
  roundvar_vec = c("speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "QC_TCMCurr_rollmean_2hours_week.png",
    "QC_TCMCurr_rollmean_3hours_week.png",
    "QC_TCMCurr_rollmean_6hours_week.png"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-07 00:00:00"),
  save_loc = here("output/plots/")
)
generate.current.plots.zoom(
  TCM_current2,
  roundvar_vec = c("speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "QC_TCMCurr_rollmean_2hours_2days.png",
    "QC_TCMCurr_rollmean_3hours_2days.png",
    "QC_TCMCurr_rollmean_6hours_2days.png"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-02 00:00:00"),
  save_loc = here("output/plots/")
)


#### For British Columbia ####
# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
# TCM current data
temp1 <- load.tcm.data(
  here("data/raw_data_downloads_prince_rupert_2023/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
)
temp2 <- load.tcm.data(
  here("data/raw_data_downloads_quadra_2023/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
)
TCM_current_bc <- rbind(temp1, temp2)

# TCM temperature data
temp1 <- load.tcm.data(
  here("data/raw_data_downloads_prince_rupert_2023/"),
  "\\_Temperature.csv",
  c("Time", "Temperature", "Sensor", "Serial")
)
temp2 <- load.tcm.data(
  here("data/raw_data_downloads_quadra_2023/"),
  "\\_Temperature.csv",
  c("Time", "Temperature", "Sensor", "Serial")
)
TCM_temp_bc <- rbind(temp1, temp2)

# Load StarOddi data
source(here("workflow/preprocessing-environmental_data/load-staroddi.R"))
temp1 <- load.star.data(here("data/raw_data_downloads_prince_rupert_2023/"))
temp2 <- load.star.data(here("data/raw_data_downloads_quadra_2023/"))
star_bc <- rbind(temp1, temp2)

# Load AquaMeasure data
source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
temp1 <- load.aqua.data(
  here("data/raw_data_downloads_prince_rupert_2023/"),
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
  here("data/raw_data_downloads_quadra_2023/"),
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
aqua_bc <- rbind(temp1, temp2)
aqua_bc$Serial <- as.character(aqua_bc$Serial)

# Load metadata
metadata <- read.csv(here("data/metadata_sensors_BC2023.csv"), sep = ";")

# Initial clean - merge with metadata, lubridate date/time, exclude deployment/recovery date/times
source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
TCM_current_bc <- initial.clean(TCM_current_bc, metadata, year = 2023)
TCM_temp_bc <- initial.clean(TCM_temp_bc, metadata, year = 2023)
aqua_bc <- initial.clean(aqua_bc, metadata, by.x = "Serial", year = 2023)
star_bc <- initial.clean(star_bc, metadata, star = TRUE, year = 2023)

# Calculate moving averages
source(here(
  "workflow/preprocessing-environmental_data/calculate-moving-averages.R"
))
TCM_current_bc <- calculate.moving.avg(TCM_current_bc, 'tcm-current')
TCM_temp_bc <- calculate.moving.avg(
  TCM_temp_bc,
  'tcm-temperature',
  site_col = "Site",
  sensor_col = "Sensor"
)
aqua_bc <- calculate.moving.avg(aqua_bc, 'aquameasure')
star_bc <- calculate.moving.avg(star_bc, 'staroddi')

### BC Plots ####

# Generate plots and save to 'output/plots/'
source(here("workflow/preprocessing-environmental_data/generate-plots.R"))
generate.plots(
  TCM_temp,
  var_vec = c("temp_ma01", "temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "BC_TCMTemp_rollmean_30mins.png",
    "BC_TCMTemp_rollmean_2hours.png",
    "BC_TCMTemp_rollmean_3hours.png",
    "BC_TCMTemp_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)"
  ),
  save_loc = here("output/plots/")
)
generate.plots(
  aqua,
  var_vec = c(
    "temp_ma01",
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma01",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_AquaTemp_rollmean_30mins.png",
    "BC_AquaTemp_rollmean_2hours.png",
    "BC_AquaTemp_rollmean_3hours.png",
    "BC_AquaTemp_rollmean_6hours.png",
    "BC_AquaSal_rollmean_30mins.png",
    "BC_AquaSal_rollmean_2hours.png",
    "BC_AquaSal_rollmean_3hours.png",
    "BC_AquaSal_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  save_loc = here("output/plots/")
)
generate.plots(
  star,
  var_vec = c(
    "temp_ma01",
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma01",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_StarTemp_rollmean_30mins.png",
    "BC_StarTemp_rollmean_2hours.png",
    "BC_StarTemp_rollmean_3hours.png",
    "BC_StarTemp_rollmean_6hours.png",
    "BC_StarSal_rollmean_30mins.png",
    "BC_StarSal_rollmean_2hours.png",
    "BC_StarSal_rollmean_3hours.png",
    "BC_StarSal_rollmean_6hours.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  save_loc = here("output/plots/")
)

source(here("workflow/preprocessing-environmental_data/generate-plots-zoom.R"))
# One Week Zoom
generate.plots.zoom(
  TCM_temp,
  origvar_vec = c("Temperature", "Temperature", "Temperature"),
  roundvar_vec = c("temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "BC_TCMTemp_rollmean_2hours_week.png",
    "BC_TCMTemp_rollmean_3hours_week.png",
    "BC_TCMTemp_rollmean_6hours_week.png"
  ),
  y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)"),
  time_vec = c("2023-09-01 00:00:00", "2023-09-07 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  aqua,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_AquaTemp_rollmean_2hours_week.png",
    "BC_AquaTemp_rollmean_3hours_week.png",
    "BC_AquaTemp_rollmean_6hours_week.png",
    "BC_AquaSal_rollmean_2hours_week.png",
    "BC_AquaSal_rollmean_3hours_week.png",
    "BC_AquaSal_rollmean_6hours_week.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-07 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  star,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_StarTemp_rollmean_2hours_week.png",
    "BC_StarTemp_rollmean_3hours_week.png",
    "BC_StarTemp_rollmean_6hours_week.png",
    "BC_StarSal_rollmean_2hours_week.png",
    "BC_StarSal_rollmean_3hours_week.png",
    "BC_StarSal_rollmean_6hours_week.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-07 00:00:00"),
  save_loc = here("output/plots/")
)

# Two Day Zoom
generate.plots.zoom(
  TCM_temp,
  origvar_vec = c("Temperature", "Temperature", "Temperature"),
  roundvar_vec = c("temp_ma02", "temp_ma03", "temp_ma04"),
  name_vec = c(
    "BC_TCMTemp_rollmean_2hours_2days.png",
    "BC_TCMTemp_rollmean_3hours_2days.png",
    "BC_TCMTemp_rollmean_6hours_2days.png"
  ),
  y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)"),
  time_vec = c("2023-09-01 00:00:00", "2023-09-02 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  aqua,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_AquaTemp_rollmean_2hours_2days.png",
    "BC_AquaTemp_rollmean_3hours_2days.png",
    "BC_AquaTemp_rollmean_6hours_2days.png",
    "BC_AquaSal_rollmean_2hours_2days.png",
    "BC_AquaSal_rollmean_3hours_2days.png",
    "BC_AquaSal_rollmean_6hours_2days.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-02 00:00:00"),
  save_loc = here("output/plots/")
)
generate.plots.zoom(
  star,
  origvar_vec = c("Temp", "Temp", "Temp", "Sal", "Sal", "Sal"),
  roundvar_vec = c(
    "temp_ma02",
    "temp_ma03",
    "temp_ma04",
    "sal_ma02",
    "sal_ma03",
    "sal_ma04"
  ),
  name_vec = c(
    "BC_StarTemp_rollmean_2hours_2days.png",
    "BC_StarTemp_rollmean_3hours_2days.png",
    "BC_StarTemp_rollmean_6hours_2days.png",
    "BC_StarSal_rollmean_2hours_2days.png",
    "BC_StarSal_rollmean_3hours_2days.png",
    "BC_StarSal_rollmean_6hours_2days.png"
  ),
  y_vec = c(
    "Temperature (C)",
    "Temperature (C)",
    "Temperature (C)",
    "Salinity (psu)",
    "Salinity (psu)",
    "Salinity (psu)"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-02 00:00:00"),
  save_loc = here("output/plots/")
)


source(here(
  "workflow/preprocessing-environmental_data/generate-current-plots.R"
))
generate.current.plots(
  TCM_current,
  var_vec = c("speed_ma01", "speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "BC_TCMCurr_rollmean_30mins.png",
    "BC_TCMCurr_rollmean_2hours.png",
    "BC_TCMCurr_rollmean_3hours.png",
    "BC_TCMCurr_rollmean_6hours.png"
  ),
  save_loc = here("output/plots/")
)

source(here(
  "workflow/preprocessing-environmental_data/generate-current-plots-zoom.R"
))
generate.current.plots.zoom(
  TCM_current,
  roundvar_vec = c("speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "BC_TCMCurr_rollmean_2hours_week.png",
    "BC_TCMCurr_rollmean_3hours_week.png",
    "BC_TCMCurr_rollmean_6hours_week.png"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-07 00:00:00"),
  save_loc = here("output/plots/")
)

generate.current.plots.zoom(
  TCM_current,
  roundvar_vec = c("speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "BC_TCMCurr_rollmean_2hours_2days.png",
    "BC_TCMCurr_rollmean_3hours_2days.png",
    "BC_TCMCurr_rollmean_6hours_2days.png"
  ),
  time_vec = c("2023-09-01 00:00:00", "2023-09-02 00:00:00"),
  save_loc = here("output/plots/")
)


#### Final Environmental Datasets ####
source(here(
  "workflow/preprocessing-environmental_data/create-environmental-dataset.R"
))
bc <- create_envdataset(c(
  "data/raw_data_downloads_prince_rupert_2023/",
  "data/raw_data_downloads_quadra_2023/",
  "data/metadata_sensors_BC2023.csv"
))
bc_temp <- lapply(bc[[1]], function(tbl) average_samedt(tbl, col_name = "Temp"))
bc_sal <- lapply(bc[[2]], function(tbl) average_samedt(tbl, col_name = "Sal"))
qc <- create_envdataset(c(
  "data/raw_data_downloads_bic_2022/",
  "data/raw_data_downloads_cacouna_2022/",
  "data/metadata_sensors_QC2022.csv"
))
qc_temp <- lapply(qc[[1]], function(tbl) average_samedt(tbl, col_name = "Temp"))
qc_sal <- lapply(qc[[2]], function(tbl) average_samedt(tbl, col_name = "Sal"))


#### Current ####
source(here(
  "workflow/preprocessing-environmental_data/create-current-dataset.R"
))
bc_current <- create_currdataset(
  c(
    "data/raw_data_downloads_prince_rupert_2023/",
    "data/raw_data_downloads_quadra_2023/",
    "data/metadata_sensors_BC2023.csv"
  ),
  2023
)
bc_current_rolled <- rollmean_current(bc_current)
qc_current <- create_currdataset(
  c(
    "data/raw_data_downloads_bic_2022/",
    "data/raw_data_downloads_cacouna_2022/",
    "data/metadata_sensors_QC2022.csv"
  ),
  2023
)
qc_current_rolled <- rollmean_current(qc_current)

# Save as csv file
cols_to_keep <- c(
  "Lat",
  "Long",
  "Serial",
  "rollmean_Temp",
  "rollmean_Sal",
  "Heading_roll_mean",
  "Speed_roll_mean"
)

source(here(
  "workflow/preprocessing-environmental_data/save-environmental-csv.R"
))
# combined_bc <- create_site_csv(
#   curr = bc_current_rolled,
#   temp = bc_temp,
#   sal = bc_sal,
#   cols_to_keep = cols_to_keep
# )
#
# combined_qc <- create_site_csv(
#   curr = qc_current_rolled,
#   temp = qc_temp,
#   sal = qc_sal,
#   cols_to_keep = cols_to_keep
# )

##### Plotting ####
library(ggplot2)
library(plotly)
library(htmlwidgets)

for (site_label in names(qc_temp)) {
  site_data <- qc_temp[[site_label]]
  # Remove rows with zero values in data column
  site_data <- site_data %>% filter(!is.na(rollmean_Temp))

  device_ids <- unique(site_data$Serial)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Serial == serial)

    plot_ly(
      data = df,
      x = ~DateTime,
      y = ~rollmean_Temp,
      type = "scatter",
      mode = "lines",
      name = unique(df$Position), # Use the combined Type-Position as the name
      line = list(
        color = RColorBrewer::brewer.pal(n = length(device_ids), "Dark2")[i]
      )
    )
  })

  # Create annotations for each subplot
  annotations <- lapply(seq_along(device_ids), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / length(device_ids),
      text = paste("Device:", device_ids[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  # Combine all device plots into one subplot
  final_plot <- subplot(
    device_plots,
    nrows = length(device_ids),
    shareX = TRUE,
    shareY = TRUE,
    titleY = FALSE
  ) %>%
    layout(
      title = paste("Temperature Trend with Rolling Mean - Site:", site_label),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      #yaxis = list(title = "Salinity (psu)"),
      yaxis = list(title = "Temperature (°C)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_temptrend", site_label, ".html")
  saveWidget(
    final_plot,
    file = here(paste0("output/plots/trend-cleaned/", file_name)),
    selfcontained = TRUE
  )
  print(paste("saved plot", site_label))
}

for (site_label in names(qc_current_rolled)) {
  site_data <- qc_current_rolled[[site_label]]
  device_ids <- unique(site_data$Serial)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Serial == serial)

    plot_ly() %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Heading_roll_mean,
        name = paste("Heading -", unique(df$Position)),
        line = list(color = RColorBrewer::brewer.pal(n = 8, "Dark2")[1])
      ) %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Speed_roll_mean,
        name = paste("Speed -", unique(df$Position)),
        yaxis = "y2",
        line = list(color = RColorBrewer::brewer.pal(n = 8, "Dark2")[2])
      ) %>%
      layout(
        yaxis = list(title = "Heading"),
        yaxis2 = list(
          title = "Speed",
          overlaying = "y",
          side = "right"
        )
      )
  })

  # Create annotations for each subplot
  annotations <- lapply(seq_along(device_ids), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / length(device_ids),
      text = paste("Device:", device_ids[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  # Combine all device plots into one subplot
  final_plot <- subplot(
    device_plots,
    nrows = length(device_ids),
    shareX = TRUE,
    titleY = FALSE
  ) %>%
    layout(
      title = paste("Current Trends - Site:", site_label),
      xaxis = list(title = "DateTime", rangeslider = list(visible = TRUE)),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_current_", site_label, ".html")
  saveWidget(
    final_plot,
    file = here(paste0("output/plots/trend-cleaned/", file_name)),
    selfcontained = TRUE
  )
  print(paste("saved plot", site_label))
}
