/***********************************************************************************
File        : 1_Merge_P2_Data.do
Authors     : Alice Ndikumana
Created     : 20 Jun 2016
Modified    : 9 Sept 2016
Description : Merges multiple excel exports from Cortellis into a single stata dataset
***********************************************************************************/

do setup.do

* Stata-fies 9 excel files from 1995-2015
forvalues i=0/8 {
    import excel using "$raw/Clinical_Trials_Results(`i').xls", sheet("Results") clear allstring firstrow case(lower)
    save "$raw/Clinical_Trials_Results(`i').dta", replace
}

* Merges excel files into a single STATA file
u "$raw/Clinical_Trials_Results(0).dta", clear
forvalues i=1/8 {
    append using "$raw/Clinical_Trials_Results(`i').dta",
}

forvalues i=0/8 {
    !rm "$raw/Clinical_Trials_Results(`i').dta"
}

* Compress and save new data set
compress
save "$interim/P2_Clinical_Trial_Starts_1995-2015_merged.dta", replace
