## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## 01_parse_trial_json.R ; Author: Ben Berger;                               
## Modified from script by Andrew Marder:                              
##
## Parses JSON columns from trials.csv (from cortellis API) as dataframes in long form. 
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
options(stringsAsFactors = FALSE)

# Uncomment line below to load data without building from scratch
#load('data/long_data.RData')

# Uncomment lines below to build data from scratch
in.data <- read_csv('data/raw/trials.csv')
nih_activity_codes <- read_csv('data/misc/nih_activity_codes.csv')
icd9_xwalk <- read_csv('../indicationXwalk/data/Cortellis_Drug_Indication_ICD9_Crosswalk_Validated_10-17-17.csv')
load('data/temp/companies_mergedAncestors.RData')


## Pick sample index to test functions
set.seed(101)
sample_index <- sample(nrow(in.data), 1000)

## Save dataframe of trials
trials <-
  in.data %>%
  rename(trial_id = id) %>% 
  arrange(trial_id)


## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
##  Parse json columns as long form dataframes:
##  i.e. trials are listed multiple times for each observation
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

## ------------------------------------------------------------------------------------------------ ##
##  Firms
## ------------------------------------------------------------------------------------------------ ##
collaborators_long <-
  trials %>%
  my_expand(trial_id, CompaniesCollaborator) %>%
  rename(collaborator_company_id = `@id`, collaborator_company_name = `$`
         ) %>% 
  left_join(ancestor_data, by = c('collaborator_company_id' = 'cortellis_id'))
# Pick which names to append 'collaborator' to 
logical <- names(collaborators_long) != 'trial_id' & grepl('collaborator', names(collaborators_long)) == F
names(collaborators_long)[logical] <- paste0('c_', names(collaborators_long)[logical])


sponsors_long <-
  trials %>%
  my_expand(trial_id, CompaniesSponsor) %>%
  rename(sponsor_company_id = `@id`, sponsor_company_name = `$`
         ) %>% 
  left_join(ancestor_data, by = c('sponsor_company_id' = 'cortellis_id'))
# Pick which names to append 'sponsor' to 
logical <- names(sponsors_long) != 'trial_id' & grepl('sponsor', names(sponsors_long)) == F
names(sponsors_long)[logical] <- paste0('s_', names(sponsors_long)[logical])


## ------------------------------------------------------------------------------------------------ ##
##  Indications and ICD-9 codes
## ------------------------------------------------------------------------------------------------ ##
indications_long <-
  trials %>%
  my_expand(trial_id, Indications) %>%
  rename(indication_id = `@id`, indication_name = `$`
         ) %>% 
  mutate(indication_name = tolower(indication_name)) 
icd9_long <- 
  indications_long %>% 
  left_join(icd9_xwalk, by = c('indication_name' = 'cortellis_condition')) %>% 
  select(trial_id, starts_with('icd9'), malignant_not_specified)

## ------------------------------------------------------------------------------------------------ ##
##  Trial Identifiers and NIH funding
## ------------------------------------------------------------------------------------------------ ##
identifiers_long <-
  trials %>% 
  my_expand(trial_id, Identifiers) %>% 
  rename(trial_identifier_type = `@type`,
         trial_identifier = `$`
         )
nih_long <- 
  identifiers_long %>% 
  mutate(trial_id_first3 = substring(trimws(trial_identifier), 1, 3)) %>% 
  mutate(nih_funding = is.element(el = trial_id_first3, set = nih_activity_codes$nih_activity_code)) %>% 
  select(trial_id, nih_funding) %>% 
  group_by(trial_id) %>% 
  summarize(nih_funding = any(nih_funding)
            )

## ------------------------------------------------------------------------------------------------ ##
##  End dates
## ------------------------------------------------------------------------------------------------ ##
date_ends_long <- 
  trials %>% 
  my_expand(trial_id, DateEnd) %>% 
  rename(date_end_type = `@type`,
         date_end = `$`
         )

## ------------------------------------------------------------------------------------------------ ##
##  Trial design, endpoints, recruitment status
## ------------------------------------------------------------------------------------------------ ##
trial_design_long <- 
  trials %>% 
  my_expand(trial_id, TermsDesign) %>% 
  rename(trial_design = `~TermsDesign`
         ) 
trial_endpoints_long <- 
  trials %>% 
  my_expand(trial_id, TermsEndpoint) %>% 
  rename(trial_endpoint = `~TermsEndpoint`
         ) 
trial_recruitment_long <- 
  trials %>% 
  my_expand(trial_id, RecruitmentStatus) %>% 
  rename(recruitment_status = `$`) %>% 
  select(-`@id`)

## ------------------------------------------------------------------------------------------------ ##
##  Trial location (US v. non-US)
## ------------------------------------------------------------------------------------------------ ##
#note: us_trial == TRUE when the US is listed as a trial site, and FALSE when it is not AND another country IS
#trials in which no site is listed with location in the trials data do NOT appear in us_trials_long
us_trials_long <- 
  trials %>%
  my_expand(trial_id, SitesByCountries) %>% 
  mutate(us_trial = (country == 'US')) %>% 
  ungroup %>% group_by(trial_id) %>% 
  summarize(us_trial = any(us_trial))


## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
##  Parse trial biomarkers
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

trial_biomarkers <- 
  trials %>% 
  my_expand(trial_id, BiomarkerNames) %>% 
  rename(biomarker_id = `@id`,
         biomarker_role = `@type`,
         biomarker_name = `$`
  ) %>% 
  mutate(disease_marker        = grepl('disease', tolower(biomarker_role)),
         toxic_marker          = grepl('toxic', tolower(biomarker_role)),
         therapeutic_marker    = grepl('therapeutic', tolower(biomarker_role)),
         not_determined_marker = grepl('not determined', tolower(biomarker_role)),
         not_determined_marker = not_determined_marker | (!disease_marker & !toxic_marker & !therapeutic_marker)
  )



save.image(file = 'data/temp/long_data.RData')
save(trial_biomarkers, file = 'data/temp/trial_biomarkers.RData')
save(indications_long, file = 'data/temp/indications_long.RData')















