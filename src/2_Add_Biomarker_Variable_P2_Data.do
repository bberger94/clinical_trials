/***********************************************************************************
File        : 2_Add_Biomarker_Variable_P2_Data.do
Authors     : Alice Ndikumana
Created     : 25 Jul 2016
Modified    : 25 Jul 2016
Description : Create list of unique biomarkers featured in P2 data
***********************************************************************************/

do setup.do

use "$processed/clinical-trials.dta"

* Create a cross walk of "biomarkers" to Row ID to facilitate mapping identifiers back to Clinical trials
* split multiple biomarkers listed into single observations and reshape to generate a list of biomarkers in the dataset
keep biomarker row_id
split biomarker, p(";")
drop biomarker
reshape long biomarker, i(row_id) j(counter)

* cleanse list of biomarkers and save crosswalk
drop counter
drop if biomarker==""
replace biomarker=lower(biomarker)
replace biomarker = trim(biomarker)
duplicates drop
label var bio "Biomarkers"
save "$interim/P2_Clinical_Trial_Biomarkers_RowID_Key.dta", replace

* Drop row_id and drop duplicates to get a unique list of biomarkers in the P2 data set
drop row_id
duplicates drop

* save list of unique biomarkers
save "$interim/P2_Clinical_Trial_Biomarkers_All.dta", replace
