* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *
* make_bmkr_sample.do
*
* Extract random sample of trial biomarker and indications
* ---------------------------------------------------------------------------- *
* ---------------------------------------------------------------------------- *

use "data/biomarker_data.dta", clear

preserve
use "data/prepared_trials.dta", clear
keep trial_id phase_* neoplasm
tempfile temp1
save "`temp1'"
restore

merge m:1 trial_id using "`temp1'"
keep if _merge == 3
drop _merge


* Keep cancer trials
keep if neoplasm == 1

* Drop if phase 1 trial
drop if phase_1 == 1

* Sample trials using utility maximizing dalmatian demand seed 
preserve
collapse (count) biomarker_id, by(trial_id)
keep trial_id
set seed 101
sample 50, count
tempfile temp1
save "`temp1'"
restore

merge m:1 trial_id using "`temp1'"
keep if _merge == 3
drop _merge

order trial_id biomarker_id  indication_id biomarker_name indication_name

!mkdir "data/samples"
save "data/samples/trial-biomarker-indications.dta", replace
export delimited using "data/samples/trial-biomarker-indications.csv", replace

