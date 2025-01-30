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

#####################
#### TCM devices ####
#####################
all.csv.files <- list.files(path = ".", pattern = "\\_Temperature.csv", recursive = TRUE,
                            ignore.case = TRUE, include.dirs = TRUE)

# Load all data
all.data <- data.frame()
for (file in all.csv.files) {
  data <- read.csv(file)

  ## Note: For Quebec TCM (sensory ID is in the file name)
  # Get sensor ID
  sensor.id <- gsub(".*?([0-9]+).*", "\\1", file)
  # Add sensor ID to column in data
  data$Sensor_ID <- sensor.id
  print(sensor.id)

  # Merge with metadata
  data <- merge(metadata, data, by = "Sensor_ID", all.y = TRUE)

  # Append to all.data
  if (nrow(all.data) == 0) {
    nrowbefore <- nrow(all.data)
    all.data <- data
  } else {
    nrowbefore <- nrow(all.data)
    all.data <- rbind(all.data, data)
  }

  # Print check
  print(paste("Added right number of rows: ", nrow(all.data) - nrowbefore == nrow(data)))
}

# Change Time column from displaying "2022-07-29T00:00:00.000" to "2022-07-29 00:00:00.000"
all.data$DateTime <- as.POSIXct(gsub("T", " ", all.data$ISO.8601.Time))
# 724091 points


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

# Remove points between time


##########################
#### Merging all data ####
##########################

# Rename columns to match
names(all.data)[names(all.data) == 'Temperature..C.'] <- 'Temperature'
names(all.data.am)[names(all.data.am) == 'Temperature..degC.'] <- 'Temperature'
names(all.data.am)[names(all.data.am) == 'Time..UTC.'] <- 'DateTime'

# Keep only some columns
col.keep <- c("Sensor_ID", "Type", "Site", "Position", "Date_deployed", "Time_deployed_UTC",
              "Date_recovered", "DateTime", "Temperature")
all.data <- subset(all.data, select = col.keep)
all.data.am <- subset(all.data.am, select = col.keep)

# Make sure all columns with date/time are in POSIX tz = UTC
all.data.am$DateTime <- as.POSIXct(all.data.am$DateTime, tz = "UTC")

# Merge to all.data
all.data.merged <- rbind(all.data, all.data.am)
all.data.merged$Date_deployed <- as.POSIXct(all.data.merged$Date_deployed, format = "%Y-%m-%d")
all.data.merged$Date_recovered <- as.POSIXct(all.data.merged$Date_recovered, format = "%Y-%m-%d")

### NEED TO SWITCH TO INDIVIDUAL DEVICES
# Remove points from outside deployment time
all.data.cleaned <- subset(all.data.merged,
                           all.data.merged$DateTime > all.data.merged$Date_deployed & all.data.merged$Date_recovered > all.data.merged$DateTime)

# Are they all unique DateTime + Site?
#print(nrow(unique(all.data.cleaned[, c("DateTime", "Site")])) == nrow(all.data.cleaned))


#### Plotting ####
# Split the data by Site
all.data.cleaned <- split(all.data.cleaned, all.data.cleaned$Site)

# Plot by site
# Determine the number of dataframes
n_plots <- length(all.data.cleaned)

# Calculate the number of rows and columns for the plot grid
n_cols <- ceiling(sqrt(n_plots))
n_rows <- ceiling(n_plots / n_cols)

# Set up the plot grid
par(mfrow = c(n_rows, n_cols))

# Plot each dataframe
for (df in all.data.cleaned) {
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
