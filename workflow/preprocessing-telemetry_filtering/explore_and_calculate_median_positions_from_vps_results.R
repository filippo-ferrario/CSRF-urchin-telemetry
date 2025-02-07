# ===============================================================================
# Name   	: Plot, explore and calculate median positions from vps data for photomosaic building
# Author 	: Katie MacGregor
# Date   	: 2024-01-27 [yyyy-mm-dd]
# Version	:
# URL		:
# Aim    	: Explore and extract median gps positions for photomosaic
# ===============================================================================


#' # Explore and calulate median positions from vps
#' ----------------------------------------------------
#'
#' Plot and explore





# =====================
# load data
# =====================

sync_data <- readr::read_csv("./output/datasets/combined_sync_and_ref_data.csv", show_col_types = FALSE)

glimpse(sync_data)

# Import receivers metadata
rece <- read.csv("./output/datasets/receivers_metadata_QC_BC.csv", sep = ",")
# filter to only have the Pilotes receivers data
rece_pilotes <- rece %>% filter (Site_2 == "Pilotes")

# Import adjusted receivers coordinates from VPS
vps_rece <- read.csv("./output/datasets/VPS_receivers_metadata_QC_BC.csv", sep = ",")
vps_pilotes <- vps_rece %>% filter (Site_2 == "Pilotes")




#' # Distribution of HPE and RMSE values in filtered dataset
#' ----------------------------------------------------

# =====================
# Distribution of HPE and RMSE values in filtered dataset
# =====================

#' HPE
# All stationary tags have the vast majority (95% overall) of their detections with HPE < 2
# (and generally less than 1).
quantile(sync_data$hpe, c(0.5, 0.9, 0.95, 0.99), na.rm = TRUE)

#' Visualize the distribution of hpe values (after filtering by the 95% quantile to remove extreme values)
fltr_hpe95 <- quantile(sync_data$hpe, c(0.95), na.rm = TRUE)
sync_data |>
  filter(hpe < fltr_hpe95)  |>
  ggplot(aes(x = hpe)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "HPE for Sync and Ref tags (filtered by 95% quantile)", subtitle = paste(unique(sync_data$site))) +
  theme_bw()


#' We can filter much more aggressively, though, say by 50%:
fltr_hpe50 <- quantile(sync_data$hpe, c(0.50), na.rm = TRUE)
sync_data |>
  filter(hpe < fltr_hpe50)  |>
  ggplot(aes(x = hpe)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "HPE for Sync and Ref tags (filtered by 50% quantile)", subtitle = paste(unique(sync_data$site))) +
  theme_bw()




p1 <- sync_data |>
  dplyr::filter(hpe < fltr_hpe50) |>
  ggplot(aes(x = hpe)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "HPE for Sync and Ref tags (filtered by 50% quantile)", subtitle = paste(unique(sync_data$site))) +
  theme_bw() +
  facet_wrap(~stn)
p1
ggsave(p1, file = "./output/plots/HPE_q50_by_station.png", width = 8, height = 8)

p2 <- sync_data  |>
  dplyr::filter(hpe < fltr_hpe50) |>
  ggplot(aes(x = hpe)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "HPE for Sync and Ref tags (filtered by 50% quantile)", subtitle = paste(unique(sync_data$site))) +
  theme_bw() +
  facet_wrap(~month(t))
p2
ggsave(p2, file = "./output/plots/HPE_q50_by_month.png", width = 8, height = 8)



#' RMSE
# RMSE islow, also (<10, and generally less than 1)
quantile(sync_data$rmse, c(0.5, 0.9, 0.95, 0.99), na.rm = TRUE)
fltr_rmse50 <- quantile(sync_data$rmse, c(0.5), na.rm = TRUE)

p3 <- sync_data %>%
  dplyr::filter(rmse < fltr_rmse50)  %>%
  ggplot(aes(x = rmse)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "RMSE for Sync and Ref tags (filtered by 50% quantile)", subtitle = paste(unique(sync_data$site))) +
  facet_wrap(~stn)
