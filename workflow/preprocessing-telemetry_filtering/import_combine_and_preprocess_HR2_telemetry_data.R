# ===============================================================================
# Name   	: Import and preprocess vps data from HR2 urchin telemetry - CSRF Quebec-BC
# Author 	: Katie MacGregor
# Date   	: 2025-01-27 [yyyy-mm-dd]
# Version	: 
# URL		: 
# Aim    	: Import VPS positioning data from Innovasea and preprocess for analysis
# ===============================================================================


#' ## Import and preprocess VPS data
#' ----------------------------------------------------
#' 
#' # Import data files



#' ----------------------------------------------------
#' Import urchin tag datasets : Quebec


# =====================
# Metadata : urchins
# =====================

# Import metadata for urchins Quebec sites (Anse des pilotes and Bic)
meta_animal_qc <- read_csv(file = "./data/metadata_urchins_QC2022.csv", show_col_types = FALSE)



#' HR2 tags have both a HR and a PPM ping, designated by A or H in the code space column
#' Extract this info to be able to separate HR2 data from PPM data
meta_animal_qc$code_type = substring(meta_animal_qc$VUE.Tag.ID, 1, 1) # Extract A or H coding
meta_animal_qc$tel_type = 'NA' # create new column for tag-type info
meta_animal_qc$tel_type[meta_animal_qc$code_type == "A"] = "PPM" # populate with A=PPM pings
meta_animal_qc$tel_type[meta_animal_qc$code_type == "H"] = "HR" # and H=HR pings

# Rename columns for ease of coding and select a restricted number of columns
meta_animal_qc  <- meta_animal_qc %>% 
  rename(id = TAG_ID_CODE, diam = `LENGTH..m.`, serial = Serial, 
    ping_type = tel_type, tagger = TAGGER, spp_com = COMMON_NAME_E, spp_sci = SCIENTIFIC_NAME, site = CAPTURE_LOCATION, 
    trt_col = TREATMENT_TYPE, dist_fct = RELEASE_LOCATION, release_time_utc = UTC_RELEASE_DATE_TIME) %>% 
  mutate(diam_mm = diam*1000) |> 
  select(site, spp_com, spp_sci, dist_fct, trt_col, id, serial, diam_mm, ping_type, release_time_utc, tagger)  |> 
  mutate(id = as.numeric(id)) # to merge with detection file, ensure id is a numeric column

glimpse(meta_animal_qc)





# =====================
# Metadata : receivers
# =====================

# Import metadata for receivers Quebec sites (Anse des pilotes and Bic)
meta_syncref_qc <- read_csv(file = "./data/metadata_receivers_QC2022.csv", show_col_types = FALSE)


# Rename columns for ease of coding and select a restricted number of columns
meta_syncref_qc  <- meta_syncref_qc  |>  
  rename(site = Site_2, stn = Station_Name, id = TRANSMITTER, serial = INS_SERIAL_NO, pos = Station_pos, stn_name_long = STATION_NO, 
    date_in = `DEPLOY_DATE_TIME   (yyyy-mm-ddThh:mm:ss)`, recovered_y_n = `RECOVERED (y/n/l)`, 
    date_out = `RECOVER_DATE_TIME (yyyy-mm-ddThh:mm:ss)`, 
    lat = DEPLOY_LAT_1, lon = DEPLOY_LONG_1, gps_error = `Error_(m)_1`, prof_m = BOTTOM_DEPTH_adj) |>  
  mutate(id = as.numeric(id), reg = "qc") |> 
  select(reg, site, stn, id, serial, pos, stn_name_long, date_in, recovered_y_n, date_out, lat, lon, gps_error, prof_m)

meta_syncref_qc <- meta_syncref_qc[is.na(meta_syncref_qc$site) == FALSE, ] # remove 1 line with all NAs

# Modify site names in metadata to match the site names in the urchin metadata and detections files:
meta_syncref_qc$site[meta_syncref_qc$site == "Baleine"] <- "BIC-BAL"
meta_syncref_qc$site[meta_syncref_qc$site == "Pilotes"] <- "BIC-PIL"
meta_syncref_qc$site[meta_syncref_qc$site == "NE"] <- "ILA-NE"
meta_syncref_qc$site[meta_syncref_qc$site == "SW"] <- "ILA-SW"
unique(meta_syncref_qc$site)

glimpse(meta_syncref_qc)



# =====================
# Start and end times to filter detection data by:
# =====================

