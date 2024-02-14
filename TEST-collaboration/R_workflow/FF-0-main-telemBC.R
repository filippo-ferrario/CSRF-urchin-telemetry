# ===============================================================================
# Name   	: Main TelemBC
# Author 	: FF
# Date   	:  [dd-mm-yyyy] 26-01-2024
# Version	: 1
# URL		: 
# Aim    	: test collaborative strategy
# ===============================================================================

setwd('TEST-collaboration')
s
# run this section only the first time.
dir.create('R_output/dataset', showWarnings = TRUE, recursive = T)
dir.create('R_output/images', showWarnings = TRUE, recursive = T)
dir.create('R_output/Rmarkdown', showWarnings = TRUE, recursive = T)
dir.create('R_output/spatial', showWarnings = TRUE, recursive = T)
 


# ================================================
# check for packages and Install missing ones
# ================================================
library(shaRe) # get it from devtools::install_github('filippo-ferrario/shaRe', ref='HEAD')

checkNinst(c('tidyverse',
'foreach',
'doParallel',
'ezknitr'), inst=F)


# ======================
# load packages
# ======================
library(tidyverse)
library(foreach)
library(doParallel)
library(ezknitr)


# ==================================
# Some workflow for this subproject
# ==================================

# example on how parallize you code
# -----------------------------------
# input: none
ezspin(file='R_workflow/FF-example-parallel_processing.R', keep_md=FALSE,  out_dir='R_output/Rmarkdown')
# input: /R_output/Rmarkdown/FF-example-parallel_processing.html