p3
ggsave(p3, file = "./output/plots/RMSE_q50_by_station.png", width = 8, height = 8)

p4 <- sync_data %>%
  dplyr::filter(rmse < fltr_rmse50)  %>%
  ggplot(aes(x = rmse)) +
  geom_density(outline.type = "full", fill = cbbPalette[3], alpha = 0.6) +
  labs(title = "RMSE for Sync and Ref tags (filtered by 50% quantile)", subtitle = paste(unique(sync_data$site))) +
  facet_wrap(~month(t))
p4
ggsave(p4, file = "./output/plots/RMSE_q50_by_month.png", width = 8, height = 8)



#' HPE vs HPEm
#

p5 <- sync_data %>%
  dplyr::filter(hpe < fltr_hpe95 & rmse < fltr_rmse50 & hpem < 1)  %>%
  ggplot(aes(x = hpe, y = hpem)) +
  geom_point(aes(colour = hpe), alpha = 0.5) +
  geom_smooth(method = "lm", formula = y~x, se = FALSE, colour = "black") +
  labs(title = "HPE vs HPEm (filtered by 50% quantile of HPE and RMSE)", subtitle = paste(unique(sync_data$site))) +
  facet_wrap(~stn) +
  theme_bw()
p5
ggsave(p5, file = "./output/plots/HPE_vsHPEm_by_station.png", width = 8, height = 8)









# =====================
# Filter (hpe and rmse) and convert data to spatial data
# =====================
glimpse(sync_data)

#' **Optionally, can filter 1-month of data here to speed up processing - commented filter line**
sync_data2 <- sync_data |>
  filter(hpe < fltr_hpe95 & rmse < fltr_rmse50) |>
  arrange(id, t)
  # filter(t > "2022-08-01 00:00:00" & t < "2022-08-31 23:59:59") # select only 1 month of data to speed up trying things out

glimpse(sync_data2)



# =====================
# Create a median positions object for plotting
# =====================
#' And a summary name file in order to plot position names and verify labelling:
stn_med <- sync_data2 |>
  group_by(site, stn) |>
  reframe(stn = unique(stn), pos = unique(pos), med_lat = median(lat, na.rm = TRUE), med_lon = median(lon, na.rm = TRUE))

stn_med2 <- vect(stn_med, geom = c("med_lon", "med_lat"), crs = "EPSG:4326")
# #' WGS 84 / UTM 19N - epsg:32619
crs_wgs84_utm19N <- "+init=EPSG:32619"
stn_med2_utm <- terra::project(stn_med2, crs_wgs84_utm19N)
stn_med2_utm_sf <- st_as_sf(stn_med2_utm)





# =====================
# Transform to spatial objects for plotting
# =====================

#' Transform sync_tag detection data into spatial object
sync_data3 <- vect(sync_data2, geom = c("lon", "lat"), crs = "EPSG:4326")
#' And transform to utm zone 19N crs using 'site' polygon
sync_data3_utm <- terra::project(sync_data3, crs_wgs84_utm19N)

sync_data3_utm_sf <- st_as_sf(sync_data3_utm)


# Transform receivers metadata into spatial objects
rece_pilotes2 <- vect(rece_pilotes, geom = c("lon", "lat"), crs = "EPSG:4326")
rece_pilotes2_utm <- terra::project(rece_pilotes2, crs_wgs84_utm19N)
rece_pilotes2_utm_sf <- st_as_sf(rece_pilotes2_utm)

vps_pilotes2 <- vect(vps_pilotes, geom = c("lon", "lat"), crs = "EPSG:4326")
vps_pilotes2_utm <- terra::project(vps_pilotes2, crs_wgs84_utm19N)
vps_pilotes2_utm_sf <- st_as_sf(vps_pilotes2_utm)
colnames(vps_pilotes2_utm_sf)[5] <- 'stn'



#' # Plot sync detections
#' ----------------------------------------------------

# =====================
# Plot sync detections
# =====================

