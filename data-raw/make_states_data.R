library(dplyr)
library(sf)
library(qs)

states <- tigris::states() %>%
  select(state = NAME) %>%
  filter(!state %in% c('United States Virgin Islands',
                       'Commonwealth of the Northern Mariana Islands',
                       'Guam', 'American Samoa', 'Puerto Rico')) %>%
  mutate(state = stringr::str_to_lower(state),
         state = stringr::str_remove_all(state, " ")) %>%
  st_transform(5072)

states$state[states$state == 'districtofcolumbia'] <- 'district'
states <- filter(states, state != 'district')

usethis::use_data(states, internal = TRUE, overwrite = TRUE)
