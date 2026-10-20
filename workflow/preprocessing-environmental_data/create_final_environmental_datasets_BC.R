# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: Create CSV files of environmental data - British Columbia 2023
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

#### Current ####
source(here(
  "workflow/preprocessing-environmental_data/function-create-current-dataset.R"
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
combined_bc <- create_site_csv(
  curr = bc_current_rolled,
  temp = bc_temp,
  sal = bc_sal,
  cols_to_keep = cols_to_keep,
  lat_col = "Lat",
  long_col = "Long",
  serial_col = "Serial"
)

source(here(
  "workflow/preprocessing-environmental_data/function-generate-trend-plots.R"
))
plot_current_trends(
  bc_current_rolled,
  serial_col = "Serial",
  file_prefix = "BC_current_",
  out_dir = "output/plots/trend"
)
plot_env_trends(
  bc_sal,
  serial_col = "Serial",
  file_prefix = "BC_sal_",
  variable = "salinity",
  value_col = "rollmean_Sal",
  out_dir = "output/plots/trend"
)
plot_env_trends(
  bc_temp,
  serial_col = "Serial",
  file_prefix = "BC_temp_",
  variable = "temperature",
  value_col = "rollmean_Temp",
  out_dir = "output/plots/trend"
)
