## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## 03_parse_biomarkers.R ; Author: Ben Berger;                              
##
## Makes dataset of trials and associated biomarkers
##
## 1. For each biomarker x indication pair and each potential detailed bmkr role
##    identify whether the pair CAN be used for that role.
## 2. Joins detailed roles to trials by matching on biomarker and indication
## 3. Joins biomarker types to trials by matching only on biomarker
##
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

## Load packages 
library(dplyr) 
library(rlang)
library(readr)
library(tidyr)
library(haven)

## ------------------------------------------------------------------------------------------------ ##
##  Define functions
## ------------------------------------------------------------------------------------------------ ##
source('source/01_build_data/00_build_functions.R')

## ------------------------------------------------------------------------------------------------ ##
##  Load data
## ------------------------------------------------------------------------------------------------ ##
# Load biomarkers used in trials
load('data/temp/trial_biomarkers.RData')
# Load indications used in trials
load('data/temp/indications_long.RData')

# Load detailed biomarker role data
biomarker_uses <- read_csv('data/raw/biomarker_uses.csv') 
roles <- 
  biomarker_uses %>% 
  select(biomarker_use_id,
         biomarker_id,
         ci_indication_id,
         biomarker,
         detailed_role = role
  ) %>% 
  group_by(biomarker_id, ci_indication_id) %>% 
  summarize(diagnosis_drole =                any(detailed_role == 'Diagnosis'), 
            diff_diagnosis_drole =           any(detailed_role == 'Differential Diagnosis'), 
            predict_resistance_drole =       any(detailed_role == 'Predicting Drug Resistance'), 
            predict_efficacy_drole =         any(detailed_role == 'Predicting Treatment Efficacy'),
            predict_toxicity_drole =         any(detailed_role == 'Predicting Treatment Toxicity'),
            screening_detail_drole =         any(detailed_role == 'Screening'), 
            selection_for_therapy_drole =    any(detailed_role == 'Selection for Therapy'),
            all_drole =                      any(detailed_role == 'All'),
            disease_profiling_drole =        any(detailed_role == 'Disease Profiling'),
            monitor_progression_drole =      any(detailed_role == 'Monitoring Disease Progression'),
            monitor_efficacy_drole =         any(detailed_role == 'Monitoring Treatment Efficacy'),
            monitor_toxicity_drole =         any(detailed_role == 'Monitoring Treatment Toxicity'),
            monitor_progression_drole =      any(detailed_role == 'Monitoring Disease Progression'),
            not_determined_drole =           any(detailed_role == 'Not Determined'),
            prognosis_drole =                any(detailed_role == 'Prognosis'),
            prognosis_riskstrat_drole =      any(detailed_role == 'Prognosis - Risk Stratification'),
            risk_factor_drole =              any(detailed_role == 'Risk Factor'),
            staging_drole =                  any(detailed_role == 'Staging'),
            toxicity_profiling_drole =       any(detailed_role == 'Toxicity Profiling')
  ) %>% 
  arrange(biomarker_id, ci_indication_id)

# Join biomarkers and indications, then match detailed role data to both
biomarkers_indications <- 
  trial_biomarkers %>% 
  left_join(indications_long, by = 'trial_id') %>% 
  mutate(indication_id = as.numeric(indication_id),
         biomarker_id = as.numeric(biomarker_id)) %>% 
  left_join(roles, by = c('biomarker_id', 'indication_id' = 'ci_indication_id')) %>% 
  select(trial_id, indication_id, biomarker_id,  everything() ) 

# Match biomarker type data
biomarker_types <- read_csv('data/raw/biomarkers.csv')
types <- 
  biomarker_types %>%
  my_expand(id, BiomarkerTypes) %>% 
  rename(biomarker_id = id,
         biomarker_type = `~BiomarkerTypes`) %>% 
  arrange(biomarker_id)

# Define function to reshape biomarker types long to wide 
# i.e. biomarker_id type -> biomarker_id type_001 type_002 type...

reshape_types <- function(df) {
  df %>% 
    group_by(biomarker_id) %>% 
    mutate(i = 1:n()) %>% 
    mutate(i = as.character(sprintf("%03d", i))) %>% 
    ungroup %>% 
    select(biomarker_id, everything()) %>% 
    gather(key, value, -c(i, biomarker_id)) %>% 
    unite(key_i, c(key, i)) %>% 
    spread(key_i, value)
  }

types <- reshape_types(types)

biomarker_data <-
  biomarkers_indications %>%
  left_join(types, by = 'biomarker_id')

# Write to file
save(file = 'data/processed/biomarker_data.RData', biomarker_data)
write_dta(biomarker_data, 'data/processed/biomarker_data.dta', version = 12)










