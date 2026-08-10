# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 22-04-2026
# Version	: 1
# URL		:
# Aim    	: To create CSV files of environmental data for 2024/2025
# ===============================================================================

library(here)

library(dplyr)
library(lubridate)
library(purrr)
library(ggplot2)


#### 2024/25 TCM and AM data ####
# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
# TCM current data
tcm_curr_2425 <- load.tcm.data(
  here("data/2024-25/TCM - current meter/"),
  "\\_Current.csv",
  c("Time", "Speed", "Heading", "V_N", "V_E", "Serial", "Sensor"),
  rewrite_sensor = TRUE
)
tcm_temp_2425 <- load.tcm.data(
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

# Load metadata
metadata <- read.table(
  here("data/2024-25/metadata_reorg.csv"),
  header = TRUE,
  sep = ","
)

# Initial clean - merge with metadata, lubridate date/time, exclude deployment/recovery date/times
source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
tcm_curr_2425 <- initial.clean(
  data = tcm_curr_2425,
  metadata,
  by.x = "Sensor",
  by.y = "description",
  year = 2024
)
tcm_temp_2425 <- initial.clean(
  tcm_temp_2425,
  metadata,
  by.x = "Serial",
  by.y = "description",
  year = 2024
)
am_sal <- initial.clean(
  am_sal,
  metadata,
  by.x = "Sensor",
  by.y = "description",
  year = 2024
)
am_temp <- initial.clean(
  am_temp,
  metadata,
  by.x = "Sensor",
  by.y = "description",
  year = 2024
)

# Round Aquameasure Datetime to nearest ten min mark
am_sal$DateTimeRounded <- round_date(
  parse_date_time(am_sal$Time, c("%Y-%m-%d %H:%M:%S", "%Y-%m-%d")),
  "10 minutes"
)
am_temp$DateTimeRounded <- round_date(
  parse_date_time(am_temp$Time, c("%Y-%m-%d %H:%M:%S", "%Y-%m-%d")),
  "10 minutes"
)
# Keep only necessary columns from Aquameasure
am_temp <- am_temp %>%
  select(
    Time,
    Sensor,
    Temperature,
    site,
    lat,
    lon,
    recovery_date,
    recovery_time,
    DateTime_recovered,
    DateTimeRounded
  ) %>%
  rename(DateTime = DateTimeRounded) %>%
  relocate(Temperature, .before = 1)
am_sal <- am_sal %>%
  select(
    No,
    Time,
    Time_Correction,
    Sensor,
    Salinity,
    site,
    lat,
    lon,
    recovery_date,
    recovery_time,
    DateTime_recovered,
    DateTimeRounded
  ) %>%
  rename(DateTime = DateTimeRounded)

# Select every ten minute from TCM
tcm_temp <- tcm_temp_2425[minute(tcm_temp_2425$DateTime) %% 10 == 0, ] %>%
  select(
    Time,
    Temperature,
    Serial,
    site,
    lat,
    lon,
    recovery_date,
    recovery_time,
    DateTime,
    DateTime_recovered
  ) %>%
  rename(Sensor = Serial) %>%
  relocate(DateTime_recovered, .before = 8)
tcm_curr <- tcm_curr_2425[minute(tcm_curr_2425$DateTime) %% 10 == 0, ] %>%
  select(
    Speed,
    Heading,
    V_N,
    V_E,
    Sensor,
    Serial,
    site,
    lat,
    lon,
    recovery_date,
    recovery_time,
    DateTime,
    DateTime_recovered
  )

# Group temperature
alltemp <- rbind(am_temp, tcm_temp)

# Separate by site
alltemp <- split(alltemp, list(alltemp$site))
tcm_curr <- split(tcm_curr, list(tcm_curr$site))
am_sal <- split(am_sal, list(am_sal$site))

# Remove current data from TCM4 for data that doesn't make sense
# Start April 8 - remove all before this
# Temperature
alltemp$rock <- alltemp$rock %>%
  filter(
    Sensor != "TCM4" | DateTime >= "2025-04-08"
  )
# Current
tcm_curr$rock <- tcm_curr$rock %>%
  filter(
    lubridate::as_datetime(DateTime) >= "2025-04-08"
  )

# Average same datetime rows and calculate moving average
source(here(
  "workflow/preprocessing-environmental_data/create-environmental-dataset.R"
))
alltemp_avg <- lapply(alltemp, average_samedt, col_name = "Temperature")
am_sal_avg <- lapply(am_sal, average_samedt, col_name = "Salinity")

# Rolling mean of current
source(here(
  "workflow/preprocessing-environmental_data/create-current-dataset.R"
))
tcm_curr_avg <- rollmean_current(tcm_curr)

# Remove between May 14 2025 12:00 and May 22 2025 16:
# Temperature
alltemp$rock <- alltemp$rock %>%
  filter(
    Sensor != "TCM4" |
      lubridate::as_datetime(DateTime) < "2025-05-13" |
      lubridate::as_datetime(DateTime) > "2025-05-22 16:00"
  )
# Current
tcm_curr_avg$rock <- tcm_curr_avg$rock %>%
  dplyr::filter(
    lubridate::as_datetime(DateTime) < "2025-05-13" |
      lubridate::as_datetime(DateTime) > "2025-05-22 16:00"
  )

# Save as csv file
cols_to_keep <- c(
  "lat",
  "lon",
  "Sensor",
  "rollmean_Temperature",
  "rollmean_Salinity",
  "Heading_roll_mean",
  "Speed_roll_mean"
)

source(here(
  "workflow/preprocessing-environmental_data/save-environmental-csv.R"
))
combined <- create_site_csv(
  curr = tcm_curr_avg,
  temp = alltemp_avg,
  sal = am_sal_avg,
  cols_to_keep = cols_to_keep,
  lat_col = "lat",
  long_col = "lon",
  serial_col = "Sensor"
)

# Plots
library(ggplot2)
library(plotly)
library(htmlwidgets)

# For salinity and temperature
for (site in names(alltemp_avg)) {
  site_data <- alltemp_avg[[site]]
  # Remove rows with zero values in data column
  #site_data <- site_data %>% filter(!is.na(temp_ma01))

  device_ids <- unique(site_data$Sensor)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Sensor == serial)

    plot_ly(
      data = df,
      x = ~DateTime,
      y = ~Temperature,
      type = "scatter",
      mode = "lines",
      name = unique(df$site), # Use the combined Type-Position as the name
      line = list(
        color = RColorBrewer::brewer.pal(n = length(device_ids), "Dark2")[i]
      )
    )
  })

  # Create annotations for each subplot
  annotations <- lapply(seq_along(device_ids), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / length(device_ids),
      text = paste("Device:", device_ids[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  # Combine all device plots into one subplot
  final_plot <- subplot(
    device_plots,
    nrows = length(device_ids),
    shareX = TRUE,
    shareY = TRUE,
    titleY = FALSE
  ) %>%
    layout(
      title = paste("Temperature Trend with Rolling Mean - Site:", site),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      #yaxis = list(title = "Salinity (psu)"),
      yaxis = list(title = "Temperature (°C)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0(site, "_temptrend.html")
  saveWidget(
    final_plot,
    file = here(paste0("output/plots/environmental_2024_25/", file_name)),
    selfcontained = TRUE
  )
  print(paste("saved plot", site))
}

# For current
library(tidyr)
for (site_label in names(tcm_curr_avg)) {
  site_data <- tcm_curr_avg[[site_label]]
  device_ids <- unique(site_data$Sensor)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>%
      filter(Sensor == serial) %>%
      arrange(DateTime) %>%
      complete(
        DateTime = seq(min(DateTime), max(DateTime), by = "10 mins") # adjust interval!
      )

    plot_ly() %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Heading_roll_mean,
        name = paste("Heading"),
        line = list(color = RColorBrewer::brewer.pal(n = 8, "Dark2")[1])
      ) %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Speed_roll_mean,
        name = paste("Speed"),
        yaxis = "y2",
        line = list(color = RColorBrewer::brewer.pal(n = 8, "Dark2")[2])
      ) %>%
      layout(
        yaxis = list(title = "Heading"),
        yaxis2 = list(
          title = "Speed",
          overlaying = "y",
          side = "right"
        )
      )
  })

  # Create annotations for each subplot
  annotations <- lapply(seq_along(device_ids), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / length(device_ids),
      text = paste("Device:", device_ids[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  # Combine all device plots into one subplot
  final_plot <- subplot(
    device_plots,
    nrows = length(device_ids),
    shareX = TRUE,
    titleY = FALSE
  ) %>%
    layout(
      title = paste("Current Trends - Site:", site_label),
      xaxis = list(title = "DateTime", rangeslider = list(visible = TRUE)),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0(site_label, "_current_furthercleaned.html")
  saveWidget(
    final_plot,
    file = here(paste0("output/plots/environmental_2024_25/", file_name)),
    selfcontained = TRUE
  )
  print(paste("saved plot", site_label))
}
