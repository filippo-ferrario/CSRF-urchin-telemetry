# ===============================================================================
# Name   	: Discussion Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-02-2024
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

library(here)

library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)
library(circular)

library(plotly)
library(dplyr)
library(htmlwidgets)

# Load TCM data
source(here("workflow/preprocessing-environmental_data/load-TCM.R"))
# TCM current data
temp1 <- load.tcm.data(here("data/raw_data_downloads_prince_rupert_2023/"),
                       "\\_Current.csv",
                       c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_quadra_2023/"),
                       "\\_Current.csv",
                       c("Time", "Speed", "Heading", "V_N", "V_E", "Sensor", "Serial"))
TCM_current <- rbind(temp1, temp2)

# TCM temperature data
# NOTE: !!!! IF THIS DOESN'T WORK, open clean-environmental.R and change line 38
# For BC: filter(DateTime > ymd_hms(DateTime_deployed) + days(1)) %>%
# For QC: filter(DateTime > ymd(DateTime_deployed) + days(1)) %>%
temp1 <- load.tcm.data(here("data/raw_data_downloads_prince_rupert_2023/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
temp2 <- load.tcm.data(here("data/raw_data_downloads_quadra_2023/"),
                       "\\_Temperature.csv",
                       c("Time", "Temperature", "Sensor", "Serial"))
TCM_temp <- rbind(temp1, temp2)

# Load StarOddi data
source(here("workflow/preprocessing-environmental_data/load-staroddi.R"))
temp1 <- load.star.data(here("data/raw_data_downloads_prince_rupert_2023/"))
temp2 <- load.star.data(here("data/raw_data_downloads_quadra_2023/"))
star <- rbind(temp1, temp2)

# Load AquaMeasure data
source(here("workflow/preprocessing-environmental_data/load-aquameasure.R"))
temp1 <- load.aqua.data(here("data/raw_data_downloads_prince_rupert_2023/"))
temp2 <- load.aqua.data(here("data/raw_data_downloads_quadra_2023/"))
aqua <- rbind(temp1, temp2)

# Load metadata
metadata <- read.csv(here("data/metadata_sensors_BC2023.csv"), sep = ";")

# Initial clean - merge with metadata, lubridate date/time, exclude deployment/recovery date/times
source(here("workflow/preprocessing-environmental_data/clean-environmental.R"))
TCM_current <- initial.clean(TCM_current, metadata)
TCM_temp <- initial.clean(TCM_temp, metadata)
aqua <- initial.clean(aqua, metadata)
star <- initial.clean(star, metadata, star = TRUE)

# Calculate moving averages
source(here("workflow/preprocessing-environmental_data/calculate-moving-averages.R"))
TCM_current <- calculate.moving.avg(TCM_current, 'tcm-current')
TCM_temp <- calculate.moving.avg(TCM_temp, 'tcm-temperature')
aqua <- calculate.moving.avg(aqua, 'aquameasure')
star <- calculate.moving.avg(star, 'staroddi')

# Combine all temperature
temp <- TCM_temp %>%
  select(Serial, Type, DateTime, Temperature, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Temp = Temperature)
temp1 <- star %>%
  select(Sensor, Type, DateTime, Temp, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Serial = Sensor)
temp2 <- aqua %>%
  select(Serial, Model, DateTime, Temp, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Type = Model)
all_temp <- bind_rows(temp, temp1, temp2)

#### ONLY FOR QUEBEC
# Remove Pilotes StarOddi - G
#all_temp <- all_temp %>%
#  filter(!(Site == "Pilotes" & Position == "G"))

# Combine all salinity
temp1 <- star %>%
  select(Sensor, Type, DateTime, Sal, sal_ma01, sal_ma02, sal_ma03, sal_ma04, Site, Position) %>%
  rename(Serial = Sensor)
temp2 <- aqua %>%
  select(Serial, Model, DateTime, Sal, sal_ma01, sal_ma02, sal_ma03, sal_ma04, Site, Position) %>%
  rename(Type = Model)
all_sal <- bind_rows(temp1, temp2)


#### Calculate difference between devices ####
# Combine all temperature
temp <- TCM_temp %>%
  select(Serial, Type, DateTime, Temperature, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Temp = Temperature)
temp$roundedDateTime <- round(temp$DateTime, "mins")
temp1 <- star %>%
  select(Sensor, Type, DateTime, Temp, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Serial = Sensor)
temp1$roundedDateTime <- round(temp1$DateTime, "mins")
temp2 <- aqua %>%
  select(Serial, Model, DateTime, Temp, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Type = Model)
temp2$roundedDateTime <- round_date(temp2$DateTime, unit = "10 mins")
all_temp <- bind_rows(temp, temp1, temp2)

# Combine all salinity
temp1 <- star %>%
  select(Sensor, Type, DateTime, Sal, sal_ma01, sal_ma02, sal_ma03, sal_ma04, Site, Position) %>%
  rename(Serial = Sensor)
temp1$roundedDateTime <- round(temp1$DateTime, "mins")
temp2 <- aqua %>%
  select(Serial, Model, DateTime, Sal, sal_ma01, sal_ma02, sal_ma03, sal_ma04, Site, Position) %>%
  rename(Type = Model)
temp2$roundedDateTime <- round_date(temp2$DateTime, unit = "10 mins")
all_sal <- bind_rows(temp1, temp2)

#all_temp$roundedDateTime <- round(all_temp$DateTime, "mins")
all_temp_site <- split(all_temp, all_temp$Site)
baleine_serial <- split(all_temp_site[["marina2"]], all_temp_site[["marina2"]]$Serial)

library(purrr)

# First, rename Temp columns to be unique per dataframe
df_list_named <- imap(baleine_serial, ~ .x %>%
                        select(roundedDateTime, Temp) %>%
                        rename(!!paste0("Temp_", .y) := Temp))

# Now join all the dataframes together by roundedDateTime
df_joined <- reduce(df_list_named, full_join, by = "roundedDateTime")

df_joined$diff_tcm_680494 <- df_joined$Temp_2206005 - df_joined$Temp_680496
df_joined$diff_tcm_680498 <- df_joined$Temp_2206005 - df_joined$Temp_680498

df_joined$diff_494_493 <- df_joined$Temp_680496 - df_joined$Temp_680498

df_joined$diff_S10226_497 <- df_joined$Temp_S10565 - df_joined$Temp_680496
df_joined$diff_S10226_499 <- df_joined$Temp_S10565 - df_joined$Temp_680498

df_joined$diff_S10276_497 <- df_joined$Temp_S10567 - df_joined$Temp_680496
df_joined$diff_S10276_499 <- df_joined$Temp_S10567 - df_joined$Temp_680498

df_joined$diff_S10277_497 <- df_joined$Temp_S12099 - df_joined$Temp_680496
df_joined$diff_S10277_499 <- df_joined$Temp_S12099 - df_joined$Temp_680498

df_joined$diff_S11162_497 <- df_joined$Temp_S12100 - df_joined$Temp_680496
df_joined$diff_S11162_499 <- df_joined$Temp_S12100 - df_joined$Temp_680498

max(df_joined$diff_S11162_499, na.rm = TRUE)
min(df_joined$diff_S11162_499, na.rm = TRUE)


#### Plots for Showing Rounding ####
# Monthly Plot for Temperature to have a comparison of rounding
all_temp <- all_temp %>% mutate(Month = format(DateTime, "%Y-%m")) # Year-month format
all_temp_monthly <- split(all_temp, all_temp$Month)

site_data <- all_temp_monthly[["2023-09"]]
device_names <- unique(site_data$Serial)

serial <- "680492"
df <- site_data %>% filter(Serial == serial)

p <- plot_ly() %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~Temp,
    type = 'scatter',
    mode = 'markers',
    marker = list(color = "#7F7F7F"),
    opacity = 0.4,
    name = "Temperature",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~temp_ma01,
    type = "scatter",
    mode = "lines",
    line = list(color = "seagreen"),
    opacity = 0.7,
    name = "Rolling Mean 30 Minutes",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~temp_ma02,
    type = "scatter",
    mode = "lines",
    line = list(color = "cornflowerblue"),
    opacity = 0.7,
    name = "Rolling Mean 2 Hours",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~temp_ma04,
    type = "scatter",
    mode = "lines",
    line = list(color = "orchid"),
    opacity = 0.7,
    name = "Rolling Mean 6 Hours",
    showlegend = TRUE
  ) %>%
  layout(
    title = "BC Temperature - Rolling Mean Comparison Using Device 680492 (AquaMeasure H - Site Tugwell1)",
    xaxis = list(title = "", rangeslider = list(visible = TRUE)),
    yaxis = list(title = "Temperature (deg C)"),
    margin = list(t = 100)
  )

file_name <- paste0("BC_rollingmeantemp", ".html")
saveWidget(p, file = here(paste0("output/plots/rollingmean/", file_name)), selfcontained = TRUE)


# Monthly Plot for Salinity to have a comparison of rounding
all_sal <- all_sal %>% mutate(Month = format(DateTime, "%Y-%m")) # Year-month format
all_sal_monthly <- split(all_sal, all_sal$Month)

site_data <- all_sal_monthly[["2023-09"]]
device_names <- unique(site_data$Serial)

serial <- "680492"
df <- site_data %>% filter(Serial == serial)

p <- plot_ly() %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~Sal,
    type = 'scatter',
    mode = 'markers',
    marker = list(color = "#7F7F7F"),
    opacity = 0.4,
    name = "Temperature",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~sal_ma01,
    type = "scatter",
    mode = "lines",
    line = list(color = "seagreen"),
    opacity = 0.7,
    name = "Rolling Mean 30 Minutes",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~sal_ma02,
    type = "scatter",
    mode = "lines",
    line = list(color = "cornflowerblue"),
    opacity = 0.7,
    name = "Rolling Mean 2 Hours",
    showlegend = TRUE
  ) %>%
  add_trace(
    data = df,
    x = ~DateTime,
    y = ~sal_ma04,
    type = "scatter",
    mode = "lines",
    line = list(color = "orchid"),
    opacity = 0.7,
    name = "Rolling Mean 6 Hours",
    showlegend = TRUE
  ) %>%
  layout(
    title = "BC Salinity - Rolling Mean Comparison Using Device 680492 (AquaMeasure H - Site Tugwell1)",
    xaxis = list(title = "", rangeslider = list(visible = TRUE)),
    yaxis = list(title = "Salinity (psu)"),
    margin = list(t = 100)
  )

