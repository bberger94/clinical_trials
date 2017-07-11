/***********************************************************************************
File        : 2_Identify_NIH_Grants_P2_data.do
Authors     : Alice Ndikumana
Created     : 14 Jul 2016
Modified    : 26 Jul 2016
Description : Identifies NIH grant numbers from the indicator variable in the
Cortellis Clinical Trials dataset
***********************************************************************************/

do setup.do

use "$interim/P2_Clinical_Trial_Starts_1995-2015_allvars.dta"

* First, create a cross walk of "identifiers" to Row ID to facilitate mapping identifiers back to Clinical trials
keep iden cort
split iden , p(";")
drop identifiers
reshape long identifiers, i(cort) j(counter)
drop counter
drop if identifiers==""
replace identifiers = trim(identifiers)
duplicates drop
label var iden "Identifiers"
save "$interim/P2_Clinical_Trial_Identifiers_TrialID_Key.dta", replace

* Drop the row ID and keep only a unique list of identifiers
drop cort
duplicates drop

* NIH grant numbers are formatted as 1-R01-MH99999-01A1, with the R01 indicating the activity code
* create dummy variable that indicates if the indicator may be an NIH grant number, based on the presence of an activity code in the identifier
* list of activity codes below, details available at: http://grants.nih.gov/grants/funding/funding_program.htm
* note: some of the indicators that happen to include the activity codes may not be NIH grant numbers, but the indicators will still help narrow the search
gen nih=""
label var nih "NIH Grant Number?"
replace nih="1-Yes" if substr(identifiers,1,3)=="P01"| substr(identifiers,1,3)=="DP2"| substr(identifiers,1,3)=="R01"| substr(identifiers,1,3)=="R23"| substr(identifiers,1,3)=="R29"| substr(identifiers,1,3)=="R37"| substr(identifiers,1,3)=="R03"| substr(identifiers,1,3)=="R15"| substr(identifiers,1,3)=="R21"| substr(identifiers,1,3)=="R41"| substr(identifiers,1,3)=="R42"| substr(identifiers,1,3)=="R43"| substr(identifiers,1,3)=="R44"| substr(identifiers,1,3)=="U43"| substr(identifiers,1,3)=="U44"| substr(identifiers,1,3)=="M01"| substr(identifiers,1,3)=="P20"| substr(identifiers,1,3)=="P30"| substr(identifiers,1,3)=="P50"| substr(identifiers,1,3)=="U54"| substr(identifiers,1,3)=="K01"| substr(identifiers,1,3)=="K02"| substr(identifiers,1,3)=="K07"| substr(identifiers,1,3)=="K08"| substr(identifiers,1,3)=="K23"| substr(identifiers,1,3)=="K24"| substr(identifiers,1,3)=="F31"| substr(identifiers,1,3)=="F32"| substr(identifiers,1,3)=="FI2"
replace nih="2-Maybe" if nih!="1-Yes" & (strpos(identifiers,"P01")|   strpos(identifiers,"DP2")|   strpos(identifiers,"R01")|   strpos(identifiers,"R23")|   strpos(identifiers,"R29")|   strpos(identifiers,"R37")|   strpos(identifiers,"R03")|   strpos(identifiers,"R15")|   strpos(identifiers,"R21")|   strpos(identifiers,"R41")|   strpos(identifiers,"R42")|   strpos(identifiers,"R43")|   strpos(identifiers,"R44")|   strpos(identifiers,"U43")|   strpos(identifiers,"U44")|   strpos(identifiers,"M01")|   strpos(identifiers,"P20")|   strpos(identifiers,"P30")|   strpos(identifiers,"P50")|   strpos(identifiers,"U54")|   strpos(identifiers,"K01")|   strpos(identifiers,"K02")|   strpos(identifiers,"K07")|   strpos(identifiers,"K08")|   strpos(identifiers,"K23")|   strpos(identifiers,"K24")|   strpos(identifiers,"F31")|   strpos(identifiers,"F32")|   strpos(identifiers,"FI2"))
replace nih="0-No" if nih==""

* Add similar flag for possible NCI trial IDs. National Cancer Institute clinical trials IDs begin with "NCI-", e.g. NCI-2012-02986
* replace nih="2-Yes" if substr(identifiers,1,3)=="NCI"
* replace nih="1-Maybe" if strpos(identifiers,"NCI")

* save a list of all identifiers with their Yes/No/Maybe flag for possible NIH grants
save "$interim/P2_Clinical_Trial_Indentifiers_All_NIH_Flag_15Aug", replace

* save a list of only probable NIH grants with the associated Row ID to facilitate matching NIH grants to clinical trials
drop if nih=="0-No"
merge 1:m identifiers using "$interim/P2_Clinical_Trial_Identifiers_TrialID_Key.dta"
drop if _m==2
drop _m
save "$interim/P2_Clinical_Trial_Identifiers_Probable_NIH", replace
rename identifier nih_identifier

generate nih_yes = nih == "1-Yes"
keep if nih_yes
keep cortellis_clinical_trial_id nih_yes
duplicates drop cortellis_clinical_trial_id, force

merge 1:1 cortellis_clinical_trial_id using "$interim/P2_Clinical_Trial_Starts_1995-2015_allvars.dta"
replace nih_yes = 0 if missing(nih_yes)

save "$processed/clinical-trials.dta", replace
