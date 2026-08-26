# ===============================================================================
# Name   	: Georeference Cameras for Tugwell 2
# Author 	: Filippo Ferrario
# Date   	: 31-08-2023 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: 1) reconstruct the estimate lines for each section (i.e., a leg) of each imaged transect
# 					a. calculate the bearing between existing ground control points (gpc, i.e., the receiver positions), both along and across trasects
#					b. estimate the positions of the start, mid and end point of each intermediate trancect
# 					c. create a line for each of the two legs of each transect, i.e., 0-30 meters and 30-60 meters
# 			  2) associate images in the dataset to each leg. This use the dataset of reference points (gcp) associated to the correct pic created manually (by looking at the photos)
#			  		a. associate pictures to legs
# 					b. associate pictures to steps
# 			  3) breack each leg line into the correct number of steps (i.e., points along the line) for that leg. This will define a gps track.
# 					a. for each leg in the pics data.frame find the number of steps
#			  		b. split the corresponding leg line (trs+leg+direction) in n=steps number of points
# 				       !!! Attention: doing a leg in one sense might not result in the same amount of pictures compared to the same leg done in the opposite sense (e.g., current stronger in 1 direction will result in different swimming times)
#					c. extract the coordinates of each point 				
# 				 	d. attach the points to the pics in the data.frame containing the sequence of pics classified in legs and steps.
# 			  4) NO! compute the offset for the additional outer cameras on the rig (NO, because it might increase error in loops )
# 			  5) export the coordinates in the format suitable form Metashape. 
# ===============================================================================

# ====================
# Load data
# ====================

gps<-read.csv('data/photogrammety/Deployment_Telemetry_HR2_BC2023.csv')
ref_pics<-read.csv('data/photogrammety/PR-Tug_2-pic2georef-main_camera.csv', na.strings = "")
pics<-read.csv('output/datasets/photogrammetry/PR-TUG_2-paired_synced.csv', na.strings = "")

# ====================
# inspect data
# ====================

head(gps)
head(pics)
head(ref_pics)

# ====================
# Processing data
# ====================

# -----------------------------------------------------------------------
# 1) reconstruct the tracs for each transect imaged
# -----------------------------------------------------------------------

head(gps)

# build a spatial object with the correct coordinate reference system
# -----------------------------------------------------------------------
receivers<-gps %>% 
		filter(SITE_NO=='Tugwell-2') %>%
		st_as_sf(.,coords=c('DEPLOY_LONG_GEODE','DEPLOY_LAT_GEODE')) %>%
		st_set_crs(4326) %>% # WGS84; need be in geographic crs to work with st_geod_azimuth, not in projected crs
		filter(!grepl(STATION_NO, pattern='[R-r]ef')) %>%
		rename_with(tolower) %>%
		bind_cols(.,st_coordinates(.)) %>%
		rename(lon='X',lat='Y', xy_grid='location') %>%
		mutate(xy_grid_copy=xy_grid) %>%
		separate(xy_grid_copy,into=c('x','y'),sep='-') %>%
		mutate(x=as.numeric(sub(x,pattern='L',replacement='')),y=as.numeric(sub(y,pattern='m',replacement=''))) %>%
		mutate(gcp=gsub(xy_grid, pattern='L',replacement='T'), 
				gcp=gsub(gcp, pattern='m',replacement=''),
				gcp=gsub(gcp, pattern=' +',replacement='') ) %>%
		select(site_no, xy_grid,x,y,gcp, lat,lon, contains('_geode'), comments) %>%
		arrange(x,y)

receivers


receivers <- filter(receivers,x!=30)
plot(st_geometry(receivers), pch=16)
with(receivers, text(lon,lat-0.00002, label=xy_grid))

# headings along the transects
# -----------------------------------------------------------------------
t0<-receivers %>% filter(x==0)
ht0<-st_geod_azimuth(t0)%>% units::set_units("degrees") 

# t30<-receivers %>% filter(x==30)
# ht30<-st_geod_azimuth(t30)%>% units::set_units("degrees") 

t60<-receivers %>% filter(x==60)
ht60<-st_geod_azimuth(t60)%>% units::set_units("degrees") 

# headings cross transects
# -----------------------------------------------------------------------
c0<-receivers %>% filter(y==0)
hc0<-st_geod_azimuth(c0)%>% units::set_units("degrees") 

c30<-receivers %>% filter(y==30)
hc30<-st_geod_azimuth(c30)%>% units::set_units("degrees") 

