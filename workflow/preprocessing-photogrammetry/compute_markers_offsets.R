# ===============================================================================
# Name   	: Offset calculation for Markers
# Author 	: Filippo Ferrario
# Date   	: [dd-mm-yyyy] v1 01-09-2026
# Version	: 1
# URL		: 
# Aim    	: Find the coordinates to be associated to the markers considering the offset relative to the receivers.
#				1. combine meta and vps to have station names associated to their relative position
# 				2. split by year and combine the coordinates (step 1) to the deployemnt
# 				3. merge with the offsets info for that year
# 				4. calclulate new offset
# 				5. split by site and correct for tide
# 				6. format for metashape and export.

# ===============================================================================



# =============================
# load data
# =============================


# Receivers metadata
# --------------------

meta_qc<-read_delim('data/metadata_receivers_QC2022.csv', delim=';')
meta_bc<-read_delim('data/metadata_receivers_BC2023.csv',delim=';')

# Quebec VPS coordinates
vps_pil<-read_delim('data/raw_data_downloads_bic_2022/vps_results_Bic_2022/anse_des_pilotes/results/stations_corrected2026.csv',delim=',')
vps_bal<-read_delim('data/raw_data_downloads_bic_2022/vps_results_Bic_2022/La_Baleine/results/stations.csv',delim=',')
vps_sw<-read_delim('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/southwest/results/stations.csv',delim=',')
vps_ne<-read_delim('data/raw_data_downloads_cacouna_2022/vps_results_cacouna_2022/northeast/results/stations.csv',delim=',')

# British Columbia VPS coordinates
vps_tug1<-read_delim('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell1/results/stations.csv',delim=',')
vps_tug2<-read_delim('data/raw_data_downloads_prince_rupert_2023/vps_results_prince_rupert_2023/tugwell2/results/stations.csv',delim=',')
vps_mar1<-read_delim('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina1/results/stations.csv',delim=',')
vps_mar2<-read_delim('data/raw_data_downloads_quadra_2023/vps_results_quadra_2023/marina2/results/stations.csv',delim=',')


# Targets metadata
# -----------------
# center offsets
tgtxl<-'data/photogrammetry/target_offsets.xlsx'
readxl::excel_sheets(tgtxl)
offs22<-readxl::read_xlsx(tgtxl, sheet = '2022', range = NULL, col_names = TRUE)
offs23<-readxl::read_xlsx(tgtxl, sheet = '2023', range = NULL, col_names = TRUE)


# deployment data 
depl<-read_csv('data/photogrammetry/targets_deployment.csv', skip=14)

# dataset only to be used for depth adjusted
bcdepts<-read_csv('output/datasets/photogrammetry/BC-targets_depth.csv')
qcdepts<-read_csv('output/datasets/photogrammetry/QC-targets_receivers_coordinates_depth.csv')

# ==============
# Process data
# ==============

# check data
# ------------------
meta_qc
vps_pil
vps_bal
vps_sw
vps_ne

meta_bc
vps_tug1
vps_tug2
vps_mar1
vps_mar2

offs22
offs23
depl

# 1. Combine meta and vps to have station names associated to their relative position
# --------------------------------------------------------------------------------------

# Quebec
pos_qc<-meta_qc %>%
		rename_with(tolower) %>%
		select(site_2, station_name, station_pos) %>%
		mutate(site_3= ifelse(site_2=='Pilotes', 'BIC-PIL', 
								ifelse(site_2=='Baleine','BIC-BAL',
									ifelse(site_2=='NE', 'IAL-NE', 'IAL-SW'))))

vps_pil <- mutate(vps_pil, site_3='BIC-PIL')
vps_bal <- mutate(vps_bal, site_3='BIC-BAL')
vps_sw <- mutate(vps_sw, site_3='IAL-SW')
vps_ne <- mutate(vps_ne, site_3='IAL-NE')

crd_qc<- bind_rows(vps_pil,vps_bal,vps_sw,vps_ne) %>%
			rename_with(tolower) %>%
			rename(station_name='stationname') %>%
			left_join(pos_qc, by=c('site_3','station_name'))
			
as.data.frame(crd_qc)

