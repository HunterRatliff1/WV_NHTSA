library(sf)
library(tigris)
library(mapboxapi)
library(dplyr)
options(tigris_class = "sf")

####--------------------------- Get reprex data ----------------------------####
# FIPS codes for 30 counties in north texas
north_TX <- c("48035", "48193", "48139", "48379", "48349", "48467", "48217", 
              "48439", "48237", "48143", "48093", "48363", "48251", "48077", 
              "48309", "48497", "48085", "48147", "48397", "48257", "48113", 
              "48425", "48097", "48181", "48231", "48367", "48221", "48337", 
              "48429", "48121")

tx_counties <- tigris::counties(state = "tx", cb=T) %>%
  filter(GEOID %in% north_TX) %>% # Limit to those counties above
  
  # Use centroid distances (mapboxapi function does this by default, but
  # making it explicit reduces the messages and makes the output cleaner)
  st_centroid()



####--------------------------- Wrapper function ---------------------------#### 
wrap_fxn <- function(data, n_orgs=20, n_dest=5, allow_large=FALSE){
  
  # Print the number of  origins & destinations
  cli::cli_alert_info(c("Origins: {.strong {n_orgs}}   ", 
                        "Destinations: {.strong {n_dest}} ",
                        "({.field coord_size} = {n_orgs+n_dest})"))
  
  mapboxapi::mb_matrix(origins      = head(data, n=n_orgs),
                       destinations = tail(data, n=n_dest), 
                       allow_large_matrix = allow_large)
}


####------------------------------- Examples -------------------------------####
### These don't work 
# all have coord_size > 25 (but neither origins nor destinations alone are >25)
tx_counties %>% wrap_fxn(n_orgs = 21, n_dest = 5)

tx_counties %>% wrap_fxn(n_orgs = 23, n_dest = 6)

tx_counties %>% wrap_fxn(n_orgs = 23, n_dest = 11)

tx_counties %>% wrap_fxn(n_orgs = 20, n_dest = 6)

# Doesn't change behavior even if allowing for large matrices
# tx_counties %>% wrap_fxn(n_orgs = 21, n_dest = 5, allow_large = TRUE)

# Works as expected
tx_counties %>% wrap_fxn(n_orgs = 2, n_dest = 2)

tx_counties %>% wrap_fxn(n_orgs = 26, n_dest = 1)
