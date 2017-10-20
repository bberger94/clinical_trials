## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
## 01_company_ancestors.R ; Author: Ben Berger;                               
##
## Joins company "ancestor" data to company data.
##
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

rm(list = ls())
library(dplyr)
library(readr)
library(haven)

data <-
  read_csv(file = 'data/raw/companies.csv',
           col_types =  cols(cortellis_id = col_character())
           )

# Make data frame of all companies
companies <-
  data %>% 
  select(cortellis_id, cortellis_name, permid, ancestor_name, public, ipo_date, permid_name)

# We exploit the fact that ancestors are just a subset of all companies
# Make data frame of all potential ancestors (this is the same as companies, but with different variable names)
ancestors <- companies %>% select(-ancestor_name) %>% rename(name = cortellis_name)

# Rename ancestor columns to begin with "ancestor_"
f <- function(x) paste0('ancestor_', x)
names(ancestors) <- sapply(names(ancestors), f)

# Merge together by cortellis ancestor name
ancestor_data <-
  companies %>% 
  left_join(ancestors, by = 'ancestor_name')

# Write to disk
save(ancestor_data, file = 'data/temp/companies_mergedAncestors.RData')








