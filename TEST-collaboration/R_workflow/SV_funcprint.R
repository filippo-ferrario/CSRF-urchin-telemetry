# ===============================================================================
# Name   	: Main TelemBC
# Author 	: FF
# Date   	:  [dd-mm-yyyy] 26-01-2024
# Version	: 1
# URL		:
# Aim    	: test collaborative strategy
# ===============================================================================

setwd('TEST-collaboration')

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
# output: none

source("./TEST-collaboration/R_workflow/JS_funcprint.R")
print(JS_funcprint(1))






# =======
source("./TEST-collaboration/R_workflow/FF_funcprint.R")
print(FF_funcprint(5))


# ==================================
# Test a branching example - Katie
# ==================================

# Jillian's number printing function
# -----------------------------------
# input: none
# output: none

source("./TEST-collaboration/R_workflow/KM_funcprint.R")
print(KM_funcprint(c(1,2, 6, 11)))



# ==================================
# Test Branch Marie-France Lavoie
# ==================================

source("./TEST-collaboration/R_workflow/MFL_funcprint.R")
print(MFL_funcprint(1))

##==============
#Test branch Sandra
#=================

source("./TEST-collaboration/R_workflow/MFL_funcprint.R")
print(SV_funcprint(1,2,3,4,5))
