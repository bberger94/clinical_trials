/*----------------------------------------------------------------------------*\


	Authors: Ben Berger, Ariel Stern
	This script: Runs regressions and outputs log files

			
\*----------------------------------------------------------------------------*/



set more off
global stars = " * 0.05 ** 0.01 *** 0.001"

use "data/processed/prepared_trials.dta" , clear

/*----------------------------------------------------------------------------*\
	Display summary statistics
\*----------------------------------------------------------------------------*/

gen phase_23 = phase == "Phase 2/Phase 3 Clinical"
	label var phase_23 "Phase 2/3 Clinical"
	sum phase_23						/* 4.0% of all trials*/
	sum phase_23 if us_trial==1			/* 2.6% of US trials*/
gen phase_2_only = phase_2 == 1 & phase_23==0	
lab var phase_2_only "Phase 2 only"
gen phase_comb = phase == "Phase 2/Phase 3 Clinical" | phase == "Phase 1/Phase 2 Clinical"
	label var phase_comb "Combined Phase Trial (1/2 or 2/3)"
	sum phase_comb						/* 12.0 of all trials*/
	sum phase_comb if us_trial ==1		/* 11.8 of US trials*/

/*----------------------------------------------------------------------------*\
	Winsorize duration to kill crazy outliers 
\*----------------------------------------------------------------------------*/

sum duration

winsor2 duration, suffix(_w) cuts(1 99) 
	label var duration_w "Duration in months (winsorized at 1% and 99%)"
	
	
	
/*----------------------------------------------------------------------------*\
	Define regression programs
\*----------------------------------------------------------------------------*/

set more off

cap program drop ppm_regs
program define ppm_regs
	syntax, ///
	ppm(string) [quietly] [margins] [estimator(string)]

	if "`estimator'" == "" local estimator regress

	*****All years	
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type any_public, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type ) post
		}
		estimates store reg1a
		
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type any_public_max, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type ) post
		}
		estimates store reg1b	
	
		
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type any_public, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1c
	
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type any_public_max, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1d	
	
	*****Most recent years only
	local if = "if year_start >= 2005"

	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type any_public `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1e

	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm i.nih_funding i.genomic_type any_public_max `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1f
		
	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type any_public `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1g

	`quietly' `estimator' `ppm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm i.nih_funding i.genomic_type any_public_max `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type) post
		}
		estimates store reg1h

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
	keep if year_start >= 2000
	
	di "`end_dates'"
	if "`end_dates'" != "" keep if date_end_type_ == "`end_dates'"

	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm nih_funding any_public g_ppm , robust
		estimates store reg2a
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm nih_funding any_public_max g_ppm , robust
		estimates store reg2b
		
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm nih_funding any_public g_ppm if us_trial == 1 , robust
		estimates store reg2c
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm nih_funding any_public_max g_ppm if us_trial == 1 , robust
		estimates store reg2d
				
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 nih_funding any_public g_ppm if us_trial == 1 & neoplasm==1 , robust
		estimates store reg2e
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 nih_funding any_public_max g_ppm if us_trial == 1 & neoplasm==1 , robust
		estimates store reg2f
		
	replace year_start = year_start
	local roles  *_drole 	 
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 nih_funding any_public_max `roles'  if us_trial == 1 & neoplasm==1 , robust
		estimates store reg2d
		
	estout reg2*, cells(b(star fmt(3) ) se(par fmt(3) )) ///
		starlevels($stars) legend label varlabels(_cons Constant) stats(N r2, fmt(0 3)) style(tex)	
		
	restore
	
end

/*----------------------------------------------------------------------------*\
	Run regression programs and log output
\*----------------------------------------------------------------------------*/

local report_dir "reports/report_10-20-17"
local reg_dir "`report_dir'/regs"

foreach dir in `report_dir' `table_dir' `figure_dir' `reg_dir' {
	!mkdir "`dir'"
}

log using "`reg_dir'/regression_output_10-20-17.log", replace


cap drop any_public*
gen any_public = sponsor_public == 1 | collaborator_public == 1
gen any_public_max = sponsor_public_max == 1 | collaborator_public_max == 1
label variable any_public "Public firm (lower bound)"
label variable any_public_max "Public firm (upper bound)"

* ------------------------------*
* Main PPM regressions (Table 7)
* ------------------------------*
ppm_regs, ppm(g_ppm) estimator(regress) quietly 
ppm_regs, ppm(r_ppm) estimator(regress) quietly

* ------------------------------*
* Duration regressions (Table 8)
* ------------------------------*
duration_regs, end_dates("actual") quietlyv


/*
* ------------------------------*
* Appendix reg table: (Table A11)
* ------------------------------*
ppm_regs, ppm(g_ppm) estimator(logit) margins quietly
ppm_regs, ppm(r_ppm) estimator(logit) margins quietly
*/



log close