c60<-receivers %>% filter(y==60)
hc60<-st_geod_azimuth(c60)%>% units::set_units("degrees") 

# estimate positions of intermediate transects
# -----------------------------------------------------------------------

# tentativo senza x = 30
# Y=0
dists<-st_distance(c0[1,],c0[2,], by_element=T) %>% as.numeric(.) %>% seq(0,.,length.out=16) %>% .[-c(1,length(.))]
t060_0<-destPoint(p=st_coordinates(receivers[receivers$gcp=='T0-0',]), b=hc0[1], d=dists) %>%
		as.data.frame(.) %>%
		mutate(gcp=paste0('T',seq(4,56,by=4),'-0')) %>%
		st_as_sf(., coords=c('lon','lat')) %>%
		st_set_crs(4326) 
plot(st_geometry(t060_0), pch=16, col=3,add=T)


#  Y=30
dists<-st_distance(c30[1,],c30[2,], by_element=T) %>% as.numeric(.) %>% seq(0,.,length.out=16) %>% .[-c(1,length(.))]
t060_30<-destPoint(p=st_coordinates(receivers[receivers$gcp=='T0-30',]), b=hc30[1], d=dists) %>%
		as.data.frame(.) %>%
		mutate(gcp=paste0('T',seq(4,56,by=4),'-30')) %>%
		st_as_sf(., coords=c('lon','lat')) %>%
		st_set_crs(4326) 
plot(st_geometry(t060_30), pch=16, col=4,add=T)


# # Y=60
dists<-st_distance(c60[1,],c60[2,], by_element=T) %>% as.numeric(.) %>% seq(0,.,length.out=16) %>% .[-c(1,length(.))]
t060_60<-destPoint(p=st_coordinates(receivers[receivers$gcp=='T0-60',]), b=hc60[1], d=dists) %>%
		as.data.frame(.) %>%
		mutate(gcp=paste0('T',seq(4,56,by=4),'-60')) %>%
		st_as_sf(., coords=c('lon','lat')) %>%
		st_set_crs(4326) 
plot(st_geometry(t060_60), pch=16, col=5,add=T)




# combine all the points 
# -----------------------------------------

gcp_all<-rbind(t0,t60) %>%
	select(gcp) %>%
	rbind(t060_0,t060_30,t060_60	) %>%
	mutate(trs=unlist(lapply(strsplit(gcp, split='-'), function(x){x[1]}))) %>%
	arrange(trs) 

as.data.frame(gcp_all)

# create lines for each leg
# -------------------------------------------

# combine start end point of a leg, then create a line between the 2 

leg_0_30<-gcp_all %>%
			filter(!grepl(gcp, pattern='-60')) 
			# mutate(pos=ifelse(grepl(gcp, pattern='-0'), 'start', 'end' ) ) %>%
			
line_0_30<-lapply(unique(leg_0_30$trs), function(x){ #browser()
						tmp<-filter(leg_0_30, trs==x) %>%
								separate(gcp, into=c('tr','pos'),sep='-') 
						res<-st_linestring(st_coordinates(tmp)) %>%
								st_sfc(.) %>%
								st_sf(data.frame(trs=x,leg=paste0(tmp$pos[1],'-',tmp$pos[2])), geom=.)
						res						
				}) %>%
			bind_rows(.) %>%
			st_set_crs(4326)

plot(st_geometry(line_0_30),add=T)

leg_30_60<-gcp_all %>%
			filter(!grepl(gcp, pattern='-0')) 
			# mutate(pos=ifelse(grepl(gcp, pattern='-0'), 'start', 'end' ) ) %>%
			
line_30_60<-lapply(unique(leg_30_60$trs), function(x){ #browser()
						tmp<-filter(leg_30_60, trs==x) %>%
								separate(gcp, into=c('tr','pos'),sep='-') 
						res<-st_linestring(st_coordinates(tmp)) %>%
								st_sfc(.) %>%
								st_sf(data.frame(trs=x,leg=paste0(tmp$pos[1],'-',tmp$pos[2])), geom=.)
						res						
				}) %>%
			bind_rows(.)%>%
			st_set_crs(4326)


plot(st_geometry(line_30_60),add=T)
legs<-bind_rows(line_0_30,line_30_60) 
# create tag for reverse leg
legs$rev_leg<-	strsplit(legs$leg,split='-') %>%
					sapply(function(n){
						paste0(n[2],'-',n[1])
						}) 
