set more off

***************************************************
**** Load Data ************************************
***************************************************
local trial_data "data/clinical_trials_07-29-17.dta"
local trial_data_sample "data/ct_sample.dta"

**Write a sample to disk for testing code
/*
use `trial_data', clear
set seed 101
sample 10 
save `trial_data_sample', replace
*/

use `trial_data_sample', clear
//use `trial_data', clear


***************************************************
**** Clean data ***********************************
***************************************************

***Trial start and end years
gen year_start = year(date_start)
gen year_end = year(date_end)

**Select universe of trials
*keep if year_start >= 1990 & year_start <= 2016
keep if phase_1 == 1 | phase_2 == 1 | phase_3 == 1

**Recode trials with multiple phase designations as the earlier phase
***(ie. Phase 2/Phase 3 -> Phase 2
replace phase_2 = 0 if phase_1 == 1 & phase_2 == 1
replace phase_3 = 0 if phase_2 == 1 & phase_3 == 1
***verify (there should be no elements in (1,1) ) 
table phase_1 phase_2
table phase_2 phase_3

***************************************************
**** Generate useful variables ********************
***************************************************

***Trial duration in months
gen duration = (date_end - date_start) / 30
label variable duration "Trial duration in months"
****Recode as missing if duration is less 1 day or greater than 1000 months
replace duration = . if duration <= 0
replace duration = . if duration > 1000

**Neoplasm indication dummy
gen neoplasm = 0
foreach var of varlist icd9_chapter_* {
	replace neoplasm = 1 if `var' == "Neoplasms"
}


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


***************************************************
**** Generate figures and tables ******************
***************************************************

**Define directory for reports
set more off
local report_dir "reports/report_7-25-17"
local table_dir "`report_dir'/tables"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

**Load table functions
do "source/02_figures_tables/tables_fns_edit7-25.do"


nih_funding_by_bmkr_us


**Generate tables and figures
nih_funding_by_bmkr, 		table_path("`table_dir'/01-nih_funding_by_bmkr.tex")
nih_funding_by_bmkr_us, 	table_path("`table_dir'/fragment-02-nih_funding_by_bmkr_us.tex")
nih_funding_by_bmkr_phase, 	table_path("`table_dir'/fragment-03-nih_funding_by_bmkr_phase.tex")
nih_funding_by_bmkrrole, 	table_path("`table_dir'/04-nih_funding_by_bmkrrole.tex")
trial_phase, 			table_path("`table_dir'/05-trial_phase.tex")
trial_duration_by_yr, 		table_path("`table_dir'/06-trial_duration_by_yr.tex") ///
					figure_path("`figure_dir'/06-trial_duration_by_yr.eps")
nih_funding_means, 		table_path("`table_dir'/07-nih_funding_means.tex")
trial_duration_by_yr_phase, 	figure_path("`figure_dir'/05-trial_duration_by_yr_phase.eps")
trial_duration_by_yr_bmkr, 	table_path("`table_dir'/11-trial_duration_by_yr_bmkr.tex") ///
					figure_path("`figure_dir'/04-trial_duration_by_yr_bmkr.eps")
nih_funding_by_yr_bmkr, 	table_path("`table_dir'/08-nih_funding_by_yr_bmkr.tex") ///
					figure_path("`figure_dir'/01-nih_funding_by_yr_bmkr.eps")

preserve
keep if us_trial == 1					
nih_funding_by_yr_bmkr, 	table_path("`table_dir'/09-nih_funding_by_yr_bmkr_us.tex") ///
					figure_path("`figure_dir'/02-nih_funding_by_yr_bmkr_us.eps")					
restore
					
nih_funding_by_yr_phase, 	table_path("`table_dir'/10-nih_funding_by_yr_phase.tex") ///
					figure_path("`figure_dir'/03-nih_funding_by_yr_phase.eps")