#' Plot sync detections and median positions + labels
t1 = tm_shape(sync_data3_utm_sf) +
  tm_grid(col = "lightgrey") +
  tm_dots() +
  tm_compass(position = c("right", "top")) +
  tm_scalebar(position = c("left", "bottom"), breaks = c(0, 0.01, 0.02, 0.03, 0.04, 0.05)) +
  tm_shape(stn_med2_utm_sf) +
  tm_dots(col = "red") +
  tm_text("stn") +
  tm_style("white")

t1

tmap_save(t1, file = "./output/plots/sync_detections.png")


# Same graph than t1 but with ggplot and adding the receivers and VPS coordinates
p6 <- sync_data3_utm_sf %>%
  ggplot()+
  geom_sf(col = "black")+
  geom_sf(data=stn_med2_utm_sf, col = "red", cex = 1.0)+
  geom_sf_text(data = stn_med2_utm_sf, aes(label = stn), col = "grey") +
  geom_sf(data=rece_pilotes2_utm_sf, col ="blue") +
  geom_sf(data=vps_pilotes2_utm_sf, col ="green") +
  theme_bw()
p6
ggsave(p6, file = "./output/plots/sync_detections_PIL_receivers.png", width = 8, height = 8)



# =====================
# Calculate the difference-distance (in m) for each station with the median
# =====================

# Distance between the median and the GPS receivers coordinates
diff_rece <- st_distance(stn_med2_utm_sf, rece_pilotes2_utm_sf, by_element = TRUE)

# Converting the matrix in a dataframe
diff_rece1 <- data.frame(diff_rece)
names(diff_rece1)[1] <- "Diff_median_receivers"



# Difference between the median and the VPS adjusted receivers coordinates
diff_vps <- st_distance(stn_med2_utm_sf, vps_pilotes2_utm_sf, by_element = TRUE)

# Converting the matrix in a dataframe
diff_vps1 <- data.frame(diff_vps)
names(diff_vps1)[1] <- "Diff_median_vps"



# Difference between GPS receivers coordinates and VPS adjusted coordinates
diff_rece_vps <- st_distance(rece_pilotes2_utm_sf, vps_pilotes2_utm_sf, by_element = TRUE)

# Converting the matrix in a dataframe
diff_rece_vps1 <- data.frame(diff_rece_vps)
names(diff_rece_vps1)[1] <- "Diff_receivers_vps"



# Combine the three dataframes
diff <- cbind(diff_rece1, diff_vps1, diff_rece_vps1)
diff

# Add a Region, Year, Site, and Station column
Region <- data.frame(matrix("QC", nrow = 11, ncol = 1))
names(Region)[1] <- "Region"
Year <- data.frame(matrix(2022, nrow = 11, ncol = 1))
names(Year)[1] <- "Year"
Site <- data.frame(matrix("Pilotes", nrow = 11, ncol = 1))
names(Site)[1] <- "Site"
stn <- data.frame("stn" = c("Ref01", "Ref02", "St01", "St02", "St03", "St04", "St05", "St06", "St07", "St08", "St09"))
diff1 <- cbind(Region, Year, Site, stn, diff)
diff1



# =====================
# Calculate MCP pour each station
# =====================

# Calculate the maximum density for each station
# Not completely sure what I'm doing here, but it seems to work - comment from MFL
p7 <- ggplot(data = sync_data3_utm_sf) +
  geom_sf() +
  theme_bw() +
  stat_density_2d(mapping = ggplot2::aes(x = purrr::map_dbl(geometry, ~.[1]),
                                         y = purrr::map_dbl(geometry, ~.[2]),
                                         fill = stat(density)),
                  geom = 'tile',
                  contour = FALSE,
                  alpha = 0.5)
p7
ggsave(p7, file = "./output/plots/Density_plot_PIL.png", width = 8, height = 8)


