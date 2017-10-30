/*----------------------------------------------------------------------------*\
	Author: Ben Berger; Date Created: 7-30-17              
	This script:
	1. Loads the cortellis clinical trials data 
	2. Makes some small modifications to phase variables    
	3. Merges biomarker data; defining LPM trials
	4. Merges firm data; constructing useful public firm indicators
	5. Generates useful variables for analysis
	6. Writes to file "data/prepared_trials.dta"
\*----------------------------------------------------------------------------*/

set more off
***************************************************
**** Load Data ************************************
***************************************************
global trial_data "data/processed/clinical_trials_09-20-17.dta"
global biomarker_data "data/processed/biomarker_data.dta"
global firm_data "data/processed/firm_data_09-20-17.dta"


//global trial_data_sample "data/ct_sample.dta"

**Write a sample to disk for testing code
/*
use $trial_data , clear
set seed 101
sample 10 
save $trial_data_sample , replace
*/

//use $trial_data_sample , clear
use $trial_data, clear


***************************************************
**** Clean data ***********************************
***************************************************

rename date_end_type date_end_type_
**Recode trials with multiple phase designations as the earlier phase
***(ie. Phase 2/Phase 3 -> Phase 2 )
replace phase_2 = 0 if phase_1 == 1 & phase_2 == 1
replace phase_3 = 0 if phase_2 == 1 & phase_3 == 1
**Verify the recoding was successful (both should return 0)
count if phase_1 == 1 & phase_2 == 1
assert `r(N)' == 0
count if phase_2 == 1 & phase_3 == 1
assert `r(N)' == 0


/****************************************
	PROCESS BIOMARKER DATA
*****************************************/
preserve
use $biomarker_data, clear

/*Identify trial-biomarker-indication combinations with
proteomic or genomic biomarkers */
cap drop *_type

rename disease_marker disease_marker_role
rename therapeutic_marker therapeutic_marker_role
rename toxic_marker toxic_marker_role
rename not_determined_marker not_determined_marker_role

rename screening_detail_drole screening_drole

cap gen anthropomorphic_type  = 0
cap gen biochemical_type = 0
cap gen cellular_type = 0
cap gen genomic_type = 0
cap gen physiological_type = 0
cap gen proteomic_type = 0
cap gen structural_type = 0

foreach var of varlist biomarker_type_* {
	replace anthropomorphic_type = 1 if `var' == "Anthropomorphic"
	replace biochemical_type = 1  if `var' == "Biochemical"
	replace cellular_type = 1 if `var' == "Cellular"
	replace genomic_type = 1 if `var' == "Genomic"
	replace physiological_type = 1 if `var' == "Physiological"
	replace proteomic_type = 1 if `var' == "Proteomic" 
	replace structural_type = 1 if `var' == "Structural (imaging)"
}

**Generate LPM variables
cap drop g_lpm r_lpm
gen g_lpm = .
replace g_lpm = (proteomic_type == 1 | genomic_type == 1) & ///
		disease_marker_role == 1 & ///
		(diagnosis_drole             == 1 | ///
		 diff_diagnosis_drole        == 1 | ///
		 predict_resistance_drole    == 1 | ///
		 predict_efficacy_drole      == 1 | ///
		 predict_toxicity_drole      == 1 | ///
		 screening_drole             == 1 | ///
		 selection_for_therapy_drole == 1   ///
		 )

gen r_lpm = .
replace r_lpm = (proteomic_type == 1 | genomic_type == 1) & ///
		disease_marker_role == 1 & ///
		(predict_resistance_drole    == 1 | ///
		 predict_efficacy_drole      == 1 | ///
		 predict_toxicity_drole      == 1  ///
		 )
 

/*
**Collapse LPM and roles/types
*Returns 1 for LPM if any biomarker x indications 
within a trial match LPM criteria  

*Returns 1 for a detailed role role if any biomarkers
within a trial may be used for that role with an indication in the trial

*Returns 1 for a type if any biomarkers within a trial have that type

*Returns 1 for a coarse role (ie. disease_marker_role) 
if any biomarkers within a trial have that role
*/

drop biomarker_role
local collapse_vars *_lpm  *_drole  *_type  *_role
		
collapse (max) 	`collapse_vars' , ///
		by(trial_id)
		
gen biomarker_status = 1

tempfile temp1
save "`temp1'"

*Merge biomarker data
restore
merge 1:1 trial_id using "`temp1'"
drop if _merge == 2
drop _merge


foreach var of varlist `collapse_vars' biomarker_status  {
	replace `var' = 0 if biomarker_status == .
}

/****************************************
	PROCESS FIRM DATA
*****************************************/					

* Save trial dates to merge into firm data
preserve
keep trial_id date_start
tempfile dates
save "`dates'"
* Load firm data
use $firm_data , clear
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
	figure out a clever way to do this all in one loop */
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


keep trial_id sponsor_public* collaborator_public*

tempfile temp1
save "`temp1'" 

restore
merge 1:1 trial_id using "`temp1'"
drop if _merge == 2
drop _merge

***************************************************
**** Generate useful variables ********************
***************************************************

***Trial start and end years
gen year_start = year(date_start)
gen year_end = year(date_end)
***Trial duration in months
gen duration = (date_end - date_start) / 30
lab var duration "Trial duration in months"
****Recode as missing if duration is less 1 day or greater than 1000 months
replace duration = . if duration <= 0
replace duration = . if duration > 1000