# British Columbia
pos_bc<-meta_bc %>%
		rename_with(tolower) %>%
		select(site_no, station_no, station_name, station_pos)%>%
		rename(site_2='site_no') %>%
		mutate(site_3= site_2,
					site_3=ifelse(grepl(site_3,pattern='Tugwell'), 
							gsub(site_3,pattern='Tugwell',replacement='TUG'),
							gsub(site_3,pattern='Marina',replacement='MARINA') ))
as.data.frame(pos_bc)

vps_tug1 <- mutate(vps_tug1, site_3='TUG-1')
vps_tug2 <- mutate(vps_tug2, site_3='TUG-2')
vps_mar1 <- mutate(vps_mar1, site_3='MARINA-1')
vps_mar2 <- mutate(vps_mar2, site_3='MARINA-2')


crd_bc<- bind_rows(vps_tug1, vps_tug2, vps_mar1, vps_mar2) %>%
			rename_with(tolower) %>%
			rename(station_no='stationname') %>%
			left_join(pos_bc, by=c('site_3','station_no'))

as.data.frame(crd_bc)


# 2. split by year and combine the coordinates (step 1) to the deployemnt
# 3. merge with the offsets info for that year
# 4. calclulate new offset
# -------------------------------------------------------------------------------
as.data.frame(depl)

deplo<- depl %>% 
		mutate(datetime=paste(date,time), station_pos=paste0(receiver_X,'_',receiver_Y)) %>%
		mutate(datetime=strptime(datetime, format='%m/%d/%Y %H:%M:%S'))
deplo

# 2022 - Quebec
# ``````````````````

lat_lon_offset<-function(heading, L) {
					# heading: is the heading of the center of the marker relative to the north. MUST BE A SINGLE NUMBER
					# L: is the distance of the  of the center of the marker from the post (i.e. the hypotenuse of the right trianlge formed with the axes).
					h<-heading*pi/180 # heading in radiants
					# first quadrant
					if (h<=(pi/2)) {
						int<-h # int stands for internal angle (i.e. the angle next to the origin of the axes and internal to the right triangle created by the projection of the marker on the axes so that, moving clockwise, the internal angle is on the left of the segment connection the origin and the marker(looking from the origin towards the marker))
						lon<-L*sin(int)
						lat<-L*cos(int)
					}
					# second quadrant
					if (h>(pi/2) & h<=pi) {
						int<-h-(pi/2) 
						lon<-L*cos(int)
						lat<-L*sin(int)
					}
					# third quadrant
					if (h>pi & h<=(pi*3/2)) {
						int<-h-pi 
						lon<-L*sin(int)
						lat<-L*cos(int)
					}
					# fourth quadrant
					if (h>(pi*3/2)) {
						int<-h-(pi*3/2) 
						lon<-L*cos(int)
						lat<-L*sin(int)
					}
				res<-list(lon=lon,lat=lat)
				return(res)

				}




crd_qc
tgt_qc<- deplo %>%
		 rename(site_3='site') %>%
		 filter(grepl(date, pattern='2022')) %>%
		 left_join(crd_qc, by=c('site_3', 'station_pos')) %>%
		 left_join(offs22, by='target_ID') %>%
		 filter(!is.na(latitude)) %>%
		 st_as_sf(coords=c('longitude','latitude'), crs=4326, remove=FALSE) %>%
		 st_transform(crs=32619) %>%
		 rename(dx='dx_mm', dy='dy_mm') %>%
 		 mutate(heading_adj=ifelse(direction=='post', 
 		 							ifelse( (heading+180)>=360, 
 		 										(heading+180)-360,
 		 										(heading+180)
 		 									), 
 		 							heading
 		 							),
		 		dx=dx/1000, dy=dy/1000, L=sqrt(dx^2+dy^2), 
		 		alpha_rad=asin(abs(dy)/L), alpha_deg=alpha_rad*180/pi,
		 		heading_mark_center=ifelse(dy<0,
		 									heading_adj-alpha_deg,
		 									heading_adj+alpha_deg
		 									),
		 		off_lat_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_mark_center,L=L, SIMPLIFY=T)['lat',]),
				off_lon_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_mark_center,L=L, SIMPLIFY=T)['lon',]),
		 		lat_utm=st_coordinates(.)[,'Y'],
		 		lon_utm=st_coordinates(.)[,'X'],
		 		lat_target=lat_utm+off_lat_mark,
		 		lon_target=lon_utm+off_lon_mark
 				) 

