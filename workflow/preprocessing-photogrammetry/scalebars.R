# ===============================================================================
# Name   	: Scalebars 
# Author 	: Filippo Ferrario	
# Date   	:  [dd-mm-yyyy] v1:25-10-2022; v2 31-08-2026
# Version	: v2
# URL		: 
# Aim    	: adjusting scalebars' depth and prep file for metashape
# ===============================================================================




# ======================
# load data
# ======================

sb_tgt<-read.csv('./data/photogrammetry/scalebars_in_situ_layout.csv', skip=18)

sb_len<-read.csv('./data/photogrammetry/scalebars_length.csv')


# tides in QC
# -------------
tideBIC_07<-read.csv('./data/tide_tables/predictions_03000_Île Bicquette_2022-07-28.csv')
tideBIC_08<-read.csv('./data/tide_tables/predictions_03000_Île Bicquette_2022-08-03.csv')
tideIAL_10<-read.csv('./data/tide_tables/predictions_03140_Île aux Lièvres_2022-10-05.csv')
tideIAL_07<-read.csv('./data/tide_tables/predictions_03140_Île aux Lièvres_2022-07-05.csv')


# tides in British Columbia
# --------------------------
tidePRT<-read.csv('./data/tide_tables/predictions_09350_Casey Cove_2023-05-23-tugwell.csv')
tideQDR<-read.csv('./data/tide_tables/predictions_08038_Whaletown_2023-05-31-marina.csv')


# ==============
# Process data
# ==============

# prepare data for tide levels in BIC avoiding replicated dates
# -----------------------------------------------------------------
str(tideBIC_07)
tideBIC_07$Date<-strptime(tideBIC_07$Date, format='%Y-%m-%d %H:%M')
tideBIC_08$Date<-strptime(tideBIC_08$Date, format='%Y-%m-%d %H:%M')

str(tideBIC_07)
str(tideBIC_08)

summary(tideBIC_07)
summary(tideBIC_08)

tideBIC<- tideBIC_07 %>%
			filter(Date<min(tideBIC_08$Date)) %>% 
			bind_rows(tideBIC_08) # bind_rows convert from POSIXlt to POSIXct silently!

sum(duplicated(tideBIC$Date))

str(tideBIC)
head(tideBIC)

# prepare data for Ile-aux-lievres
# ------------------------------------------
tideIAL<-bind_rows(tideIAL_07,tideIAL_10)

sum(duplicated(tideIAL$Date))

str(tideIAL)
head(tideIAL)


# Check tide table for BC
# ---------------------------------
str(tidePRT)
head(tidePRT)

str(tideQDR)
head(tideQDR)


# adjust depths of scalebars
# ------------------------------


head(sb_tgt)
sb_tgt<-select(sb_tgt, site:note)
summary(sb_tgt)
str(sb_tgt)
# Avoid presence of NA in depth by assigning to targets with missing depth the value of the other terget in the scalebar

sb_tgt_full<-sb_tgt %>% 
	mutate(unique_depl=paste(site,date,barID)) %>%
	split(f=.$unique_depl) %>%
	lapply(function(x) { 
		# browser()
		has_val<-which(!is.na(x$depth_m))
		if(length(has_val)==1) {	
			x[-has_val,]$depth_m<- x[has_val,]$depth_m 
			x[-has_val,]$time<- x[has_val,]$time }
		x
		}) %>%
	bind_rows()	 %>% 
	mutate(DateTime=paste(date,time)) %>%
	mutate(DateTime=strptime(DateTime, format='%m/%d/%Y %H:%M'))

str(sb_tgt_full)

head(sb_tgt)
sb_tgt_full

# BIC
# ```````````
str(tideBIC)
bic<-sb_tgt_full %>%	
		filter(grepl(site, pattern='BIC' )) %>%
 		mutate(depth_adj=FielderInTheLab::depth_adjust(tidetable_df=tideBIC,
 							observed_df=., 
 							time_tide_col='Date', 
 							lev_tide_col='predictions.m.', 
 							time_obs_col='DateTime',
 							depth_obs_col='depth_m', 
 							ts_tide_format='%Y-%m-%d %H:%M:%S', 
 							ts_obs_format='%Y-%m-%d %H:%M:%S')
 				)
bic

# IAL
# ```````````
str(tideIAL)
str(sb_tgt_full)

ial<-sb_tgt_full %>%
 		filter(grepl(site, pattern='IAL' )) %>% 
 		mutate(depth_adj=FielderInTheLab::depth_adjust(tidetable_df=tideIAL,
 							observed_df=., 
 							time_tide_col='Date', 
 							lev_tide_col='predictions.m.', 
 							time_obs_col='DateTime',
 							depth_obs_col='depth_m', 
 							ts_tide_format='%Y-%m-%d %H:%M', 
 							ts_obs_format='%Y-%m-%d %H:%M:%S')
 				)
ial



# PRT
# ```````````
str(tidePRT)
str(sb_tgt_full)

