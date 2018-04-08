## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## sample_firm_data.R
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
##  Load data
## ------------------------------------------------------------------------------------------------ ##


# Uncomment line below to load data without building from scratch
#load('data/long_data.RData')

get_ids <- function(){
  set.seed(101)
  sponsors_long %>% 
    select(trial_id) %>% 
    unique %>% 
    sample_n(size = 200) %>% 
    collect %>% .[[1]]
}

trial_ids <- get_ids()

data <-
  sponsors_long %>% 
  filter(trial_id %in% trial_ids) %>% 
  select(trial_id, 
         sponsor_company_name, s_ancestor_name,
         s_public, s_ancestor_public,
         s_ipo_date, s_ancestor_ipo_date
         ) %>% 
  arrange(trial_id) 

write_csv(data, 'data/samples/trial-firms.csv')




