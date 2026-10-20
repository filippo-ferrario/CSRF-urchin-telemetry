# ===============================================================================
# Name   	: Generate Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings var_vec,
#           vector of Strings name_vec, vector of Strings y_vec, String save_loc
# Output  : Plots saved to "output/plots/trend/"
# ===============================================================================

library(plotly)
library(dplyr)
library(htmlwidgets)
library(here)

#' Save one trend plot per site
#'
#' @param data_list   Named list of data frames, one per site (e.g. qc_current_rolled).
#' @param serial_col  Name of the device ID column, as a string.
#' @param file_prefix Prefix for the output file name.
#' @param out_dir     Output directory, relative to the project root.
#'

plot_current_trends <- function(
  data_list,
  serial_col,
  file_prefix,
  out_dir
) {
  dark2 <- RColorBrewer::brewer.pal(n = 8, "Dark2")

  ifelse(
    !dir.exists(out_dir),
    dir.create(out_dir),
    "Directory exists"
  )

  for (site_label in names(data_list)) {
    site_data <- data_list[[site_label]]
    device_ids <- unique(site_data[[serial_col]])

    # Create a plot for each device
    device_plots <- lapply(seq_along(device_ids), function(i) {
      serial <- device_ids[i]
      df <- site_data %>% filter(.data[[serial_col]] == serial)

      plot_ly() %>%
        add_lines(
          data = df,
          x = ~DateTime,
          y = ~Heading_roll_mean,
          name = paste("Heading -", unique(df$Position)),
          line = list(color = dark2[1])
        ) %>%
        add_lines(
          data = df,
          x = ~DateTime,
          y = ~Speed_roll_mean,
          name = paste("Speed -", unique(df$Position)),
          yaxis = "y2",
          line = list(color = dark2[2])
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

    file_name <- paste0(file_prefix, site_label, ".html")
    saveWidget(
      final_plot,
      file = here(out_dir, file_name),
      selfcontained = TRUE
    )
    print(paste("saved plot", site_label))
  }

  invisible(NULL)
}


#' Save one multi-sensor trend plot per site for temperature or salinity
#'
#' @param data_list   Named list of data frames, one per site (e.g. alltemp_avg).
#' @param variable    Which variable to plot: "temperature" or "salinity".
#'                    Controls the plot title, y-axis label and default file suffix.
#' @param value_col   Name of the column holding the values to plot, as a string.
#'                    Can be a vector of candidate names (e.g. c("Salinity", "Sal")),
#'                    in which case the first one found in each site's data is used.
#'                    Defaults to "Temperature" or "Salinity" based on `variable`.
#' @param serial_col  Name of the device ID column, as a string (default "Sensor").
#' @param file_prefix Prefix for the output file name, placed before the site name.
#'                    Defaults to "temptrend_" or "salinitytrend_" based on `variable`.
#' @param out_dir     Output directory, relative to the project root
#'                    (default "output/plots/environmental_2024_25").
plot_env_trends <- function(
  data_list,
  variable = c("temperature", "salinity"),
  value_col = NULL,
  serial_col = "Sensor",
  file_prefix = NULL,
  out_dir
) {
  ifelse(
    !dir.exists(out_dir),
    dir.create(out_dir),
    "Directory exists"
  )

  variable <- match.arg(variable)

  # Settings that differ between the two variables
  settings <- list(
    temperature = list(
      col = "Temperature",
      label = "Temperature",
      axis = "Temperature (\u00B0C)"
    ),
    salinity = list(
      col = "Salinity",
      label = "Salinity",
      axis = "Salinity (psu)"
    )
  )[[variable]]

  for (site in names(data_list)) {
    site_data <- data_list[[site]]

    # Use the first candidate column name that exists in this site's data
    site_value_col <- intersect(value_col, names(site_data))[1]
    if (is.na(site_value_col)) {
      stop(
        "None of the column(s) '",
        paste(value_col, collapse = "', '"),
        "' found in data for site: ",
        site
      )
    }

    device_ids <- unique(site_data[[serial_col]])

    # brewer.pal needs n >= 3; extra colours are ignored when there are fewer devices
    cols <- RColorBrewer::brewer.pal(n = max(3, length(device_ids)), "Dark2")

    # Create a plot for each device
    device_plots <- lapply(seq_along(device_ids), function(i) {
      serial <- device_ids[i]
      df <- site_data %>% filter(.data[[serial_col]] == serial)

      plot_ly(
        data = df,
        x = ~DateTime,
        y = df[[site_value_col]],
        type = "scatter",
        mode = "lines",
        name = if ("site" %in% names(df)) {
          unique(df$site)
        } else {
          as.character(serial)
        },
        line = list(color = cols[i])
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
        title = paste(settings$label, "Trend with Rolling Mean - Site:", site),
        xaxis = list(title = "", rangeslider = list(visible = TRUE)),
        yaxis = list(title = settings$axis),
        annotations = annotations,
        margin = list(t = 100)
      )

    file_name <- paste0(file_prefix, site, ".html")
    saveWidget(
      final_plot,
      file = here(out_dir, file_name),
      selfcontained = TRUE
    )
    print(paste("saved plot", site))
  }

  invisible(NULL)
}
