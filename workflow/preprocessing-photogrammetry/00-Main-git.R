# ===============================================================================
# Name   	: Main workflow
# Author 	: Filippo Ferrario
# Date   	: [dd-mm-yyyy] v1: 21-7-2022; v2: 26-08-2026
# Version	: v2
# URL		: 
# Aim    	: Organize and keep track of script used.
# 			  Version 2 is the subset of 00-Main-local (from Filippo Ferrario's laptop) that contains only scripts relevant to the photogrammetry processing
# 			 paths in the source() have been adapted to the Project folder folder-structure.	
# ===============================================================================

# ====================================
# setup output folders for the task
# ====================================
dir.create('output/datasets/photogrammetry', showWarnings = TRUE, recursive = T) # This folder is to store datasets and their metadata,


 
# ====================================
# check and Instal packages
# ====================================
library(shaRe) # install using devtools::install_github('filippo-ferrario/shaRe', ref='HEAD')

checkNinst(pk=c(
				'tidyverse',
				'ActioneeR',
				'sf',
				'lwgeom',
				'geosphere',
				'ezknitr',
				'FielderInTheLab',
				'gstat',
				'foreach',
				'doParallel',
				'magick' 
				), inst=F)

# devtools::install_github('filippo-ferrario/ActioneeR', ref='HEAD')
# devtools::install_github('filippo-ferrario/FielderInTheLab', ref='HEAD')

# renv::install('filippo-ferrario/ActioneeR')
# renv::install('filippo-ferrario/FielderInTheLab')
# renv::install('geosphere@1.5-18')

# ==================================
# Load packages 
# ==================================

library(tidyverse)
library(ActioneeR)
library(sf)
library(lwgeom) 
library(geosphere)
# library(ezknitr)




# ============================================================
# Image and field data processing for Photogrammetry 
# ============================================================

# BIC 
# ==========================

# Synchronize and subsample
# --------------------------
{ # ATTENTION: This step requires access to Imagery files. Only run if this is available
# # ATTENTION!!! 
# # Synchronisation Scripts refers to images on HDD using absolute paths: checks script before running!)

# # input: data/photogrammetry/BIC-PIL-image_sync.csv
# # 		 data/photogrammetry/BIC-BAL-image_sync.csv
# # 		+ image files on HDD
# source('workflow/preprocessing-photogrammetry/imagery_sync-BIC.R') ; rm(list=ls())
# # output: output/datasets/photogrammetry/BIC-PIL-image_sync-esitmated_ref-check03.csv
# # 		  output/datasets/photogrammetry/BIC-PIL-paired_synced.csv	
# # 		  output/datasets/photogrammetry/BIC-BAL-image_sync-esitmated_ref.csv
# # 		  output/datasets/photogrammetry/BIC-BAL-paired_synced.csv
# # 		+ image files on HDD

# { # 2026-08-17 FF: these scripts refers to a folder hierarchy that has been adoipted in the early stages. outputs are presents in image_processing subfolders but not at paths specified in the scripts.
# # input:
# # 		imagery/QC-BIC-mosaicing/BAL/sub-2/subsample_list.csv
# #		output/datasets/photogrammetry/BIC-PIL-paired_synced.csv	
# # source('workflow/preprocessing-photogrammetry/BIC-BAL-extra_pics.R') ; rm(list=ls()) # select pics to add to BIC-BAL metashape project
# # output:
# # 		image_processing/pics-color_corrected/gimp/BIC-BAL/complement_sub2/README.txt

# # inputs:
# # 		imagery/QC-BIC-mosaicing/PIL/sub-2/subsample_list.csv
# # 		datasets/photogrammetry/BIC-PIL-paired_synced.csv
# # source('workflow/preprocessing-photogrammetry/BIC-PIL-extra_pics.R');   rm(list=ls()) # select pics to add to BIC-BAL metashape project
# # outputs: see note at top of {}
# }
}

# Georeference images
# ------------------------

