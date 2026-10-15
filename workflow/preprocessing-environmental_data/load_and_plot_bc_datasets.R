# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: To create CSV files of environmental data - ONLY NEED TO RUN SECTION
#           #### Final Environmental Datasets
# ===============================================================================

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
