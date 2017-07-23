/***********************************************************************************
File        : 3.1_Summary_Statistics_P2_Data.do
Authors     : Ben Berger
Created     : 13 Mar 2017
Description : creates summary statistics tables and figures
	      from P2 clinical trial starts from 1995 - 2015
	      writes tables to .tex; writes graphics to .eps
***********************************************************************************/

set more off 
do setup.do

use "$processed/clinical-trials.dta", clear


*label variables 
cap label drop biomarker_label
	label define biomarker_label 0 "No biomarker" 1 "Biomarker"
	label values biomarker_included biomarker_label

cap label drop nih_label
	label define nih_label 0 "No funding" 1 "NIH funding"
	label values nih_yes nih_label

*labeling at least one of years will force esttab to produce year labels without preceding variable names
*ie otherwise tables will appear "Start Year = 1995" "Start Year = 1996" ...
cap label drop year_labels
	label define year_labels 1995 1995
	label values start_year year_labels


*define helper function to export figures: same as from figures.do
cap program drop my_export
program define my_export
  // graph export to eps, then use convert to create png
  // http://teaching.sociology.ul.ie/bhalpin/wordpress/?p=135
  syntax anything

  graph export "../reports/figures/`anything'", replace
end


*****define functions for making tables & figures

*all-time xtab of funding count by biomarker presence
cap program drop nih_bmkr_count
program define nih_bmkr_count
	syntax, /// 
	
	preserve
	
	estpost tabulate biomarker_included nih_yes 

	esttab . using "../reports/tables/finished/nih-bmkr-count.tex", ///
		replace ///
		title("Number of Phase II trials receiving NIH funding by presence of biomarker") ///
		b(%8.0gc) ///
		compress ///
		unstack ///
		noobs ///
		nonotes ///
		nonumbers ///
		label ///
	
	restore

end


*all-time xtab of funding probability by biomarker presence
cap program drop nih_bmkr_pct
program define nih_bmkr_pct
	
	label variable nih_yes "Number of trials receiving funding"
	
	total nih_yes, over(biomarker_included)
	est sto A
	
	total nih_yes if us_trial == 1, over(biomarker_included)
	est sto B
	
	total nih_yes if us_trial == 0, over(biomarker_included)
	est sto C
	
	esttab A B C using  "../reports/tables/interim/nih-bmkr-pct_appended.tex", ///
		replace ///
		title("Number of Phase II trials receiving NIH funding by presence of biomarker") ///
		label mtitle("All Trials" "US Trials" "Non-US Trials") ///
		cells(b se(fmt(a1) par)) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		noobs ///
		fragment ///

	cap drop nih_times100
	gen nih_times100 = nih_yes * 100
	label variable nih_times100 "Percent of trials receiving funding"

	mean nih_times100, over(biomarker_included)
	est sto A
	
	mean nih_times100 if us_trial == 1, over(biomarker_included)
	est sto B
	
	mean nih_times100 if us_trial == 0, over(biomarker_included)
	est sto C
	
	esttab A B C using  "../reports/tables/interim/nih-bmkr-pct_appended.tex", ///
		append ///
		label ///
		mtitle("" "" "") ///
		cells(b(fmt(1)) se(fmt(2) par)) ///
		scalars(N) ///
		sfmt(%8.0gc) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		nonum ///
		fragment ///

end


*all-time xtab of funding probability by biomarker type
cap program drop nih_bmkrtype
program define nih_bmkrtype
	
	eststo clear
	
	cap drop nih_times100
	gen nih_times100 = nih_yes * 100
	label variable nih_times100 "Percent of trials receiving funding"

	quietly mean nih_times100 if genomic_biomarker_type == 1
	estimates store Genomic
	
	quietly mean nih_times100 if proteomic_biomarker_type == 1
	estimates store Proteomic
	
	quietly mean nih_times100 if biochemical_biomarker_type == 1
	estimates store Biochemical
	
	quietly mean nih_times100 if cellular_biomarker_type == 1
	estimates store Cellular
	
	quietly mean nih_times100 if physiological_biomarker_type == 1
	estimates store Physiological
	
	quietly mean nih_times100 if structural_biomarker_type == 1
	estimates store Structural

	quietly mean nih_times100 if anthropomorphic_biomarker_type == 1
	estimates store Anthropomorphic

	esttab Genomic Proteomic Biochemical Cellular Physiological Structural Anthropomorphic ///
		using "../reports/tables/finished/nih-bmkrtype.tex", ///
		replace ///
		nostar ///
		se ///
		mtitles ///
		b(1) ///
		label ///
		title("Percent of Phase II trials receiving NIH funding by biomarker type") ///

end


*all-time xtab of funding probability by biomarker role
cap program drop nih_bmkrrole
program define nih_bmkrrole
	
	eststo clear
	
	cap drop nih_times100
	gen nih_times100 = nih_yes * 100
	label variable nih_times100 "Percent receiving funding"
	
	quietly mean nih_times100 if disease_biomarke_role == 1
	estimates store disease

	quietly mean nih_times100 if therapeutic_effect_biomarke_role == 1
	estimates store therapeutic_effect
	
	quietly mean nih_times100 if toxic_effect_biomarke_role == 1
	estimates store toxic_effect
		
	quietly mean nih_times100 if not_determined_biomarke_role == 1
	estimates store not_determined
	
	
	esttab disease therapeutic_effect toxic_effect not_determined ///
		using "../reports/tables/finished/nih-bmkrrole.tex", ///
		replace ///
		nostar ///
		se ///
		mtitle("Disease" "Therapeutic effect" "Toxic effect" "Not determined") ///
		b(1) ///
		label ///
		title("Percent of Phase II trials receiving NIH funding by biomarker role") ///