# Site: BIC-PIL (Pilotes)
# ```````````````````````
# input:
# 		output/datasets/photogrammetry/QC-targets_receivers_coordinates_depth.csv  [this file use produced on the S:/]
# 		data/photogrammetry/BIC-PIL-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BIC-PIL-paired_synced.csv
source('workflow/preprocessing-photogrammetry/imagery_georef-BIC-PIL.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-BIC-PIL.csv (+ dictionary)


# Site: BIC-BAL (Balaine)
# ```````````````````````
# input: 
# 		data/photogrammetry/gps bal nov geo-gps.csv 
# 		data/photogrammetry/BIC-BAL-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BIC-BAL-paired_synced.csv' 
source('workflow/preprocessing-photogrammetry/imagery_georef-BIC-BAL.R'); rm(list=ls())
# output: 
# 		output/datasets/photogrammetry/georeferenced_images-BIC-BAL.csv + dictionary
 		

# Ile-aux-Lievres (IAL)
# ==========================

# Synchronize and subsample
# --------------------------
{ # ATTENTION: This step requires access to Imagery files. Only run if this is available
# # ATTENTION!!! 
# # Synchronisation Scripts refers to images on HDD using absolute paths: checks script before running!)

# # input:
# # 		data/photogrammetry/IAL-NE-image_sync.csv
# # 		data/photogrammetry/IAL-SW-image_sync.csv
# # 		data/photogrammetry/IAL-SW-202207-image_sync.csv
# source('workflow/preprocessing-photogrammetry/imagery_sync-IAL.R'); rm(list=ls())
# # output: 
# # 		output/datasets/photogrammetry/IAL-NE-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/IAL-NE-paired_synced.csv
# # 		output/datasets/photogrammetry/IAL-SW-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/IAL-SW-paired_synced.csv
# # 		output/datasets/photogrammetry/IAL-SW-202207-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/IAL-SW-202207-paired_synced.csv
}

# Georeference images
# ------------------------


# Site: IAL-NE
# ```````````````````````
# input: 
# 		data/photogrammetry/IAL-NE-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/QC-targets_receivers_coordinates_depth.csv
# 		output/datasets/photogrammetry/IAL-NE-paired_synced.csv
source('R_workflow/imagery_georef-IAL-NE.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-IAL-NE.csv (+dictionary)


# Site: IAL-SW
# ```````````````````````
# input: 
# 		data/photogrammetry/IAL-SW-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/QC-targets_receivers_coordinates_depth.csv
# 		output/datasets/photogrammetry/IAL-SW-paired_synced.csv
source('R_workflow/imagery_georef-IAL-SW.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-IAL-SW.csv (+dictionary)



# BC - Prince rupert (PR)
# ==========================

# Synchronize and subsample
# --------------------------
{ # ATTENTION: This step requires access to Imagery files. Only run if this is available
# # ATTENTION!!! 
# # Synchronisation Scripts refers to images on HDD using absolute paths: checks script before running!)

# # input:
# # 		data/photogrammety/PR-TUG_1-image_sync.csv
# # 		data/photogrammety/PR-TUG_2-image_sync.csv
# source('R_workflow/imagery_sync-PRT.R'); rm(list=ls())
# # output:
# # 		output/datasets/photogrammetry/PR-TUG_1-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/PR-TUG_1-paired_synced.csv
# # 		output/datasets/photogrammetry/PR-TUG_2-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/PR-TUG_2-paired_synced.csv
}

# Georeference images
# ------------------------

# Site: TUG-1
# ```````````````````````
# input: 
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/PR-Tug_1-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/PR-TUG_1-paired_synced.csv
source('R_workflow/imagery_georef-PR-TUG_1.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-PR-TUG_1.csv (+ dictionary)


# Site: TUG-1 with offsets per cameras on the wing
# `````````````````````````````````````````````````
# input: 
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/PR-Tug_1-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/PR-TUG_1-paired_synced.csv
source('R_workflow/imagery_georef-PR-TUG_1-offset.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-PR-TUG_1-offset.csv (+ dictionary)


# Site: TUG-2
# ```````````````````````
# input: 
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/PR-Tug_2-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/PR-TUG_2-paired_synced.csv
source('R_workflow/imagery_georef-PR-TUG_2.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-PR-TUG_2.csv (+ dictionary)


# Site: TUG-2 with offsets per cameras on the wing
# `````````````````````````````````````````````````
# input: 
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/PR-Tug_2-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/PR-TUG_2-paired_synced.csv
source('R_workflow/imagery_georef-PR-TUG_2-offset.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-PR-TUG_2-offset.csv (+ dictionary)


# BC - Quadra Island (QD)
# ==========================

# Synchronize and subsample
# --------------------------
{ # ATTENTION: This step requires access to Imagery files. Only run if this is available
# # ATTENTION!!! 
# # Synchronisation Scripts refers to images on HDD using absolute paths: checks script before running!)

# # input:
# # 		data/photogrammety/QD-MAR_1-image_sync.csv
# # 		data/photogrammety/QD-MAR_2-image_sync.csv
# source('R_workflow/imagery_sync-MAR.R'); rm(list=ls())
# # output:
# # 		output/datasets/photogrammetry/QD-MAR_1-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/QD-MAR_1-paired_synced.csv
# # 		output/datasets/photogrammetry/QD-MAR_2-image_sync-esitmated_ref.csv
# # 		output/datasets/photogrammetry/QD-MAR_2-paired_synced.csv
}

# Adjusted depths of targets in BC
# ---------------------------------------------------------------
# input:
# 		data/photogrammetry/targets_deployment.csv
# 		data/tide_tables/predictions_09350_Casey Cove_2023-05-23-tugwell.csv
# 		data/tide_tables/predictions_08038_Whaletown_2023-05-31-marina.csv
source('R_workflow/BC-site_data-targets_depths.R'); rm(list=ls())
# output: 
# 		output/datasets/photogrammetry/BC-targets_depth.csv (+ dictionary)



# Georeference images
# ------------------------

# Site: MAR-1
# ```````````````````````
# input:
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/QD-MAR_1-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BC-targets_depth.csv
# 		output/datasets/photogrammetry/QD-MAR_1-paired_synced.csv
source('R_workflow/imagery_georef-QD-MAR_1.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-QD-MAR_1.csv (+ dictionary)

# Site: MAR-1 with offsets per cameras on the wing
# `````````````````````````````````````````````````
# input:
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/QD-MAR_1-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BC-targets_depth.csv
# 		output/datasets/photogrammetry/QD-MAR_1-paired_synced.csv
source('R_workflow/imagery_georef-QD-MAR_1-offset.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-QD-MAR_1-offset.csv (+ dictionary)


# Site: MAR-2
# ```````````````````````
# input:
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/QD-MAR_2-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BC-targets_depth.csv
# 		output/datasets/photogrammetry/QD-MAR_2-paired_synced.csv
source('R_workflow/imagery_georef-QD-MAR_2.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-QD-MAR_2.csv (+ dictionary)


# Site: MAR-2 with offsets per cameras on the wing
# `````````````````````````````````````````````````
# input:
# 		data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv
# 		data/photogrammety/QD-MAR_2-pic2georef-main_camera.csv
# 		output/datasets/photogrammetry/BC-targets_depth.csv
# 		output/datasets/photogrammetry/QD-MAR_2-paired_synced.csv
source('R_workflow/imagery_georef-QD-MAR_2-offset.R'); rm(list=ls())
# output:
# 		output/datasets/photogrammetry/georeferenced_images-QD-MAR_2-offset.csv (+ dictionary)



# Scalebars deployments with tide adjustment
# ---------------------------------------------
# input: 
# 		data/photogrammetry/scalebars_in_situ_layout.csv 
# 		data/photogrammetry/scalebars_length.csv 
# 		data/tide_tables/predictions_03000_Île Bicquette_2022-07-28.csv 
# 		data/tide_tables/predictions_03000_Île Bicquette_2022-08-03.csv 
# 		data/tide_tables/predictions_03140_Île aux Lièvres_2022-10-05.csv 
# 		data/tide_tables/predictions_03140_Île aux Lièvres_2022-07-05.csv
source('workflow/preprocessing-photogrammetry/scalebars.R'); rm(list=ls())
# output: output/datasets/photogrammetry/scalebars.csv (+ dictionary)




