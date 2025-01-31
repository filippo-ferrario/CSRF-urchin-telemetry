# ===============================================================================
# Name   	: Clean temperature
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 30-01-2025
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

### Folder structure
# C:/Users/shaoj/Documents/csrf_urchin/
# - bc
#   - quadra-marina1
#     - aquameasure
#     - star_oddi
#     - TCM
#   - quadra-marina2
#     ...
#   - tugwell-1
#     ...
#   - tugwell-2
#     ...
#   - metadata_sensors_BC2023.csv
# - qc
#   - anse-des-pilotes
#     ...
#   - cacouna-northeast
#     ...
#   - cacouna-southwest
#     ...
#   - la-baleine
#     ...
#   - metadata_sensors_QC2022.csv

setwd("C:/Users/shaoj/Documents/csrf_urchin/qc/")

metadata <- read.csv("./metadata_sensors_QC2022.csv")

# Function to convert time strings
convert_time <- function(time_str) {
  if (time_str == "") {
    return("")
  }

  # Correct time zone and extract time
  time_str <- gsub("Hest", "", time_str)
  time_str <- trimws(time_str)
  time_str <- paste0(time_str, ":00")

  return(time_str)
}

# Apply conversion to the column
metadata$Time_deployed_POSIX <- sapply(metadata$Time_deployed_UTC, convert_time)

# Create a new datetime column
metadata$DateTime_deployed <- as.POSIXct(paste(metadata$Date_deployed, metadata$Time_deployed_POSIX), format = "%Y-%m-%d %H:%M:%S")

#####################
#### TCM devices ####
#####################
all.csv.tcm <- list.files(path = ".", pattern = "\\_Temperature.csv", recursive = TRUE,
                          ignore.case = TRUE, include.dirs = TRUE)

# Load all data
all.data.tcm <- data.frame()
for (file in all.csv.tcm) {
  data <- read.csv(file)

  ## Note: For Quebec TCM (sensory ID is in the file name)
  # Get sensor ID
  sensor.id <- gsub(".*?([0-9]+).*", "\\1", file)
  # Add sensor ID to column in data
  data$Sensor_ID <- sensor.id
  print(sensor.id)

  # Merge with metadata
  data <- merge(metadata, data, by = "Sensor_ID", all.y = TRUE)

  # Append to all.data.tcm
  if (nrow(all.data.tcm) == 0) {
    nrowbefore <- nrow(all.data.tcm)
    all.data.tcm <- data
  } else {
    nrowbefore <- nrow(all.data.tcm)
    all.data.tcm <- rbind(all.data.tcm, data)
  }

  # Print check
  print(paste("Added right number of rows: ", nrow(all.data.tcm) - nrowbefore == nrow(data)))
}

# Change Time column from displaying "2022-07-29T00:00:00.000" to "2022-07-29 00:00:00.000"
all.data.tcm$DateTime <- as.POSIXct(gsub("T", " ", all.data.tcm$ISO.8601.Time))
# 724091 points

# Remove points from outside deployment time
all.data.tcm.cleaned <- subset(all.data.tcm,
                               all.data.tcm$DateTime > all.data.tcm$Date_deployed & all.data.tcm$Date_recovered > all.data.tcm$DateTime)

#############################
#### AquaMeasure devices ####
#############################
all.csv.am <- list.files(path = ".", pattern = ".*aquaMeasure.*\\.csv$", recursive = TRUE,
                               ignore.case = TRUE, include.dirs = TRUE)

# Load all data
all.data.am <- data.frame()
for (file in all.csv.am) {
  data <- read.csv(file)

  # Merge with metadata for AquaMeasure devices
  data <- merge(x = metadata, y = data,
                  by.x = "Sensor_ID", by.y = "Serial.Number",
                  all.y = TRUE)

  # Append to all.data.am
  if (nrow(all.data.am) == 0) {
    nrowbefore <- nrow(all.data.am)
    all.data.am <- data
  } else {
    nrowbefore <- nrow(all.data.am)
    all.data.am <- rbind(all.data.am, data)
  }

  # Print check
  print(paste("Added right number of rows: ", nrow(all.data.am) - nrowbefore == nrow(data)))
}

