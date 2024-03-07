# ===============================================================================
# Name   	: Master Main file
# Author 	: Filippo Ferrario
# Date   	: 2024-03-06
# Version	: 
# URL		: 
# Aim    	: contains all the instructions for the complete project.
# ===============================================================================



# create hierarchy for raw data folder
# =======================================

dir.create('data/raw_data_downloads_bic_2022/vps_results_Bic_2022/La_Baleine/results/', showWarnings = TRUE, recursive = T)



# create hierarchy for R_output folder
# =======================================

# run this section only the first time.
dir.create('R_output/dataset', showWarnings = TRUE, recursive = T) # This folder is to store datasets and their metadata,
dir.create('R_output/plots', showWarnings = TRUE, recursive = T) # This folder is to store plots from analysis 
dir.create('R_output/Rmarkdown', showWarnings = TRUE, recursive = T) # This folder is to store Markdowns and htmls
dir.create('R_output/raster_vector_data', showWarnings = TRUE, recursive = T) # This folder is to store spatial data and their metadata in formats like:
dir.create('R_output/R_objects', showWarnings = TRUE, recursive = T) # This folder is to store the R objects and their metadata.
 

