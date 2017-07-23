/***********************************************************************************
File        : 2_Map_Condition_to_ICD9Code_P2_Data.do
Authors     : Alice Ndikumana
Created     : 1 Jul 2016
Modified    : 15 Aug 2016
Description : Maps cortellis conditions in P2 Cortellis Clinical Trials data to
ICD-9 codes
***********************************************************************************/

do setup.do

* First, create a crosswalk between Cortellis indications and ICD-9 codes, using files from Josh Krieger

* import the indication key, which pairs Cortellis drug indications with an ID
import delimited "$raw/CortellisDrugsIndicationsKey.txt", delimiter("|") varnames(1)
save "$interim/temp.dta", replace

* The Cortellis Indications ICD9 Crosswalk matches the indication IDs to ICD9 codes
* merge the indication key with the crosswalk to match drug indications to ICD-9 codes
clear
import delimited "$raw/CortellisIndicationsICD9Crosswalk_ProfessionallyCoded_Nov2014 (1).txt", delimiter("|") varnames(1)
merge 1:1 indicationsid using "$interim/temp.dta"
!rm "$interim/temp.dta"
label var icd9 "ICD-9"
* drop uneeded variables
drop _merge indicationsid

* make all indications lowercase & rename variable as 'condition' to facilitate mapping to Cortellis conditions
replace ind = lower(ind)
rename ind condition
label var condition "Condition"

* save the crosswalk from Cortellis drug indications to ICD-9 codes
save "$interim/Cortellis_Drug_Indication_ICD9_Crosswalk.dta", replace
clear

*Next, create a list of unique conditions listed in the phase 2 Cortellis Clinical trials data

use "$processed/clinical-trials.dta"

* keep only condition variable and observation ID (row_id)
keep condition cortellis_clinical_trial_id

* split multiple conditions listed per observation and reshape to generate a list of conditions in the dataset
split condition, p(";")
drop condition
reshape long condition, i(cortellis) j(counter)

* save a cross walk of Cortellis Conditions to Row ID to facilitate mapping conditions back to Clinical trials
drop counter
drop if condition==""
replace condition=lower(condition)
replace condition = trim(condition)
label var condition "Condition"
save "$interim/P2_Clinical_Trials_Conditions_TrialID_key.dta", replace

* keep list of only unique P2 Cortellis Clinical Trials to attempt matching with the ICD9 crosswalk
drop cortellis
duplicates drop

* map P2 Cortellis conditions to ICD-9 codes using the crosswalk, drop all unmatched indications
merge 1:1 condition using "$interim/Cortellis_Drug_Indication_ICD9_Crosswalk.dta"
* drop the Drug Indications that do not match P2 Cortellis Clinical Trial conditions
drop if _merge==2

* create new variables that clarify if Cortellis Clinical Trials was mapped to an ICD9 code
gen match_to_ICD9_crosswalk=""
label var match "Match to ICD9 Crosswalk?"
replace match="condition mapped to ICD9 code" if _m==3
replace match="condition not matched to ICD9 code" if _m==1
drop _m

* save and export to excel to review remaining unmatched conditions
save "$interim/P2_Cortellis_Conditions_Partial_ICD9_Match_15Aug.dta", replace