end


*make yearly xtab of funding probability by biomarker presence; plot and tabulate
cap program drop nih_bmkr_yr
program define nih_bmkr_yr
	syntax, ///
	trial_set(string)
	
	eststo clear
	preserve
	
	assert "`trial_set'" == "us" | "`trial_set'" == "all"
		
	if  "`trial_set'" == "all"{
	local samplestring "All trials"
	}
	
	if "`trial_set'" == "us"{
	keep if us_trial == 1
	local samplestring "US trials"
	}	
	
	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_yes * 100 
	
	*make plot
	reg nih_times100 i.start_year##i.biomarker_included 
	margins, over(start_year biomarker_included) post
	
	/* 
	*use this marginsplot command if we want confidence intervals
	marginsplot, ///
		title("Percent of Phase II trials receiving NIH funding: `samplestring'") ///
		xlabel(1995(5)2015) ///
		ylabel(0(5)25) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(-7 25)) ///
	*/
	
	marginsplot, ///
		title("Percent of Phase II trials receiving NIH funding: `samplestring'") ///
		xlabel(1995(5)2015) ///
		ylabel(0(5)20) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(0 20)) ///
		noci ///
	
	my_export nih-bmkr-yr-`trial_set'.eps

	*make table	
	gen biomarker_excluded = 1 - biomarker_included
	reg nih_times100 i.start_year##i.biomarker_included
	margins, over(start_year) subpop(biomarker_excluded) post
	eststo No_biomarker
	
	reg nih_times100 i.start_year##i.biomarker_included 
	margins, over(start_year) subpop(biomarker_included) post
	eststo Biomarker


	esttab using "../reports/tables/finished/nih-bmkr-yr-`trial_set'.tex", ///
			replace ///
			title("Percent of Phase II trials receiving NIH funding by presence of biomarker: `samplestring'") ///
			mtitle("No biomarker" "Biomarker") ///
			not ///
			nostar ///
			b(1) ///
			nogaps ///
			noobs ///
			label ///
	
	restore

end


*table of trial count by phase 
cap program drop trial_phase
program define trial_phase
	
	estpost tabulate phase

	esttab . using "../reports/tables/finished/trial-phase.tex", 						///
		replace 					///
		cells("b(fmt(%8.0gc)) pct(fmt(1))") 				///
		title("Trials by Phase") 			///
		collabels("Trial count" "Percent of all Phase II") ///
		nomtitle					///
		compress 					///
		noobs						///
		nonum						///
		
end


*table of variable means over nih funding status
cap program drop nih_means
program define nih_means
	
	eststo clear
	
	quietly mean trial_duration_in_months, over(nih_yes)
	est sto duration
	
	quietly mean us_trial, over(nih_yes)
	est sto us
	
	quietly mean enrollment_count, over(nih_yes)
	est sto enroll
	
	esttab duration us enroll, ///
		cells("b _N")  ///
	
	/*transpose the table according to notes here: 
	http://fmwww.bc.edu/repec/bocode/e/estout/advanced.html */
	matrix C = r(coefs)
	
	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	
	local i 0
	
	foreach name of local rnames {
	local ++i
	local j 0
	capture matrix drop b
	capture matrix drop N
	foreach model of local models {
           local ++j
           matrix tmp = C[`i', 2*`j'-1]
           if tmp[1,1]<. {
              matrix colnames tmp = `model'
              matrix b = nullmat(b), tmp
              matrix tmp[1,1] = C[`i', 2*`j']
              matrix N = nullmat(N), tmp
          }
	}
	ereturn post b
	quietly estadd matrix N
	eststo `name'
	}

	esttab using "../reports/tables/finished/nih-means.tex",  ///
		replace ///
		cells("b(fmt(a2)) N(fmt(%8.0gc))") ///
		title("Selected statistics by NIH funding status") ///
		mtitles("No NIH funding" "NIH funding") ///
		varlabels(duration "Duration" us "US Trial" enroll "Subjects enrolled") ///
		collabels("Mean" "\# of nonmissing observations") ///
		noobs nonum
	
end


*table of average trial duration over years
cap program drop trial_duration
program define trial_duration
		
	*make plot
	reg trial_duration i.start_year
	margins, over(start_year) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(1995(5)2015) ///
		ylabel(0(10)100) ///
		xtitle("Trial start year") ///
		ytitle("Trial duration in months") ///
	
	my_export trial-duration.eps

	esttab . using "../reports/tables/finished/trial-duration.tex", ///
		replace ///
		cells("b(fmt(1)) _N(fmt(%8.0gc))") ///
		title("Average trial duration in months") ///
		not nostar nonum ///
		label ///
		collabels("Duration" "\# of trials with nonmissing duration", lhs("Year"))
				
end


cap program drop main
program define main 

	nih_bmkr_count
	nih_bmkr_pct
	nih_bmkrrole
	nih_bmkrtype
	nih_means
	trial_phase
	trial_duration
	nih_bmkr_yr, trial_set(all)
	nih_bmkr_yr, trial_set(us)

end


****call functions
main



