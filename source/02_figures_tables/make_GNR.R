# GNR stands for Generous Not Restrictive. 
# GNR trials are identified as using an LPM biomarker under the generous definition
# but NOT the restrictive definition.
# GNR does NOT stand for the garbage American rock band Guns n Roses.

library(haven)
library(dplyr)
library(readr)
library(lubridate)

# Load data
trials <- read_dta('data/processed/prepared_trials.dta')
trial_descriptions <- read_csv('data/raw/trials.csv')

#  Generous Not Restrictive (GNR) Subsample
gnr_trials <- 
   trials %>% 
   select(trial_id, r_lpm, g_lpm
          ,date_start, date_end
          ,starts_with('phase')
          ,us_trial, nih_funding, neoplasm, patient_count_enrollment
          ,sponsor_public, sponsor_public_max
          ,ends_with('_drole'), ends_with('_role'), ends_with('type')
          ) %>% 
   filter(r_lpm != g_lpm) 

gnr_trials <- gnr_trials %>% mutate_if(function(x) is.double(x) & !is.Date(x), as.integer)

# Join in descriptions
data <- gnr_trials %>% 
   left_join(
      trial_descriptions %>% 
         select(trial_id = id, biomarker_names = BiomarkerNames, aims_and_scope = AimsAndScope)
   ) %>% 
   select(trial_id, r_lpm, g_lpm, aims_and_scope, biomarker_names, everything())

# Write to disk
write_csv(data, 'data/misc/GNR_trials.csv')
