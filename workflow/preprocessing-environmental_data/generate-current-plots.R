# ===============================================================================
# Name   	: Generate Current Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings var_vec,
#           vector of Strings name_vec, String save_loc
# Output  : Plots saved to "./R_output/plots/"
# ===============================================================================

generate.current.plots <- function(data, var_vec, name_vec, save_loc) {
  library(ggplot2)

  for (i in 1:length(var_vec)) {
    data %>%
      ggplot(aes(x = DateTime)) +
      geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
      geom_point(aes(y = !!sym(var_vec[i])), color = "black", alpha = 0.1, shape = 16) +
      labs(title = name_vec[i], x = '', y = "Current speed (cm/s)") +
      theme_bw() +
      scale_color_gradientn(colours = terrain.colors(16)) +
      facet_wrap(~Site)

    ggsave(filename = paste(save_loc, name_vec[i], sep = '/'))
  }

}
