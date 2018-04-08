# trial_count.R
# Author: Ben Berger

# This script counts the number of Phase I-III trials that companies participated in.
# Particularly, we aggregate companies up to the level of "ancestor company" 
# as defined by the Cortellis API. 
# Companies are further identified as "sponsors" or "collaborators" and trial
# counts are separately reported for just these roles.

library(haven)
library(readr)
library(dplyr)
library(tidyr)


rm(list = ls())
trial_data <- read_dta('data/prepared_trials.dta')
company_data <- read_dta('data/companies_mergedAncestors.dta')

# Keep only company and trial IDs; reshape long
trials <-
  trial_data %>%
  select(trial_id, contains('company_id')) %>% 
  gather(key, company_id, -trial_id) 

# Join company and ancestor company data to trials
merged <- 
  company_data %>% 
  select(company_id = cortellis_id, 
         ancestor_company_id = ancestor_cortellis_id,
         ancestor_name
         ) %>% 
  right_join(trials, by = 'company_id') %>% 
  filter(company_id != "") %>% 
  arrange(trial_id)

# Count number of trials by company sponsor and/or collaborator

# Variable definitions:
# n = count of unique trial ids by ancestor company (sponsor or collaborator)
# n_sponsor = count of unique trial ids for ancestor companies acting as sponsor
# n_collab = count of unique trial ids for ancestor companies acting as collaborator
# n_sponsor + n_collab >= n (ancestor companies can be both sponsor and collaborator on a trial)

trial_counts <- 
  merged %>% 
  mutate(sponsor_co = grepl(pattern = 'sponsor', x = key),
         collab_co = grepl(pattern = 'collaborator', x = key)
         ) %>% 
  group_by(ancestor_company_id, ancestor_name) %>% 
  summarize(n = length(unique(trial_id)),                              
            n_sponsor = length(unique(trial_id[sponsor_co == TRUE])),  
            n_collab = length(unique(trial_id[collab_co == TRUE]))    
            ) %>% 
  arrange(ancestor_company_id)

# Write to disk
write_csv(trial_counts, 'data/trial_counts.csv')








