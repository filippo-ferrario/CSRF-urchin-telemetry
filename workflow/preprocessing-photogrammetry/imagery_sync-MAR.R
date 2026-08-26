# ===============================================================================
# Name   	: Estimate reference points Quadra Island (BC)			
# Author 	: Filippo Ferrario
# Date   	: 08-08-2023 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: Identify sequences and synchronize images from Marina (BC), & subsample imagery.
# ===============================================================================



# ============
# load packages
# ============

library(ActioneeR)

# initiate_sync('data/photogrammety/QD-MAR_1-image_sync.csv')
# initiate_sync('data/photogrammety/QD-MAR_2-image_sync.csv')


# ============
# load data
# ============
Mar1_ref_ann<-read.csv('data/photogrammety/QD-MAR_1-image_sync.csv')

Mar2_ref_ann<-read.csv('data/photogrammety/QD-MAR_2-image_sync.csv')


# Quadra Island - Marina 1
# ============================
Mar1_ref_ann
split(Mar1_ref_ann,f=Mar1_ref_ann$shooting_group)

half1<-split(Mar1_ref_ann,f=Mar1_ref_ann$shooting_group)$`20230604-T00_00Rx-T32_00Lx`
half2<-split(Mar1_ref_ann,f=Mar1_ref_ann$shooting_group)$`20230604-T28_00Rx-T60_00Lx`


# Estimate position of reference points for start and end sequences
half1_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_1' ,
							output_path='output/datasets/photogrammetry/QD-MAR_1-image_sync-esitmated_ref.csv',
							ref_data=half1 ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

half2_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_1' ,
							output_path='output/datasets/photogrammetry/QD-MAR_1-image_sync-esitmated_ref.csv',
							ref_data=half2 ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

Mar1_ref_est<-bind_rows(half1_ref_est,half2_ref_est) 
write.csv(Mar1_ref_est, file = 'output/datasets/photogrammetry/QD-MAR_1-image_sync-esitmated_ref.csv', quote = FALSE, row.names = FALSE)



# pair the synced images
Mar1_paired<-pair_synced(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_1',
			output_path='output/datasets/photogrammetry/QD-MAR_1-paired_synced.csv',  
			ref_data=Mar1_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# Subsample every 2 frames 
img_subsample(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_1' ,
			  dest='E:/2022-CSRF_urchin_kelp/image_processing/QD-Mar1/03-pics-color_corrected', 
			  paired_synced=as.data.frame(Mar1_paired), 
			  interval=2,
			  shooting_group='shooting_group', 
			  cameraID='cameraID' )


# Quadra Island - Marina 2
# ============================

Mar2_ref_ann
chunks<-split(Mar2_ref_ann,f=Mar2_ref_ann$shooting_group)
chunks
gr1<-bind_rows(chunks[1:2])
gr2<-chunks[[3]]
gr3<-bind_rows(chunks[4:5])


# Estimate position of reference points for start and end sequences
gr1_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_2' ,
							output_path='output/datasets/photogrammetry/QD-MAR_2-image_sync-esitmated_ref.csv',
							ref_data=gr1 ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

gr2_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_2' ,
							output_path='output/datasets/photogrammetry/QD-MAR_2-image_sync-esitmated_ref.csv',
							ref_data=gr2 ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')


gr3_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_2' ,
							output_path='output/datasets/photogrammetry/QD-MAR_2-image_sync-esitmated_ref.csv',
							ref_data=gr3 ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

Mar2_ref_est<-bind_rows(gr1_ref_est,gr2_ref_est,gr3_ref_est) 
write.csv(Mar2_ref_est, file = 'output/datasets/photogrammetry/QD-MAR_2-image_sync-esitmated_ref.csv', quote = FALSE, row.names = FALSE)


# pair the synced images
Mar2_paired<-pair_synced(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_2',
			output_path='output/datasets/photogrammetry/QD-MAR_2-paired_synced.csv',  
			ref_data=Mar2_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# Subsample every 2 frames 
img_subsample(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Quadra-mosaicing/Marina_2' ,
			  dest='E:/2022-CSRF_urchin_kelp/image_processing/QD-Mar2/03-pics-color_corrected', 
			  paired_synced=as.data.frame(Mar2_paired), 
			  interval=2,
			  shooting_group='shooting_group', 
			  cameraID='cameraID' )

