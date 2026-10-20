# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	: [dd-mm-yyyy] 19-10-2026
# Version	: 1
# URL		  :
# Aim    	: Organize the process of visualizing and prepping the environmental
#           dataset. To create CSV files of environmental data - ONLY NEED TO
#           RUN SECTION 'Create final environmental datasets for both BC and QC'
# ===============================================================================

# =========================
# load packages
# =========================
library(here)

library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)
library(circular)
library(purrr)

# =========================
# Import Quebec data and preliminary plots for investigation
# =========================

# input: data/raw_data_downloads_bic_2022/
# input: data/raw_data_downloads_cacouna_2022/
# input: data/metadata_sensors_QC2022.csv
source(
  "./workflow/preprocessing-environmental_data/load_and_plot_quebec_datasets.R"
)

# output: "output/plots/QC_TCMTemp_rollmean_30mins.png"
# output: "output/plots/QC_AquaSal_rollmean_2hours.png"
# output: "output/plots/QC_AquaSal_rollmean_2hours_2days.png"
# output: "output/plots/QC_AquaSal_rollmean_2hours_week.png"
# output: "output/plots/QC_AquaSal_rollmean_3hours.png"
# output: "output/plots/QC_AquaSal_rollmean_3hours_2days.png"
# output: "output/plots/QC_AquaSal_rollmean_3hours_week.png"
# output: "output/plots/QC_AquaSal_rollmean_6hours.png"
# output: "output/plots/QC_AquaSal_rollmean_6hours_2days.png"
# output: "output/plots/QC_AquaSal_rollmean_6hours_week.png"
# output: "output/plots/QC_AquaSal_rollmean_30mins.png"
# output: "output/plots/QC_AquaTemp_rollmean_2hours.png"
# output: "output/plots/QC_AquaTemp_rollmean_2hours_2days.png"
# output: "output/plots/QC_AquaTemp_rollmean_2hours_week.png"
# output: "output/plots/QC_AquaTemp_rollmean_3hours.png"
# output: "output/plots/QC_AquaTemp_rollmean_3hours_2days.png"
# output: "output/plots/QC_AquaTemp_rollmean_3hours_week.png"
# output: "output/plots/QC_AquaTemp_rollmean_6hours.png"
# output: "output/plots/QC_AquaTemp_rollmean_6hours_2days.png"
# output: "output/plots/QC_AquaTemp_rollmean_6hours_week.png"
# output: "output/plots/QC_AquaTemp_rollmean_30mins.png"
# output: "output/plots/QC_StarSal_rollmean_2hours.png"
# output: "output/plots/QC_StarSal_rollmean_2hours_2days.png"
# output: "output/plots/QC_StarSal_rollmean_2hours_week.png"
# output: "output/plots/QC_StarSal_rollmean_3hours.png"
# output: "output/plots/QC_StarSal_rollmean_3hours_2days.png"
# output: "output/plots/QC_StarSal_rollmean_3hours_week.png"
# output: "output/plots/QC_StarSal_rollmean_6hours.png"
# output: "output/plots/QC_StarSal_rollmean_6hours_2days.png"
# output: "output/plots/QC_StarSal_rollmean_6hours_week.png"
# output: "output/plots/QC_StarSal_rollmean_30mins.png"
# output: "output/plots/QC_StarTemp_rollmean_2hours.png"
# output: "output/plots/QC_StarTemp_rollmean_2hours_2days.png"
# output: "output/plots/QC_StarTemp_rollmean_2hours_week.png"
# output: "output/plots/QC_StarTemp_rollmean_3hours.png"
# output: "output/plots/QC_StarTemp_rollmean_3hours_2days.png"
# output: "output/plots/QC_StarTemp_rollmean_3hours_week.png"
# output: "output/plots/QC_StarTemp_rollmean_6hours.png"
# output: "output/plots/QC_StarTemp_rollmean_6hours_2days.png"
# output: "output/plots/QC_StarTemp_rollmean_6hours_week.png"
# output: "output/plots/QC_StarTemp_rollmean_30mins.png"
# output: "output/plots/QC_TCMCurr_rollmean_2hours.png"
# output: "output/plots/QC_TCMCurr_rollmean_2hours_2days.png"
# output: "output/plots/QC_TCMCurr_rollmean_2hours_week.png"
# output: "output/plots/QC_TCMCurr_rollmean_3hours.png"
# output: "output/plots/QC_TCMCurr_rollmean_3hours_2days.png"
# output: "output/plots/QC_TCMCurr_rollmean_3hours_week.png"
# output: "output/plots/QC_TCMCurr_rollmean_6hours.png"
# output: "output/plots/QC_TCMCurr_rollmean_6hours_2days.png"
# output: "output/plots/QC_TCMCurr_rollmean_6hours_week.png"
# output: "output/plots/QC_TCMCurr_rollmean_30mins.png"
# output: "output/plots/QC_TCMTemp_rollmean_2hours.png"
# output: "output/plots/QC_TCMTemp_rollmean_2hours_2days.png"
# output: "output/plots/QC_TCMTemp_rollmean_2hours_week.png"
# output: "output/plots/QC_TCMTemp_rollmean_3hours.png"
# output: "output/plots/QC_TCMTemp_rollmean_3hours_2days.png"
# output: "output/plots/QC_TCMTemp_rollmean_3hours_week.png"
# output: "output/plots/QC_TCMTemp_rollmean_6hours.png"
# output: "output/plots/QC_TCMTemp_rollmean_6hours_2days.png"
# output: "output/plots/QC_TCMTemp_rollmean_6hours_week.png"

