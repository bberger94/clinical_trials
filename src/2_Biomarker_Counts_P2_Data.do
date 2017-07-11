/***********************************************************************************
File        : 2_Biomarker_Counts_P2_Data.do
Authors     : Alice Ndikumana
Created     : 1 Jul 2016
Modified    : 2 Sept 2016
Description : Count the number of unique biomarkers, biomarker type and biomarker roles in the data
***********************************************************************************/

do setup.do

foreach b in biomarker_type biomarker_role biomarker {
    * load updated biomarker data
        use "$processed/clinical-trials.dta", clear

        * first discard all other variables
        keep `b' cortellis

        * split multiple observations listed and reshape to generate a list of conditions in the dataset
        split `b', p(";")
        drop `b'
        reshape long `b', i(cort) j(counter)

        * keep only unique observations
        drop if `b'==""
        replace `b'=lower(`b')
        replace `b' = trim(`b')
        duplicates drop

        * tabulate observations
        tab `b'

        * display count of unique biomarkers
        count
}
