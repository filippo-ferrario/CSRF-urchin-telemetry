# ===============================================================================
# Name   	: Create dataset for test
# Author 	: Filippo Ferrario
# Date   	:  [dd-mm-yyyy] 13-02-2024
# Version	: 1
# URL		: 
# Aim    	: Create dataset for test
# ===============================================================================

#' ## Create a dummy dataset
#' # -----------------------------
# create a dataset

my_data<- data.frame('site'=c(rep(paste0('site_0',1:9),each=100),rep('site_10',100)) , x=rnorm(1000))

my_data$site<-as.factor(my_data$site)

# ==============================================
# SAVE DATA
# ==============================================

# for now I am not saving the metadata to avoid installin shaRe and to keep things simple.