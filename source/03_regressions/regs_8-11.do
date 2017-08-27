********************************************************************************
*  Chandra-Garthwaite-Stern		                                               *
*  ...with a lot of help from Berger                                           *  
*                                                                              *
*  This do file runs a set of basic regressions to predict precision trials    * 
*                                                                              *
*  HISTORY                                                                     *
*  - AUG 2017 : Regression analysis                                            *
*                                                                              *
********************************************************************************
local output_dir "reports/regression_output_08-13-17"
!mkdir `output_dir'
log using "`output_dir'/regression_output_08-13-17.log", replace


clear
set more off
global stars = " * 0.05 ** 0.01 *** 0.001"

use data/prepared_trials.dta , clear

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

sum duration

winsor2 duration, suffix(_w) cuts(1 99) /* winsorize duration variable to kill crazy outliers */
	label var duration_w "Duration in months (winsorized at 1% and 99%)"
	
	
	
********************************************************************************
set more off

*For the below: need to...
	*A) un-comment the "margins" rows so that tables print marginal effects from logit regs 
	*B) see if we can cluster at ICD-9 chapter (most aggregate) level...can add this to a 4th column
	*C) then re-do for r_ppm

cap program drop ppm_regs
program define ppm_regs
	syntax, ///
	ppm(string) [quietly] [margins]

	*all years
	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial neoplasm nih_funding genomic_type
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1a
		
	`quietly' logit `ppm' ///
		year_start phase_2_only phase_23 phase_3 i.us_trial neoplasm nih_funding genomic_type
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2_only phase_23 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1b
		
	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm nih_funding genomic_type
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1c
		
	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm nih_funding genomic_type, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1d

		
	*Most recent years only
	local if = "if year_start >= 2005"

	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial neoplasm nih_funding genomic_type `if'
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1e
		
	`quietly' logit `ppm' ///
		year_start phase_2_only phase_23 phase_3 i.us_trial neoplasm nih_funding genomic_type `if'
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2_only phase_23 phase_3 i.us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1f
		
	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm nih_funding genomic_type `if'
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1g
		
	`quietly' logit `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm nih_funding genomic_type `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store regs_1h

	if "`margins'" != "" local fmt 4
	else local fmt 3
	
	estout regs_1a regs_1b regs_1c regs_1d regs_1e regs_1f regs_1g regs_1h, ///
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
		estimates store regs_2a
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm nih_funding g_ppm if us_trial == 1 
		estimates store regs_2b
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 nih_funding g_ppm if us_trial == 1 & neoplasm==1 
		estimates store regs_2c
		
	replace year_start = year_start
	local roles  *_drole 	 
	`quietly' reg duration_w ///
		year_start phase_2 phase_3 nih_funding g_ppm `roles'  if us_trial == 1 & neoplasm==1 
		estimates store regs_2d
		
	estout regs_2a regs_2b regs_2c regs_2d, cells(b(star fmt(3) ) se(par fmt(3) )) ///
		starlevels($stars) legend label varlabels(_cons Constant) stats(N r2, fmt(0 3)) style(tex)	
		
	restore
	
end


*************************************************************************************
******************* Make tables *****************************************************
*************************************************************************************

*************************************************************************************
*G_PPM Logit Coefficients
*************************************************************************************
ppm_regs, ppm(g_ppm) quietly

*************************************************************************************
*G_PPM Margins
*************************************************************************************
ppm_regs, ppm(g_ppm) quietly margins

*************************************************************************************
*R_PPM Logit Coefficients
*************************************************************************************
ppm_regs, ppm(r_ppm) quietly

*************************************************************************************
*R_PPM Margins
*************************************************************************************
ppm_regs, ppm(r_ppm) quietly margins

*************************************************************************************
*Duration estimates
*************************************************************************************
duration_regs, quietly 

*************************************************************************************
*Duration estimates for trials with actual (non-estimated) end dates
*************************************************************************************
duration_regs, quietly end_dates("actual")



log close
