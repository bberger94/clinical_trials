## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##
##  Saves trial sponsor/collaborator -> ancestor company linkages to a file: trial_company_ancestors.csv 
##
##
## ------------------------------------------------------------------------------------------------ ##
## ------------------------------------------------------------------------------------------------ ##

library(dplyr)
load('data/long_data.RData')


dir.create('data/misc', showWarnings = FALSE)

sponsors <- 
  sponsors_long %>% 
  select(trial_id, company_id = sponsor_company_id, company_name = sponsor_company_name, 
         everything(), -starts_with('ancestor'), starts_with('ancestor'),
         -cortellis_name) %>% 
  mutate(sponsor_or_collab = 'sponsor')

collaborators <- 
  collaborators_long %>%
  select(trial_id, company_id = collaborator_company_id, company_name = collaborator_company_name, 
         everything(), -starts_with('ancestor'), starts_with('ancestor'),
         -cortellis_name) %>% 
  mutate(sponsor_or_collab = 'collaborator')



sponsors %>%
  bind_rows(collaborators) %>%
  select(trial_id, sponsor_or_collab, everything()) %>% 
  arrange(trial_id) %>%
  write_csv(path = 'data/misc/trial_company_ancestors.csv')
    
