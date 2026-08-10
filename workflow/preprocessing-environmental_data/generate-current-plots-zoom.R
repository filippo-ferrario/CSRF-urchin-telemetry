# ===============================================================================
# Name   	: Generate Zoomed Current Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 09-04-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings roundvar_vec,
#           vector of Strings name_vec,
#           vector of Strings time_vec default to NULL (only two, beginning and end),
#           String save_loc
# Output  : Plots saved to "./R_output/plots/"
# ===============================================================================

generate.current.plots.zoom <- function(data, roundvar_vec, name_vec, time_vec, save_loc) {
  require(ggplot2)

  for (i in 1:length(roundvar_vec)) {
    # Zoom in on portion of time (meaningful for tidal variation?)
    data %>%
      filter(DateTime >= as.POSIXct(time_vec[1]) & DateTime <= as.POSIXct(time_vec[2])) %>%
      ggplot(aes(x = DateTime)) +
      geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
      geom_path(aes(y = !!sym(roundvar_vec[i])), color = "black", alpha = 0.8) +
      labs(title = name_vec[i], x = '', y = "Current speed (cm/s)") +
      theme_bw() +
      scale_color_gradientn(colours = terrain.colors(16)) +
      facet_wrap(~Site)

    ggsave(filename = paste(save_loc, name_vec[i], sep = '/'))
  }

}
