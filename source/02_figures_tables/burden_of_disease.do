********************************************************************************
** Author: Ben Berger; Date Created: 10-10-17
** This script:
** 1. Loads (cleaned) burden of disease data
** 2. Aggregates years of life lost by ICD-9
** 3. Merges into trial data by ICD-9
** 4. Averages years of life lost for each trial over indications
** 5. Compares years of life lost between LPM and non-LPM trials
********************************************************************************


set more off

************************************
* Prepare burden of disease data
************************************
foreach US_or_global in "US" "global" {

import excel "data/misc/burden_of_disease/Cancer_all_ages_`US_or_global'_cleaned-BB.xlsx", ///
	sheet("with icd9") first clear

keep icd9 cancer_type total
rename total yll

* Sum years of life lost by ICD-9 
collapse (sum) yll_`US_or_global' = yll , by(icd9)
drop if icd9 == "" | icd9 == "?"

tempfile burden_data_`US_or_global'
save "`burden_data_`US_or_global''"

}

* Merge US and global burden together
use "`burden_data_US'", clear
merge 1:1 icd9 using "`burden_data_global'"
drop _merge
tempfile burden_data
save "`burden_data'"

************************************
* Load trial data
************************************
use "data/processed/prepared_trials.dta" , clear

* Reshape indications long by trial id for merging in burden of disease
keep trial_id icd9_0*
reshape long icd9 , i(trial_id) j(j) string

* Merge burden data by ICD-9
merge m:1 icd9 using "`burden_data'" 

count if _merge == 3
local merge_count = `r(N)'
drop if _merge == 2

* What percentage of ICD-9s did we match?
count if icd9 != ""
di `merge_count' / `r(N)' * 100 " percent of ICD-9 matched"

/*************************************************************************
Take the average year lives lost (YLL) for each trial
denominator is # of indications with nonmissing YLL
e.g. a trial with 3 indications, 2 of which have YLL data, 
will have average YLL of: (YLL1 + YLL2) / 2								
*************************************************************************/
collapse (mean) mean_yll_US = yll_US ///
		mean_yll_global = yll_global , by(trial_id) 

* What percentage of trials have at least one ICD9 matching burden of disease data?
count if mean_yll_global != .
di `r(N)' / _N * 100 " percent of trials with matching ICD-9"

************************************************************************
* Compare YLL across LPM and non-LPM trials
************************************************************************

* Merge rest of trial data back in 
merge 1:1 trial_id using "data/processed/prepared_trials.dta"

* Perform comparison of means t-test

* Scale YLL by 1 million
foreach var of varlist mean_yll_* {
replace `var' = `var' / 1000000
}
* Label YLL
cap label drop lpm_label
label define lpm_label  0 "non-LPM" 1 "LPM"
label values g_lpm lpm_label
* Mean of US YLL
estpost ttest mean_yll_US, by(g_lpm) unequal
matrix est_US = (e(mu_1) \ e(mu_2) \ -e(t)) 
* Mean of Global YLL
estpost ttest mean_yll_global, by(g_lpm) unequal
matrix est_global = (e(mu_1) \ e(mu_2) \ -e(t)) 
* Combine into one matrix
matrix est_ttest = (est_US , est_global)
matrix rownames est_ttest = "non-LPM" "LPM" "t-statistic"
matrix colnames est_ttest = "US" "Global"

* Output to Tex
matlist est_ttest
local output_directory "reports/report_10-20-17/tables/burden_of_disease"
!mkdir "`output_directory'"
outtable using "`output_directory'/ttest", ///
	mat(est_ttest) replace f(%9.2f) caption("Burden of disease: Millions of years of life lost")











