# ===============================================================================
# Name   	: Main environmental data
# Author 	: Filippo Ferrario
# Date   	:  [dd-mm-yyyy] 14-02-2024
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

library(here)

source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
temp1 <- load.tcm.data(here("data/raw_data_downloads_bic_2022/"),
                            "\\_Current.csv",
                            c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_cacouna_2022/"),
                       "\\_Current.csv",
                       c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
TCM_current2 <- rbind(temp1, temp2)

temp1 <- load.tcm.data(here("data/raw_data_downloads_bic_2022/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_cacouna_2022/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
TCM_temp2 <- rbind(temp1, temp2)

source(here("workflow/preprocessing-environmental_data/load-staroddi.R"))
temp1 <- load.star.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.star.data(here("data/raw_data_downloads_cacouna_2022/"))
star2 <- rbind(temp1, temp2)

source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
temp1 <- load.aqua.data(here("data/raw_data_downloads_bic_2022/"))
temp2 <- load.aqua.data(here("data/raw_data_downloads_cacouna_2022/"))
aqua2 <- rbind(temp1, temp2)

# Load metadata
metadata <- read.csv(here("data/metadata_sensors_QC2022.csv"), sep = ";")

source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
TCM_current2 <- initial.clean(TCM_current2, metadata)
TCM_temp2 <- initial.clean(TCM_temp2, metadata)
aqua2 <- initial.clean(aqua2, metadata)
star2 <- initial.clean(star2, metadata, star = TRUE)
