# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	: [dd-mm-yyyy] 19-10-2026
# Version	: 1
# URL		  :
# Aim    	: Organize the process of visualizing and prepping the environmental
#           dataset. To create CSV files of environmental data - ONLY NEED TO
#           RUN SECTION #### Final Environmental Datasets
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

library(ezknitr)


# =========================
# Import Quebec data and preliminary plots for investigation
# =========================

# Import
# -------------------------
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
