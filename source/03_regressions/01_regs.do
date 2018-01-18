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
do "source/03_regressions/reg_fns.do"

/*----------------------------------------------------------------------------*\
	Run regression programs and log output
\*----------------------------------------------------------------------------*/

local report_dir "reports/report_01-18-18"
local reg_dir "`report_dir'/regs"

foreach dir in `report_dir' `table_dir' `figure_dir' `reg_dir' {
	!mkdir "`dir'"
}

log using "`reg_dir'/regression_output_01-18-18.log", replace

label variable any_public "Public firm (lower bound)"
label variable any_public_max "Public firm (upper bound)"

* ------------------------------*
* Main LPM regressions (Table 9)
* ------------------------------*
lpm_regs, lpm(g_lpm) estimator(regress) quietly 
lpm_regs, lpm(r_lpm) estimator(regress) quietly

* ------------------------------*
* Duration regressions (Table 10)
* ------------------------------*
duration_regs, end_dates("actual") quietly


log close

/*
* ------------------------------*
* Appendix reg table: (Table A11)
* ------------------------------*
lpm_regs, lpm(g_lpm) estimator(logit) margins quietly
lpm_regs, lpm(r_lpm) estimator(logit) margins quietly
*/


