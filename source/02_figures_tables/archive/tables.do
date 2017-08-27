set more off
local trial_data "data/clinical_trials_07-23-17.dta"
local trial_data_sample "data/ct_sample.dta"

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

**Recode trials with multiple phase designations
replace phase_2 = 0 if phase_1 == 1 & phase_2 == 1
replace phase_3 = 0 if phase_2 == 1 & phase_3 == 1
***verify (there should be no elements in (1,1) ) 
table phase_1 phase_2
table phase_2 phase_3

**Generate useful variables
***Trial start and end years
gen year_start = year(date_start)
gen year_end = year(date_end)

***Trial duration: throw out trials with duration less than 15 days
gen duration = (date_end - date_start) / 30
label variable duration "Trial duration in months"
replace duration = . if duration <= 0
replace duration = . if duration > 1000

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
local report_directory "reports"
do "source/02_figures_tables/tables_fns.do"

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

*Yearly xtabs of funding probability by biomarker presence and phase; plot and tabulate
nih_bmkr_yr, report_directory(`report_directory')
nih_phase_yr, report_directory(`report_directory')
