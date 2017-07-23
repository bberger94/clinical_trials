/***********************************************************************************
File        : 2_Create_Dummy_Var_P2_Data.do
Authors     : Alice Ndikumana
Created     : 28 Jun 2016
Modified    : 02 Sept 2016
Description : Creates dummy variables for Phase2/2a/2b, US Trial, Single Primary Intervention
biomarker included, each biomarker role and type. Create variable for start year
***********************************************************************************/

do setup.do

use "$interim/P2_Clinical_Trial_Starts_1995-2015_clean.dta"


*create dummy variable to indicate if the Trial occurs in the US (includes trials that occur in the US and other countries
gen us_trial=(strpos(country, "US")|strpos(country, "USA")|strpos(country, "U.S.")|strpos(country, "United States"))
label var us_trial "US Trial"

*Note for Ariel - I used the following to double check the "false" data points in the US Trial variable
*list country if us_trial==0

*create dummy variable for phase2, phase2a and phase2b from the phase variable
gen phase2 = (phase=="Phase 2 Clinical")
label var phase2 "Phase 2"

gen phase2a = (phase=="Phase 2a Clinical")
label var phase2a "Phase 2a"

gen phase2b = (phase=="Phase 2b Clinical")
label var phase2b "Phase 2b"

*create dummy varialbe for clinical trials with only one primary intervention
gen single_primary_intervention = !(strpos(primary_int,";")|strpos(primary_int,","))
label var single_p "Single Primary Intervention"

*create variable for start year
gen start_year = year(start_date)
label var start_year "Start Year"

*create a dummy variable indicating if a biomarker is list
gen biomarker_included = (biomarker!="")
label var biomarker_included "Biomarker Included"

*create dummy variable for each biomarker role
replace biomarker_role = lower(biomarker_role)
foreach i in "disease" "therapeutic effect" "toxic effect" "not determined" {

    local var = strtoname("`i'")+"_biomarke_role"
    gen `var' = (strpos(biomarker_role, "`i'") != 0)

    local varlabel = proper("`i'")+" Biomarker Role"
    label var `var' "`varlabel'"
    di "`varlabel'"
}

*create a dummy variable for each biomarker type
replace biomarker_type = lower(biomarker_type)
foreach i in "genomic" "proteomic" "biochemical" "cellular" "physiological" "structural" "anthropomorphic" {

    local var = strtoname("`i'")+"_biomarker_type"
    gen `var' = (strpos(biomarker_type, "`i'") !=0)

    local varlabel = proper("`i'")+" Biomarker Type"
    label var `var' "`varlabel'"
    di "`varlabel'"
}

generate row_id = _n

*this makes the file size as small as possible, useful with large dataset
compress

*save new formatted dataset
save "$interim/P2_Clinical_Trial_Starts_1995-2015_allvars.dta", replace
