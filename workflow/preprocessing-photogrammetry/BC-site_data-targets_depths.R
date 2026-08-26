# ===============================================================================
# Name      : Target adjusted depth - British Columbia 2023
# Author    : Filippo Ferrario
# Date      : [dd-mm-yyyy] v1 30-06-2023; v2 25-08-2026 
# Version   : 2.0
# URL       : 
# Aim       :   1. programmatically correct the depth of targets for the tidal level using tables from tides.gc.ca.
#               
#               Version 1 was originally run on the S:\ driver on the DFO network. Files on that drovers have been moved and renamed at some point.
#               Version 2 is the copy of the script on the S:\ and it has been adapted to match the file structure on the Github repo (and locally on Filippo Ferrario's Laptop)
#              
# ===============================================================================



# ======================
# load data
# ======================

# # Receivers metadata
# # --------------------
# gps<-read.csv2("data/Deployment_Telemetry_HR2_BC2023.csv")
# rec_offset<-read.csv("data/Receivers_offsets_heading.csv", skip=13)
# head(rec_offset)

# # Targets metadata
# # -----------------

# deployment data 
depl<-read.csv('data/photogrammetry/targets_deployment.csv', skip=14)
head(depl)

# # center offsets
# tgtxl<-'./data/target_offsets.xlsx'
# readxl::excel_sheets(tgtxl)
# offs<-readxl::read_xlsx(tgtxl, sheet = '2023', range = NULL, col_names = TRUE)


# Tide table data
# ------------------
tide_Tug<-   read.csv('data/tide_tables/predictions_09350_Casey Cove_2023-05-23-tugwell.csv')
tide_Marina<-read.csv('data/tide_tables/predictions_08038_Whaletown_2023-05-31-marina.csv')


# =========
# Process data
# ==============

# # Preprocess 'gps' dataset
# # ==========================

# head(gps)
# names(gps)
# str(gps)

# # modify names

# new_names_gps<- names(gps) %>%
#                 gsub(pattern=' +|\\.+', replacement='_') %>%
#                 gsub(pattern='\\(|\\)', replacement='') %>%
#                 gsub(pattern='-|:',replacement='_') %>%
#                 tolower()

# new_names_gps
# names(gps)<-new_names_gps
# str(gps)


# gps$deploy_date_time_yyyy_mm_ddthh_mm_ss_utm_<-strptime(gps$deploy_date_time_yyyy_mm_ddthh_mm_ss_utm_, format='%Y-%m-%d %H:%M')
# gps$deploy_lat_geode<-as.numeric(gps$deploy_lat_geode)
# gps$deploy_long_geode<-as.numeric(gps$deploy_long_geode)


# # Explore date-time deployments of receivers
# # Time is in UTC
# gps %>%
# group_by(site_no) %>%
# summarise(range(deploy_date_time_yyyy_mm_ddthh_mm_ss_utm_))


# gps<- as.data.frame(gps)
# head(gps)


# Preprocess 'target deployment' dataset
# =======================================
head(depl)
# Explore date-time deployments of targets
# Time is in EDT 
depl %>%
group_by(site) %>%
summarise(range(date))

# Prepare deployemnt data to have a DateTime column.
depl$DateTime<-paste(depl$date,depl$time) %>%
                strptime( format='%m/%d/%Y %H:%M') 
depl<-filter(depl, DateTime> as.Date('01/01/2023', format='%m/%d/%Y') )

str(depl)

# Preprocess tide tables
# ========================

# Tide in Tugwell (Prince Rupert)
# ------------------
str(tide_Tug)
tide_Tug$Date<-strptime(tide_Tug$Date, format='%Y-%m-%d %H:%M')

tide_Tug
# check
sum(duplicated(tide_Tug$Date))
str(tide_Tug)


# Tide in Marina (Quadra)
# ------------------
str(tide_Marina)
tide_Marina$Date<-strptime(tide_Marina$Date, format='%Y-%m-%d %H:%M')

tide_Marina
# check
sum(duplicated(tide_Marina$Date))
str(tide_Marina)



# Adjust tides 
# =====================

# Deployed targets
# ---------------------

depl<-split(depl, f=depl$site) %>%
    lapply(function(x){ #browser()
        if (grepl(unique(x$site), pattern='TUG')){ tide_table<-tide_Tug }else {tide_table<-tide_Marina}
        x$depth_adjusted<-FielderInTheLab::depth_adjust(tidetable_df=tide_table,observed_df=x, time_tide_col='Date', lev_tide_col='predictions..m.', time_obs_col='DateTime',depth_obs_col='depth_m', ts_tide_format='%Y-%m-%d %H:%M:%S', ts_obs_format='%Y-%m-%d %H:%M') 
        x
        }) %>%
bind_rows(.)


head(depl)



# # Process targets coordinates 
# # ============================

# head(depl)
# head(offs)
# head(gps)
# names(gps)
# str(gps)

# head(rec_offset)



# # Estimate missing heading of receiver 60-60 in tugwell-2 (orientation estimated visually from images) 
# # br<-geosphere::bearing( p1=as.matrix(gps[gps$site_no=='Tugwell-2' & gps$location=='L60-0m',c('deploy_long_geode','deploy_lat_geode')]), 
# #                     p2=as.matrix(gps[gps$site_no=='Tugwell-2' & gps$location=='L60-60m',c('deploy_long_geode','deploy_lat_geode')]))
# # br+70




