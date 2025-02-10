# ===============================================================================
# Name   	: initialize renv
# Author 	: Filippo Ferrario
# Date   	:  [dd-mm-yyyy] 14-02-2024
# Version	: 1
# URL		: following  https://rstudio.github.io/renv/articles/renv.html
# Aim    	: 
# ===============================================================================

# R version used is 4.3.2 with Rtools43

renv::init()

# Renv was initialized after populating the project folder with some scripts inherited from TEST-projects-1 and saved in TEST-collaboration/R_workflow.
# no scripts were run befor initializing


# - Installing ezknitr ...                        OK [installed binary and cached in 1.5s]
# The following package(s) were not installed successfully:
# - [shaRe]: package 'shaRe' is not available
# You may need to manually download and install these packages.

# The following required packages are not installed:
# - codetools  [required by foreach]
# - MASS       [required by ggplot2]
# - mgcv       [required by ggplot2]
# Consider reinstalling these packages before snapshotting the lockfile.

# Error in renv_snapshot_validate_report(valid, prompt, force) : 
#   aborting snapshot due to pre-flight validation failure
# In addition: Warning message:
# "~/.Rprofile" is missing a trailing newline 
# Traceback (most recent calls last):
# 4: renv::init()
# 3: snapshot(library = libpaths, repos = repos, prompt = FALSE, project = project)
# 2: renv_snapshot_validate_report(valid, prompt, force)
# 1: stop("aborting snapshot due to pre-flight validation failure")


# renv::install(c('codetools','MASS','mgcv','filippo-ferrario/shaRe'))
renv::install(c('codetools','MASS','mgcv'))

renv::init()

renv::snapshot()
     