**HELPER FUNCTIONS**
*Make phase into a factor variable with 3 levels
cap program drop prep_phases
program define prep_phases
	syntax, ///
	
	drop phase
	gen phase = .
	replace phase = 1 if phase_1 == 1
	replace phase = 2 if phase_2 == 1
	replace phase = 3 if phase_3 == 1
	
	cap label drop phase_label
		label define phase_label 1 "Phase I" 2 "Phase II" 3 "Phase III"
		label values phase phase_label
		
	gen phase_123 = (phase_1 | phase_2 | phase_3)
end




*Trial count by phase
cap program drop trial_count_by_phase
program define trial_count_by_phase
	syntax, ///
	[figure_path(string)] ///
	[title(string)] ///
	[ylabel(string)]

	preserve
	*Count number of trials by year and phase
	collapse (sum) phase_1 phase_2 phase_3, by(year_start) 
	
	*Default y-axis options
	if "`ylabel'" == "" local ylabel ylabel(,angle(0))
		
	if "`title'" == "" local title "Number of registered Phase I-III trials (1995-2016)"
	graph bar phase_*, ///	
		over(year_start, label(angle(290))) ///
		title("`title'", size(medsmall)) ///
		ytitle("Number of trials") ///
		`ylabel' ///
		legend(	lab(1 "Phase I") ///
			lab(2 "Phase II") ///
			lab(3 "Phase III") ///
			rows(1) ///
			) 
	if "`figure_path'" != "" graph export "`figure_path'", replace
			
	restore
end

*Trial growth by phase
cap program drop trial_growth_by_phase
program define trial_growth_by_phase
	syntax, ///
	[figure_path(string)] ///
	[title(string)] ///
	[ylabel(string)]


	preserve
	
	*Count number of trials by year and phase
	collapse (sum) phase_1 phase_2 phase_3, by(year_start) 
		
	*Scale each phase count so that their value in the first year == 0
	quietly summarize year_start
	local first_year `r(min)'
	
	foreach var of varlist phase_* {
	quietly summarize `var' if year_start == `first_year'
	local first_year_value `r(mean)' 
	replace `var' = 100 * (`var'/`first_year_value' - 1)
	}
	
	
	*Plot
	if "`ylabel'" == "" local ylabel ylabel(0(200)2000, angle(0))
	if "`title'" == "" local title "Growth in number of registered Phase I-III trials since 1995" 
	graph twoway ///
		line phase_1 year_start, lpattern(solid) || ///
		line phase_2 year_start, lpattern(dash) || ///
		line phase_3 year_start, lpattern(dash_dot) ///
		title("`title'", size(medium)) ///
			ytitle("Growth (%)") ///
			`ylabel' ///
			xtitle("Start year") ///
			legend(	lab(1 "Phase I") ///
				lab(2 "Phase II") ///
				lab(3 "Phase III") ///
				rows(1) ///
				) 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	restore
end


*Share of trials by biomarker use
cap program drop trial_share_by_phase
program define trial_share_by_phase	
	syntax, ///
	var(string) ///
	[figure_path(string)] ///
	[title(string)] ///
	[ylabel(string)]

	preserve
	
	prep_phases
	collapse (mean) `var', by(year_start phase) 
	replace `var' = `var' * 100
	reshape wide `var', i(year_start) j(phase)
	
	if "`ylabel'" == "" local ylabel ylabel(0(10)100,angle(0))
	
	graph twoway ///
		line `var'1 year_start, lpattern(solid) || ///
		line `var'2 year_start, lpattern(dash) || ///
		line `var'3 year_start ,lpattern(dash_dot) ///
		title("`title'", size(medium)) ///
		ytitle("Share of trials (%)", size(medsmall))  ///
		`ylabel' ///
		xtitle("Start year") ///
		legend(	lab(1 "Phase I") ///
			lab(2 "Phase II") ///
			lab(3 "Phase III") ///
			rows(1) ///
			) 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	restore

end


cap program drop trial_count_by_type
program define trial_count_by_type
	syntax, ///
	[figure_path(string)] ///
	[title(string)] ///
	[ylabel(string)]

	preserve

	collapse (sum)  *_type , by(year_start) 

	label var anthropomorphic_type	"Anthropomorphic"
	label var biochemical_type	"Biochemical"
	label var cellular_type	 	"Cellular" 
	label var genomic_type	 	"Genomic"
	label var physiological_type 	"Physiological"
	label var proteomic_type	"Proteomic"
	label var structural_type	"Structural (imaging)"

	if "`title'" == "" local title "Number of trials by biomarker types used"

	*Default y-axis options
	if "`ylabel'" == "" local ylabel ylabel(,angle(0))

	graph twoway ///
		line anthropomorphic_type 	year_start, lpattern(solid) || ///
		line biochemical_type		year_start, lpattern(dash) || ///
		line cellular_type	 	year_start, lpattern(dash_dot) || ///
		line genomic_type	 	year_start, lpattern(shortdash) || ///
		line physiological_type 	year_start, lpattern(shortdash_dot) || ///
		line proteomic_type	 	year_start, lpattern(longdash) || ///
		line structural_type	 	year_start, lpattern(longdash_dot) ///
		title("`title'", size(medsmall)) ///
		ytitle("Number of trials", size(small))  ///
		ylabel(, angle(0)) ///
		xtitle("Start year") ///
		`ylabel' ///
		legend(	rows(3) ) 
	if "`figure_path'" != "" graph export "`figure_path'", replace


	restore
end


**The following program is in development
/*

cap program drop trial_duration_by_yr_phase
program define trial_duration_by_yr_phase
	syntax, ///
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve
	
	/*
	local first_year 2000 
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
	*/
	prep_phases

	if "`title'" == "" local title "Average trial duration in months by trial phase"				

	*Plot
	quietly reg duration i.year_end##i.phase
	quietly margins, over(year_end phase) post
	marginsplot, ///
		title("`title'") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)42) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	*Table
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}

	eststo A: quietly mean duration, over(year_end)
	eststo B: quietly mean duration if phase == 1, over(year_end)
	eststo C: quietly mean duration if phase == 2, over(year_end)
	eststo D: quietly mean duration if phase == 3, over(year_end)

	label variable duration " "
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab A B C D	`write_tex', ///
			coeflabels(`labels') not nostar nonum ///
			replace ///
			label ///
			cells("_N(fmt(%8.0gc)) b(fmt(1))") ///
			title("`title'") ///
			collabels("Number of trials" "Average duration", lhs("End year")) ///
			mtitles("All trials with start and end dates" ///
				"Phase I" ///
				"Phase II" ///
				"Phase III" ///
				) 	
	restore	
end











