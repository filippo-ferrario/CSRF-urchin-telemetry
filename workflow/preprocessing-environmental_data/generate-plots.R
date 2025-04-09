# ===============================================================================
# Name   	: Generate Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# Input   : Dataframe data, vector of Strings var_vec,
#           vector of Strings name_vec, String save_loc
# Output  : Plots saved to "./R_output/plots/"
# ===============================================================================

generate.plots <- function(data, var_vec, name_vec, save_loc) {
  library(ggplot2)

  for (i in 1:length(var_vec)) {
    data %>%
      ggplot(aes(x = DateTime)) +
      #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
      geom_path(aes(y = !!sym(var_vec[i]), color = Position)) +
      labs(title = name_vec[i], x = '', y = "Temperature (C)") +
      theme_bw() +
      scale_color_brewer(palette = "Dark2") +
      facet_wrap(~Site)

    ggsave(filename = paste(save_loc, name_vec[i], sep = '/'))
  }

}