# Add a 0 after the T for transects <10
idx<-grepl(legs$trs, pattern='(T[0-9]){1}$') 					
legs$trs[idx]<-sub(legs$trs[idx],pattern='T',replacement='T0')				

as.data.frame(legs)

# -------------------------------------------------------
# 2) associate images in the dataset to each leg.
# -------------------------------------------------------

head(pics)
head(ref_pics)

# initialize variable to store info on the leg and the step (i.e., gps coord) to be assigned to the pic
pics$leg<-NA
pics$step<-NA

# split ref dataset in a list by leg (2023-03-22 note: added shooting group as factor because there were pics of the same leg tacken in 2 different dives! )
seqList<-split(ref_pics, f=paste(ref_pics$shooting_group,ref_pics$sequence_georef) ) 

# check reference points
len_ref<-lapply(seqList,nrow)
seqList[! len_ref %in%c(2,3) ]

# find the rows of the paired pic dataset that fall in each leg and assign pics to steps
# !!!! Attention: pics in loops should be given the same step !!!
# This is doing 2.a and 2.b

for(i in 1:length(seqList)){
			# a. Associate pictures to legs
			# ------------------------
			temp<-seqList[[i]]

			# find camera
			colname<-gsub(unique(temp$cameraID), pattern='-',replacement='\\.')
			# find number of reference points in the leg and id file start and end
			n_ref<-nrow(temp)
			start_endID<-which(pics[,colname] %in% c(temp$file_name[1],temp$file_name[n_ref]))
			# assign leg to file
			seqTAG<-unique(temp$sequence_georef)
			pics$leg[start_endID[1]:start_endID[2]]<-seqTAG
			
			# b. Associate pictures to steps
			# ----------------------------
			# find leg length
			leglen<-start_endID[2]-start_endID[1]+1
			# find the loops
			loopID<-grep(temp$ref_point, pattern='str_loop')
				# assign steps to pics when no loops are present
				# ---------------------------------------------
				if (length(loopID)==0) steps<-1:leglen




				# if loops are present
				# ---------------------------------------------
				if (length(loopID)>0) {
					pictemp<-pics[start_endID[1]:start_endID[2],] # the output from this line doesn't do anything after
					

					# find loop length
					looplen<-sapply(loopID, function(x){ 
							#browser()
							st_enID<-which(pics[,colname] %in% c(temp$file_name[x],temp$file_name[x+1]))
							n_pic_loop<- st_enID[2]-st_enID[1]+1
							n_pic_loop
						})
					
					# find position of start loop files in the leg
					loop_pos<-which(pics[!is.na(pics$leg) & pics$leg==seqTAG , colname] %in% temp$file_name[loopID])
							
					# initialize the step vector
					steps<-rep(NA,leglen)
					counter=1
					pos=1

					for (p in 1:leglen) {

						if(! pos %in% loop_pos) {
							steps[pos]<-counter
							counter<-counter+1
							pos<-pos+1} else {
								
								if (pos %in% loop_pos) {
									# find to which loop pos correspond 
									pid<-which(loop_pos==pos)
									# select the lenght of the loop and account for the position pos already taken
									lenloop<-looplen[pid]-1
									# assign the same step to all the positions in the loop
									steps[pos:(pos+lenloop)]<-counter
									counter<-counter+1
									pos<-pos+looplen[pid]
								}		
							}
						# provide exit if steps is completed before end of loop (i.e., before p=leglen)
						if (pos>leglen) break

					}
				}
			pics$step[start_endID[1]:start_endID[2]]<-steps
}

pics


# ==================================================================================================================================================
# 3) breack each leg line into the correct number of steps (i.e., points along the line) for that leg. This will define a gps track.
# ==================================================================================================================================================

head(pics)
legs

unique(legs$leg)

# The labels in column leg in the line dataframe legs are matching only the direction 0 to 60.
# This is because the lines will always be the same in the opposite direction, only the number of points and their sequence will change.
# This can be taken into account by reversing the order of the positions of points in the R vector when assigning them to the leg.

# create a list whose elements are individual legs in pics
# picsList<-split(pics, f=paste(pics$shooting_group,pics$leg))
picsList<-split(pics, f=pics$leg)
lapply(picsList,nrow)
picsList[lapply(picsList,nrow)<50]
# split lines for legs moving 0 -> 60.