file_name <- paste0("BC_rollingmeansalinity", ".html")
saveWidget(p, file = here(paste0("output/plots/rollingmean/", file_name)), selfcontained = TRUE)



#### Weekly Plots ####

# Assuming all_temp has a DateTime column
all_temp <- all_temp %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
all_temp$SP <- paste(all_temp$Type, all_temp$Position, sep='-')
all_temp_weekly <- split(all_temp, all_temp$Week)

for (date_label in names(all_temp_weekly)) {
  site_data <- all_temp_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Temp,
        color = ~SP,
        type = 'scatter',
        mode = 'markers',
        colors = "Dark2",
        showlegend = TRUE,
        name = ~SP
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~temp_ma02,
        color = ~SP,
        type = "scatter",
        mode = "lines",
        colors = "Dark2",
        name = ~SP,
        showlegend = (i == 0)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("QC Temperature", date_label, "(", week_label, ")"),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Temperature"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_temp_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/weekly/", file_name)), selfcontained = TRUE)
  print(paste("printed", date_label))
}



### Weekly Plots for Salinity

# Assuming all_sal  has a DateTime column
all_sal  <- all_sal  %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
all_sal$SP <- paste(all_sal$Type, all_sal$Position, sep='-')
all_sal_weekly <- split(all_sal , all_sal$Week)

