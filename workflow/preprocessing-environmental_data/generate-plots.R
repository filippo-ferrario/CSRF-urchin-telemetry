# ===============================================================================
# Name   	: Generate Plots
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 23-02-2025
# Version	: 1
# URL		:
# Aim    	:
# ===============================================================================

library(dplyr)
library(ggplot2)
library(here)

# ===============================================================================
# Plots for TCM Current
# ===============================================================================

# Rolling mean plotted over original datapoints showing direction
TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_point(aes(y = speed_ma01), color = "black", alpha = 0.1, shape = 16) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_30mins.png")

TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_2hours.png")

TCM_current %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = Heading), alpha = 0.1, shape = 16) +
  geom_point(aes(y = speed_ma03), color = "black", alpha = 0.1, shape = 16) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
TCM_current %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma01), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom1_rollmean_30mins.png")

# Second zoom
TCM_current %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma01), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom2_rollmean_30mins.png")

TCM_current %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom1_rollmean_2hours.png")

TCM_current %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Speed, color = head_circ), alpha = 0.1, shape = 16) +
  geom_path(aes(y = speed_ma02), color = "black", alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Current speed (cm/s)") +
  theme_bw() +
  scale_color_gradientn(colours = terrain.colors(16)) +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/CurrentSpeed_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for TCM Temperature
# ===============================================================================

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position)) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_30mins.png")

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma03, color = Position)) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_6hours.png")

TCM_temp %>%
  ggplot(aes(x = DateTime)) +
  #geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_rollmean_2hours.png")

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

# Second zoom
TCM_temp %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position)) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom2_rollmean_30mins.png")

TCM_temp %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom1_rollmean_2hours.png")

TCM_temp %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temperature), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position)) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/TCMTemp_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for AquaMeasure Temperature
# ===============================================================================

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_30mins.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_6hours.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_rollmean_2hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom1_rollmean_30mins.png")

# Second zoom
aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom2_rollmean_30mins.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom1_rollmean_2hours.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaTemp_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for AquaMeasure Salinity
# ===============================================================================

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_30mins.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  #scale_color_gradientn(colours = terrain.colors(16)) +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_2hours.png")

aqua %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom1_rollmean_30mins.png")

# Second zoom
aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom2_rollmean_30mins.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom1_rollmean_2hours.png")

aqua %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/AquaSal_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for StarOddi Temperature
# ===============================================================================

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_30mins.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_2hours.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = temp_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom1_rollmean_30mins.png")

# Second zoom
star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom2_rollmean_30mins.png")

star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom1_rollmean_2hours.png")

star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Temp, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = temp_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Temperature (C)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarTemp_zoom2_rollmean_2hours.png")


# ===============================================================================
# Plots for StarOddi Salinity
# ===============================================================================

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_30mins.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_2hours.png")

star %>%
  ggplot(aes(x = DateTime)) +
  geom_path(aes(y = sal_ma03, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 6 hours", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_rollmean_6hours.png")

# Zoom in on portion of time (meaningful for tidal variation?)
star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom1_rollmean_30mins.png")

# Second zoom
star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma01, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 30 minutes - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom2_rollmean_30mins.png")

star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-07 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 1 week", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom1_rollmean_2hours.png")

star %>%
  filter(DateTime >= as.POSIXct("2022-09-01 00:00:00") & DateTime <= as.POSIXct("2022-09-02 00:00:00")) %>%
  ggplot(aes(x = DateTime)) +
  geom_point(aes(y = Sal, color = Position), alpha = 0.1, shape = 16) +
  geom_path(aes(y = sal_ma02, color = Position), alpha = 0.8) +
  labs(title = "Rolling average - 2 hours - zoom on 2 days", x = '', y = "Salinity (psu)") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap(~Site)
ggsave(filename = "./R_output/plots/StarSal_zoom2_rollmean_2hours.png")