# Make sure column with data point date/time are in POSIX tz = UTC
all.data.am$DateTime <- as.POSIXct(all.data.am$Time..UTC., tz = "UTC")

# Remove points from outside deployment time
all.data.am.cleaned <- all.data.am[(is.na(all.data.am$DateTime_deployed) & all.data.am$DateTime > all.data.am$Date_deployed & all.data.am$DateTime < all.data.am$Date_recovered) |
                  (!is.na(all.data.am$DateTime_deployed) & all.data.am$DateTime > all.data.am$DateTime_deployed & all.data.am$DateTime < all.data.am$Date_recovered), ]


##########################
#### Merging all data ####
##########################

# Rename columns to match
names(all.data.tcm.cleaned)[names(all.data.tcm.cleaned) == 'Temperature..C.'] <- 'Temperature'
names(all.data.am.cleaned)[names(all.data.am.cleaned) == 'Temperature..degC.'] <- 'Temperature'
names(all.data.am.cleaned)[names(all.data.am.cleaned) == 'Time..UTC.'] <- 'DateTime'

# Keep only some columns
col.keep <- c("Sensor_ID", "Type", "Site", "Position", "DateTime", "Temperature")
all.data.tcm.cleaned <- subset(all.data.tcm.cleaned, select = col.keep)
all.data.am.cleaned <- subset(all.data.am.cleaned, select = col.keep)

# Merge to all.data
all.data.merged <- rbind(all.data.tcm.cleaned, all.data.am.cleaned)

# Are they all unique DateTime + Site?
#print(nrow(unique(all.data.cleaned[, c("DateTime", "Site")])) == nrow(all.data.cleaned))


#### Plotting ####
# Split the data by Site
all.data.merged <- split(all.data.merged, all.data.merged$Site)

# Plot by site
# Determine the number of dataframes
n_plots <- length(all.data.merged)

# Calculate the number of rows and columns for the plot grid
n_cols <- ceiling(sqrt(n_plots))
n_rows <- ceiling(n_plots / n_cols)

# Set up the plot grid
par(mfrow = c(n_rows, n_cols))

# Plot each dataframe
for (df in all.data.merged) {
  plot(df$DateTime, df$Temperature,
       xlab = "Date", ylab = "Temperature",
       main = paste("Site:", unique(df$Site)))
}
# Reset the plotting parameters
par(mfrow = c(1, 1))



##########################
#### StarOddi devices ####
##########################
all.csv.staroddi <- list.files(path = ".", pattern = "\\_exported.csv", recursive = TRUE,
                               ignore.case = TRUE, include.dirs = TRUE)

# Load all data
all.data.staroddi <- data.frame()
for (file in all.csv.staroddi) {
  # Specific for StarOddi
  data <- read.csv(file, sep = ";", check.names = FALSE)
  names(data) <- iconv(names(data), to = "ASCII", sub = "")

  # Specific for StarOddi
  # Get sensor ID
  sensor.id <- gsub("^.*/([^_]*)_.*$", "\\1", file)
  # Add sensor ID to column in data
  data$Sensor_ID <- sensor.id
  print(sensor.id)

  # Merge with metadata
  data <- merge(metadata, data, by = "Sensor_ID", all.y = TRUE)

  # Append to all.data.staroddi
  if (nrow(all.data.staroddi) == 0) {
    nrowbefore <- nrow(all.data.staroddi)
    all.data.staroddi <- data
  } else {
    nrowbefore <- nrow(all.data.staroddi)
    all.data.staroddi <- rbind(all.data.staroddi, data)
  }

  # Print check
  print(paste("Added right number of rows: ", nrow(all.data.staroddi) - nrowbefore == nrow(data)))
}
