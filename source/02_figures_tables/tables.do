set more off
local trial_data "../data/clinical_trials_07-23-17.dta"
local trial_data_sample "../data/ct_sample.dta"

/*
use `trial_data', clear
**Write a sample to disk for testing code
set seed 101
sample 10 
save `trial_data_sample', replace
*/

use `trial_data_sample', clear
//use `trial_data', clear

**Select universe of trials
keep if phase_1 == 1 | phase_2 == 1 | phase_3 == 1

**Replace missing nih funding with 0
replace nih_funding = 0 if nih_funding == .
**Recode trials with multiple phase designations
replace phase_2 = 0 if phase_1 == 1 & phase_2 == 1
replace phase_3 = 0 if phase_2 == 1 & phase_3 == 1
***verify (there should be no elements in (1,1) ) 
table phase_1 phase_2
table phase_2 phase_3

**Biomarker roles listed as biomarker types: rename as stopgap
rename biomarker_type_* biomarker_role_*

**Generate useful variables
***Trial start and end years
gen year_start = year(date_start)
gen year_end = year(date_end)

***Trial duration: throw out trials with duration less than 15 days
gen duration = (date_end - date_start) / 30
label variable duration "Trial duration in months"
replace duration = . if duration <= .5
replace duration = . if duration > 1000

***Indicator for biomarker role
cap drop *_role
gen disease_biomarker_role = 0
gen toxic_biomarker_role = 0
gen therapeutic_biomarker_role = 0
gen not_determined_biomarker_role = 0
foreach var of varlist biomarker_role_* {
	replace `var' = lower(`var')
	replace disease_biomarker_role = 1 if strpos(`var', "disease")
	replace toxic_biomarker_role = 1 if strpos(`var', "toxic")
	replace therapeutic_biomarker_role = 1 if strpos(`var', "therapeutic")
	replace not_determined_biomarker_role = 1 if strpos(`var', "not determined") 
}
**Indicate any trials with biomarkers but no specified roles as "not_determined"
replace not_determined_biomarker_role = 1 if biomarker_status == 1 & ///
	disease_biomarker_role == 0 & toxic_biomarker_role == 0 & therapeutic_biomarker_role == 0

**Label variables 
cap label drop biomarker_label
	label define biomarker_label 0 "No biomarker" 1 "Biomarker"
	label values biomarker_status biomarker_label
cap label drop nih_label
	label define nih_label 0 "No funding" 1 "NIH funding"
	label values nih_funding nih_label
cap label drop year_labels
	label define year_labels 1995 1995
	label values year_start year_labels
	label values year_end year_labels



**Define directory for reports
set more off
local report_directory "../reports"
do "02_figures_tables/tables_fns.do"

*Generate tables
**Number of trials receiving NIH funding by presence of biomarker
nih_bmkr_count, report_directory(`report_directory')

**Percent of trials receiving NIH funding by biomarker and trial location
nih_bmkr_us_pct, report_directory(`report_directory')

**Percent of trials receiving NIH funding by biomarker and phase
nih_bmkr_phase_pct, report_directory(`report_directory')

**Percent of trials receiving NIH funding by biomarker role
nih_bmkrrole, report_directory(`report_directory')

**Count of trials by phase
trial_phase, report_directory(`report_directory')

**Averages of select variables
nih_means, report_directory(`report_directory')

**Average trial duration by end year
trial_duration, report_directory(`report_directory')


