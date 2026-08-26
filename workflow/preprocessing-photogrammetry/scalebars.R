# ===============================================================================
# Name   	: Scalebars 
# Author 	: Filippo Ferrario	
# Date   	: 25-10-2022 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: adjusting scalebars' depth and prep file for metashape
# ===============================================================================




# ======================
# load data
# ======================

sb_tgt<-read.csv('./data/photogrammetry/scalebars_in_situ_layout.csv', skip=18)

sb_len<-read.csv('./data/photogrammetry/scalebars_length.csv')



tideBIC_07<-read.csv('./data/tide_tables/predictions_03000_Île Bicquette_2022-07-28.csv')
tideBIC_08<-read.csv('./data/tide_tables/predictions_03000_Île Bicquette_2022-08-03.csv')
tideIAL_10<-read.csv('./data/tide_tables/predictions_03140_Île aux Lièvres_2022-10-05.csv')
tideIAL_07<-read.csv('./data/tide_tables/predictions_03140_Île aux Lièvres_2022-07-05.csv')


# ==============
# Process data
# ==============

# prepare data for tide levels in BIC avoiding replicated dates
str(tideBIC_07)
tideBIC_07$Date<-strptime(tideBIC_07$Date, format='%Y-%m-%d %H:%M')
tideBIC_08$Date<-strptime(tideBIC_08$Date, format='%Y-%m-%d %H:%M')

summary(tideBIC_07)
summary(tideBIC_08)

tideBIC<-tideBIC_07 %>%
			filter(Date<min(tideBIC_08$Date)) %>%
			bind_rows(tideBIC_08)

sum(duplicated(tideBIC$Date))

str(tideBIC)

tideIAL<-bind_rows(tideIAL_07,tideIAL_10)



head(sb_tgt)
head(sb_len)

sb<-sb_tgt %>%
	left_join(sb_len, by=c('barID'='bar')) %>%
	filter(!duplicated(paste0(site,barID,date))) %>%
	mutate(lenght_m=length_cm/100, DateTime=paste(date,time)) 

sb$depth_adjusted[grepl(sb$site, pattern='IAL')]<- FielderInTheLab::depth_adjust(tidetable_df=tideIAL,observed_df=sb[grepl(sb$site, pattern='IAL'),], time_tide_col='Date', lev_tide_col='predictions.m.', time_obs_col='DateTime',depth_obs_col='depth_m', ts_tide_format='%Y-%m-%d %H:%M', ts_obs_format='%m/%d/%Y %H:%M')
sb$depth_adjusted[grepl(sb$site, pattern='BIC')]<- FielderInTheLab::depth_adjust(tidetable_df=tideBIC,observed_df=sb[grepl(sb$site, pattern='BIC'),], time_tide_col='Date', lev_tide_col='predictions.m.', time_obs_col='DateTime',depth_obs_col='depth_m', ts_tide_format='%Y-%m-%d %H:%M:%S', ts_obs_format='%m/%d/%Y %H:%M')


sb<-sb %>% 
	select(site, barID,pos,transect,bar_layout,depth_adjusted,lenght_m,DateTime,note,-markerID,-(depth_m:date),-length_cm) %>%
	rename(bar_id='barID')

head(sb)

# ==============================================
# SAVE DATA
# ==============================================

daytag<-as.Date(Sys.time())
script_ver<-'scalebars.R'


sb_dict<-shaRe::initiate_dictionary(sb)
sb_dict

sb_dict[ sb_dict$field_name == 'site',2:4]<-c('Name of the site where the bar was used','character','N/A')
sb_dict[ sb_dict$field_name == 'bar_id',2:4]<-c('unique id of the scalebar','character','N/A')
sb_dict[ sb_dict$field_name == 'pos',2:4]<-c('Position in the grid. Format T<num1>_<num2><side> where <num1> is the distance from the 0 along the horizontal line identifying a transect, <num2> is the distance along the transect where the bar was placed, <side> indicate if the bar was left (LX) or right (RX) for an observer having the horizontal line at the back and the look towards the end of the transects.','character','N/A')
sb_dict[ sb_dict$field_name == 'transect',2:4]<-c('transect number: the distance from the 0 along the horizontal line ','numeric','N/A')
sb_dict[ sb_dict$field_name == 'depth_adjusted',2:4]<-c('Depth of the target adjusted for the tide','numeric','meters')
sb_dict[ sb_dict$field_name == 'lenght_m',2:4]<-c('length of the scalebar from center to center of the targets','numeric','meters')
sb_dict[ sb_dict$field_name == 'DateTime',2:4]<-c('Date of when the scalebar was used and time at which the depth was taken. format %m/%d/%Y %H:%M','character','N/A')
sb_dict[ sb_dict$field_name == 'note',2:4]<-c('notes on the scalebar','character','N/A')
sb_dict[ sb_dict$field_name == 'bar_layout',2:4]<-c('orientation of the bar : "main" if the scalebar is parallel to the horizontal line, "transect" if parallel to the transect.','character','N/A')



txt<-paste0('
R SCRIPT: ',script_ver,' on ',daytag,'

Object type: csv dataframe

DESCRIPTION:
Data on deployment of the scalebars used for photogrammetry.
Depth (corrected for the tide) and position in the grid are reported. 


')

shaRe::export_dictionary(description=txt, varTable= sb_dict, path='./output/datasets/photogrammetry/scalebars-dictionary.txt')

write.table(sb, file='./output/datasets/photogrammetry/scalebars.csv', quote=F,sep=',',dec='.',row.names=F)





