# ===============================================================================
# Name   	: Main environmental data
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 14-11-2025
# Version	: 1
# URL		:
# Aim    	: To create CSV files of environmental data - ONLY NEED TO RUN SECTION
#           #### Final Environmental Datasets
# ===============================================================================

#### Final Environmental Datasets ####
source(here(
  "workflow/preprocessing-environmental_data/create-environmental-dataset.R"
))
bc <- create_envdataset(c(
  "data/raw_data_downloads_prince_rupert_2023/",
  "data/raw_data_downloads_quadra_2023/",
  "data/metadata_sensors_BC2023.csv"
))
bc_temp <- lapply(bc[[1]], function(tbl) average_samedt(tbl, col_name = "Temp"))
bc_sal <- lapply(bc[[2]], function(tbl) average_samedt(tbl, col_name = "Sal"))
qc <- create_envdataset(c(
  "data/raw_data_downloads_bic_2022/",
  "data/raw_data_downloads_cacouna_2022/",
  "data/metadata_sensors_QC2022.csv"
))
qc_temp <- lapply(qc[[1]], function(tbl) average_samedt(tbl, col_name = "Temp"))
qc_sal <- lapply(qc[[2]], function(tbl) average_samedt(tbl, col_name = "Sal"))


#### Current ####
source(here(
  "workflow/preprocessing-environmental_data/create-current-dataset.R"
))
bc_current <- create_currdataset(
  c(
    "data/raw_data_downloads_prince_rupert_2023/",
    "data/raw_data_downloads_quadra_2023/",
    "data/metadata_sensors_BC2023.csv"
  ),
  2023
)
bc_current_rolled <- rollmean_current(bc_current)
qc_current <- create_currdataset(
  c(
    "data/raw_data_downloads_bic_2022/",
    "data/raw_data_downloads_cacouna_2022/",
    "data/metadata_sensors_QC2022.csv"
  ),
  2023
)
qc_current_rolled <- rollmean_current(qc_current)

# Save as csv file
cols_to_keep <- c(
  "Lat",
  "Long",
  "Serial",
  "rollmean_Temp",
  "rollmean_Sal",
  "Heading_roll_mean",
  "Speed_roll_mean"
)

source(here(
  "workflow/preprocessing-environmental_data/save-environmental-csv.R"
))
combined_bc <- create_site_csv(
  curr = bc_current_rolled,
  temp = bc_temp,
  sal = bc_sal,
  cols_to_keep = cols_to_keep
)

combined_qc <- create_site_csv(
  curr = qc_current_rolled,
  temp = qc_temp,
  sal = qc_sal,
  cols_to_keep = cols_to_keep
)

# Plot QC !!!!!!! PUT INTO ANOTHER FUNCTION THEN CALL FOR ALL
for (site_label in names(qc_current_rolled)) {
  site_data <- qc_current_rolled[[site_label]]
  device_ids <- unique(site_data$Serial)

  # Create a plot for each device
  device_plots <- lapply(seq_along(device_ids), function(i) {
    serial <- device_ids[i]
    df <- site_data %>% filter(Serial == serial)

    plot_ly() %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Heading_roll_mean,
        name = paste("Heading -", unique(df$Position)),
        line = list(color = RColorBrewer::brewer.pal(n = 8, "Dark2")[1])
      ) %>%
      add_lines(
        data = df,
        x = ~DateTime,
        y = ~Speed_roll_mean,
        name = paste("Speed -", unique(df$Position)),
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

  file_name <- paste0("QC_current_", site_label, ".html")
  saveWidget(
    final_plot,
    file = here(paste0("output/plots/trend-cleaned/", file_name)),
    selfcontained = TRUE
  )
  print(paste("saved plot", site_label))
}
