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

# Uncomment line below to modify variable construction without building from scratch
load('data/long_data.RData')

# Uncomment lines below to build from scratch
# in.data <- read_csv('/Users/BBerger/Dropbox/Files_ClinTrials_Data/trials.csv')
# in.data <- read_csv('../Files_ClinTrials_Data/trials.csv')
# nih_activity_codes <- read_csv('data/nih_activity_codes.csv')
#icd9_xwalk <- read_csv('../bkthruWork_local/indicationXwalk/data/Cortellis_Drug_Indication_ICD9_Crosswalk_cancerValidated.csv')
#icd9_xwalk <- read_csv('../indicationXwalk/data/Cortellis_Drug_Indication_ICD9_Crosswalk_cancerValidated.csv')


## Subset to test functions
set.seed(101)
sample_index <- sample(nrow(in.data), 1000)
trials <-
  in.data %>%
  #slice(sample_index) %>% 
  rename(trial_id = id) %>% 
  arrange(trial_id)

## Parse json columns as tibbles (data_frames)
#Companies
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
#Indications and ICD-9 codes
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

#Biomarkers
biomarkers_long <- 
  trials %>% 
  my_expand(trial_id, BiomarkerNames) %>% 
  rename(biomarker_id = `@id`,
         biomarker_role = `@type`,
         biomarker_name = `$`
         ) %>% 
  mutate(disease_marker = grepl('disease', tolower(biomarker_role)),
         toxic_marker = grepl('toxic', tolower(biomarker_role)),
         therapeutic_marker = grepl('therapeutic', tolower(biomarker_role)),
         not_determined_marker = grepl('not determined', tolower(biomarker_role)),
         not_determined_marker = not_determined_marker | (!disease_marker & !toxic_marker & !therapeutic_marker)
         )
trial_biomarkers_long <- 
  biomarkers_long %>% 
  group_by(trial_id) %>% 
  summarize(disease_marker = any(disease_marker),
            toxic_marker = any(toxic_marker),
            therapeutic_marker = any(therapeutic_marker),
            not_determined_marker = any(not_determined_marker)
            )
biomarkers_long <-
  biomarkers_long %>% 
  select(-ends_with('_marker'))

#Trial Identifiers and NIH funding
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
#End dates
date_ends_long <- 
  trials %>% 
  my_expand(trial_id, DateEnd) %>% 
  rename(date_end_type = `@type`,
         date_end = `$`
         )
#Trial design, endpoints, recruitment status
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

#Trial location (US v. non-US)
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

