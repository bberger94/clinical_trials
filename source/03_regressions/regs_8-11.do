********************************************************************************
*  Chandra-Garthwaite-Stern		                                               *
*  ...with a lot of help from Berger                                           *  
*                                                                              *
*  This do file runs a set of basic regressions to predict precision trials    * 
*                                                                              *
*  HISTORY                                                                     *
*  - AUG 2017 : Regression analyssis                                           *
*                                                                              *
********************************************************************************

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
gen phase_comb = phase == "Phase 2/Phase 3 Clinical" | phase == "Phase 1/Phase 2 Clinical"
	label var phase_comb "Combined Phase Trial (1/2 or 2/3)"
	sum phase_comb						/* 12.0 of all trails*/
	sum phase_comb if us_trial ==1		/* 11.8 of US trials*/

sum duration

winsor2 duration, suffix(_w) cuts(1 99) /* winsorize duration variable to kill crazy outliers */
	label var duration_w "Duration in months (winsorized at 1% and 99%)"
********************************************************************************
set more off
local if = "if year_start >= 2005"

*For the below: need to...
	*A) un-comment the "margins" rows so that tables print marginal effects from logit regs 
	*B) see if we can cluster at ICD-9 chapter (most aggregate) level...can add this to a 4th column
	*C) then re-do for r_ppm

*all years
local x year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type
logit g_ppm `x'
	*margins, dydx(`x') post
	*margins
	estimates store regs_1a
logit g_ppm year_start phase_2_only phase_23 phase_3 us_trial neoplasm nih_funding genomic_type
	*margins
	estimates store regs_1b
logit g_ppm year_start phase_2 phase_3 us_trial##neoplasm nih_funding genomic_type
	*margins
	estimates store regs_1c
logit g_ppm year_start phase_2 phase_3 us_trial##neoplasm nih_funding genomic_type, ///
	vce(cluster most_common_chapter)
	*margins
	estimates store regs_1c

	
*Most recent years only
logit g_ppm year_start phase_2 phase_3 us_trial neoplasm nih_funding genomic_type `if'
	*margins
	estimates store regs_1d
logit g_ppm year_start phase_2_only phase_23 phase_3 us_trial neoplasm nih_funding genomic_type `if'
	*margins
	estimates store regs_1e
logit g_ppm year_start phase_2_only phase_3 us_trial##neoplasm nih_funding genomic_type `if'
	*margins
	estimates store regs_1f
*Add one more column, exact same as above regression but with SEs clustered at ICD-9 Chapter level
	

estout regs_1a regs_1b regs_1c regs_1d regs_1e regs_1f, cells(b(star fmt(3) ) se(par fmt(3) )) ///
	starlevels($stars) legend label varlabels(_cons Constant) stats(N r2) style(tex)	

	
********************************************************************************

*ideally, we would have "preserve" here but the dataset is so damn big that I'm leaving it out for now...
keep if year_end>2005

reg duration_w i.year_start phase_2 phase_3 us_trial neoplasm nih_funding g_ppm
	estimates store regs_2a
reg duration_w i.year_start phase_2 phase_3 neoplasm nih_funding g_ppm if us_trial == 1
	estimates store regs_2b
reg duration_w i.year_start phase_2 phase_3 nih_funding g_ppm if us_trial == 1 & neoplasm==1
	estimates store regs_2c
	
*include all detailed roles in local macro below...
local roles = "diagnosis_drole diff_diagnosis_drole predict_resistance_drole predict_efficacy_drole predict_toxicity_drole screening_drole selection_for_therapy_drole"
reg duration_w year_start phase_2 phase_3 nih_funding g_ppm `roles'	if us_trial == 1 & neoplasm==1 
	estimates store regs_2d
	*include detailed uses...need to pull all, I think...

estout regs_2a regs_2b regs_2c regs_2d, cells(b(star fmt(3) ) se(par fmt(3) )) ///
	starlevels($stars) legend label varlabels(_cons Constant) stats(N r2) style(tex)	

