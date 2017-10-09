/*******************************************************************************
 Author: Ben Berger; 
 This script:
	1. Loads firm data
	2. Recodes "public" firms as non-public where IPO date is after trial start
	3. Merges in the remainder of trial data for the N = ~130k subset we consider
	
*******************************************************************************/



set more off

use "data/firm_data_09-20-17.dta", clear


* Merge in start dates from trial data
preserve
use "data/clinical_trials_09-20-17", clear
keep trial_id date_start
tempfile dates
save "`dates'"
restore

merge 1:1 trial_id using "`dates'"
drop if _merge == 2
drop _merge

* Indicate whether any sponsor/collaborator ancestor is public firm
foreach firm_role in sponsor collaborator {
	
	if "`firm_role'" == "sponsor" local abb s
	if "`firm_role'" == "collaborator" local abb c
	
	* Replace public indicator if IPO at later date than trial
	foreach var of varlist `abb'_public_* {
	
	local var_index = substr("`var'", 10, 3)
	
	replace `var' = 0 if ///
		`abb'_ipo_date_`var_index' > date_start ///
		& `abb'_ipo_date_`var_index' != . ///
		& date_start != .	
	}
	
	/* Same for ancestors
	Note Ben 10-9: 
	figure out a clever way to do this all in 1 loop */
	foreach var of varlist `abb'_ancestor_public_* {
	
	local var_index = substr("`var'", 19, 3)
	
	replace `var' = 0 if ///
		`abb'_ancestor_ipo_date_`var_index' > date_start ///
		& `abb'_ancestor_ipo_date_`var_index' != . ///
		& date_start != .	
	}

	
	
	* Check whether trial sponsors or collaborators are publicly listed
	cap drop `firm_role'_public
	egen `firm_role'_public = anymatch(`abb'_public_*), values(1)
	
	cap drop public_missing 
	egen public_missing = anymatch(`abb'_public_*), values(0 1)
	replace public_missing = 1 - public_missing
	replace `firm_role'_public = . if public_missing == 1	
	
	
	* Then do the same for their ancestors
	cap drop `firm_role'_public_ancestor
	egen `firm_role'_public_ancestor = anymatch(`abb'_ancestor_public_*), values(1)
	
	cap drop public_missing 
	egen public_missing = anymatch(`abb'_ancestor_public_*), values(0 1)
	replace public_missing = 1 - public_missing
	replace `firm_role'_public_ancestor = . if public_missing == 1
	
	*  Then take the maximum of the two
	cap drop `firm_role'_public_max 
	egen `firm_role'_public_max = rowmax(`firm_role'_public*) 

	/*This corresponds to at least one public company OR company w/ public ancestor
	Note: Some companies are listed as public while their ancestors are private! */
	
}

keep trial_id sponsor_public* collaborator_public_*

tempfile temp1
save "`temp1'" 

use "data/prepared_trials.dta"
merge 1:1 trial_id using "`temp1'"
keep if _merge == 3