options( error=recover ) 
picsList_coords<-lapply(names(picsList), function(x){
			# browser()
			# select the element in leg corresponding to the line
			picXleg<-picsList[x] [[1]]
			# define if it is a revers leg
			reverse<-grepl(x, pattern='30-0|60-30') 


			# Which transect in legs is in the name of the list element?  
			trs_id<-sapply(legs$trs, function(y) grepl(x,pattern=y))  
			# Which leg in legs is in the name of the list element?
			if (!reverse) {
				leg_id<-sapply(legs$leg, function(y) grepl(x,pattern=y))
				} else { 
				leg_id<-sapply(legs$rev_leg, function(y) grepl(x,pattern=y))
				}

			# select the line needed
			line<-legs[trs_id & leg_id,]

			# a. for each leg in the pics data.frame find he number of steps
			# ------------------------------------------------------------------
			n_steps<- max(picXleg$step)

			# b. split the corresponding leg line (trs+leg+direction) in n=steps number of points
			# --------------------------------------------------------------------------------------
			pts_steps<-line %>%
						st_transform(crs=32609) %>% # need to set projected coordinates to use st_line_sample
						st_line_sample( n=n_steps, type='regular') %>%
						st_cast('POINT') %>%
						st_transform(crs=4326) %>% # backtransform to geographical coords for plotting and offset calculation
						# c. extract the coordinates of each point 			
						# -----------------------------------------
						st_coordinates(.) %>%
						as.data.frame(.) 
			if(reverse) {
				pts_steps$step<-nrow(pts_steps):1
				} else {
					pts_steps$step<-1:nrow(pts_steps )
				} 

			# plot(st_point(c(pts_steps[pts_steps$step==1,'X'],pts_steps[pts_steps$step==1,'Y'])), col='yellow', pch=16, add=T)
			# plot(st_point(c(pts_steps[pts_steps$step==n_steps,'X'],pts_steps[pts_steps$step==n_steps,'Y'])), col='purple', pch=16, add=T)



			# d. attach the points to the pics in  the data.frame containing the sequence of pics classified in legs and steps.
			# -------------------------------------------------------------------------------------------------------------------
			picXleg<-left_join(picXleg,pts_steps)
			picXleg
			}
		) 
picsList_coords_df<-bind_rows(picsList_coords)




# Verify coords are correct based on position of pic in the leg and swimming direction
# ----------------------------------------------------------------------------------------

head(picsList_coords_df)



plot(st_geometry(receivers), pch=16)
with(receivers, text(lon,lat-0.00002, label=xy_grid))
# plot(st_geometry(t030_0), pch=16, col=3,add=T)
# plot(st_geometry(t3060_0), pch=16, col=4,add=T)
# plot(st_geometry(t030_30), pch=16, col=5,add=T)
# plot(st_geometry(t3060_30), pch=16, col=7,add=T)
# plot(st_geometry(t030_60), pch=16, col=6,add=T)
# plot(st_geometry(t3060_60), pch=16, col=8,add=T)
plot(st_geometry(line_0_30),add=T)
plot(st_geometry(line_30_60),add=T)

# plot start and end pics of legs going from 0->30

picsList_coords_df %>%
		filter(grepl(.$leg,pattern='-0-30')) %>%
		split(f=.$leg) %>%	
		lapply(function(x){ #browser()
			pt_1<-st_multipoint(cbind(x[x$step==1,'X'],x[x$step==1,'Y']))
			pt_2<-st_multipoint(cbind(x[x$step==(max(x$step)-1),'X'],x[x$step==(max(x$step)-1),'Y']))
			plot(pt_1, bg='yellow', pch=21, add=T)
			plot(pt_2, bg='purple', pch=21, add=T)

			})

# plot start and end pics of legs going from 30->0

picsList_coords_df %>%
		filter(grepl(.$leg,pattern='-30-0')) %>%
		split(f=.$leg) %>%
		lapply(function(x){ #browser()
			pt_1<-st_multipoint(cbind(x[x$step==1,'X'],x[x$step==1,'Y']))
			pt_2<-st_multipoint(cbind(x[x$step==(max(x$step)-1),'X'],x[x$step==(max(x$step)-1),'Y']))
			plot(pt_1, bg='red', pch=21, add=T) 
			plot(pt_2, bg='black', pch=21, add=T) 

			})


# plot start and end pics of legs going from 30->60

