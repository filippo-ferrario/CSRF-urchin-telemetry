# ===============================================================================
# Name   	: Estimate reference points Prince Rupert			
# Author 	: Filippo Ferrario
# Date   	: 07-07-2023; 08-08-2023 [dd-mm-yyyy]
# Version	: 
# URL		: 
# Aim    	: Identify sequences and synchronize images from Tugwell (BC), & subsample imagery.
# ===============================================================================



# ============
# load packages
# ============

library(ActioneeR)

# ============
# load data
# ============
Tug1_ref_ann<-read.csv('data/photogrammety/PR-TUG_1-image_sync.csv')

Tug2_ref_ann<-read.csv('data/photogrammety/PR-TUG_2-image_sync.csv')




# ============
# Processing
# ============
 

# Prince Rupert - Tugwell 1
# ============================
Tug1_ref_ann

# Estimate position of reference points for start and end sequences
Tug1_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_1' ,
							output_path='output/datasets/photogrammetry/PR-TUG_1-image_sync-esitmated_ref.csv',
							ref_data=Tug1_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

# pair the synced images
Tug1_paired<-pair_synced(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_1',
			output_path='output/datasets/photogrammetry/PR-TUG_1-paired_synced.csv',  
			ref_data=Tug1_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')

# first synchronization was done on 20230707, but it did not correctely accounted for the mishap in Ondine's dive: filming started on T32 right instead of left, then it continued from left to rigth from T36 to T60.
# The sync file was corrected on 20230808 and the script re-run. 
# However, since the order for the shooting between T0 and T32 was ok, only the pics from the shooting group 20230525-T32_00Lx-T60_00Rx were subsampled and copied from scratch.
# On the 20230829:  The sync file was further corrected on the 20230829 to fix a mislabeling of sequence in the shooting group 20230525-T28_00Rx-T32_00Lx that mistakenly reported sequences only for thranset 32. The estimated sync and the paired sync files were generated again BUT NO further subsampling was done because it should be fine.
# 					The column sequence in the subsample_list-20230707.csv file is manually corrected to match the edits.

# # Subsample every 1 frames (run on the 20230707)
# img_subsample(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_1' ,
# 			  dest='E:/2022-CSRF_urchin_kelp/image_processing/PR-Tug1/03-pics-color_corrected', 
# 			  paired_synced=as.data.frame(Tug1_paired), 
# 			  interval=1,
# 			  shooting_group='shooting_group', 
# 			  cameraID='cameraID' )

# Subsample every 1 frames (run on the 20230808)

t32t60<-split(Tug1_paired,f=Tug1_paired$shooting_group)$`20230525-T32_00Lx-T60_00Rx`

img_subsample(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_1' ,
			  dest='E:/2022-CSRF_urchin_kelp/image_processing/PR-Tug1/03-pics-color_corrected', 
			  paired_synced=as.data.frame(t32t60), 
			  interval=1,
			  shooting_group='shooting_group', 
			  cameraID='cameraID' )




# Prince Rupert - Tugwell 2
# ============================
Tug2_ref_ann
split(Tug2_ref_ann,f=Tug2_ref_ann$shooting_group)

# Estimate position of reference points for start and end sequences
Tug2_ref_est<-estimate_sync(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_2' ,
							output_path='output/datasets/photogrammetry/PR-TUG_2-image_sync-esitmated_ref.csv',
							ref_data=Tug2_ref_ann ,
							shooting_group='shooting_group' ,
							cameraID='cameraID' ,
							camera_role='camera_role' ,
							sequence='sequence' ,
							ref_point='ref_point' ,
							file_name='file_name')

# pair the synced images
Tug2_paired<-pair_synced(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_2',
			output_path='output/datasets/photogrammetry/PR-TUG_2-paired_synced.csv',  
			ref_data=Tug2_ref_est, 
			shooting_group='shooting_group', 
			cameraID='cameraID' , 
			camera_role='camera_role' ,
			sequence='sequence' ,
			ref_point='ref_point' ,
			file_name='file_name')


# Subsample every 1 frames 
img_subsample(source='E:/2022-CSRF_urchin_kelp/imagery/BC-Prince_Rupert-mosaicing/Tugwell_2' ,
			  dest='E:/2022-CSRF_urchin_kelp/image_processing/PR-Tug2/03-pics-color_corrected', 
			  paired_synced=as.data.frame(Tug2_paired), 
			  interval=1,
			  shooting_group='shooting_group', 
			  cameraID='cameraID' )