as.data.frame(tgt_qc)

# lat_lon_offset(heading= 13.17591 ,L=0.1110720)

# 2023 - British Columbia
# `````````````````````````
# in the file from innovasea with the calibrated coordinates there are 2 lines for Receivers 8D in marina-2
# with 2 different deployments dates. This seems to have been generated by Innovasea since the Spec file we sent them only
# has one position for the 8D receiver.  
# since we filmed in june I will keep that point.

crd_bc_clean<-crd_bc %>%
				filter(!(site_2=='Marina-2' & station_no=='8D' & grepl(start, pattern='2023-10') )) 

# crs used for tug in image georef=32609
# crs used for Marina in image georef=32609
# crs that should be used for marina = 32610 (https://epsg.io/32610)


tgt_bc<- deplo %>%
		 filter(grepl(date, pattern='2023')) %>%
		 rename(site_3='site') %>%
		 left_join(crd_bc_clean, by=c('site_3', 'station_pos')) %>%
		 left_join(offs23, by='target_ID') %>%
		 filter(!is.na(latitude)) %>%
		 st_as_sf(coords=c('longitude','latitude'), crs=4326, remove=FALSE) 

tgt_prt<- tgt_bc %>%
			filter(grepl(site_3, patter='TUG')) %>%
			st_transform(crs=32609) %>% 
			mutate(heading_adj=ifelse(direction=='post', # in 2023 the marker was setup to have the center allined with the braket so that the heading of the bracket is also the heading of the marker.
 		 							ifelse( (heading+180)>=360, 
 		 										(heading+180)-360,
 		 										(heading+180)
 		 									), 
 		 							heading
 		 							),
				    L=d_mm/1000,
				  	off_lat_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_adj,L=L, SIMPLIFY=T)['lat',]),
					off_lon_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_adj,L=L, SIMPLIFY=T)['lon',]),
		 		    lat_utm=st_coordinates(.)[,'Y'],
			 		lon_utm=st_coordinates(.)[,'X'],
			 		lat_target=lat_utm+off_lat_mark,
			 		lon_target=lon_utm+off_lon_mark)
 				
		 		


tgt_qdr<- tgt_bc %>%
			filter(grepl(site_3, patter='MAR')) %>%
			st_transform(crs=32610) %>% 
			# check the math!
			mutate(heading_adj=ifelse(direction=='post',  # in 2023 the marker was setup to have the center allined with the braket so that the heading of the bracket is also the heading of the marker.
 		 							ifelse( (heading+180)>=360, 
 		 										(heading+180)-360,
 		 										(heading+180)
 		 									), 
 		 							heading
 		 							),
				    L=d_mm/1000,
				  	off_lat_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_adj,L=L, SIMPLIFY=T)['lat',]),
					off_lon_mark= as.numeric(mapply(FUN= lat_lon_offset,heading=heading_adj,L=L, SIMPLIFY=T)['lon',]),
		 		    lat_utm=st_coordinates(.)[,'Y'],
			 		lon_utm=st_coordinates(.)[,'X'],
			 		lat_target=lat_utm+off_lat_mark,
			 		lon_target=lon_utm+off_lon_mark)

# tgt_qdr %>% select(target_ID,lat_utm,lat_target, lon_utm, lon_target, contains('off_'), heading_adj, heading) %>% as.data.frame()

# 5. add depth corrected for tide
# ---------------------------------
# Quebec
# ```````````````
tgt_qc
qcdepts
# View(qcdepts)

tgt_qc_dep<-qcdepts %>%
	select(site,target_id,target_depth_adj) %>%
	filter(!duplicated(target_id)) %>%
	left_join(tgt_qc,., by=c('site_3'='site','target_ID'='target_id' ))

# Prince Rupert
# ``````````````````
View(bcdepts)

tgt_prt_dep<-bcdepts %>%
	filter(site %in% c('TUG-1','TUG-2')) %>%
	select(site,target_id,target_depth_adj) %>%
	left_join(tgt_prt,., by=c('site_3'='site','target_ID'='target_id' ))
View(tgt_prt_dep)

# Quadra
# ``````````````````
bcdepts
tgt_qdr

