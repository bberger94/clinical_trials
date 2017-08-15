# For exporting trials and associated NIH grant numbers
# Author: Ben Berger
# Created: 8-15-17

library(dplyr)
library(rlang)
library(readr)
library(tidyr)
library(haven)

my_reshape <- function(df) {
  df %>% 
    group_by(trial_id) %>% 
    mutate(i = 1:n()) %>% 
    mutate(i = as.character(sprintf("%03d", i))) %>% 
    ungroup %>% 
    select(trial_id, everything()) %>% 
    gather(key, value, -c(i, trial_id)) %>% 
    unite(key_i, c(key, i)) %>% 
    spread(key_i, value)
}

#############################################################
load('data/long_data.RData')

nih_ids <- 
  identifiers_long %>% 
  mutate(trial_id_first3 = substring(trimws(trial_identifier), 1, 3)) %>% 
  mutate(nih_funding = is.element(el = trial_id_first3, set = nih_activity_codes$nih_activity_code)) %>% 
  filter(nih_funding == T) %>% 
  select(trial_id, nih_grant_num = trial_identifier) 

trials_nih_ids_long <-
  trials %>% 
  select(trial_id) %>% 
  left_join(nih_ids, by = 'trial_id') 

trials_nih_ids <- 
  trials_nih_ids_long %>% 
  my_reshape


trials_nih_ids %>% 
  write_csv(path = 'data/trials_nih_ids.csv', na = "")
