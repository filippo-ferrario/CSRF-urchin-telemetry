# ===============================================================================
# Name   	: Estimate reference points BIC
# Author 	: Filippo Ferrario
# Date   	: 22-08-2022 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: Identify sequences and synchronize images from BIC, & subsample imagery.
# ===============================================================================



# ============
# load packages
# ============

# library(ActioneeR)

# ============
# load data
# ============              
PIL_ref_ann<-read.csv('data/photogrammetry/BIC-PIL-image_sync.csv')
BAL_ref_ann<-read.csv('data/photogrammetry/BIC-BAL-image_sync.csv')


# ============
# Processing
# ============
 

# BIC - Anse aux Pilotes
# ============================

# Estimate position of reference points for start and end sequences
PIL_ref_est<-estimate_sync(source='./imagery/QC-BIC-mosaicing/PIL/TL_1s' ,
							output_path='output/datasets/photogrammetry/BIC-PIL-image_sync-esitmated_ref-check03.csv',
							ref_data=PIL_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

# pair the synced images
PIL_paired<-pair_synced(source='./imagery/QC-BIC-mosaicing/PIL/TL_1s',
			output_path='output/datasets/photogrammetry/BIC-PIL-paired_synced.csv',  
			ref_data=PIL_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# Subsample every 2 frames
img_subsample(source='./imagery/QC-BIC-mosaicing/PIL/TL_1s' ,
			  dest='./imagery/QC-BIC-mosaicing/PIL/sub-2', 
			  paired_synced=as.data.frame(PIL_paired), 
			  interval=2,
			  shooting_group='shooting_group' , 
			  cameraID='cameraID' )



# BIC - La balaine
# ============================

# Estimate position of reference points for start and end sequences
BAL_ref_est<-estimate_sync(source='D:/2022-CSRF_urchin_kelp/imagery/QC-BIC-mosaicing/BAL/TL_1s' ,
							output_path='output/datasets/photogrammetry/BIC-BAL-image_sync-esitmated_ref.csv',
							ref_data=BAL_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

# pair the synced images
BAL_paired<-pair_synced(source='D:/2022-CSRF_urchin_kelp/imagery/QC-BIC-mosaicing/BAL/TL_1s',
			output_path='output/datasets/photogrammetry/BIC-BAL-paired_synced.csv',  
			ref_data=BAL_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# Subsample every 2 frames
img_subsample(source='D:/2022-CSRF_urchin_kelp/imagery/QC-BIC-mosaicing/BAL/TL_1s' ,
			  dest='./imagery/QC-BIC-mosaicing/BAL/sub-2', 
			  paired_synced=as.data.frame(BAL_paired), 
			  interval=2,
			  shooting_group='shooting_group' , 
			  cameraID='cameraID' )