bcdepts_dep<-bcdepts %>% 
	filter(site %in% c('MARINA-1','MARINA-2')) %>%
	mutate(datetime_cr = as.character(datetime)) %>%
	select(site,target_id,target_depth_adj, datetime_cr,note) 

tgt_qdr_dep<- tgt_qdr	%>%
	mutate(datetime_cr = as.character(datetime)) %>%
	left_join(.,bcdepts_dep, by=c('site_3'='site','target_ID'='target_id', 'datetime_cr' ))

tgt_qdr_dep
View(tgt_qdr_dep)

# 6. format for metashape.
# ---------------------------------

# Quebec
# ```````````````
tgt_qc_dep
names(tgt_qc_dep)

# BIC-PIL

# check for duplicates

dup_id<-tgt_qc_dep %>%
		filter(site_3=='BIC-PIL' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_qc_dep %>%
		filter(site_3=='BIC-PIL', target_ID %in% dup_id	)


pil<-tgt_qc_dep %>%
	filter(site_3=='BIC-PIL', !grepl(station_name, pattern='Ref')) %>%
	filter(grepl(start, pattern='07-28')) %>%
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude)

pil[duplicated(sf::st_coordinates(pil)),]

pil<-pil %>%
	as.data.frame() %>%
	select(-geometry)
pil


tgt_qc_dep %>%
	filter(site_3=='BIC-PIL', !grepl(station_name, pattern='Ref')) %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	st_as_sf(coords=c('lon_utm','lat_utm'), crs=32619) %>%
	st_geometry() %>%
	plot()
pil %>%	st_as_sf(coords=c('longitude','latitude'), crs=32619) %>%
	st_geometry() %>%
	plot(add=T, pch=16 , col=2)


# # BIC-BAL
# check for duplicates

dup_id<-tgt_qc_dep %>%
		filter(site_3=='BIC-BAL' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_qc_dep %>%
		filter(site_3=='BIC-BAL', target_ID %in% dup_id	)


bal<-tgt_qc_dep %>%
	filter(site_3=='BIC-BAL', !grepl(station_name, pattern='Ref')) %>%
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude) 

bal[duplicated(sf::st_coordinates(bal)),]

bal<-bal %>%
	as.data.frame() %>%
	select(-geometry)
bal

tgt_qc_dep %>%
	filter(site_3=='BIC-BAL', !grepl(station_name, pattern='Ref')) %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	st_as_sf(coords=c('lon_utm','lat_utm'), crs=32619) %>%
	st_geometry() %>%
	plot()
bal %>%	st_as_sf(coords=c('longitude','latitude'), crs=32619) %>%
	st_geometry() %>%
	plot(add=T, pch=16 , col=2)


# Prince Rupert
# ``````````````````
tgt_prt_dep
names(tgt_prt_dep)

# TUG-1

# check for duplicates

dup_id<-tgt_prt_dep %>%
		filter(site_3=='TUG-1' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_prt_dep %>%
		filter(site_3=='TUG-1', target_ID %in% dup_id	)


tug1<-tgt_prt_dep %>%
	filter(site_3=='TUG-1') %>%
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude) 

tug1[duplicated(sf::st_coordinates(tug1)),]

tug1<-tug1 %>%
	as.data.frame() %>%
	select(-geometry)
tug1

tgt_prt_dep %>%
	filter(site_3=='TUG-1') %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	st_as_sf(coords=c('lon_utm','lat_utm'), crs=32609) %>%
	st_geometry() %>%
	plot()
tug1 %>%	st_as_sf(coords=c('longitude','latitude'), crs=32609) %>%
	st_geometry() %>%
	plot(add=T, pch=16 , col=2)


# TUG-2

# check for duplicates

dup_id<-tgt_prt_dep %>%
		filter(site_3=='TUG-2' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_prt_dep %>%
		filter(site_3=='TUG-2', target_ID %in% dup_id	)


tug2<-tgt_prt_dep %>%
	filter(site_3=='TUG-2') %>% 
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude) 

tug2[duplicated(sf::st_coordinates(tug2)),]

tug2<-tug2 %>%
	as.data.frame() %>%
	select(-geometry)
tug2

