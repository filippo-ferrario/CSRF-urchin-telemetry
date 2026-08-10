# ===============================================================================
# Name   	: Save CSV of temperature, salinity, and current from AM and TCM by site
# Author 	: Jillian Shao
# Date   	:  [dd-mm-yyyy] 04-21-2026
# Version	: 1
# URL		  :
# Aim    	: Calculate moving averages
# Input   : Dataframe data vector of files
#           year integer 2023 or 2024
# Output  : Dataframe
# ================================================================================

# Each row is an hour and column per data, csv file per site
# Input: curr, temp, sal are the list of data
create_site_csv <- function(
  curr,
  temp,
  sal,
  cols_to_keep,
  lat_col,
  long_col,
  serial_col
) {
  # Combine the three lists into one named list
  lists <- list(curr = curr, temp = temp, sal = sal)

  # Get the site names from the first list (assumes all share same names)
  sites <- names(curr)

  # Iterate over sites
  combined <- map(sites, function(site) {
    # Extract and process each dataset for this site
    site_dfs <- map2(lists, names(lists), function(lst, nm) {
      df <- lst[[site]] %>%
        # Keep only relevant columns that exist
        select(any_of(c("DateTime", cols_to_keep))) %>%
        # Rename Lat/Long/Serial with dataset suffix
        rename_with(
          ~ paste0(., "_", nm),
          any_of(c(lat_col, long_col, serial_col))
        )
    })

    # Join all three datasets by DateTime
    reduce(site_dfs, full_join, by = "DateTime") %>%
      arrange(DateTime)
  })

  # Name the resulting list by site
  names(combined) <- sites

  # Save as csv
  # Folder to save CSVs
  output_dir <- "output/datasets/environmental/"
  for (nm in names(combined)) {
    write.csv(
      combined[[nm]],
      file = file.path(output_dir, paste0(nm, ".csv")),
      row.names = FALSE
    )
  }

  return(combined)
}