**Neoplasm indication dummy
gen neoplasm = 0
foreach var of varlist icd9_chapter_* {
	replace neoplasm = 1 if `var' == "Neoplasms"
}

/****************************************
	MOST COMMON ICD-9 CHAPTER
*****************************************/
/* NOTE: Takes 10+ minutes
Comment out below until the merge command 
to read tempfile from disk      */

/*
preserve
keep trial_id icd9_chapter_*

*Reshape long to collapse by trial id
reshape long icd9_chapter_ , i(trial_id) j(j) string

/*Get mode (most common chapter) 
* Where there is a tie, take the first */
bys trial_id: egen most_common_chapter = mode(icd9_chapter), min

*Collapse, taking the most common chapter from each trial
collapse (firstnm) most_common_chapter  , by(trial_id)
list in 1/20

save "data/cache/icd9_modal_chapter.dta", replace
restore
*/


merge 1:1 trial_id using "data/cache/icd9_modal_chapter.dta"
drop _merge


**Label variable values 
cap label drop biomarker_label
	label define biomarker_label 0 "No biomarker" 1 "Biomarker"
	label values biomarker_status biomarker_label
cap label drop nih_label
	label define nih_label 0 "No funding" 1 "NIH funding"
	label values nih_funding nih_label

**Label variables
lab var trial_id "Cortellis trial ID"

lab var date_start "Start date"
lab var date_end "End date"
lab var date_end_type "Actual or estimated trial end date" 
lab var year_start "Trial start year"
lab var year_end "Trial end year"

lab var phase 	"Trial phase (detailed)"
lab var phase_1 "Phase 1 Clinical (includes Phase 1/Phase 2 trials)"
lab var phase_2 "Phase 2 Clinical (includes Phase 2/Phase 3 trials)"
lab var phase_3 "Phase 3 Clinical"

lab var patient_count_enrollment "Trial enrollment"
lab var recruitment_status "Trial recruitment status"

lab var biomarker_status "Uses biomarker" 
lab var nih_funding "Received NIH funding" 
lab var us_trial "Trial site in US" 
lab var neoplasm "Drug indication for neoplasm"

lab var g_lpm "Generous LPM" 
lab var r_lpm "Restrictive LPM" 

*Firm public/non-public
lab var sponsor_public 			"At least one sponsor is public firm"
lab var sponsor_public_ancestor		"At least one sponsor has public ancestor"
lab var sponsor_public_max		"At least one sponsor is public or has public ancestor"

lab var collaborator_public		"At least one collaborator is public firm"
lab var collaborator_public_ancestor	"At least one collaborator has public ancestor"
lab var collaborator_public_max		"At least one collaborator is public or has public ancestor"


*Coarse Roles
lab var therapeutic_marker_role "Biomarker role: therapeutic effect"
lab var disease_marker_role "Biomarker role: disease"
lab var toxic_marker_role "Biomarker role: toxic effect"
lab var not_determined_marker_role "Biomarker role: not determined"
*Detailed Roles
lab var diagnosis_drole   	    "Biomarker role (detailed): diagnosis"
lab var diff_diagnosis_drole         "Biomarker role (detailed): differential diagnosis"
lab var predict_resistance_drole     "Biomarker role (detailed): predicting drug resistance"
lab var predict_efficacy_drole       "Biomarker role (detailed): predicting treatment efficacy"
lab var predict_toxicity_drole       "Biomarker role (detailed): predicting treatment toxicity"
lab var screening_drole              "Biomarker role (detailed): screening"
lab var selection_for_therapy_drole  "Biomarker role (detailed): selection for therapy"

lab var all_drole   	    		"Biomarker role (detailed): all"
lab var disease_profiling_drole         "Biomarker role (detailed): disease profiling"
lab var monitor_progression_drole     	"Biomarker role (detailed): monitoring disease progression"
lab var monitor_efficacy_drole       	"Biomarker role (detailed): monitoring treatment efficacy"
lab var monitor_toxicity_drole       	"Biomarker role (detailed): monitoring treatment toxicity"
lab var not_determined_drole       	"Biomarker role (detailed): not determined"
lab var prognosis_drole              	"Biomarker role (detailed): prognosis"
lab var prognosis_riskstrat_drole  	"Biomarker role (detailed): prognosis - risk stratification"
lab var risk_factor_drole              	"Biomarker role (detailed): risk factor"
lab var staging_drole              	"Biomarker role (detailed): staging"
lab var toxicity_profiling_drole        "Biomarker role (detailed): toxicity profiling"

drop all_drole

*Biomarker Types
lab var anthropomorphic_type	"Biomarker type: anthropomorphic"
lab var biochemical_type 	"Biomarker type: biochemical"
lab var cellular_type 		"Biomarker type: cellular" 
lab var genomic_type 		"Biomarker type: genomic"
lab var physiological_type 	"Biomarker type: physiological"
lab var proteomic_type 		"Biomarker type: proteomic"
lab var structural_type 	"Biomarker type: structural (imaging)"

lab var most_common_chapter 	"Most common ICD-9 chapter"

order trial_id date* year* duration ///
	phase* us_trial neoplasm nih_funding ///
	recruitment_status patient_count_enrollment ///
	sponsor* collaborator* ///
	biomarker_status *_lpm *_drole *_type *_role most_common_chapter 
	       
***************************************************
**** Select universe of trials ********************
***************************************************
keep if year_start >= 1995 & year_start <= 2016
keep if phase_1 == 1 | phase_2 == 1 | phase_3 == 1
drop phase_4

save "data/processed/prepared_trials.dta", replace

















