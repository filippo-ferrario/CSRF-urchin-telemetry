# ===============================================================================
# Name   	: Create current dataset
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 04-21-2026
# Version	: 1
# URL		  :
# Aim    	: Calculate moving averages
# Input   : Dataframe data vector of files
#           year integer 2023 or 2024
# Output  : Dataframe
# ================================================================================

create_currdataset <- function(data, year) {
  # Load TCM current data
  source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
  temp1 <- load.tcm.data(
    here(data[1]),
    "\\_Current.csv",
    c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
  )
  temp2 <- load.tcm.data(
    here(data[2]),
    "\\_Current.csv",
    c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial")
  )
  TCM_current <- rbind(temp1, temp2)

  # Load metadata
  metadata <- read.csv(here(data[3]), sep = ";")

  # Initial clean - merge with metadata, lubridate date/time, exclude based on deployment/recovery time
  source(here(
    "workflow/preprocessing-environmental_data/clean-environmental.R"
  ))
  TCM_current <- initial.clean(TCM_current, metadata, year = year)

  # Select every ten minute
  TCM_current <- TCM_current[minute(TCM_current$DateTime) %% 10 == 0, ]

  # Separate by site
  grouped_current <- split(TCM_current, TCM_current$Site)

  return(grouped_current)
}

# Function to create columns with rolling mean and standard deviation for Heading and Speed
rollmean_current <- function(data) {
  data <- lapply(data, function(df) {
    df %>%
      mutate(across(
        .cols = c(Heading, Speed),
        .fns = list(
          roll_mean = ~ zoo::rollmean(.x, k = 3, fill = NA, align = "right"),
          roll_sd = ~ zoo::rollapply(
            .x,
            width = 3,
            FUN = sd,
            fill = NA,
            align = "right"
          )
        ),
        .names = "{.col}_{.fn}"
      ))
  })
  return(data)
}
