# ===============================================================================
# Name   	: Import and preprocess receivers and urchins metadata - CSRF QC-BC
# Author 	: Marie-Fracnce Lavoie
# Date   	: 2025-02-07 [yyyy-mm-dd]
# Version	:
# URL		:
# Aim    	: - Import receivers metadata for each region
#           - Clean the files and put all the data together
#           - Create a file with the adjusted coordinates for each station from VPS results
# ===============================================================================


#' ## Import receivers data
#' ----------------------------------------------------

# **IMPORTANT TO UPLOAD THE LAST VERSION ON AZURE of all the metadata**


# =====================
# load data
# =====================

# Import receivers metadata for Quebec 2022
rece_qc <- read.csv("./data/metadata_receivers_QC2022.csv", sep = ";")

# Import receivers metadata for BC 2023
rece_bc <- read.csv("./data/metadata_receivers_BC2023.csv", sep = ";")

# Import adjusted receivers coordinates from VPS sheet QC 2022 - VEMCO (on Azure)
vps_rece_qc <- read.csv("./data/vps_metadata_VEMCO_QC2022.csv", sep = ";")

# Import adjusted receivers coordinates from VPS sheet BC 2023 - VEMCO (on Azure)
# We only have the VPS coordinates for Tugwell-1 and Marina-2
vps_rece_bc <- read.csv("./data/vps_metadata_VEMCO_BC2023.csv", sep = ";")

# Import urchins metadata for Quebec 2022
meta_animal_qc <- read.csv(file = "./data/metadata_urchins_QC2022.csv")

# Import urchins metadata for BC 2022
meta_animal_bc <- read.csv(file = "./data/metadata_urchins_BC2023.csv", sep = ";")


# =====================
# Clean receivers metadata and combine the QC and BC
# =====================

# QC metadata
glimpse(rece_qc)
Year <- data.frame(matrix(2022, nrow = 42, ncol = 1)) #create a dataframe with the year
Region <- data.frame(matrix("QC", nrow = 42, ncol = 1)) #create a dataframe with the region
rece_qc <- cbind(Year, Region, rece_qc)

rece_qc <- rece_qc[, c(2, 1, 3, 4, 6, 7, 8, 9, 10, 11, 17, 19, 20, 24)]
names(rece_qc)[1] <- "Region"
names(rece_qc)[2] <- "Year"
names(rece_qc)[5] <- "stn"
names(rece_qc)[8] <- "deploy_date"
names(rece_qc)[9] <- "lat"
names(rece_qc)[10] <- "lon"
names(rece_qc)[11] <- "Instrument_depth"
names(rece_qc)[14] <- "recov_date"

rece_qc$SITE[rece_qc$SITE == 'Bic, La Baleine'] <- 'Bic'
rece_qc$SITE[rece_qc$SITE == 'Bic, Anse des Pilotes'] <- 'Bic'
rece_qc$SITE[rece_qc$SITE == '\xcele-aux-li\xe8vres, NE'] <- 'Cacouna'
rece_qc$SITE[rece_qc$SITE == '\xcele-aux-li\xe8vres, SW'] <- 'Cacouna'


# BC metadata
glimpse(rece_bc)
Year_bc <- data.frame(matrix(2023, nrow = 44, ncol = 1)) #create a dataframe with the year
Region_bc <- data.frame(matrix("BC", nrow = 44, ncol = 1)) #create a dataframe with the region
Site_bc1 <- data.frame(matrix("Tugwell", nrow = 22, ncol = 1)) #create a dataframe with the Site Tugwell
names(Site_bc1)[1] <- "SITE"
Site_bc2 <- data.frame(matrix("Marina", nrow = 22, ncol = 1)) #create a dataframe with the Site Marina
names(Site_bc2)[1] <- "SITE"
Site_bc <- rbind(Site_bc1, Site_bc2)
rece_bc <- cbind(Region_bc, Year_bc, Site_bc, rece_bc)

rece_bc <- rece_bc[, c(1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 14, 16, 17, 21)]
names(rece_bc)[1] <- "Region"
names(rece_bc)[2] <- "Year"
names(rece_bc)[4] <- "Site_2"
names(rece_bc)[5] <- "stn"
names(rece_bc)[6] <- "Station_Pos"
names(rece_bc)[7] <- "Position"
names(rece_bc)[8] <- "deploy_date"
names(rece_bc)[9] <- "lat"
names(rece_bc)[10] <- "lon"
names(rece_bc)[11] <- "Instrument_depth"
names(rece_bc)[14] <- "recov_date"

# Combine Qc and BC receivers metadata
receivers_metadata <- rbind(rece_qc, rece_bc)


# =====================
# Clean VPS metadata and combine QC and BC
# =====================

# QC VPS metadata
glimpse(vps_rece_qc)

# BC VPS metadata
glimpse(vps_rece_bc)

# Combine data
vps_rece_metadata <- rbind(vps_rece_qc, vps_rece_bc)


# =====================
# Clean urchins metadata and combine QC and BC
# =====================

# HR2 tags have both a HR and a PPM ping, designated by A or H in the code space column

