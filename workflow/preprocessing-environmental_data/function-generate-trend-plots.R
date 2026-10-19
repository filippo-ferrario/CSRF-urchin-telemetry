# ===============================================================================
# Name   	: Generate Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings var_vec,
#           vector of Strings name_vec, vector of Strings y_vec, String save_loc
# Output  : Plots saved to "./R_output/plots/"
# ===============================================================================

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