# =========================
# Import BC data and preliminary plots for investigation
# =========================

# input: data/raw_data_downloads_prince_rupert_2023/
# input: data/raw_data_downloads_quadra_2023/
# input: data/metadata_sensors_BC2023.csv
source(
  "./workflow/preprocessing-environmental_data/load_and_plot_bc_datasets.R"
)

# output: "output/plots/BC_AquaSal_rollmean_2hours.png"
# output: "output/plots/BC_AquaSal_rollmean_2hours_2days.png"
# output: "output/plots/BC_AquaSal_rollmean_2hours_week.png"
# output: "output/plots/BC_AquaSal_rollmean_3hours.png"
# output: "output/plots/BC_AquaSal_rollmean_3hours_2days.png"
# output: "output/plots/BC_AquaSal_rollmean_3hours_week.png"
# output: "output/plots/BC_AquaSal_rollmean_6hours.png"
# output: "output/plots/BC_AquaSal_rollmean_6hours_2days.png"
# output: "output/plots/BC_AquaSal_rollmean_6hours_week.png"
# output: "output/plots/BC_AquaSal_rollmean_30mins.png"
# output: "output/plots/BC_AquaTemp_rollmean_2hours.png"
# output: "output/plots/BC_AquaTemp_rollmean_2hours_2days.png"
# output: "output/plots/BC_AquaTemp_rollmean_2hours_week.png"
# output: "output/plots/BC_AquaTemp_rollmean_3hours.png"
# output: "output/plots/BC_AquaTemp_rollmean_3hours_2days.png"
# output: "output/plots/BC_AquaTemp_rollmean_3hours_week.png"
# output: "output/plots/BC_AquaTemp_rollmean_6hours.png"
# output: "output/plots/BC_AquaTemp_rollmean_6hours_2days.png"
# output: "output/plots/BC_AquaTemp_rollmean_6hours_week.png"
# output: "output/plots/BC_AquaTemp_rollmean_30mins.png"
# output: "output/plots/BC_StarSal_rollmean_2hours.png"
# output: "output/plots/BC_StarSal_rollmean_2hours_2days.png"
# output: "output/plots/BC_StarSal_rollmean_2hours_week.png"
# output: "output/plots/BC_StarSal_rollmean_3hours.png"
# output: "output/plots/BC_StarSal_rollmean_3hours_2days.png"
# output: "output/plots/BC_StarSal_rollmean_3hours_week.png"
# output: "output/plots/BC_StarSal_rollmean_6hours.png"
# output: "output/plots/BC_StarSal_rollmean_6hours_2days.png"
# output: "output/plots/BC_StarSal_rollmean_6hours_week.png"
# output: "output/plots/BC_StarSal_rollmean_30mins.png"
# output: "output/plots/BC_StarTemp_rollmean_2hours.png"
# output: "output/plots/BC_StarTemp_rollmean_2hours_2days.png"
# output: "output/plots/BC_StarTemp_rollmean_2hours_week.png"
# output: "output/plots/BC_StarTemp_rollmean_3hours.png"
# output: "output/plots/BC_StarTemp_rollmean_3hours_2days.png"
# output: "output/plots/BC_StarTemp_rollmean_3hours_week.png"
# output: "output/plots/BC_StarTemp_rollmean_6hours.png"
# output: "output/plots/BC_StarTemp_rollmean_6hours_2days.png"
# output: "output/plots/BC_StarTemp_rollmean_6hours_week.png"
# output: "output/plots/BC_StarTemp_rollmean_30mins.png"
# output: "output/plots/BC_TCMCurr_rollmean_2hours.png"
# output: "output/plots/BC_TCMCurr_rollmean_2hours_2days.png"
# output: "output/plots/BC_TCMCurr_rollmean_2hours_week.png"
# output: "output/plots/BC_TCMCurr_rollmean_3hours.png"
# output: "output/plots/BC_TCMCurr_rollmean_3hours_2days.png"
# output: "output/plots/BC_TCMCurr_rollmean_3hours_week.png"
# output: "output/plots/BC_TCMCurr_rollmean_6hours.png"
# output: "output/plots/BC_TCMCurr_rollmean_6hours_2days.png"

