library(tidyr)
library(haven)

#To reshape trial data long to wide
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

#Initialize a tibble with only non-json columns
data_wide <-
  trials %>%
  select(trial_id,
         date_start = DateStart,
         patient_count_enrollment = PatientCountEnrollment,
         phase = Phase) 

#Reshape intermediary dataframes wide and right join by trial_id
for(longdata in ls(pattern = '*_long')){
  longdata <- get(longdata) 
  data_wide <- longdata %>% my_reshape %>% right_join(data_wide)
}

#Select for column order; Arrange to sort by trial_id
data_wide <- 
  data_wide %>%
  mutate(phase_1 = grepl('Phase 1', phase),
         phase_2 = grepl('Phase 2', phase),
         phase_3 = grepl('Phase 3', phase),
         phase_4 = grepl('Phase 4', phase),
         ) 

#Replace phase_N columns with NA if phase is not specified 
#'Phase Not Applicable' returns phase_N = 0 for all trial phases N
data_wide[data_wide$phase == 'Phase not specified',grep('phase_', colnames(data_wide))] <- NA

data <- 
  data_wide %>% 
  select(
    trial_id, 
    date_start = date_start,
    date_end = date_end_001,
    date_end_type = date_end_type_001,
    starts_with('phase'),
    us_trial = us_trial_001,
    patient_count_enrollment,
    recruitment_status = recruitment_status_001,
    starts_with('indication'),
    starts_with('sponsor_company'),
    starts_with('collaborator_company'),
    starts_with('biomarker_id'),
    starts_with('biomarker_name'),
    starts_with('biomarker_type'),
    starts_with('trial_endpoint'),
    starts_with('trial_design'),
    everything()
  ) %>%
  mutate(date_start = as.Date(date_start),
         date_end = as.Date(date_end)) %>% 
  mutate_if(is.logical, as.numeric) %>% 
  arrange(trial_id)

save(file = '../Dropbox/clinical_trials/data/clinical_trials_07-19-17.RData', data) 
write_csv(data, '../Dropbox/clinical_trials/data/clinical_trials_07-19-17.csv') 
write_dta(data, '../Dropbox/clinical_trials/data/clinical_trials_07-19-17.dta', version = 12) 



#write_dta('/Users/BBerger/Dropbox/clinical_trials/data/clinical_trials_toydata.dta', version = 13) 
