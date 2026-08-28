# ===============================================================================
# Name   	: Estimate reference points IAL
# Author 	: Filippo Ferrario
# Date   	: 14-10-2022 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: Identify sequences and synchronize images from IAL, & subsample imagery.
# ===============================================================================



# ============
# load packages
# ============

# library(ActioneeR)
# ============
# load data
# ============
NE_ref_ann<-read.csv('data/photogrammetry/IAL-NE-image_sync.csv')
SW_ref_ann<-read.csv('data/photogrammetry/IAL-SW-image_sync.csv')
SW_202207_ref_ann<-read.csv('data/photogrammetry/IAL-SW-202207-image_sync.csv')


# ============
# Processing
# ============
 


# IAL - North East
# ============================
# Estimate position of reference points for start and end sequences
NE_ref_est<-estimate_sync(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/NE_site/TL_1s' ,
							output_path='output/datasets/photogrammetry/IAL-NE-image_sync-esitmated_ref.csv',
							ref_data=NE_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name',
							img_extension='JPG')

# pair the synced images

NE_ref_est<-read.csv('output/datasets/photogrammetry/IAL-NE-image_sync-esitmated_ref.csv')
NE_paired<-pair_synced(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/NE_site/TL_1s',
			output_path='output/datasets/photogrammetry/IAL-NE-paired_synced.csv',  
			ref_data=NE_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# Subsample every 1 frames
NE_paired<-read.csv('output/datasets/photogrammetry/IAL-NE-paired_synced.csv')

img_subsample(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/NE_site/TL_1s' ,
			  dest='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/NE_site/full_set', 
			  paired_synced=as.data.frame(NE_paired), 
			  interval=1,
			  overwrite=FALSE,
			  shooting_group='shooting_group' , 
			  cameraID='cameraID' )
# Note of the 20230103:
# The original set was first subsetted to 1 every 2 images generating a subfolder calle 'sub-2'. 
# Then I added remaining pics in the sub-2 folder to have the full set and renamed the folder 'full_set'.
# This was then cut and pasted in the 2022-CSRF_urchin_kelp\image_processing\pics-color_corrected\gimp folder and renamed 'IAL-NE' for color correction




# IAL - South West
# ============================
# Estimate position of reference points for start and end sequences
SW_ref_est<-estimate_sync(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s' ,
							output_path='output/datasets/photogrammetry/IAL-SW-image_sync-esitmated_ref.csv',
							ref_data=SW_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name',
							img_extension='JPG')
# pair the synced images
SW_ref_est<-read.csv('output/datasets/photogrammetry/IAL-SW-image_sync-esitmated_ref.csv')
SW_paired<-pair_synced(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s',
			output_path='output/datasets/photogrammetry/IAL-SW-paired_synced.csv',  
			ref_data=SW_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')


# Subsample every 1 frames (i.e., Full dataset)
SW_paired<-read.csv('output/datasets/photogrammetry/IAL-SW-paired_synced.csv')
img_subsample(source='D:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s' ,
			  dest='D:/2022-CSRF_urchin_kelp/image_processing/pics-color_corrected/gimp/IAL-SW', 
			  paired_synced=as.data.frame(SW_paired), 
			  interval=1,
			  shooting_group='shooting_group' , 
			  cameraID='cameraID' )




# IAL - South West - July Attempt
# ===================================
# Estimate position of reference points for start and end sequences
SW_202207_ref_est<-estimate_sync(source='F:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s' ,
							output_path='output/datasets/photogrammetry/IAL-SW-202207-image_sync-esitmated_ref.csv',
							ref_data=SW_202207_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID',
							camera_role='camera_role',
							sequence='sequence',
							ref_point='ref_point',
							file_name='file_name',
							img_extension='JPG')
# pair the synced images
SW_202207_ref_est<-read.csv('output/datasets/photogrammetry/IAL-SW-202207-image_sync-esitmated_ref.csv')
SW_202207_paired<-pair_synced(source='F:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s',
			output_path='output/datasets/photogrammetry/IAL-SW-202207-paired_synced.csv',  
			ref_data=SW_202207_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')


# Subsample every 1 frames (i.e., Full dataset)
SW_202207_paired<-read.csv('output/datasets/photogrammetry/data/IAL-SW-202207-paired_synced.csv')
img_subsample(source='F:/2022-CSRF_urchin_kelp/imagery/QC-ile_blanche-mosaicing/SW_site/TL_1s' ,
			  dest='F:/2022-CSRF_urchin_kelp/image_processing/IAL-SW/03-pics-color_corrected/20220705', 
			  paired_synced=as.data.frame(SW_202207_paired), 
			  interval=1,
			  shooting_group='shooting_group' , 
			  cameraID='cameraID' )