prt<-sb_tgt_full %>%
 		filter(grepl(site, pattern='TUG' )) %>% 
 		mutate(depth_adj=FielderInTheLab::depth_adjust(tidetable_df=tidePRT,
 							observed_df=., 
 							time_tide_col='Date', 
 							lev_tide_col='predictions..m.', 
 							time_obs_col='DateTime',
 							depth_obs_col='depth_m', 
 							ts_tide_format='%Y-%m-%d %H:%M', 
 							ts_obs_format='%Y-%m-%d %H:%M:%S')
 				)
prt

# QDR
# ```````````
str(tideQDR)
str(sb_tgt_full)

qdr<-sb_tgt_full %>%
 		filter(grepl(site, pattern='MARINA' )) %>% 
 		mutate(depth_adj=FielderInTheLab::depth_adjust(tidetable_df=tideQDR,
 							observed_df=., 
 							time_tide_col='Date', 
 							lev_tide_col='predictions..m.', 
 							time_obs_col='DateTime',
 							depth_obs_col='depth_m', 
 							ts_tide_format='%Y-%m-%d %H:%M', 
 							ts_obs_format='%Y-%m-%d %H:%M:%S')
 				)
qdr

# combine all

sb<- bind_rows(bic,ial,prt,qdr) %>%
		split(f=.$unique_depl) %>%
		lapply(function(x){
			# browser()
			x %>%
			mutate(marker=c('A','B')) %>%
			pivot_wider(names_from=marker, values_from=c(markerID,depth_m,depth_adj, note)) %>%
			mutate(bar_depth=mean(c(.$depth_adj_A,.$depth_adj_B)) )
			}) %>%
		bind_rows() %>%
		mutate(diff_dept=abs(depth_adj_A-depth_adj_B)) %>%
		left_join(sb_len, by=c('barID'='bar')) %>%
		mutate(length_m=length_cm/100) %>%
		select(-unique_depl) %>%
		rename(bar_id='barID') %>%
		select(site,bar_id,pos,transect,length_m,bar_layout,markerID_A, markerID_B,depth_adj_A, depth_adj_B, bar_depth, diff_dept, DateTime)


sb



head(sb)

# ==============================================
# SAVE DATA
# ==============================================

script_ver<-'scalebars.R'


sb_dict<-shaRe::initiate_dictionary(sb)
sb_dict

sb_dict[ sb_dict$field_name == 'site',2:4]<-c('Name of the site where the bar was used','character','N/A')
sb_dict[ sb_dict$field_name == 'bar_id',2:4]<-c('unique id of the scalebar','character','N/A')
sb_dict[ sb_dict$field_name == 'pos',2:4]<-c('Position in the grid. Format T<num1>_<num2><side> where <num1> is the distance from the 0 along the horizontal line identifying a transect, <num2> is the distance along the transect where the bar was placed, <side> indicate if the bar was left (LX) or right (RX) for an observer having the horizontal line at the back and the look towards the end of the transects.','character','N/A')
sb_dict[ sb_dict$field_name == 'transect',2:4]<-c('transect number: the distance from the 0 along the horizontal line ','numeric','N/A')
sb_dict[ sb_dict$field_name == 'markerID_A',2:4]<-c('Identifier of target A','numeric','N/A')
sb_dict[ sb_dict$field_name == 'markerID_B',2:4]<-c('Identifier of target B','numeric','N/A')
sb_dict[ sb_dict$field_name == 'bar_layout',2:4]<-c('orientation of the bar relative to the transect: "main" means paraller to the main line, "transect" means parallel to the transect line ','character','N/A')
sb_dict[ sb_dict$field_name == 'depth_adjusted_A',2:4]<-c('Depth of the target A adjusted for the tide','numeric','meters')
sb_dict[ sb_dict$field_name == 'depth_adjusted_B',2:4]<-c('Depth of the target B adjusted for the tide','numeric','meters')
sb_dict[ sb_dict$field_name == 'bar_depth',2:4]<-c('Mean depth of the bar adjusted for the tide','numeric','meters')
sb_dict[ sb_dict$field_name == 'lenght_m',2:4]<-c('length of the scalebar from center to center of the targets','numeric','meters')
sb_dict[ sb_dict$field_name == 'DateTime',2:4]<-c('Date of when the scalebar was used and time at which the depth was taken. format %m/%d/%Y %H:%M','character','N/A')
sb_dict[ sb_dict$field_name == 'note',2:4]<-c('notes on the scalebar','character','N/A')
sb_dict[ sb_dict$field_name == 'fiff_depth',2:4]<-c('difference in depth between markers','numeric','meters')

                 

txt<-paste0('
R SCRIPT: ',script_ver,' on ',as.Date(Sys.time()),' with ', R.version.string,',

Object type: csv dataframe

DESCRIPTION:
Data on deployment of the scalebars used for photogrammetry.
Depth (corrected for the tide) and position in the grid are reported. 

SESSION INFO:
')

txt<-paste0(txt,'\n', paste0(capture.output(sessionInfo()), collapse='\n'))


shaRe::export_dictionary(description=txt, varTable= sb_dict, formatTable='long', path='./output/datasets/photogrammetry/scalebars-dictionary.txt')

write.table(sb, file='./output/datasets/photogrammetry/scalebars.csv', quote=F,sep=',',dec='.',row.names=F)




