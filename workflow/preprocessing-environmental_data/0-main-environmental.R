# ===============================================================================
# Name   	: Main environmental data
# Author 	: Filippo Ferrario
# Date   	:  [dd-mm-yyyy] 14-02-2024
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

library(here)

# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
# TCM current data
temp1 <- load.tcm.data(here("data/raw_data_downloads_bic_2022/"),
                            "\\_Current.csv",
                            c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_cacouna_2022/"),
                       "\\_Current.csv",
                       c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
TCM_current2 <- rbind(temp1, temp2)

# TCM temperature data
temp1 <- load.tcm.data(here("data/raw_data_downloads_bic_2022/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_cacouna_2022/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
TCM_temp2 <- rbind(temp1, temp2)

# Load StarOddi data
source(here("workflow/preprocessing-environmental_data/load-staroddi.R"))
temp1 <- load.star.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.star.data(here("data/raw_data_downloads_cacouna_2022/"))
star2 <- rbind(temp1, temp2)

# Load AquaMeasure data
source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
temp1 <- load.aqua.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.aqua.data(here("data/raw_data_downloads_cacouna_2022/"))
aqua2 <- rbind(temp1, temp2)

# Load metadata
metadata <- read.csv(here("data/metadata_sensors_QC2022.csv"), sep = ";")

# Initial clean - merge with metadata, lubridate date/time, exclude deployment/recovery date/times
source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
TCM_current2 <- initial.clean(TCM_current2, metadata)
TCM_temp2 <- initial.clean(TCM_temp2, metadata)
aqua2 <- initial.clean(aqua2, metadata)
star2 <- initial.clean(star2, metadata, star = TRUE)

# Calculate moving averages
source(here("workflow/preprocessing-environmental_data/calculate-moving-averages.R"))
TCM_current2 <- calculate.moving.avg(TCM_current2, 'tcm-current')
TCM_temp2 <- calculate.moving.avg(TCM_temp2, 'tcm-temperature')
aqua2 <- calculate.moving.avg(aqua2, 'aquameasure')
star2 <- calculate.moving.avg(star2, 'staroddi')

# Generate plots and save to 'output/plots/'
source(here("workflow/preprocessing-environmental_data/generate-plots.R"))
generate.plots(TCM_temp2,
               var_vec = c("temp_ma01", "temp_ma02", "temp_ma03", "temp_ma04"),
               name_vec = c("QC_TCMTemp_rollmean_30mins.png", "QC_TCMTemp_rollmean_2hours.png",
                            "QC_TCMTemp_rollmean_3hours.png", "QC_TCMTemp_rollmean_6hours.png"),
               y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)", "Temperature (C)"),
               save_loc = here("output/plots/"))
generate.plots(aqua2,
               var_vec = c("temp_ma01", "temp_ma02", "temp_ma03", "temp_ma04",
                           "sal_ma01", "sal_ma02", "sal_ma03", "sal_ma04"),
               name_vec = c("QC_AquaTemp_rollmean_30mins.png", "QC_AquaTemp_rollmean_2hours.png",
                            "QC_AquaTemp_rollmean_3hours.png", "QC_AquaTemp_rollmean_6hours.png",
                            "QC_AquaSal_rollmean_30mins.png", "QC_AquaSal_rollmean_2hours.png",
                            "QC_AquaSal_rollmean_3hours.png", "QC_AquaSal_rollmean_6hours.png"),
               y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)", "Temperature (C)",
                         "Salinity (psu)", "Salinity (psu)", "Salinity (psu)", "Salinity (psu)"),
               save_loc = here("output/plots/"))
generate.plots(star2,
               var_vec = c("temp_ma01", "temp_ma02", "temp_ma03", "temp_ma04",
                           "sal_ma01", "sal_ma02", "sal_ma03", "sal_ma04"),
               name_vec = c("QC_StarTemp_rollmean_30mins.png", "QC_StarTemp_rollmean_2hours.png",
                            "QC_StarTemp_rollmean_3hours.png", "QC_StarTemp_rollmean_6hours.png",
                            "QC_StarSal_rollmean_30mins.png", "QC_StarSal_rollmean_2hours.png",
                            "QC_StarSal_rollmean_3hours.png", "QC_StarSal_rollmean_6hours.png"),
               y_vec = c("Temperature (C)", "Temperature (C)", "Temperature (C)", "Temperature (C)",
                         "Salinity (psu)", "Salinity (psu)", "Salinity (psu)", "Salinity (psu)"),
               save_loc = here("output/plots/"))



source(here("workflow/preprocessing-environmental_data/generate-current-plots.R"))
generate.current.plots(TCM_current2,
                       var_vec = c("speed_ma01", "speed_ma02", "speed_ma03", "speed_ma04"),
                       name_vec = c("QC_TCMCurr_rollmean_30mins.png", "QC_TCMCurr_rollmean_2hours.png",
                                    "QC_TCMCurr_rollmean_3hours.png", "QC_TCMCurr_rollmean_6hours.png"),
                       y_vec = c("Current speed (cm/s)", "Current speed (cm/s)",
                                 "Current speed (cm/s)", "Current speed (cm/s)"),
                       save_loc = here("output/plots/"))