tgt_prt_dep %>%
	filter(site_3=='TUG-2') %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	# st_as_sf(coords=c('lon_utm','lat_utm'), crs=32609) %>%
	st_geometry() %>%
	plot()
	
tug2 %>%	st_as_sf(coords=c('longitude','latitude'), crs=32609) %>%
	st_geometry() %>%
	plot(add=T, pch=16 , col=2)


# Quadra
# ``````````````````
tgt_qdr_dep
names(tgt_qdr_dep)

# MARINA-1

# check for duplicates

dup_id<-tgt_qdr_dep %>%
		filter(site_3=='MARINA-1' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_qdr_dep %>%
		filter(site_3=='MARINA-1', target_ID %in% dup_id	) %>%
		select(target_ID,date, note.x)


mar1<-tgt_qdr_dep %>%
	filter(site_3=='MARINA-1', !( (target_ID=='43' & date=='6/1/2023') |
								  (target_ID=='53' & date=='6/2/2023'))
								  ) %>% 
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude) 

mar1[duplicated(sf::st_coordinates(mar1)),]

mar1<-mar1 %>%
	as.data.frame() %>%
	select(-geometry)
mar1

tgt_qdr_dep %>%
	filter(site_3=='MARINA-1') %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	# st_as_sf(coords=c('lon_utm','lat_utm'), crs=32610) %>%
	st_geometry() %>%
	plot()
	
mar1 %>%	
	st_as_sf(coords=c('longitude','latitude'), crs=32610) %>%
	st_geometry() %>%
	plot(add=F, pch=16 , col=2)



# MARINA-2

# check for duplicates

dup_id<-tgt_qdr_dep %>%
		filter(site_3=='MARINA-2' )
dup_id<-dup_id[duplicated(dup_id$target_ID),]$target_ID %>% unique(.) 

tgt_qdr_dep %>%
		filter(site_3=='MARINA-2', target_ID %in% dup_id	) %>%
		select(target_ID,date, note.x)


mar2<-tgt_qdr_dep %>%
	filter(site_3=='MARINA-2'  ) %>% 
	select(target_ID,lon_target,lat_target, target_depth_adj) %>%
	mutate(label=paste('target', target_ID), altitude=-round(target_depth_adj,1)) %>%
	rename(longitude='lon_target', latitude='lat_target') %>%
	select(label, longitude,latitude,altitude) 

mar2[duplicated(sf::st_coordinates(mar2)),]

mar2<-mar2 %>%
	as.data.frame() %>%
	select(-geometry)
mar2

tgt_qdr_dep %>%
	filter(site_3=='MARINA-2') %>%
	select(target_ID,lon_utm,lat_utm)  %>%
	# st_as_sf(coords=c('lon_utm','lat_utm'), crs=32610) %>%
	st_geometry() %>%
	plot()
	
mar2 %>%	
	st_as_sf(coords=c('longitude','latitude'), crs=32610) %>%
	st_geometry() %>%
	plot(add=T, pch=16 , col=2)

# CHECK IN METASHAPE FORMAT TO ADD ERRORS FOR lat long and dept: coordinates error are available for Quebec but not for BC so I will not add any accuracy information

# ==============================================
# SAVE DATA
# ==============================================

# daytag<-as.Date(Sys.time())
script_ver<-'compute_markers_offsets.R'

