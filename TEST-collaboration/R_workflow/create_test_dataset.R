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

# daytag<-as.Date(Sys.time())
script_ver<-'create_test_dataset.R'


mydata_dict<-shaRe::initiate_dictionary(my_data)
mydata_dict

mydata_dict[ mydata_dict$field_name == 'site',2:5]<-c('this is the site id','character','N/A', NA)
mydata_dict[ mydata_dict$field_name == 'x'	 ,2:5]<-c('this is the variable to analyse','numeric','baudi', NA)

txt<-paste0('
R SCRIPT: ',script_ver,' on ',as.Date(Sys.time()),' with ', R.version.string,',

Object type: dataset

DESCRIPTION:
this is a test dataset that reports the measurements of a variable `x` (unit measures `baudi`) at 10 different sites.

for more info on the unit `baudi` please read here: 
https://www.nssmag.com/en/lifestyle/32112/fantasanremo-origins-papalina-baudi

SESSION INFO:
')

txt<-paste0(txt,'\n', paste0(capture.output(sessionInfo()), collapse='\n'))


shaRe::export_dictionary(description=txt, varTable= mydata_dict, path='R_output/dataset/dummy_data-dictionary.txt')

write_csv(my_data,file='R_output/dataset/dummy_data.csv')