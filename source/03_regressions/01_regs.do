********************************************************************************
*  Name: regs.do		                                       
*  Authors: Stern & Berger
*
********************************************************************************


clear
set more off
global stars = " * 0.05 ** 0.01 *** 0.001"

use data/prepared_trials.dta , clear
sample 20

********************************************************************************

gen phase_23 = phase == "Phase 2/Phase 3 Clinical"
	label var phase_23 "Phase 2/3 Clinical"
	sum phase_23						/* 4.0% of all trials*/
	sum phase_23 if us_trial==1			/* 2.6% of US trials*/
gen phase_2_only = phase_2 == 1 & phase_23==0	
lab var phase_2_only "Phase 2 only"
gen phase_comb = phase == "Phase 2/Phase 3 Clinical" | phase == "Phase 1/Phase 2 Clinical"
	label var phase_comb "Combined Phase Trial (1/2 or 2/3)"
	sum phase_comb						/* 12.0 of all trails*/
	sum phase_comb if us_trial ==1		/* 11.8 of US trials*/


* Winsorize duration to kill crazy outliers 
sum duration

winsor2 duration, suffix(_w) cuts(1 99) 
	label var duration_w "Duration in months (winsorized at 1% and 99%)"
	
	
	
********************************************************************************
set more off

cap program drop ppm_regs
program define ppm_regs
	syntax, ///
	ppm(string) [quietly] [margins] [estimator(string)]

	if "`estimator'" == "" local estimator regress

	*****All years	
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1a
		
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1b
		
	
	*****Most recent years only
	local if = "if year_start >= 2005"

	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1c
		
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1d

	local fmt 4
	
	di "Dependent variable: `ppm'" 
	
	estout reg1*, ///
		cells(b(star fmt(`fmt') ) se(par fmt(`fmt') )) ///
		starlevels($stars) ///
		legend label varlabels(_cons Constant) stats(N r2 , fmt(0 3)) ///
		noomitted nobaselevels style(tex)	

end

	
********************************************************************************
cap program drop duration_regs
program define duration_regs
	syntax, ///
	[end_dates(string)] ///
	[quietly]
	
	
	preserve
	keep if year_end>2005
	
	di "`no_estimated_end_dates'"
	if "`end_dates'" != "" keep if date_end_type_ == "`end_dates'"

	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm nih_funding g_ppm 
		estimates store reg2a
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm nih_funding g_ppm if us_trial == 1 
		estimates store reg2b
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 nih_funding g_ppm if us_trial == 1 & neoplasm==1 
		estimates store reg2c
		
	replace year_start = year_start
	local roles  *_drole 	 
	`quietly' reg duration_w ///
		year_start phase_2 phase_3 nih_funding g_ppm `roles'  if us_trial == 1 & neoplasm==1 
		estimates store reg2d
		
	estout reg2*, cells(b(star fmt(3) ) se(par fmt(3) )) ///
		starlevels($stars) legend label varlabels(_cons Constant) stats(N r2, fmt(0 3)) style(tex)	
		
	restore
	
end

*************************************************************************************
******************* Make tables *****************************************************
*************************************************************************************

local output_dir "reports/regression_output_08-28-17"
!mkdir `output_dir'
log using "`output_dir'/regression_output_08-28-17.log", replace

* ------------------------------*
* Main PPM regressions (Table 7)
* ------------------------------*

ppm_regs, ppm(g_ppm) estimator(regress) quietly 
ppm_regs, ppm(r_ppm) estimator(regress) quietly

* ------------------------------*
* Duration regressions (Table 8)
* ------------------------------*

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *\
  Run programs here when final model specs are determined 
\* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 


* ------------------------------*
* Appendix reg table: (Table A11)
* ------------------------------*
ppm_regs, ppm(g_ppm) estimator(logit) margins quietly
ppm_regs, ppm(r_ppm) estimator(logit) margins quietly



log close



