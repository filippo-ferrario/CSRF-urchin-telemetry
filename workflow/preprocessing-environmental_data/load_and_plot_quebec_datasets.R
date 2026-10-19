# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: Load and save preliminary investigative plots for Quebec
#           environmental datasets for 2022
# ===============================================================================

#### For Quebec ####
# Load TCM data
source(here("workflow/preprocessing-environmental_data/function-load-TCM.R"))
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
source(here(
  "workflow/preprocessing-environmental_data/function-load-staroddi.R"
))
temp1 <- load.star.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.star.data(here("data/raw_data_downloads_cacouna_2022/"))
star <- rbind(temp1, temp2)

# Load AquaMeasure data
source(here(
  "workflow/preprocessing-environmental_data/function-load-aquameasure.R"
))
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
source(here(
  "workflow/preprocessing-environmental_data/function-clean-environmental.R"
))
TCM_current <- initial.clean(TCM_current, metadata, year = 2023)
TCM_temp <- initial.clean(TCM_temp, metadata, year = 2023)
aqua <- initial.clean(aqua, metadata, by.x = "Serial", year = 2023)
star <- initial.clean(star, metadata, star = TRUE, year = 2023)

# Calculate moving averages
source(here(
  "workflow/preprocessing-environmental_data/function-calculate-moving-averages.R"
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
source(here(
  "workflow/preprocessing-environmental_data/function-generate-plots.R"
))
generate.plots(
  TCM_temp,
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

source(here(
  "workflow/preprocessing-environmental_data/function-generate-plots-zoom.R"
))
# One Week Zoom
generate.plots.zoom(
  TCM_temp,
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
  TCM_temp,
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
  "workflow/preprocessing-environmental_data/function-generate-current-plots.R"
))
generate.current.plots(
  TCM_current,
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
  "workflow/preprocessing-environmental_data/function-generate-current-plots-zoom.R"
))
generate.current.plots.zoom(
  TCM_current,
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
  TCM_current,
  roundvar_vec = c("speed_ma02", "speed_ma03", "speed_ma04"),
  name_vec = c(
    "QC_TCMCurr_rollmean_2hours_2days.png",
    "QC_TCMCurr_rollmean_3hours_2days.png",
    "QC_TCMCurr_rollmean_6hours_2days.png"
  ),
  time_vec = c("2022-09-01 00:00:00", "2022-09-02 00:00:00"),
  save_loc = here("output/plots/")
)
