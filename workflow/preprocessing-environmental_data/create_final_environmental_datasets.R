# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: To create CSV files of environmental data - ONLY NEED TO RUN SECTION
#           #### Final Environmental Datasets
# ===============================================================================

#### Final Environmental Datasets ####
source(here(
  "workflow/preprocessing-environmental_data/function-create-environmental-dataset.R"
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
combined_bc <- create_site_csv(
  curr = bc_current_rolled,
  temp = bc_temp,
  sal = bc_sal,
  cols_to_keep = cols_to_keep
)

combined_qc <- create_site_csv(
  curr = qc_current_rolled,
  temp = qc_temp,
  sal = qc_sal,
  cols_to_keep = cols_to_keep
)