library(plotly)
library(dplyr)
library(htmlwidgets)
library(lubridate)  # for date handling

for (date_label in names(all_sal_weekly)) {
  site_data <- all_sal_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Sal,
        color = ~SP,
        type = 'scatter',
        mode = 'markers',
        colors = "Dark2",
        showlegend = (i == 1),
        name = ~SP
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~sal_ma02,
        color = ~SP,
        type = "scatter",
        mode = "lines",
        colors = "Dark2",
        name = ~SP,
        showlegend = (i == 0)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("QC Salinity", date_label, "(", week_label, ")"),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Salinity"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_sal_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/weekly/", file_name)), selfcontained = TRUE)
  print(paste("printed salinity", date_label))
}


### Weekly Plots for Current

TCM_current <- TCM_current %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
TCM_current$SP <- paste(TCM_current$Type, TCM_current$Position, sep='-')
TCM_current_weekly <- split(TCM_current , TCM_current$Week)

for (date_label in names(TCM_current_weekly)) {
  site_data <- TCM_current_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Speed,
        type = 'scatter',
        mode = 'lines',
        line = list(color = "#7F7F7F"),
        opacity = 0.4,
        name = "Speed",
        showlegend = (i == 1)
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~speed_ma01,
        type = "scatter",
        mode = "lines",
        line = list(color = "seagreen"),
        name = "Rolling Mean 30 Minutes",
        showlegend = (i == 1)
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~speed_ma02,
        type = "scatter",
        mode = "lines",
        line = list(color = "cornflowerblue"),
        name = "Rolling Mean 2 Hours",
        showlegend = (i == 1)
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~speed_ma03,
        type = "scatter",
        mode = "lines",
        line = list(color = "mediumslateblue"),
        name = "Rolling Mean 3 Hours",
        showlegend = (i == 1)
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~speed_ma04,
        type = "scatter",
        mode = "lines",
        line = list(color = "orchid"),
        name = "Rolling Mean 6 Hours",
        showlegend = (i == 1)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("QC Current", date_label, "(", week_label, ")"),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Current speed (cm/s)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_current_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/weekly/", file_name)), selfcontained = TRUE)
  print(paste("printed current", date_label))
}