# Extract this info to be able to separate HR2 data from PPM data - QC metadata
meta_animal_qc$code_type <- substring(meta_animal_qc$VUE.Tag.ID, 1, 1) # Extract A or H coding
meta_animal_qc$tel_type <- 'NA' # create new column for tag-type info
meta_animal_qc$tel_type[meta_animal_qc$code_type == "A"] = "PPM" # populate with A=PPM pings
meta_animal_qc$tel_type[meta_animal_qc$code_type == "H"] = "HR" # and H=HR pings

# Add a general site column
meta_animal_qc$site <- meta_animal_qc$CAPTURE_LOCATION
meta_animal_qc$site[meta_animal_qc$site == 'BIC-BAL'] <- 'Bic'
meta_animal_qc$site[meta_animal_qc$site == 'BIC-PIL'] <- 'Bic'
meta_animal_qc$site[meta_animal_qc$site == 'ILA-NE'] <- 'Cacouna'
meta_animal_qc$site[meta_animal_qc$site == 'ILA-SW'] <- 'Cacouna'

# Change the date format
meta_animal_qc$UTC_RELEASE_DATE_TIME = mdy_hm(meta_animal_qc$UTC_RELEASE_DATE_TIME)

# Rename columns for ease of coding and select a restricted number of columns
meta_animal_qc  <- meta_animal_qc %>%
  rename(id = TAG_ID_CODE, diam = `LENGTH..m.`, serial = Serial,
         ping_type = tel_type, tagger = TAGGER, spp_com = COMMON_NAME_E, spp_sci = SCIENTIFIC_NAME, site_2 = CAPTURE_LOCATION,
         trt_col = TREATMENT_TYPE, dist_fct = RELEASE_LOCATION, release_time_utc = UTC_RELEASE_DATE_TIME) %>%
  mutate(diam_mm = diam*1000) |>
  select(site, site_2, spp_com, spp_sci, dist_fct, trt_col, id, serial, diam_mm, ping_type, release_time_utc, tagger)  |>
  mutate(id = as.numeric(id)) # to merge with detection file, ensure id is a numeric column

# Put same name than for receiver metadata site_2
meta_animal_qc$site_2[meta_animal_qc$site_2 == 'BIC-BAL'] <- 'Baleine'
meta_animal_qc$site_2[meta_animal_qc$site_2 == 'BIC-PIL'] <- 'Pilotes'
meta_animal_qc$site_2[meta_animal_qc$site_2 == 'ILA-NE'] <- 'NE'
meta_animal_qc$site_2[meta_animal_qc$site_2 == 'ILA-SW'] <- 'SW'

glimpse(meta_animal_qc)


# Extract this info to be able to separate HR2 data from PPM data - BC metadata
meta_animal_bc$code_type <- substring(meta_animal_bc$VUE.Tag.ID, 1, 1) # Extract A or H coding
meta_animal_bc$tel_type <- 'NA' # create new column for tag-type info
meta_animal_bc$tel_type[meta_animal_bc$code_type == "A"] = "PPM" # populate with A=PPM pings
meta_animal_bc$tel_type[meta_animal_bc$code_type == "H"] = "HR" # and H=HR pings

# Add a general site column
meta_animal_bc$site <- meta_animal_bc$CAPTURE_LOCATION
meta_animal_bc$site[meta_animal_bc$site == 'Tugwell-1'] <- 'Tugwell'
meta_animal_bc$site[meta_animal_bc$site == 'Tugwell-2'] <- 'Tugwell'
meta_animal_bc$site[meta_animal_bc$site == 'Marina-1'] <- 'Marina'
meta_animal_bc$site[meta_animal_bc$site == 'Marina-2'] <- 'Marina'

# Rename columns for ease of coding and select a restricted number of columns
meta_animal_bc  <- meta_animal_bc %>%
  rename(id = TAG_ID_CODE, diam = `LENGTH..m.`, serial = Serial,
         ping_type = tel_type, tagger = TAGGER, spp_com = COMMON_NAME_E, spp_sci = SCIENTIFIC_NAME, site_2 = CAPTURE_LOCATION,
         trt_col = TREATMENT_TYPE, dist_fct = RELEASE_LOCATION, release_time_utc = UTC_RELEASE_DATE_TIME) %>%
  mutate(diam_mm = diam*1000) |>
  select(site, site_2, spp_com, spp_sci, dist_fct, trt_col, id, serial, diam_mm, ping_type, release_time_utc, tagger)  |>
  mutate(id = as.numeric(id)) # to merge with detection file, ensure id is a numeric column

glimpse(meta_animal_bc)

# Combine data
urchin_metadata <- rbind(meta_animal_qc, meta_animal_bc)


# =====================
# Save data
# =====================

write_csv(receivers_metadata, file = "./output/datasets/combined_receivers_metadata_QC_BC.csv")

write_csv(vps_rece_metadata, file = "./output/datasets/combined_VPS_receivers_metadata_QC_BC.csv")

write_csv(urchin_metadata, file =  "./output/datasets/combined_urchin_metadata_QC_BC.csv")