# =========================
# Create final environmental datasets for QC
# =========================

# input: data/raw_data_downloads_bic_2022/
# input: data/raw_data_downloads_cacouna_2022/
# input: data/metadata_sensors_QC2022.csv
source(
  "./workflow/preprocessing-environmental_data/create_final_environmental_datasets_QC.R"
)

# Dataset outputs
# output: "output/datasets/environmental/Baleine.csv",
# output: "output/datasets/environmental/NE.csv",
# output: "output/datasets/environmental/Pilotes.csv",
# output: "output/datasets/environmental/SW.csv"
# Plotting outputs - each HTML file has a corresponding folder
# output: "output/plots/trend/QC_temp_SW.html"
# output: "output/plots/trend/QC_current_Baleine_files"
# output: "output/plots/trend/QC_current_NE_files"
# output: "output/plots/trend/QC_current_Pilotes_files"
# output: "output/plots/trend/QC_current_SW_files"
# output: "output/plots/trend/QC_sal_Baleine_files"
# output: "output/plots/trend/QC_sal_NE_files"
# output: "output/plots/trend/QC_sal_Pilotes_files"
# output: "output/plots/trend/QC_sal_SW_files"
# output: "output/plots/trend/QC_temp_Baleine_files"
# output: "output/plots/trend/QC_temp_NE_files"
# output: "output/plots/trend/QC_temp_Pilotes_files"
# output: "output/plots/trend/QC_temp_SW_files"
# output: "output/plots/trend/QC_current_Baleine.html"
# output: "output/plots/trend/QC_current_NE.html"
# output: "output/plots/trend/QC_current_Pilotes.html"
# output: "output/plots/trend/QC_current_SW.html"
# output: "output/plots/trend/QC_sal_Baleine.html"
# output: "output/plots/trend/QC_sal_NE.html"
# output: "output/plots/trend/QC_sal_Pilotes.html"
# output: "output/plots/trend/QC_sal_SW.html"
# output: "output/plots/trend/QC_temp_Baleine.html"
# output: "output/plots/trend/QC_temp_NE.html"
# output: "output/plots/trend/QC_temp_Pilotes.html"

# =========================
# Create final environmental datasets for BC
# =========================

# input: data/raw_data_downloads_prince_rupert_2023/
# input: data/raw_data_downloads_quadra_2023/
# input: data/metadata_sensors_BC2023.csv
source(
  "./workflow/preprocessing-environmental_data/create_final_environmental_datasets_BC.R"
)

# Dataset outputs
# output: "output/datasets/environmental/marina1.csv",
# output: "output/datasets/environmental/marina2.csv",
# output: "output/datasets/environmental/tugwell1.csv",
# output: "output/datasets/environmental/tugwell2.csv"
# Plotting outputs - each HTML file has a corresponding folder
# output: "output/plots/trend/BC_temp_tugwell2.html"
# output: "output/plots/trend/BC_current_marina1_files"
# output: "output/plots/trend/BC_current_marina2_files"
# output: "output/plots/trend/BC_current_tugwell1_files"
# output: "output/plots/trend/BC_current_tugwell2_files"
# output: "output/plots/trend/BC_sal_marina1_files"
# output: "output/plots/trend/BC_sal_marina2_files"
# output: "output/plots/trend/BC_sal_tugwell1_files"
# output: "output/plots/trend/BC_sal_tugwell2_files"
# output: "output/plots/trend/BC_temp_marina1_files"
# output: "output/plots/trend/BC_temp_marina2_files"
# output: "output/plots/trend/BC_temp_tugwell1_files"
# output: "output/plots/trend/BC_temp_tugwell2_files"
# output: "output/plots/trend/BC_current_marina1.html"
# output: "output/plots/trend/BC_current_marina2.html"
# output: "output/plots/trend/BC_current_tugwell1.html"
# output: "output/plots/trend/BC_current_tugwell2.html"
# output: "output/plots/trend/BC_sal_marina1.html"
# output: "output/plots/trend/BC_sal_marina2.html"
# output: "output/plots/trend/BC_sal_tugwell1.html"
# output: "output/plots/trend/BC_sal_tugwell2.html"
# output: "output/plots/trend/BC_temp_marina1.html"
# output: "output/plots/trend/BC_temp_marina2.html"
# output: "output/plots/trend/BC_temp_tugwell1.html"
