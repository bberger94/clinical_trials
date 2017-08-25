

library(dplyr)
library(fuzzyjoin)

# Extract geodata
json_to_dataframe_geodata <- function(s) {
  # If JSON is blank string return NULL
  if(is.na(s)) return(tibble())
  
  # Else JSON -> list
  l <- jsonlite::fromJSON(s)
  assert(class(l) == "list")
  
  # Separate countries and sites
  countries <- l[['SitesByCountry']][['@country']]
  sites <- l[['SitesByCountry']][['Sites']][['Site']] %>% as.list()
  
  # Print structure
  # countries %>% str %>% print
  # sites %>% str %>% print
  
  # Check if list 
  is_list <- sites %>% lapply(is.list) %>% as.logical %>% all
  # If not, make it one
  if(!is_list) sites <- list(sites)
  
  # Check whether first element of list contains address data
  # If it doesn't, only return countries
  list_names <- names(sites[[1]])
  if(all(grepl('Address*', list_names) == FALSE)){
    countries <- countries %>% as_tibble %>% rename(Country = value)
    return(countries)
  }
  
  #Add country variable to sites using a for loop because I'm terrible
  if(length(sites) == 1) sites[[1]][['Country']] <- countries
  else if(length(sites) > 1){
    for(i in seq_along(countries)){
      sites[[i]][['Country']] <- countries[i]
    }
  }
  
  # Change all data.frame columns to lists
  f <- function(x){
    if(class(x) == 'data.frame'){
      as.list(x)
    }
    else(x)
  }
  sites <- lapply(sites, lapply, f)
  
  #Change all integers and numerics to characters
  f <- function(x){
    if(class(x) == 'numeric' | class(x) == 'integer') as.character(x)
    else(x)
  }
  sites <- lapply(sites, lapply, f)
  
  #Remove unwanted columns
  f <- function(list){
    ok_names <- c('Address1', 'Address2', 'Address3', 'Name', 'Country')
    for(name in names(list)){
      if(!is.element(name, ok_names)) list[name] <- NULL
    }
    if(all(is.element(names(list), ok_names) == FALSE)) return(list())
    else(list)
  }
  sites <- lapply(sites, f)
  
  #Wrangle into a data frame
  sites <- lapply(sites, as.data.frame)
  sites <- bind_rows(sites)
  sites <- as_tibble(sites)
  
  return(sites)
}

# Running this should take about 20-30 minutes
geodata <-
  trials %>%
  #slice(1:2000) %>%
  select(trial_id, SitesByCountries) %>%
  my_expand(trial_id, SitesByCountries) %>% 
  select(trial_id, Country, everything())


# Load geodata from disk
geodata <- read_csv('data/geodata/geodata.csv')
###### Clean up the Geodata a bit
# Some country names only show up in the Address2 column
# E.g.Czechia does not appear as a country; replace all trials identified in Czechia with Country = 'Czech Republic'
data <- 
  geodata %>% 
  mutate(czechia = grepl('Czechia', Address2, ignore.case = TRUE), 
         serbmont = grepl('Former Serbia and Montenegro', Address2, ignore.case = TRUE),
         korea = grepl('Korea', Address2, ignore.case = TRUE),
         bulgaria = grepl('Bulgarian Drug Agency', Address2, ignore.case = TRUE),
         venez = grepl('Venezuela', Address2, ignore.case = TRUE),
         us = grepl('United States', Address2, ignore.case = TRUE),
         laos = grepl('Lao People\'s', Address2, ignore.case = TRUE),
         ivory = grepl('Côte D\'Ivoire', Address2, ignore.case = TRUE),
         micro = grepl('Micronesia', Address2, ignore.case = TRUE),
         kosovo = grepl('Kosovo', Address2, ignore.case = TRUE),
         brunei = grepl('Brunei', Address2, ignore.case = TRUE),
         macao = grepl('Macao', Address2, ignore.case = TRUE),
         
         Country = replace(Country, czechia == TRUE, 'Czech Republic'),
         Country = replace(Country, serbmont == TRUE, 'Former Serbia and Montenegro'),
         Country = replace(Country, korea == TRUE, 'South Korea'),
         Country = replace(Country, bulgaria == TRUE, 'Bulgaria'),
         Country = replace(Country, venez == TRUE, 'Venezuela'),
         Country = replace(Country, us == TRUE, 'US'),
         Country = replace(Country, laos == TRUE, 'Laos'),
         Country = replace(Country, ivory == TRUE, 'Ivory Coast'),
         Country = replace(Country, micro == TRUE, 'Micronesia, Federated States of'),
         Country = replace(Country, kosovo == TRUE, 'Kosovo'),
         Country = replace(Country, brunei == TRUE, 'Brunei'),
         Country = replace(Country, macao == TRUE, 'Macau')
  ) %>% 
  filter(!is.na(Country)) %>% 
  select(trial_id, Country, Name, starts_with('Address')) 

