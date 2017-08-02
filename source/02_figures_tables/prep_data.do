***********************************************************
** Author: Ben Berger; Date Created: 7-30-17              
** This script:
** 1. Loads the cortellis clinical trials data 
** 2. Makes some small modifications to phase variables    
** 3. Defines the universe of trials we are interested in
** 4. Generates useful variables for analysis
***********************************************************

set more off
***************************************************
**** Load Data ************************************
***************************************************
global trial_data "data/clinical_trials_08-01-17.dta"
global trial_data_sample "data/ct_sample.dta"
global biomarker_data "data/biomarker_data_08-01-17.dta"

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
count if phase_1 & phase_2
assert `r(N)' == 0
count if phase_2 & phase_3
assert `r(N)' == 0


**Load biomarker data
preserve
use $biomarker_data, clear

/*Identify trial-biomarker-indication combinations with
proteomic or genomic biomarkers */
cap drop *_type

rename disease_marker disease_marker_role
rename therapeutic_marker therapeutic_marker_role
rename toxic_marker toxic_marker_role
rename not_determined_marker not_determined_marker_role

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

cap drop ppm
gen ppm = .
replace ppm = 	(proteomic_type == 1 | genomic_type == 1) & ///
		disease_marker_role == 1 & ///
		(selection_for_therapy == 1 | ///
		 predicting_treatment_efficacy == 1 | ///
		 predicting_treatment_toxicity == 1 | ///
		 disease_profiling == 1 | ///
		 differential_diagnosis == 1)
	
drop biomarker_role
local collapse_vars ppm *_type  *_role ///
		selection_for_therapy ///
		predicting_treatment_efficacy ///
		predicting_treatment_toxicity ///
		disease_profiling ///
		differential_diagnosis
		
collapse (max) 	`collapse_vars' , ///
		by(trial_id)
		
gen biomarker_status = 1

!mkdir "data/temp" 
save "data/temp/ppm_temp.dta", replace

*Merge biomarker data
restore
merge 1:1 trial_id using "data/temp/ppm_temp.dta"
drop if _merge == 2
drop _merge


foreach var of varlist `collapse_vars' biomarker_status  {
	replace `var' = 0 if biomarker_status == .
}

***************************************************
**** Generate useful variables ********************
***************************************************

***Trial start and end years
gen year_start = year(date_start)
gen year_end = year(date_end)
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

**Label variable values 
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

**Label variables
label variable biomarker_status "Uses biomarker" 
label variable phase_1 "Phase 1 Clinical"
label variable phase_2 "Phase 2 Clinical"
label variable phase_3 "Phase 3 Clinical"
label variable nih_funding "Received NIH funding" 
label variable us_trial "Trial site in US" 
label variable neoplasm "Drug indication for neoplasm"
label variable therapeutic_marker_role "Biomarker role: therapeutic effect"
label variable disease_marker_role "Biomarker role: disease"
label variable toxic_marker_role "Biomarker role: toxic effect"
label variable not_determined_marker_role "Biomarker role: not determined"
label variable ppm "Precision medicine"



***************************************************
**** Select universe of trials ********************
***************************************************
keep if year_start >= 1995 & year_start <= 2016
keep if phase_1 == 1 | phase_2 == 1 | phase_3 == 1

save "data/processed.dta", replace