# ===============================================================================
# Plots for Series & Positions
# ===============================================================================

star %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temp), alpha = 0.1) +
  geom_path(aes(y = Temp), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/StarTemp_all.png", width = 8, height = 10)

star %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Sal), alpha = 0.1) +
  geom_path(aes(y = Sal), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/StarSal_all.png", width = 8, height = 10)

aqua %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temp), alpha = 0.1) +
  geom_path(aes(y = Temp), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/AquaTemp_all.png", width = 8, height = 10)

aqua %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Sal), alpha = 0.1) +
  geom_path(aes(y = Sal), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/AquaSal_all.png", width = 8, height = 10)

TCM_temp %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Temperature), alpha = 0.1) +
  geom_path(aes(y = Temperature), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/TCMTemp_all.png", width = 8, height = 10)

TCM_current %>%
  # filter(Site == "AnsePilotes") %>%
  group_by(Position) %>%
  ggplot(aes(x = DateTime, color = Position)) +
  geom_point(aes(y = Speed), alpha = 0.1) +
  geom_path(aes(y = Speed), color = "black") +
  # geom_point(aes(y = temp), alpha = 0.6) +
  theme_bw() +
  facet_wrap(~Site*Position)
ggsave(filename = "./R_output/plots/TCMCurSpeed_all.png", width = 8, height = 10)

# ===============================================================================
# Map of Devices
# ===============================================================================

library(sf)

## Prep devices
# Get unique rows based on columns Site, Position, Lat, Long
unique_star <- star %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_star$DeviceType <- "StarOddi"
unique_star$SP <- paste(unique_star$DeviceType, unique_star$Position, sep='-')

unique_aqua <- aqua %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_aqua$DeviceType <- "AquaMeasure"
unique_aqua$SP <- paste(unique_aqua$DeviceType, unique_aqua$Position, sep='-')

unique_TCM <- TCM_temp %>%
  distinct(Site, Position, Lat, Long, .keep_all = FALSE)
unique_TCM$DeviceType <- "TCM"
unique_TCM$SP <- paste(unique_TCM$DeviceType, unique_TCM$Position, sep='-')

all_unique <- rbind(unique_star, unique_aqua, unique_TCM)
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), ~ gsub(",", ".", .)))

# ## Cut world map
# sf::sf_use_s2(FALSE)
#
# world <- st_read("C:/Users/shaoj/Documents/land_polygons_shp/land_polygons.shp")
#
# # Check for invalid geometries
# invalid_geoms <- !st_is_valid(world)
# if (any(invalid_geoms)) {
#   cat("Fixing", sum(invalid_geoms), "invalid geometries...\n")
#   world <- st_make_valid(world)  # Fix invalid geometries
# }
#
# xmin <- as.numeric(min(all_unique$Long)) - 0.1  # Min Longitude
# xmax <- as.numeric(max(all_unique$Long)) + 0.1  # Max Longitude
# ymin <- as.numeric(min(all_unique$Lat)) - 0.1   # Min Latitude
# ymax <- as.numeric(min(all_unique$Lat)) + 0.1   # Max Latitude
#
# bbox <- st_bbox(c(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), crs = st_crs(world))
# world_cropped <- st_crop(world, bbox)

## Plot devices on map
all_unique <- all_unique %>%
  mutate(across(c(Lat, Long), as.numeric)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

unique_split <- split(all_unique, all_unique$Site)

lapply(names(unique_split), function(name) {
  # p <- ggplot(data = unique_split[[name]]) +
  #   geom_sf(aes(color = SP), size = 2, alpha = 0.5) +
  #   theme_bw()

  ggplot(data = unique_split[[name]]) +
    geom_sf(aes(color = SP), size = 2) +
    theme_bw()

  # Save the plot with a unique filename
  #ggsave(filename = paste0("./R_output/maps/", name, "_deviceloc.png"), plot = p, width = 8, height = 6, dpi = 300)
})