# Addind the median results and receivers coordinates on the graph
p8 <- ggplot(data = sync_data3_utm_sf) +
  geom_sf() +
  theme_bw() +
  stat_density_2d(mapping = ggplot2::aes(x = purrr::map_dbl(geometry, ~.[1]),
                                         y = purrr::map_dbl(geometry, ~.[2]),
                                         fill = stat(density)),
                  geom = 'tile',
                  contour = FALSE,
                  alpha = 0.5) +
  geom_sf(data=stn_med2_utm_sf, col = "red", cex = 1.0)+
  geom_sf_text(data = stn_med2_utm_sf, aes(label = stn), col = "grey") +
  geom_sf(data=rece_pilotes2_utm_sf, col ="blue") +
  geom_sf(data=vps_pilotes2_utm_sf, col ="green")
p8
ggsave(p8, file = "./output/plots/Density_plot_PIL_median.png", width = 8, height = 8)




# =====================
# Save data
# =====================

#' Export file with median positions:
write_csv(stn_med2_utm_sf, file = "./output/datasets/median_positions_utm_sf.csv")

# Export file with distance between receivers and vps coodinates with the median
write_csv(diff1, file = "./output/datasets/distance_receivers_median.csv")















# #' # Calculate median sync positions - old process to send points to Filippo
# #' ----------------------------------------------------

# # =====================
# # Calculate median sync positions
# # =====================
# glimpse(sync_data)
# unique(sync_data$ID)

# # calculate median positions based on filtered (HPE less than 2 and RMSE less than 1) dataset

# pos_summary <- sync_data %>%
#   dplyr::filter(HPE < 2) %>%
#   dplyr::filter(RMSE < 1) %>%
#   group_by(period, ID) %>%
#   summarize(Stn = unique(Stn.y), Stn2 = unique(Stn.x), period = unique(period), Time_in = unique(Time_in), Time_out = unique(Time_out),
#    med_lat = median(Lat), med_y = median(Y), med_lon = median(Lon), med_x = median(X),
#     gps_lat = unique(gps_lat), gps_long = unique(gps_lon), gps_error = unique(gps_error), depth_mllw = unique(depth_mllw))


# #' Examine output in console:
# print(pos_summary, n = 30, width = Inf)


# #' Export file with this summary:
# write_csv(pos_summary, file = "./R_output/datasets/median_positions.csv")


# #' Plot the vps and gps positions to visualize:
# shapes <- c("GPS" = 16, "VPS" = 18)

# pos_summary %>%
#   ggplot(aes(x = med_lon, y = med_lat, colour = period)) +
#   geom_point(aes(shape = "VPS"), size = 3, alpha = 0.5) +
#   geom_point(aes(x = gps_long, y = gps_lat, shape = "GPS"), size = 3, alpha = 0.5) +
#   theme_bw() +
#   geom_label_repel(aes(label = Stn2), fill = "white", show_guide = F) +
#   scale_shape_manual(values = shapes) +
#   scale_colour_manual(values = cbbPalette[2:3], ) +
#   guides(colour = guide_legend("Period", override.aes = list(label = "", alpha = 1, size = 4)),
#   	shape = guide_legend("GPS vs VPS"))

# ggsave(file = "./R_output/plots/pos_summary_positions.png", width = 12, height = 12)






# # =====================
# # Plot sync detections with these pos_summary positions
# # =====================

# #' panelled by period and with gps points overlaid
# p2 <- sync_data %>%
#   dplyr::filter(HPE < 2) %>%
#   ggplot(aes(x = Lon, y = Lat, colour = HPE)) +
#   geom_point(alpha = 0.1) +
#   geom_point(data = pos_summary, aes(x = med_lon, y = med_lat), colour = "green", shape = 18, size = 2, alpha = 0.9) +
#   geom_point(data = pos_summary, aes(x = gps_long, y = gps_lat), colour = "red", shape = 16, size = 2, alpha = 0.9) +
#   theme_bw() +
#   facet_wrap(~period)

# plot(p2)

# ggsave(p2, file = "./R_output/plots/sync_tag_detections_HPE2_with_median_and_gps.png", width = 24, height = 16)









# =====================
# Section
# =====================

#' # Text to explain
#' --------------------------------------------------

# sutitle/section text
# -------------------------
