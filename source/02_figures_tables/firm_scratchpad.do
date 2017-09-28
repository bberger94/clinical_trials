
use "data/firm_data_09-20-17.dta", clear

* Indicate whether any sponsor/collaborator ancestor is public firm

foreach firm_role in sponsor collaborator {
	
	if "`firm_role'" == "sponsor" local abb s
	if "`firm_role'" == "collaborator" local abb c

	* Check whether trial sponsor is publicly listed
	cap drop `firm_role'_public
	egen `firm_role'_public = anymatch(`abb'_public_*), values(1)
	replace `firm_role'_public = . if `abb'_public_001 == . 
	* Then its ancestor
	cap drop `firm_role'_public_ancestor
	egen `firm_role'_public_ancestor = anymatch(`abb'_ancestor_public_*), values(1)
	replace `firm_role'_public_ancestor = . if `abb'_ancestor_public_001 == . 

	* Then take the maximum of the two 
	/* Note: Some companies are listed as public while their ancestors are private! */
	cap drop `firm_role'_public_max 
	egen `firm_role'_public_max = rowmax(`firm_role'_public*) 

	/*
	drop sponsor_public sponsor_public_ancestor
	rename sponsor_public_max sponsor_public
	*/

	
}

keep trial_id *_public* 

tempfile temp1
save "`temp1'" 

use "data/prepared_trials.dta"
merge 1:1 trial_id using "`temp1'"
keep if _merge == 3




reg g_ppm sponsor_public_max##collaborator_public_max if year_start >= 2011

margins, over( sponsor_public_max collaborator_public_max)
