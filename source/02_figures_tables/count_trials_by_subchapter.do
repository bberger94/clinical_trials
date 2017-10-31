/*----------------------------------------------------------------------------*\


	Author: Ben Berger; Date Created: 10-31-17     
	This script counts # of trials for each ICD-9 3-digit code
	
		
\*----------------------------------------------------------------------------*/

set more off
use "data/processed/prepared_trials.dta", clear

/*----------------------------------------------------------------------------*\
	DEFINE OUTPUT DIRECTORY
\*----------------------------------------------------------------------------*/

**Define directory for current summary data report
set more off
local report_dir "reports/report_10-20-17"
local table_dir "`report_dir'/tables"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

/*----------------------------------------------------------------------------*\
	PROCESS DATA
\*----------------------------------------------------------------------------*/
* Reshape long 
keep trial_id  icd9_0* icd9_sub_chapter*
reshape long icd9 icd9_sub_chapter, i(trial_id) j(j) string
drop if icd9 == ""

* Keep only one row per ICD-9 sub-chapter within trial
/* e.g.
 if a trial has sub-chapter "Malignant neoplasm of lip, oral cavity, and pharynx"
 repeated twice, we will count only one instance				*/

bysort trial_id icd9_sub_chapter : gen i = _n /* returns 2+ if more than one indication per ICD-9 */
keep if i == 1

* Generate neoplasm ICD-9 indicator
destring icd9 , generate(icd9_num) force
gen neoplasm = icd9_num >= 140 & icd9_num <= 239
drop icd9_num

* Get the smallest ICD-9 to sort subchapters
sort icd9 trial_id
bysort icd9_sub_chapter : gen smallest_icd9 = icd9[1]
sort icd9

* Collapse by subchapter
collapse (count) n_trial = i ///
	 (min)   neoplasm , ///
	 by(icd9_sub_chapter smallest_icd9)

sort smallest_icd9
drop smallest_icd9

* Label variables
cap label drop neoplasm_label
label define neoplasm_label 0 "No" 1 "Yes"
lab values neoplasm neoplasm_label

lab var icd9_sub_chapter "ICD-9 Sub-chapter"
lab var n_trial 	 "Number of trials"
lab var neoplasm 	 "Neoplasm sub-chapter"

/*----------------------------------------------------------------------------*\
	Save data
\*----------------------------------------------------------------------------*/
save "data/summary_data/subchapter_trial_counts.dta" , replace
outsheet using "data/summary_data/subchapter_trial_counts.csv", comma replace


