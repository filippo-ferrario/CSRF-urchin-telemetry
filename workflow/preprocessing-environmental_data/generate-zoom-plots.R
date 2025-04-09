# ===============================================================================
# Name   	: Generate Zoomed Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings var_vec,
#           vector of Strings time_vec default to NULL, String save_loc
# Output  : Plots saved to "./R_output/plots/"
# ===============================================================================

generate_plots <- function(data, var_vec, name_vec, time_vec, save_loc) {
  library(ggplot2)
  # Zoom in on portion of time (meaningful for tidal variation?)
  TCM_temp %>%
    filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
    ggplot(aes(x = DateTime)) +
    geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
    geom_path(aes(y = temp_ma01, color = Position)) +
    labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
    theme_bw() +
    scale_color_brewer(palette = "Dark2") +
    facet_wrap(~Site)
  ggsave(filename = "./R_output/plots/TCMTemp_zoom1_rollmean_30mins.png")

}
