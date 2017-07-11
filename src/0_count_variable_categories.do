/***********************************************************************************
File        : 0_count_variable_categories.do
Authors     : Alice Ndikumana
Created     : 25 Jul 2016
Modified    : 26 Jul 2016
Description : count number of categories for following categorical variables in P2 data:
patient_segment, primary_interventions, sponsor_only, collaborator_only, action, active_controls, country, category, design,
age_race_healthy_volunteers, endpoint_types, endpoint, adverse_events

***********************************************************************************/

do setup.do

use "$processed/clinical-trials.dta"

* create a local macro of categorical variables of interest
local cvs primary_interventions patient_segment endpoints

* begin for loop through all variables of interest
foreach var of varlist `cvs' {

    * split observations of
    keep `var' row_id
    split `var', p(";")
    drop `var'
    reshape long `var', i(row_id) j(counter)

    * cleanse list of biomarkers and save crosswalk
    keep `var'
    drop if `var'==""
    replace `var'=lower(`var')
    replace `var' = trim(`var')
    duplicates drop

    * count of unique observations
    count
    codebook `var'
    clear
    use "$processed/clinical-trials.dta"

    * save list of unique observations of variable
    * save P2_Clinical_Trial_'catvar'_All.dta, replace

}
