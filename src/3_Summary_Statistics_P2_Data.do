/***********************************************************************************
File        : 2_Summary_Statistics_P2_Data.do
Authors     : A. Ndikumana & A. D. Stern
Created     : 17 Aug 2016
Modified    : 19 Sep 2016
Description : creates summary statistics from P2 clinical trial starts from 1995 - 2015
***********************************************************************************/

do setup.do

use "$processed/clinical-trials.dta", clear


* Number of observations
count

* table of clinical trials per year
table start_year

* table of clinical trials with and without biomarkers per year
table start_year  biomarker_included

* table of frequency of each biomarker role, overall and per year

local roles disease_biomarke_role therapeutic_effect_biomarke_role toxic_effect_biomarke_role not_determined_biomarke_role
foreach r of local roles {

table `r' if biomarker_included==1

}

local roles disease_biomarke_role therapeutic_effect_biomarke_role toxic_effect_biomarke_role not_determined_biomarke_role
foreach r of local roles {

table start_year `r' if biomarker_included==1

}

* table of frequency of each biomarker type, overall and per year

local types genomic_biomarker_type proteomic_biomarker_type biochemical_biomarker_type cellular_biomarker_type physiological_biomarker_type structural_biomarker_type anthropomorphic_biomarker_type
foreach t of local types {

table `t' if biomarker_included==1

}

local types genomic_biomarker_type proteomic_biomarker_type biochemical_biomarker_type cellular_biomarker_type physiological_biomarker_type structural_biomarker_type anthropomorphic_biomarker_type
foreach t of local types {

table start_year `t' if biomarker_included==1

}

*the way "nih_yes" is currently coded is not complete...as a stopgap:
gen nih_funded = 1 if nih_yes==1

sum us_trial
table nih_funded biomarker_included if us_trial==1

