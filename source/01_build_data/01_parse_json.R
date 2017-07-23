#########################################################################
## parse_json.R ; Author: Ben Berger;                                  ##
## Modified from script by Andrew Marder:                              ##

## Original notes from AM:                                             ##
## I've written a function called `my_expand` to make working with the ##
## trials data a little bit easier. The `get_name`, `assert`, and      ##
## `json_to_dataframe` functions are helper functions that I used to   ##
## write the `my_expand` function.                                     ##
#########################################################################

library(dplyr)
library(rlang)
library(readr)

## Andrew: I prefer to assert conditions instead of stopping if not a condition.
assert <- stopifnot

get_name <- function(x) as.character(UQE(x))

## Apply json_to_dataframe to each cell of a column
my_expand <- function(df, id, var) {
  id <- enquo(id)
  var <- enquo(var)
  varname <- deparse(substitute(var))
  
  f <- function(row) {
    assert(class(row) == "list")
    if(varname == '~SitesByCountries') data <- json_to_dataframe_geodata(row[[get_name(var)]])
    else data <- json_to_dataframe(row[[get_name(var)]], varname)
    data[[get_name(id)]] <- row[[get_name(id)]]
    return(data)
  }
  
  df %>%
    select(!!id, !!var) %>%
    filter(!is.na(!!var)) %>%
    rowwise() %>%
    do(f(.)) %>% 
    ungroup
}


## Parse a JSON cell as a tibble (data_frame)
json_to_dataframe <- function(s, varname) {
  l <- jsonlite::fromJSON(s)
  assert(class(l) == "list")
  if(length(l) == 1) data <- l[[1]]
  else data <- l
  
  if (class(data) == "data.frame") {
    return(data)
  }
  else {
    data2 <- data.frame(data)
    if(length(names(data)) == 0) names(data2) <- varname
    else names(data2) <- names(data)
    # next few lines are some test code for getting country data
    # if(varname == '~SitesByCountries'){
    #    data2$site_subdivision_code <- data2[['Sites.Site.CountrySubDivision']][['@code']]
    #    data2$site_subdivision_name <- data2[['Sites.Site.CountrySubDivision']][['$']]
    #    data2[['Sites.Site.CountrySubDivision']] <- NULL
    # }
    
    return(data2)
  }
}

#Parse Geographic Data Column: Extract limited information
json_to_dataframe_geodata <- function(s) {
  l <- jsonlite::fromJSON(s)
  assert(class(l) == "list")
  if(length(l) == 1) data <- l[[1]]
  else data <- l

  if(is.null(data[['@country']])) data[['@country']] <- NA
  data <- data[['@country']] %>% as.data.frame
  names(data) <- 'country'

  return(data)
}


#########################################
## Call functions to parse JSON below  ##
#########################################
## Read in data
options(stringsAsFactors = FALSE)
#in.data <- read_csv('/Users/BBerger/Dropbox/Files_ClinTrials_Data/trials.csv')
in.data <- read_csv('../Files_ClinTrials_Data/trials.csv')
nih_activity_codes <- read_csv('data/nih_activity_codes.csv')

## Subset to test functions
set.seed(101)
sample_index <- sample(nrow(in.data), 10000)
trials <-
  in.data %>%
  #slice(sample_index) %>% 
  rename(trial_id = id) %>% 
  arrange(trial_id)

## Parse json columns as tibbles (data_frames)
collaborators_long <-
  trials %>%
  my_expand(trial_id, CompaniesCollaborator) %>%
  rename(collaborator_company_id = `@id`, collaborator_company_name = `$`
         )
sponsors_long <-
  trials %>%
  my_expand(trial_id, CompaniesSponsor) %>%
  rename(sponsor_company_id = `@id`, sponsor_company_name = `$`
         )
indications_long <-
  trials %>%
  my_expand(trial_id, Indications) %>%
  rename(indication_id = `@id`, indication_name = `$`
         )
biomarkers_long <- 
  trials %>% 
  my_expand(trial_id, BiomarkerNames) %>% 
  rename(biomarker_id = `@id`,
         biomarker_type = `@type`,
         biomarker_name = `$`
         )
identifiers_long <-
  trials %>% 
  my_expand(trial_id, Identifiers) %>% 
  rename(trial_identifier_type = `@type`,
         trial_identifier = `$`
         )
nih_long <- 
  identifiers_long %>% 
  mutate(trial_id_first3 = substring(trimws(trial_identifier), 1, 3)) %>% 
  mutate(nih_yes = is.element(el = trial_id_first3, set = nih_activity_codes$nih_activity_code)) %>% 
  select(trial_id, nih_yes) %>% 
  group_by(trial_id) %>% 
  summarize(nih_yes = any(nih_yes)
            )
date_ends_long <- 
  trials %>% 
  my_expand(trial_id, DateEnd) %>% 
  rename(date_end_type = `@type`,
         date_end = `$`
         ) 
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
#note: us_trial is true when the US is listed as a trial site, and false when it is not AND another country IS
#trials in which no site is listed with location in the trials data do NOT appear in us_trials_long
us_trials_long <- 
  trials %>%
  #slice(166378) %>% 
  my_expand(trial_id, SitesByCountries) %>% 
  mutate(us_trial = (country == 'US')) %>% 
  ungroup %>% group_by(trial_id) %>% 
  summarize(us_trial = any(us_trial))

save.image(file = 'data/long_data.RData')

