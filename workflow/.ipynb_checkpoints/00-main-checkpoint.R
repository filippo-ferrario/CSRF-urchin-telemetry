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

# This will create a common data folder structure for everyone working on the project. Each person can
# download only the data you want to work with, but put it in your data folder within this same
# folder structure in order to ensure that scripts are transferable between us all.

# Transect data
dir.create('data/transects/', showWarnings = TRUE, recursive = T)


## Bic data folders
# Anse des Pilotes
dir.create('data/raw_data_downloads_bic_2022/sensors_anse_des_pilotes/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_anse_des_pilotes/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_anse_des_pilotes/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_anse_des_pilotes/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/syncref/', showWarnings = TRUE, recursive = T)

# La Baleine
dir.create('data/raw_data_downloads_bic_2022/sensors_la_baleine/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_la_baleine/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_la_baleine/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/sensors_la_baleine/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_bic_2022/vps_results_bic_2022/la_baleine/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_bic_2022/vps_results_bic_2022/la_baleine/results/syncref/', showWarnings = TRUE, recursive = T)


## Cacouna data folders
# ADCPs deployed between the two sites (one shallower and one deeper)
dir.create('data/raw_data_downloads_cacouna_2022/ADCP_between_2_sites/', showWarnings = TRUE, recursive = T)
#Southwest
dir.create('data/raw_data_downloads_cacouna_2022/sensors_southwest/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/sensors_southwest/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/sensors_southwest/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/southwest/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/southwest/results/syncref/', showWarnings = TRUE, recursive = T)

# Northeast
dir.create('data/raw_data_downloads_cacouna_2022/sensors_northeast/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/sensors_northeast/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/sensors_northeast/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/northeast/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/northeast/results/syncref/', showWarnings = TRUE, recursive = T)



## Prince Rupert data folders
# Tugwell 1
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell1/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell1/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell1/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell1/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell1/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell1/results/syncref/', showWarnings = TRUE, recursive = T)

# Tugwell 2
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell2/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell2/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell2/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/sensors_tugwell2/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell2/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell2/results/syncref/', showWarnings = TRUE, recursive = T)


## Quadra data folders
# Marina 1
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina1/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina1/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina1/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina1/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina1/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina1/results/syncref/', showWarnings = TRUE, recursive = T)

# Marina 2
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina2/ADCP/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina2/aquameasure/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina2/star_oddi/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/sensors_marina2/TCM/', showWarnings = TRUE, recursive = T)

dir.create('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina2/results/animal/', showWarnings = TRUE, recursive = T)
dir.create('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina2/results/syncref/', showWarnings = TRUE, recursive = T)










# create hierarchy for R_output folder
# =======================================

# run this section only the first time.
dir.create('output/datasets', showWarnings = TRUE, recursive = T) # This folder is to store datasets and their metadata,
dir.create('output/plots', showWarnings = TRUE, recursive = T) # This folder is to store plots from analysis 
dir.create('output/Rmarkdown', showWarnings = TRUE, recursive = T) # This folder is to store Markdowns and htmls
dir.create('output/raster_vector_data', showWarnings = TRUE, recursive = T) # This folder is to store spatial data and their metadata in formats like:
dir.create('output/R_objects', showWarnings = TRUE, recursive = T) # This folder is to store the R objects and their metadata.
 