# # simplyfy 'offs' names 
# names(offs)<-tolower(names(offs)) %>% gsub(.,pattern=' ', replace='_')
# head(offs)


# # Convert coordinates of receivers from WGS84 to UTM19N
# utm<-gps %>%
#      # combine final coordinates and errors from differen missions in a common variable
#      # mutate(deploy_lat=ifelse(is.na(deploy_lat_2),deploy_lat_1,deploy_lat_2),
#      #        deploy_long=ifelse(is.na(deploy_long_2),deploy_long_1,deploy_long_2),
#      #        error_depl_m=ifelse(is.na(error_m_2),error_m_1,error_m_2)) %>%
#     # convert CRS
#     st_as_sf( coords=c('deploy_long_gps','deploy_lat_gps'), crs=4326) %>%
#     st_transform(crs=32619) #%>% 
#     # format names to simplify dataset join
#     # separate(station_no, into=c('position', 'xy_tag'), sep=',')

# head(as.data.frame(utm))

# # Visualize to check 
# par(mfrow=c(2,2))
# sites<-unique(utm$site_no)
# for (i in seq_along(sites) ){
#    pts<- utm %>% 
#         filter(grepl(site_no, pattern=sites[i]))
#     plot(st_geometry(pts), main=paste0(sites[i],' - GPS'))
#     text(st_coordinates(st_geometry(pts))[,'X'],st_coordinates(st_geometry(pts))[,'Y'],pts$station_no)
# }

# 

# Format dataset 
# ============================
names(depl)<-tolower(names(depl))
# create a tag to be matched with labels used in gpsxl
depl$xy_tag<-paste0('L',depl$receiver_x,'-',depl$receiver_y,'m')

depl<-rename(depl, target_depth_adj=depth_adjusted, xy_grid=xy_tag) %>%
        select(-time,-date)
depl<-select(depl, site:depth_m,target_depth_adj,datetime,receiver_id,xy_grid,note)
head(depl)


# ==============================================
# SAVE DATA
# ==============================================

# daytag<-as.Date(Sys.time())
script_ver<-'BC-site_data-targets_depths.R'


depl_dict<-shaRe::initiate_dictionary(depl)
depl_dict

depl_dict[ depl_dict$field_name == 'site',2:4]<-c('Name of the site','character','N/A')
depl_dict[ depl_dict$field_name == 'position',2:4]<-c('numeric position of the target as noted by the divers on the map of the site on the datasheet. Refer to picture of the datasheet for verification','numeric','N/A')
depl_dict[ depl_dict$field_name == 'target_id',2:4]<-c('unique identifier of the photogrammetry target','numeric','N/A')
depl_dict[ depl_dict$field_name == 'receiver_x',2:4]<-c('relative x-axix coordinate in the grid: the distance from the 0 along the horizontal line','numeric','N/A')
depl_dict[ depl_dict$field_name == 'receiver_y',2:4]<-c('relative y-axix coordinate in the grid: the distance from the 0 along a transect line (i.e., distance from the horizontal line)','numeric','N/A')
depl_dict[ depl_dict$field_name == 'heading',2:4]<-c('heading of the metal braket read on the compass in the field','numeric','degree')
depl_dict[ depl_dict$field_name == 'direction',2:4]<-c('direction in which the reading of the heading was taken relative to the receiver post. Values are "post" = target between diver and post; "out" = post between diver and target','character','N/A')
depl_dict[ depl_dict$field_name == 'depth_m',2:4]<-c('observd depth of the targer in meters, not corrected for tide.','numeric','meters')
depl_dict[ depl_dict$field_name == 'target_depth_adj',2:4]<-c('Depth of the target adjusted for the tide','numeric','meters')
depl_dict[ depl_dict$field_name == 'datetime',2:4]<-c('Date and time of the measurements. Time is in PDT (UTC-7)','character','yyyy-mm-dd hh:mm:ss')
depl_dict[ depl_dict$field_name == 'receiver_id',2:4]<-c('unique identifier of the acoustic receiver or reference tag','character','N/A')
depl_dict[ depl_dict$field_name == 'xy_grid',2:4]<-c('realtive coordinate of the porition in the grid. Format is "L<num1>-<num2>m" where <num1> is the distance from the 0 along the horizontal line (i.e., the grid x-axis), and the <num2> is the distance from the 0 along a transect line (i.e., the grid y-axis, the distance from horizontal line)','character','N/A')
depl_dict[ depl_dict$field_name == 'note',2:4]<-c('notes on the data point','character','N/A')

txt<-paste0('
R SCRIPT: ',script_ver,' on ',as.Date(Sys.time()),' with ', R.version.string,',


Object type: csv dataframe

DESCRIPTION:

Dataset with depth of the targets for photogrammetry, corrected for the tide level.
The targets were placed on the Acoustic receiver post, attached on a metal braket.
The depth of the bottom and that of the instrument was not recorded on site.

IMPORTANT NOTEs FOR HOUSEKEEPING
- This dataset has been created from the common workflow on the IML remote driver S:

')

shaRe::export_dictionary(description=txt, varTable= depl_dict, formatTable='long', path='output/datasets/photogrammetry/BC-targets_depth-dictionary.txt')

write.table(depl, file='output/datasets/photogrammetry/BC-targets_depth.csv', quote=F,sep=',',dec='.',row.names=F)