#### Weekly Plots No StarOddi ####
# Combine all temperature
temp <- TCM_temp %>%
  select(Serial, Type, DateTime, Temperature, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Temp = Temperature)
temp2 <- aqua %>%
  select(Serial, Model, DateTime, Temp, temp_ma01, temp_ma02, temp_ma03, temp_ma04, Site, Position) %>%
  rename(Type = Model)
temp_nostar <- bind_rows(temp, temp2)

temp_nostar <- temp_nostar %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
temp_nostar$SP <- paste(temp_nostar$Type, temp_nostar$Position, sep='-')
temp_nostar_weekly <- split(temp_nostar, temp_nostar$Week)

for (date_label in names(temp_nostar_weekly)) {
  site_data <- temp_nostar_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Temp,
        color = ~SP,
        type = 'scatter',
        mode = 'markers',
        colors = "Dark2",
        showlegend = (i == 1),
        name = ~SP
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~temp_ma02,
        color = ~SP,
        type = "scatter",
        mode = "lines",
        colors = "Dark2",
        name = ~SP,
        showlegend = (i == 0)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("QC Temperature", date_label, "(", week_label, ")"),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Temperature"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_temp_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/weekly-nostar/", file_name)), selfcontained = TRUE)
  print(paste("printed temp", date_label))
}



### Weekly Plots for Salinity

# Assuming all_sal  has a DateTime column
aqua  <- aqua  %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
aqua$SP <- paste(aqua$Type, aqua$Position, sep='-')
aqua_weekly <- split(aqua , aqua$Week)

for (date_label in names(aqua_weekly)) {
  site_data <- aqua_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Sal,
        color = ~SP,
        type = 'scatter',
        mode = 'markers',
        colors = "Dark2",
        showlegend = (i == 1),
        name = ~SP
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~sal_ma02,
        color = ~SP,
        type = "scatter",
        mode = "lines",
        colors = "Dark2",
        name = ~SP,
        showlegend = (i == 0)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("QC Salinity", date_label, "(", week_label, ")"),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Salinity"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_sal_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/weekly-nostar/", file_name)), selfcontained = TRUE)
  print(paste("printed salinity", date_label))
}


#### Plots for Entire Trend - Temperature ####
all_temp$SP <- paste(all_temp$Type, all_temp$Position, sep = '-')
all_temp_site <- split(all_temp, all_temp$Site)