# Start time: get the latest release time recorded for urchins at each site and add 1 day as a buffer.
start <- meta_animal_qc |> 
  mutate(t_release = mdy_hm(release_time_utc)) |> 
  group_by(site) |> 
  reframe(start = min(t_release, na.rm = TRUE) + days(1))
# End time: get the earliest time a receiver was removed from the water per site and substract one day as a buffer
end <- meta_syncref_qc |> 
  mutate(t_out = mdy_hm(date_out)) |> 
  group_by(site) |> 
  reframe(end = max(t_out, na.rm = TRUE) - days(1))

start_end <- start |> 
  left_join(end, by = c("site"))


start_end








# =====================
# Detection data : urchins
# =====================

# import detection data for all urchins, Anse des pilotes (Quebec)
animal_pil <- read_csv(file = "./data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/animal/all.csv", show_col_types = FALSE)

animal_pil$tel_type = substring(animal_pil$FullId, 1, 1)
animal_pil$tel_type[animal_pil$tel_type == "A"] = "PPM"
animal_pil$tel_type[animal_pil$tel_type == "H"] = "HR"

animal_pil <-  animal_pil |> 
  rename(id = Id, x = X, y = Y, z = Z, t = Time, lon = Longitude, lat = Latitude, hpe = HPE, rmse = RMSE, ping_type = tel_type) |> 
  select(id, x, y, z, t, lon, lat, hpe, rmse, ping_type) |> 
  mutate(id = as.numeric(id))





# =====================
# Combine urchin metadata file with detection data and filter by start and end date-times
# =====================
all_sync6 = all_sync5 |>  
  mutate(t = ymd_hms(t)) |>  
  left_join(meta_stations01, by = "tag_id") |>  
  mutate(period = "July-Oct")



# Combine multiple sites together - not yet implemented
animal_data <- bind_rows(animal_pil)

#' Join urchin detections with tag metadata:
tmp <- animal_data  |>  
  left_join(meta_animal_qc, by = c("id", "ping_type"))

#' Rename data object, filter to only work with HR detections, and ensure object is ordered by detection
tmp2 <- tmp |>  
  filter(ping_type == "HR") |>  
  arrange(id, t)

#' Filter by start and end dates per site 
#' Combine these adjusted start and end times with the dataset, and filter all rows that do not fall within start and end times
animal_data <- tmp2 |> 
  left_join(start_end, by = c("site")) |> 
  filter(t > start & t < end) |> 
  select(-start, -end)








# =====================
# Detection data : Receivers
# =====================

# import detection data for all urchins, Anse des pilotes (Quebec)
syncref_pil <- read_csv(file = "./data/raw_data_downloads_bic_2022/vps_results_bic_2022/anse_des_pilotes/results/syncref/all.csv", show_col_types = FALSE)

syncref_pil$tel_type = substring(syncref_pil$FullId, 1, 1)
syncref_pil$tel_type[syncref_pil$tel_type == "A"] = "PPM"
syncref_pil$tel_type[syncref_pil$tel_type == "H"] = "HR"

syncref_pil <- syncref_pil |> 
  rename(id = Id, x = X, y = Y, z = Z, t = Time, lon = Longitude, lat = Latitude, hpe = HPE, hpem = HPEm, rmse = RMSE, ping_type = tel_type) |> 
  select(id, x, y, z, t, lon, lat, hpe, hpem, rmse, ping_type) |> 
  mutate(id = as.numeric(id))

glimpse(syncref_pil)

# Combine multiple sites together - not yet implemented
syncref_data <- bind_rows(syncref_pil)




# =====================
# Combine syncref metadata file with detection data and filter by start and end date-times
# =====================
#' Join syncref detections with syncref metadata:
tmp <- syncref_data  |>  
  left_join(meta_syncref_qc[, c(1:7)], by = c("id"))

#' Rename data object, filter to only work with HR detections, and ensure object is ordered by detection
tmp2 <- tmp |>  
  filter(ping_type == "HR") |>  
  arrange(id, t)

#' Filter by start and end dates per site 
#' Combine these adjusted start and end times with the dataset, and filter all rows that do not fall within start and end times
syncref_data <- tmp2 |> 
  left_join(start_end, by = c("site")) |> 
  filter(t > start & t < end) |> 
  select(-start, -end)

glimpse(syncref_data)









#' # Export combined datasets
#' ----------------------------------------------------

# =====================
# Export combined datasets
# =====================

write_csv(syncref_data, file = "./output/datasets/combined_sync_and_ref_data.csv")

write_csv(animal_data, file = "./output/datasets/combined_animal_data.csv")