picsList_coords_df %>%
		filter(grepl(.$leg,pattern='-30-60')) %>%
		split(f=.$leg) %>%	
		lapply(function(x){ #browser()
			pt_1<-st_multipoint(cbind(x[x$step==5,'X'],x[x$step==5,'Y']))
			pt_2<-st_multipoint(cbind(x[x$step==(max(x$step)-5),'X'],x[x$step==(max(x$step)-5),'Y']))
			plot(pt_1, bg='yellow', pch=21, add=T) 
			plot(pt_2, bg='purple', pch=21, add=T)

			})

# plot start and end pics of legs going from 60->30

picsList_coords_df %>%
		filter(grepl(.$leg,pattern='-60-30')) %>%
		split(f=.$leg) %>%	
		lapply(function(x){ #browser()
			pt_1<-st_multipoint(cbind(x[x$step==1,'X'],x[x$step==1,'Y']))
			pt_2<-st_multipoint(cbind(x[x$step==(max(x$step)-1),'X'],x[x$step==(max(x$step)-1),'Y']))
			plot(pt_1, bg='red', pch=21, add=T) 
			plot(pt_2, bg='black', pch=21, add=T)

			})



# ==================================================================================================================================================
# 5) export the coordinates in the format suitable form Metashape.
# ==================================================================================================================================================

head(picsList_coords_df)


geo_pics<-picsList_coords_df %>%
	pivot_longer(cols=contains(c('cr.','cl.','lx.','rx.')), names_to='cameraID', values_to='path') %>%
	rename('longitude'='X', 'latitude'='Y') %>%
	mutate(label=unlist(lapply(path, function(x) {
							res<-unlist(strsplit(x,split='/'))
							lres<-length(res)
							res[lres]
							})),
		   altitude=-4) %>%  # altitude is needed otherwise the data are not imported by Metashape
	mutate(coods_accuracy=6,altitude_accuracy=5) %>% # deliberately high value to give low accuracy
	select(label, contains(c('itude','accuracy')) ) %>%
	filter(!label=='NA') %>%	
	as.data.frame(.)

head(geo_pics)

# names(geo_pics)<- paste0('<',names(geo_pics),'>')

# ==============================================
# SAVE DATA
# ==============================================

daytag<-as.Date(Sys.time())
script_ver<-'imagery_georef-PR-TUG_2.R'


geo_dict<-shaRe::initiate_dictionary(geo_pics)
geo_dict

geo_dict[ geo_dict$field_name == 'label',2:5]<-c('file name of the image','character','n/a', 'NA')
geo_dict[ geo_dict$field_name == 'longitude',2:5]<-c('longitude of the image. CRS WGS84, epsg:4326','numeric','decimal degrees', 'NA')
geo_dict[ geo_dict$field_name == 'latitude',2:5]<-c('latitude of the image. CRS WGS84, epsg:4326','numeric','decimal degrees', 'NA')
geo_dict[ geo_dict$field_name == 'altitude',2:5]<-c('altitude of the image. Arbitrarily, but plausible, chosen value','numeric','meters', 'NA')
geo_dict[ geo_dict$field_name == 'coods_accuracy',2:5]<-c('Accuracy of coordinate of the image. Arbitrarily set to a deliberately high value to give low accuracy','numeric','meters', 'NA')
geo_dict[ geo_dict$field_name == 'altitude_accuracy',2:5]<-c('Accuracy of the altitude of the image. Arbitrarily set to a deliberately high value to give low accuracy','numeric','meters', 'NA')



txt<-paste0('
R SCRIPT: ',script_ver,' on ',daytag,' with ', R.version.string,',

Object type: dataframe

DESCRIPTION:
Dataframe with estimated longitude and latitude coordinates of images to be used for photogrammetry.
The File is formatted for Metashape 1.8.
Only the images with estimated coordinates are listed. 
The full photogrammetry dataset may contain additional images for which it was not possible to estimate coordinates.
Coordinates are estimated based on :
- the knonw GPS position of ground control points (GCPs, e.g., receivers)
- the path swam
- the number of pictures (excluding those circling around the same position) between two consecutive GCPs.

CRS= WGS84
')

shaRe::export_dictionary(description=txt, varTable= geo_dict, path='output/datasets/photogrammetry/georeferenced_images-PR-TUG_2-dictionary.txt', formatTable='long')

write.csv(geo_pics,file='output/datasets/photogrammetry/georeferenced_images-PR-TUG_2.csv', quote=F, row.names=F)



