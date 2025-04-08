# ===============================================================================
# Name   	: Info from Metadata
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 08-04-2025
# Version	: 1
# URL		:
# Aim    	: Gather extra info from metadata to help compare data from devices
# ===============================================================================

library(here)

# Load metadata
metadata_qc <- read.csv(here("./data/metadata_sensors_QC2022.csv"), sep = ";")
metadata_bc <- read.csv(here("./data/metadata_sensors_BC2023.csv"), sep = ";")

# Columns to keep
keep <- c("Sensor_ID", "Type", "Site", "Position")
metadata_qc <- subset(metadata_qc, select = keep)
metadata_bc <- subset(metadata_bc, select = keep)

# Pair on Sensor_ID
metadata <- metadata_qc %>%
  left_join(metadata_bc, by = "Sensor_ID")
