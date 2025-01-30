# ===============================================================================
# Name   	: Main telemetry filtering
# Author 	: Katie MacGregor
# Date   	:  [yyyy-mm-dd] 2025-01-27
# Version	: 1
# URL		: 
# Aim    	: Organize the process of prepping the telemetry data sets
# ===============================================================================

# ATTENTION: remember to reflect the path of the script in the source function







# =========================
# load packages
# =========================
# library(shaRe) # to facilitate data and metadata export 
library(ezknitr)

library(RColorBrewer)
library(ggplot2)
library(ggrepel)
library(ggpubr)

library(tidyverse)
library(tidyr)
library(lubridate)

library(amt)

library(sf)
library(terra)
library(tmap)


library(conflicted)
conflicted::conflicts_prefer(dplyr::filter)
conflicted::conflicts_prefer(dplyr::select)




# =========================
# Colour schemes and functions
# =========================

# Load colour schemes for plotting
# ---------------------------------------------
source('./workflow/00_colourPalettes.R')






# =========================
# Import vps data and preprocess to filter and combine metadata with detections
# =========================

# Import and explore dataset
# ---------------------------------------------
# input:./data/metadata_urchins_QC2022.csv
# input: ./data/metadata_receivers_QC2022.csv
# input: 
# input: 
# Bic: Anse des Pilotes                                                                                                                                                                                             
# input: ./data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/animal/all.csv
# input: ./data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/syncref/all.csv
# Bic: Baleines
# input: 
# input:  
# Iles aux Lievres - southwest
# input: 
# input: 
# Iles aux Lievres - northeast
# input: 
# input: 
# Prince Rupert - Tugwell 1
# input: 
# input: 
# Prince Rupert - Tugwell 2
# input: 
# input: 
# Quadra - Marina 1
# input: 
# input: 
# Quadra - Marina 2
# input: 
# input:   

source('./workflow/preprocessing-telemetry_filtering/import_combine_and_preprocess_HR2_telemetry_data.R'); rm(list=ls())

# output: ./output/datasets/combined_sync_and_ref_data.csv
# output: ./output/datasets/combined_animal_data.csv

# Render as html file
ezspin(file = './workflow/preprocessing-telemetry_filtering/import_combine_and_preprocess_HR2_telemetry_data.R', keep_md = FALSE,  out_dir = './R_output/Rmarkdown', keep_rmd=TRUE)






# =========================
# Explore and calculate median gps positions from vps data
# =========================

# Explore and calculate median gps positions from vps data
# ---------------------------------------------
# input: ./output/datasets/combined_sync_and_ref_data.csv
# input: ./data/site_polygon.gpkg
source('./workflow/explore_and_calculate_median_positions_from_vps_results.R'); rm(list=ls())
# output: ./output/plots/sync_tag_detections_HPE2.png
# output: ./output/plots/all_detections_HPE2.png
# output: ./output/plots/all_detections_RMSE2.png
# output: ./output/datasets/median_positions.csv
# output: ./output/plots/pos_summary_positions.png
# output: ./output/plots/sync_tag_detections_HPE2_with_median_and_gps.png
# output: ./output/datasets/median_positions_utm_sf.csv


# Render as html file
ezspin(file = './workflow/explore_and_calculate_median_positions_from_vps_results.R', keep_md = FALSE,  out_dir = './output/Rmarkdown', keep_rmd=TRUE)







# =========================
# Filter and plot urchin detection data
# =========================

# Filter and plot urchin detection data
# ---------------------------------------------

# input: ./R_output/datasets/combined_animal_tag_data.csv
# input: ./data/site_polygon.gpkg
source('R_workflow/filter_and_plot_urchin_detection_data.R'); rm(list=ls())
# output: ./R_output/plots/animal_HPE_q90_by_urchin.png
# output: ./R_output/plots/animal_HPE_q90_by_month.png
# output: ./R_output/plots/animal_RMSE_q90_by_urchin.png 
# output: ./R_output/plots/animal_RMSE_q90_by_month.png
# output: ./R_output/plots/urchin_detections/animal_detections_1week_test.png
# output: ./R_output/datasets/one_individual_test_data_for_filtering.csv


# Render as html file
ezspin(file = 'R_workflow/filter_and_plot_urchin_detection_data.R', keep_md = FALSE,  out_dir = './R_output/Rmarkdown', keep_rmd=TRUE)








# =========================
# Filtering strategy for HR urchin positions: test with small dataset
# =========================

# Filtering strategy for HR urchin positions: test with small dataset
# ---------------------------------------------

# input: ./R_output/datasets/one_individual_test_data_for_filtering.csv
# input: ./data/site_polygon.gpkg
source('R_workflow/filtering_strategy_HR_urchin_data_test_with_small_dataset.R'); rm(list=ls())
# output: 



# Render as html file
ezspin(file = 'R_workflow/filtering_strategy_HR_urchin_data_test_with_small_dataset.R', keep_md = FALSE,  out_dir = './R_output/Rmarkdown', keep_rmd=TRUE)