# View remaining trials with missing country entries
data %>% filter(is.na(Country) & !(is.na(Address1) & is.na(Address2))) %>% View

us_latlong_xwalk <- read_csv('data/geodata/zip_codes_states.csv') 
us_latlong_xwalk

# Update Base R objects with DC (note: puerto rico is listed as its own country)
state.name <- c(datasets::state.name, 'District of Columbia')
state.abb <- c(datasets::state.abb, 'DC')
state_codes <- tibble(state.name, state.abb)

# Subset to US Data
us_data <-
  data %>% 
  filter(Country == 'US') 

# Replace state names with 2 letter state abbreviations
us_data <- 
  us_data %>% 
  mutate(
    id = row_number(),
    is_state_name = Address2 %in% state.name,
    is_state_abb = Address2 %in% state.abb,
    is_state = is_state_name | is_state_abb
  )
list <- which(us_data$is_state_name)
us_data <- 
  us_data %>% 
  left_join(state_codes, by = c('Address2' = 'state.name')) %>% 
  mutate(Address2 = replace(Address2, list, state.abb[list])) %>% 
  select(id, trial_id, Name, starts_with('Address'), starts_with('is'))

## Perform
# 1. A direct match to zip code
# 2. A direct match to city and state code
# 3. A fuzzy match on addresses
# Prefer these in numeric order (ie. the first 2 always beat out a fuzzy match)

## Match directly to zip code
match_zip <-
  us_data %>% 
  rename(zip_code = Address3) %>% 
  mutate(zip_code = substr(zip_code, 1, 5)) %>% 
  inner_join(us_latlong_xwalk,
            by = 'zip_code'
  ) %>% 
  select(id, city, state, zip_code, latitude, longitude)

# Get index of matched lat/lngs
match_zip_ind <-
  match_zip %>%
  filter(!is.na(latitude)) %>%
  select(id) %>% unlist

## Match directly to city and state; if there are multiple zips per city, use average lat/lng
citystate_xwalk <- 
  us_latlong_xwalk %>% 
  group_by(city, state) %>% 
  summarize(latitude = mean(latitude, na.rm = T),
            longitude = mean(longitude, na.rm = T)
            )

match_citystate <- 
  us_data %>% 
  filter(!is.element(id, match_zip_ind)) %>% 
  rename(city = Address1, state = Address2) %>% 
  inner_join(citystate_xwalk,
            by = c('city', 'state')
            ) %>% 
  select(id, city, state, latitude, longitude)

match_citystate_ind <-
  match_citystate %>%
  filter(!is.na(latitude)) %>%
  select(id) %>% unlist

#### Fuzzy match on unmatched addresses
# # Bind address columns into one address column
# address_data <- 
#   us_data %>% 
#   filter(!is.element(id, union(match_zip_ind, match_citystate_ind))) %>%  # filter out matched zips
#   #filter(!(is.na(Address1) & is.na(Address2) & is.na(Address3))) %>%      # filter out if addresses columns are all blank
#   replace_na(list(Address1 = '', Address2 = '', Address3 = '')) %>% 
#   mutate(address = paste(Address1, Address2, Address3)) 
# 
# # Repeat above for crosswalk 
# address_xwalk <- 
#   us_latlong_xwalk %>% 
#   mutate(address = paste(city, state, zip_code))
# 
# # Execute fuzzy matching;
# # If multiple zips match to address, take their average lat/lngs
# match_address <-
#   address_data %>% 
#   slice(1:20) %>% 
#   stringdist_left_join(address_xwalk, method = 'jw', distance_col = 'String_dist', max_dist = .4) %>% 
#   group_by(id) %>% 
#   filter(String_dist == min(String_dist)) %>% 
#   group_by(id, address.x, city, state) %>% 
#   summarize(latitude = mean(latitude, na.rm = TRUE), longitude = mean(longitude, na.rm = TRUE))
# match_address %>% View


#----------------------#
## Merge lat/lngs back 
merged_data <- 
  us_data %>%
  left_join(match_zip, by = 'id') %>%
  left_join(match_citystate, by = 'id') %>% 
  mutate(city = coalesce(city.x, city.y),
         state = coalesce(state.x, state.y),
         latitude = coalesce(latitude.x, latitude.y),
         longitude = coalesce(longitude.x, longitude.y)
         ) %>% 
  select(-ends_with('.x'), -ends_with('.y')) 



###### Write to disk
dir.create('data/geodata', showWarnings = F)
geodata %>% 
  write_csv(path = 'data/geodata/geodata.csv')




