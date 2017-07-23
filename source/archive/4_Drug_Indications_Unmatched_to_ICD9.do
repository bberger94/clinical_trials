/***********************************************************************************
File        : 1_Drug_Indications_Unmatched_to_ICD9.do
Authors     : Alice Ndikumana
Created     : 19 Jul 2016
Modified    : 19 Jul 2016
Description : Using an excel export of all Cortellis drugs as of 7/19, 9am, identify
indications that are in Cortellis but not included in the crosswalk from Cortellis
indications to ICD-9 codes recieved from John.
***********************************************************************************/

do setup.do

* Stata-fies first 7 excel files from 2005-2015, then 2 excel files from 1995-2004
forvalues i=0/12{
clear
import delimited "$raw/Drugs_Results(`i').csv"
save $interim/Results-`i'.dta, replace
}

* Merges excel files into a single STATA file
use $interim/Results-0.dta,clear
forvalues i=1/12{
append using $interim/Results-`i'.dta
}
save $interim/Results-all.dta, replace

*generate a key for drug names, to be used to match indications back to drugs
keep drugname
gen id=_n
save "$interim/drug-id.dta", replace
clear

* keep drug indications, drop all other variables
use "$interim/Results-all.dta"
keep activein inactivein
gen id=_n

* create unduplicated list of drug indications
* combine the active and inactive indications variables
gen indication = active+";"+inactive
keep ind id
* split the indications and reshape to create a list of indications
split ind, p(";")
drop indication
reshape long indication, i(id) j(j)
* drop empty indications
drop if ind==""
replace ind = trim(ind)
replace ind = lower(ind)

* save indication key, to be used to match indications back to drugs
merge m:1 id using "$interim/drug-id.dta"
drop _merge
save $interim/drug_indication_key.dta, replace

* drop duplicate indications
keep ind
duplicates drop

* match variable name to enable comparison to drug indication key
rename ind indicationname

* Compress and save list of unique Cortellis drug indications
compress
save "$interim/List of Cortellis_Drug_Indications_as_of_19Jul2016.dta", replace


* merge with Cortellis Drug Inidcations Key from Josh Krieger
preserve
  import delimited "$raw/CortellisDrugsIndicationsKey.txt", delimiter("|") varnames(1) clear
  local path "$interim/CortellisDrugsIndicationsKey.dta"
  save `path', replace
restore
merge 1:1 indicationname using "`path'"

* create new variable that clarifies if the Cortellis indication is included in the indication key
gen match_to_icd9_key=_m
tostring match_to_icd9, replace
replace match_to_icd9="Cortellis indication, included in indication key" if _m==3
replace match_to_icd9="Cortellis indication, not included in indication key" if _m==1
replace match_to_icd9="Not a Cortellis indication, included in indication key" if _m==2

* drop _merge variable and label new variable
drop _m
label var match "Match to ICD9 Key"

* Now match list of indications with P2 conditions
* frist, rename the indicationname variable to condition and make all entries lowercase
rename indicationname condition
replace con=lower(con)

* then, merge the list of P2 conditions
* TODO: File does not exist: P2_conditions.dta

// Clean up data so it can be merged with P2_conditions
  generate test = "Cortellis indication, not included in indication key" if missing(indicationsid)
  replace test = "Not a Cortellis indication, included in indication key" if !missing(indicationsid)
  assert test == match_to_icd9_key
  drop test match_to_icd9_key

  sort condition indicationsid
  generate id = _n
  egen start = min(id), by(condition)
  replace id = id - start
  drop start
  reshape wide indicationsid, i(condition) j(id)
  assert missing(indicationsid1)
  drop indicationsid1
  rename indicationsid0 indicationsid

merge 1:1 condition using "$raw/P2_conditions.dta"

* create new variable that clarifies if the Cortellis condition is included in the list of indications
gen match_to_P2=_m
tostring match_to_P, replace
replace match_to_P="Cortellis condition with matching indication" if _m==3
replace match_to_P="Cortellis condition without matching indication" if _m==2
replace match_to_P="Indication without matching Cortellis condition" if _m==1

* drop _merge variable and label new variable
drop _m
label var match_to_P "Match to P2 Cortellis Conditions"

* now match indications back to drug names
rename con indication
merge 1:m indication using "$interim/drug_indication_key.dta"
label var id "ID"
drop _m

*rename condition variable to denote that the list includes indications and or conditions
rename indication conditions_andor_indications
label var con "Conditions and/or Indications"

save "$interim/Cortellis_Drug_IndicationsandConditions_all.dta", replace