txt<-paste0('
R SCRIPT: ',script_ver,' on ',as.Date(Sys.time()),' with ', R.version.string,',

Object type: dataset

DESCRIPTION:
the dataset contains the coordinates of the center of markers used to georeference the photogrammetry project.
Coordinates are calculated to take into account the offset from the receivers post to which they were attached.
The depth (altitude) was recorded on site and it has been corrected for the tide level.

')

# txt<-paste0(txt,'\n', paste0(capture.output(sessionInfo()), collapse='\n'))

# PIL
# -------
pil_dict<-shaRe::initiate_dictionary(pil)
pil_dict


pil_dict[ pil_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
pil_dict[ pil_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
pil_dict[ pil_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
pil_dict[ pil_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# pil_dict[ pil_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# pil_dict[ pil_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# pil_dict[ pil_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')



shaRe::export_dictionary(description=txt, varTable= pil_dict, path='output/datasets/photogrammetry/markers_coords-PIL-dictionary.txt')

write.table(pil,file='output/datasets/photogrammetry/markers_coords-PIL.csv', sep=',',dec='.', quote=F,row.names = FALSE)

			
# BAL
# -------
bal_dict<-shaRe::initiate_dictionary(bal)
bal_dict


bal_dict[ bal_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
bal_dict[ bal_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
bal_dict[ bal_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
bal_dict[ bal_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# bal_dict[ bal_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# bal_dict[ bal_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')
# bal_dict[ bal_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 19N (epgs: 32619)','numeric','meters', 'NA')


shaRe::export_dictionary(description=txt, varTable= bal_dict, path='output/datasets/photogrammetry/markers_coords-BAL-dictionary.txt')

write.table(bal,file='output/datasets/photogrammetry/markers_coords-BAL.csv', sep=',',dec='.', quote=F,row.names = FALSE)

# TUG1
# -------
tug1_dict<-shaRe::initiate_dictionary(tug1)
tug1_dict


tug1_dict[ tug1_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
tug1_dict[ tug1_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
tug1_dict[ tug1_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
tug1_dict[ tug1_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug1_dict[ tug1_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug1_dict[ tug1_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug1_dict[ tug1_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')


shaRe::export_dictionary(description=txt, varTable= tug1_dict, path='output/datasets/photogrammetry/markers_coords-TUG1-dictionary.txt')

write.table(tug1,file='output/datasets/photogrammetry/markers_coords-TUG1.csv', sep=',',dec='.', quote=F,row.names = FALSE)

# TUG2
# -------
tug2_dict<-shaRe::initiate_dictionary(tug2)
tug2_dict


tug2_dict[ tug2_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
tug2_dict[ tug2_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
tug2_dict[ tug2_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
tug2_dict[ tug2_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug2_dict[ tug2_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug2_dict[ tug2_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')
# tug2_dict[ tug2_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 9N (epgs: 32609)','numeric','meters', 'NA')


shaRe::export_dictionary(description=txt, varTable= tug2_dict, path='output/datasets/photogrammetry/markers_coords-TUG2-dictionary.txt')

write.table(tug2,file='output/datasets/photogrammetry/markers_coords-TUG2.csv', sep=',',dec='.', quote=F,row.names = FALSE)



# MARINA1
# -------
mar1_dict<-shaRe::initiate_dictionary(mar1)
mar1_dict


mar1_dict[ mar1_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
mar1_dict[ mar1_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
mar1_dict[ mar1_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
mar1_dict[ mar1_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar1_dict[ mar1_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar1_dict[ mar1_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar1_dict[ mar1_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')


shaRe::export_dictionary(description=txt, varTable= mar1_dict, path='output/datasets/photogrammetry/markers_coords-MAR1-dictionary.txt')

write.table(mar1,file='output/datasets/photogrammetry/markers_coords-MAR1.csv', sep=',',dec='.', quote=F,row.names = FALSE)


# MARINA2
# -------
mar2_dict<-shaRe::initiate_dictionary(mar2)
mar2_dict


mar2_dict[ mar2_dict$field_name == 'label',2:5]<-c('label used for the marker in metashape','character','N/A', 'NA')
mar2_dict[ mar2_dict$field_name == 'longitude',2:5]<-c('longitude (considering the markers offset) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
mar2_dict[ mar2_dict$field_name == 'latitude',2:5]<-c('latitude (considering the markers offset) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
mar2_dict[ mar2_dict$field_name == 'altitude',2:5]<-c('altitude (depth adjusted for the tide) of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar2_dict[ mar2_dict$field_name == 'longitude_acc',2:5]<-c('longitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar2_dict[ mar2_dict$field_name == 'latitude_acc',2:5]<-c('latitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')
# mar2_dict[ mar2_dict$field_name == 'altitude_acc',2:5]<-c('altitude accuracy of the marker in UTM 10N (epgs: 32610)','numeric','meters', 'NA')

shaRe::export_dictionary(description=txt, varTable= mar2_dict, path='output/datasets/photogrammetry/markers_coords-MAR2-dictionary.txt')

write.table(mar2,file='output/datasets/photogrammetry/markers_coords-MAR2.csv', sep=',',dec='.', quote=F,row.names = FALSE)

