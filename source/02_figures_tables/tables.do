do "02_figures_tables/tables_fns.do"

local trial_data "../data/clinical_trials_07-19-17.dta"
local trial_data_sample "../data/ct_sample.dta"

/*
use `trial_data', clear
**Write a sample to disk for testing code
set seed 101
sample 10 
save `trial_data_sample', replace
*/

use `trial_data_sample', clear

**Select universe of trials
keep if phase_1 == 1 || phase_2 == 1 || phase_3 == 1