# Loop through each Site
for (site_label in names(all_temp_site)) {
  site_data <- all_temp_site[[site_label]]
  device_ids <- unique(site_data$Serial)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Serial == serial)

    plot_ly(
      data = df,
      x = ~DateTime,
      y = ~temp_ma02,
      type = "scatter",
      mode = "lines",
      name = unique(df$SP),  # Use the combined Type-Position as the name
      line = list(color = RColorBrewer::brewer.pal(n = length(device_ids), "Dark2")[i])
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
      title = paste("Temperature Trend with Rolling Mean - Site:", site_label),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis = list(title = "Temperature (°C)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_temptrend", site_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/trend/", file_name)), selfcontained = TRUE)
  print(paste("saved plot", site_label))
}



#### Plots for Entire Trend - Salinity ####
all_sal$SP <- paste(all_sal$Type, all_sal$Position, sep='-')
all_sal_site <- split(all_sal, all_sal$Site)

# Loop through each Site
for (site_label in names(all_sal_site)) {
  site_data <- all_sal_site[[site_label]]
  device_ids <- unique(site_data$Serial)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Serial == serial)

    plot_ly(
      data = df,
      x = ~DateTime,
      y = ~sal_ma02,
      type = "scatter",
      mode = "lines",
      name = unique(df$SP),  # Use the combined Type-Position as the name
      line = list(color = RColorBrewer::brewer.pal(n = length(device_ids), "Dark2")[i])
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
      title = paste("Salinity Trend with Rolling Mean - Site:", site_label),
      xaxis = list(title = "", rangeslider = list(visible = TRUE)),
      yaxis3 = list(title = "Salinity (psu)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("QC_saltrend", site_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/trend/", file_name)), selfcontained = TRUE)
  print(paste("saved plot", site_label))
}

#### Plots for Current with Heading ####
# Assuming TCM_current has a DateTime column
TCM_current <- TCM_current %>% mutate(Week = format(DateTime, "%Y-%U"))  # Year-week format
TCM_current$SP <- paste(TCM_current$Type, TCM_current$Position, sep='-')
TCM_current_weekly <- split(TCM_current, TCM_current$Week)

for (date_label in names(TCM_current_weekly)) {
  site_data <- TCM_current_weekly[[date_label]]
  site_names <- unique(site_data$Site)

  # --- Convert "2023-22" to start and end dates ---
  year_week <- strsplit(date_label, "-")[[1]]
  year <- as.integer(year_week[1])
  week <- as.integer(year_week[2])
  start_date <- ISOweek::ISOweek2date(paste0(year, "-W", sprintf("%02d", week), "-1"))
  end_date <- start_date + days(6)

  # Format for plot title
  week_label <- paste0(format(start_date, "%b %d"), " - ", format(end_date, "%b %d"))

  site_plots <- lapply(seq_along(site_names), function(i) {
    site <- site_names[i]
    df <- site_data %>% filter(Site == site)

    plot_ly() %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~Speed,
        color = ~as.numeric(head_circ),
        type = 'scatter',
        mode = 'markers',
        colors = "Dark2",
        showlegend = (i == 1)
      ) %>%
      add_trace(
        data = df,
        x = ~DateTime,
        y = ~speed_ma02,
        color = ~as.numeric(head_circ),
        type = "scatter",
        mode = "lines",
        colors = "Dark2",
        showlegend = (i == 0)
      )
  })

  n <- length(site_names)

  annotations <- lapply(seq_along(site_names), function(i) {
    list(
      x = 0.5,
      y = 1 - ((i - 1) + 0.02) / n,
      text = paste("Site:", site_names[i]),
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 14),
      align = "center"
    )
  })

  final_plot <- subplot(site_plots, nrows = length(site_plots), shareX = TRUE, titleY = TRUE) %>%
    layout(
      title = paste("BC Current", date_label, "(", week_label, ")"),
      xaxis = list(
        title = "",
        range = c(start_date, end_date),
        rangeslider = list(visible = TRUE)
      ),
      yaxis = list(title = "Current speed (cm/s)"),
      annotations = annotations,
      margin = list(t = 100)
    )

  file_name <- paste0("BC_current_", date_label, ".html")
  saveWidget(final_plot, file = here(paste0("output/plots/current/", file_name)), selfcontained = TRUE)
  print(paste("printed", date_label))
}
