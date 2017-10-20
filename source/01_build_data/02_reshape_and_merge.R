## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## 02_reshape_and_merge.R ; Author: Ben Berger;                              
##                                                                           
## Takes parsed data in the long format produced by "01_parse_trial_json.R",       
## and reshapes them in the wide format with each row representing a unique trial                                                                     ##
##
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

#Load packages
library(dplyr)
library(tidyr)
library(haven)
library(readr)
library(lubridate)

## ------------------------------------------------------------------------------------------------ ##
##  Define function to reshape trial data long to wide
## ------------------------------------------------------------------------------------------------ ##
# This function changes each data frame from long (index = trial_id-observation) to wide (index = trial_id).
#
# For each value of variable NAME within a trial, create a variable named NAME_XYZ where XYZ is 
# a 3-digit number. The first variable is named NAME_001, then NAME_002, NAME_003 etc.
#
# If variable NAME has a single value within each trial is NOT named NAME_001, it is just named NAME. 

my_reshape <- function(df) {
  
  # Function checks whether class of x is POSIXct (datetime)
  is.POSIXct <- function(x) 'POSIXct' %in% class(x)
  
  df %>% 
    group_by(trial_id) %>% 
    # Mutate Date vars -> Character vars
    mutate_if(is.POSIXct, as.character.Date) %>% 
    mutate(i = 1:n()) %>% 
    mutate(i = as.character(sprintf("%03d", i))) %>% 
    ungroup %>% 
    select(trial_id, everything()) %>% 
    gather(key, value, -c(i, trial_id)) %>% 
    # For each variable identify if only 1 value
    group_by(key) %>% mutate(one_value = (all(i == '001'))) %>% ungroup %>% 
    unite(key_i, c(key, i)) %>% 
    mutate(key_i = replace( x = key_i,
                            list = one_value == TRUE,
                            # If only 1 var value, remove trailing "_001"
                            values = substr(key_i, 1, nchar(key_i) - 4) 
                            )
           ) %>% 
    select(-one_value) %>% 
    spread(key_i, value)
}


## ------------------------------------------------------------------------------------------------ ##
##  Load long data (from 01_parse_trial_json.R)
## ------------------------------------------------------------------------------------------------ ##
load('data/temp/long_data.RData')

# Initialize a tibble with only non-json columns
data_wide <-
  trials %>%
  select(trial_id,
         date_start = DateStart,
         patient_count_enrollment = PatientCountEnrollment,
         phase = Phase) 

# Make a copy for companies 
firms_wide <-
  trials %>%
  select(trial_id) 

## ------------------------------------------------------------------------------------------------ ##
##  Reshape long dataframes wide and right join by trial_id 
## ------------------------------------------------------------------------------------------------ ##

# First for just firm-level data
longdata_names_firms <- c('sponsors_long', 'collaborators_long')
for(longdata in longdata_names_firms){
  print(longdata)
  longdata <- get(longdata) 
  firms_wide <- longdata %>% my_reshape %>% right_join(firms_wide, by = 'trial_id')
}

# Then for everything else
longdata_names_nofirms <- setdiff(ls(pattern = '*_long'), longdata_names_firms)
for(longdata in longdata_names_nofirms ){
  print(longdata)
  longdata <- get(longdata) 
  data_wide <- longdata %>% my_reshape %>% right_join(data_wide, by = 'trial_id')
}


## ------------------------------------------------------------------------------------------------ ##
##  Clean data
## ------------------------------------------------------------------------------------------------ ##

#Make phase indicators; indicator of biomarker presence
data_wide <- 
  data_wide %>%
  mutate(phase_1 = grepl('Phase 1', phase),
         phase_2 = grepl('Phase 2', phase),
         phase_3 = grepl('Phase 3', phase),
         phase_4 = grepl('Phase 4', phase)
         ) 

#Replace phase_ columns with NA if phase is not specified 
#'Phase Not Applicable' returns phase_N = 0 for all trial phases N
# data_wide[data_wide$phase == 'Phase not specified',grep('phase_', colnames(data_wide))] <- NA

# Replace nih funding indicator with false if NA (which means no trial identifiers)
data_wide$nih_funding[is.na(data_wide$nih_funding)] <- FALSE
table(data_wide$nih_funding)

# Make the data pretty(ish)!
data <- 
  data_wide %>% 
  select(
    trial_id, 
    date_start,
    date_end,
    date_end_type,
    starts_with('phase'),
    us_trial,
    nih_funding,
    patient_count_enrollment,
    recruitment_status,
    starts_with('indication'),
    starts_with('icd9'), 
    starts_with('trial_endpoint'), starts_with('trial_design'),
    starts_with('malignant_not_specified'),
    everything()
  ) %>%
  mutate(date_start = as.Date(date_start),
         date_end = as.Date(date_end)) %>% 
  mutate_if(is.logical, as.numeric) %>% 
  arrange(trial_id)

data_firms <- 
  firms_wide %>% 
  select(trial_id, starts_with('s'), starts_with('c')) %>%
  mutate_at(vars(contains('public')), as.integer) %>% 
  mutate_at(vars(contains('ipo_date')), function(col) as_date(col)) 

## ------------------------------------------------------------------------------------------------ ##
##  Export data; saving firm data separately
## ------------------------------------------------------------------------------------------------ ##
save(file = 'data/processed/clinical_trials_09-20-17.RData', data) 
save(file = 'data/processed/firm_data_09-20-17.RData', data_firms) 
 
write_dta(data,       'data/processed/clinical_trials_09-20-17.dta', version = 12)
write_dta(data_firms, 'data/processed/firm_data_09-20-17.dta',       version = 12) 














