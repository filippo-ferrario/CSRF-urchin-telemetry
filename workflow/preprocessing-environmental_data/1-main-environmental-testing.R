library(here)

library(lubridate)
library(assertthat)

#### Testing ####
# Load metadata
metadata <- read.table(
  here("data/2024-25/metadata_reorg.csv"),
  header = TRUE,
  sep = ","
)
# Load original temp/sal data
# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
tcm_temp <- load.tcm.data(
  here("data/2024-25/TCM - current meter/"),
  "\\_Temperature.csv",
  c("Time", "Temperature", "Sensor", "Serial"),
  rewrite_sensor = TRUE
)

# Load AquaMeasure data
source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
am_2425 <- load.aqua.data(
  here("data/2024-25/Aquameasure"),
  c(
    "No",
    "Time",
    "Time_Correction",
    "Sensor",
    "Record_Type",
    "Salinity",
    "Temperature",
    "Tilt",
    "Battery",
    "TimeSet",
    "Time_Blank",
    "Text"
  ),
  rewrite_sensor = TRUE
)
# Separate AquaMeasure into salinity and temperature
am_sal <- am_2425[am_2425$Record_Type == "Salinity", ] %>% select(-Temperature)
am_temp <- am_2425[am_2425$Record_Type == "Temperature", ] %>% select(-Salinity)

# Load original current data
# TCM current data
tcm_curr <- load.tcm.data(
  here("data/2024-25/TCM - current meter/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Serial", "Sensor"),
  rewrite_sensor = TRUE
)

# Merge with metadata - check if each device only at one site, assert equals number of devices
tcm_temporary <- tcm_temp %>%
  left_join(metadata, by = setNames("description", "Serial"))
assert_that(nrow(unique(tcm_temporary[, c("site", "Serial")])) == 4)
tcm_temporary <- tcm_curr %>%
  left_join(metadata, by = setNames("description", "Serial"))
assert_that(nrow(unique(tcm_temporary[, c("site", "Serial")])) == 4)
am_temporary <- am_sal %>%
  left_join(metadata, by = setNames("description", "Sensor"))
assert_that(nrow(unique(am_temporary[, c("site", "Sensor")])) == 6)
am_temporary <- am_temp %>%
  left_join(metadata, by = setNames("description", "Sensor"))
assert_that(nrow(unique(am_temporary[, c("site", "Sensor")])) == 6)
# Split by serial
tcm_temp <- split(tcm_temp, list(tcm_temp$Serial))
tcm_curr <- split(tcm_curr, list(tcm_curr$Serial))
am_sal <- split(am_sal, list(am_sal$Sensor))
am_temp <- split(am_temp, list(am_temp$Sensor))

# Load cleaned data
drift1 <- read.csv(here("output/datasets/environmental/drift-1.csv"))
drift2 <- read.csv(here("output/datasets/environmental/drift-2.csv"))
rock <- read.csv(here("output/datasets/environmental/rock.csv"))
sand <- read.csv(here("output/datasets/environmental/sand.csv"))

# Previously used to compare datasets (expected to get no differences in summary)
c_drift1 <- read.csv(here("output/datasets/drift-1.csv"))
c_drift2 <- read.csv(here("output/datasets/drift-2.csv"))
c_rock <- read.csv(here("output/datasets/rock.csv"))
c_sand <- read.csv(here("output/datasets/sand.csv"))
#
# library(arsenal)
# summary(arsenal::comparedf(drift1, c_drift1))
# summary(arsenal::comparedf(drift2, c_drift2))
summary(arsenal::comparedf(rock, c_rock))
# summary(arsenal::comparedf(sand, c_sand))

# Every sensor exists
unique(drift2$Sensor_curr)
unique(drift2$Sensor_temp)
unique(drift2$Sensor_sal)
# Assert that both aquameasure and tcm for the correct site have been used in temperature for rock/sand
assert_that(
  setequal(
    metadata[metadata$site == "rock", "description"],
    strsplit(as.list(unique(rock$Sensor_temp))[[1]], ",\\s*")[[1]]
  )
)
print(unique(rock$Sensor_temp))
assert_that(
  setequal(
    metadata[metadata$site == "sand", "description"],
    strsplit(as.list(unique(sand$Sensor_temp))[[1]], ",\\s*")[[1]]
  )
)
print(unique(sand$Sensor_temp))
# Assert both aquameasure used for salinity
assert_that(
  setequal(
    expected <- c("1aquaMeasure", "4aquaMeasure"),
    strsplit(as.list(unique(rock$Sensor_sal))[[1]], ",\\s*")[[1]]
  )
)
print(unique(rock$Sensor_sal))
assert_that(
  setequal(
    expected <- c("2aquaMeasure", "3aquaMeasure"),
    strsplit(as.list(unique(sand$Sensor_sal))[[1]], ",\\s*")[[1]]
  )
)
print(unique(sand$Sensor_sal))
# Assert that correct single tcm for current
assert_that(unique(na.omit(rock$Sensor_curr)) == "TCM4")
assert_that(unique(na.omit(sand$Sensor_curr)) == "TCM3")

