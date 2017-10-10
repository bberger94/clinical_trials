********************************************************************************
** Author: Ben Berger; Date Created: 10-10-17
** This script:
** 1. Loads (cleaned) burden of disease data
** 2. Aggregates years of life lost by ICD-9
** 3. Merges into trial data by ICD-9
** 4. Averages years of life lost for each trial over indications
** 5. Compares years of life lost between PPM and non-PPM trials
********************************************************************************

set more off

************************************
* Prepare burden of disease data
************************************
import excel "data/fwcancertables/Cancer_all_ages_US_cleaned-BB.xlsx", sheet("with icd9") first clear
keep icd9 cancer_type total
rename total yll
* Total years of life lost by ICD-9 
collapse (sum) yll, by(icd9)
drop if icd9 == "" | icd9 == "?"

tempfile burden_data 
save "`burden_data'"

************************************
* Load trial data
************************************
use "data/prepared_trials.dta" , clear

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
collapse (mean) mean_yll = yll , by(trial_id) 

* What percentage of trials have at least one ICD9 matching burden of disease data?
count if mean_yll != .
di `r(N)' / _N * 100 " percent of trials with matching ICD-9"

************************************************************************
* Compare YLL across PPM and non-PPM trials
************************************************************************

* Merge rest of trial data back in 
merge 1:1 trial_id using "data/prepared_trials.dta"

* Perform comparison of means t-test
cap label drop ppm_label
label define ppm_label  0 "non-PPM" 1 "PPM"
label values g_ppm ppm_label
ttest mean_yll, by(g_ppm) unequal
