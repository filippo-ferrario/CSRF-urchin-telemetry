# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: Create CSV files of environmental data - Quebec 2022
# ===============================================================================

#### Final Environmental Datasets ####
source(here(
  "workflow/preprocessing-environmental_data/function-create-environmental-dataset.R"
))
qc <- create_envdataset(c(
  "data/raw_data_downloads_bic_2022/",
  "data/raw_data_downloads_cacouna_2022/",
  "data/metadata_sensors_QC2022.csv"
))
qc_temp <- lapply(qc[[1]], function(tbl) average_samedt(tbl, col_name = "Temp"))
qc_sal <- lapply(qc[[2]], function(tbl) average_samedt(tbl, col_name = "Sal"))

#### Current ####
source(here(
  "workflow/preprocessing-environmental_data/function-create-current-dataset.R"
))
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
  "workflow/preprocessing-environmental_data/function-save-environmental-csv.R"
))
combined_qc <- create_site_csv(
  curr = qc_current_rolled,
  temp = qc_temp,
  sal = qc_sal,
  cols_to_keep = cols_to_keep,
  lat_col = "Lat",
  long_col = "Long",
  serial_col = "Sensor"
)

source(here(
  "workflow/preprocessing-environmental_data/function-generate-trend-plots.R"
))
plot_current_trends(
  qc_current_rolled,
  serial_col = "Sensor",
  file_prefix = "QC_current_",
  out_dir = "output/plots/trend"
)
plot_env_trends(
  qc_sal,
  serial_col = "Sensor",
  file_prefix = "QC_sal_",
  variable = "salinity",
  value_col = "rollmean_Sal",
  out_dir = "output/plots/trend"
)
plot_env_trends(
  qc_temp,
  serial_col = "Sensor",
  file_prefix = "QC_temp_",
  variable = "temperature",
  value_col = "rollmean_Temp",
  out_dir = "output/plots/trend"
)