# Assert that correct aquameasure is used for correct site for salinity
assert_that(unique(na.omit(drift1$Sensor_sal)) == "7aquaMeasure")
assert_that(unique(na.omit(drift2$Sensor_sal)) == "8aquaMeasure")
# Assert that correct TCM is used for correct site for current
assert_that(unique(na.omit(drift1$Sensor_curr)) == "TCM5")
assert_that(unique(na.omit(drift2$Sensor_curr)) == "TCM2")
# Assert that correct TCM AND aquameasure used for correct site for temperature
assert_that(
  setequal(
    metadata[metadata$site == "drift-1", "description"],
    unique(trimws(unlist(strsplit(na.omit(drift1$Sensor_temp), ",\\s*"))))
  )
)
print(unique(drift1$Sensor_temp))
assert_that(
  setequal(
    metadata[metadata$site == "drift-2", "description"],
    unique(trimws(unlist(strsplit(na.omit(drift2$Sensor_temp), ",\\s*"))))
  )
)
print(unique(drift2$Sensor_temp))

# Starts 24hrs after devices put in
# Assert first value for each device is more than 24 hours before recovery date/time
assert_that(
  as_datetime(metadata[metadata$description == "TCM5", ]$date) + days(1) <=
    drift1[which(drift1$Sensor_curr == "TCM5")[1], ]$DateTime
)
print(as_datetime(metadata[metadata$description == "TCM5", ]$date) + days(1))
print(drift1[which(drift1$Sensor_curr == "TCM5")[1], ]$DateTime)

# Ends 24hrs before recovery date and time (from metadata)
# Assert last value for each device is less than 24 hours before recovery date/time
assert_that(
  as_datetime(
    paste(
      metadata[metadata$description == "TCM5", "recovery_date"],
      metadata[metadata$description == "TCM5", "recovery_time"]
    ),
    format = "%Y-%m-%d %H:%M"
  ) -
    days(1) >=
    as_datetime(drift1[which(drift1$Sensor_curr == "TCM5"), ]$DateTime[nrow(
      drift1
    )])
)
print(
  as_datetime(
    paste(
      metadata[metadata$description == "TCM5", "recovery_date"],
      metadata[metadata$description == "TCM5", "recovery_time"]
    ),
    format = "%Y-%m-%d %H:%M"
  ) -
    days(1)
)
print(as_datetime(drift1[which(drift1$Sensor_curr == "TCM5"), ]$DateTime[nrow(
  drift1
)]))


# Assert that there is one row every 10mins from metadata start/end times
end <- as_datetime(
  paste(
    min(metadata[metadata$site == "drift-1", "recovery_date"]),
    min(metadata[metadata$site == "drift-1", "recovery_time"])
  ),
  format = "%Y-%m-%d %H:%M",
  tz = "UTC"
) -
  days(1)
start <- as_datetime(min(metadata[metadata$site == "drift-1", "date"])) +
  days(1)
num_ten <- as.numeric(difftime(end, start, units = "mins")) / 10
assert_that(nrow(drift1) == floor(num_ten))

# Assert that there is one row every 10mins from metadata start/end times
end <- round_date(
  as_datetime(
    paste(
      min(metadata[metadata$site == "drift-2", "recovery_date"]),
      min(metadata[metadata$site == "drift-2", "recovery_time"])
    ),
    format = "%Y-%m-%d %H:%M",
    tz = "UTC"
  ) -
    days(1),
  "10 minutes"
)
start <- as_datetime(min(metadata[metadata$site == "drift-2", "date"])) +
  days(1)
num_ten <- as.numeric(difftime(end, start, units = "mins")) / 10
assert_that(nrow(drift2) == floor(num_ten))

assert_that(length(unique(drift1$DateTime)) == nrow(drift1))
assert_that(length(unique(drift2$DateTime)) == nrow(drift2))
assert_that(length(unique(sand$DateTime)) == nrow(sand))
assert_that(length(unique(rock$DateTime)) == nrow(rock))
assert_that(length(which(is.na(drift1$DateTime))) == 0)
assert_that(length(which(is.na(drift2$DateTime))) == 0)
assert_that(length(which(is.na(sand$DateTime))) == 0)
assert_that(length(which(is.na(rock$DateTime))) == 0)

# Check for NA values
which(is.na(drift1$rollmean_Salinity))
which(is.na(drift1$rollmean_Temperature))
which(is.na(drift1$Heading_roll_mean))
which(is.na(drift1$Speed_roll_mean))

which(is.na(drift2$rollmean_Salinity))
which(is.na(drift2$rollmean_Temperature))
which(is.na(drift2$Heading_roll_mean))
which(is.na(drift2$Speed_roll_mean))

which(is.na(rock$rollmean_Salinity))
which(is.na(rock$rollmean_Temperature))
which(is.na(rock$Heading_roll_mean)) # missing after recovery
which(is.na(rock$Speed_roll_mean))

which(is.na(sand$rollmean_Salinity))
which(is.na(sand$rollmean_Temperature))
which(is.na(sand$Heading_roll_mean))
which(is.na(sand$Speed_roll_mean))


rock[
  is.na(rock$Heading_roll_mean) &
    as_datetime(rock$DateTime) %in% tcm_curr$rock$DateTime,
]

sand[
  is.na(sand$Heading_roll_mean) &
    as_datetime(sand$DateTime) %in% tcm_curr$sand$DateTime,
]
