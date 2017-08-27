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
	[title(string)]

	preserve
	*Count number of trials by year and phase
	collapse (sum) phase_1 phase_2 phase_3, by(year_start) 

	if "`title'" == "" local title "Number of registered Phase I-III trials (1995-2016)"
	graph bar phase_*, ///	
		over(year_start, label(angle(290))) ///
		title("`title'", size(medsmall)) ///
		ytitle("Number of trials") ///
		ylabel(,angle(0)) ///
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
	[title(string)]

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
	if "`title'" == "" local title "Growth in number of registered Phase I- III trials since 1995" 
	graph twoway ///
		line phase_1 year_start || ///
		line phase_2 year_start || ///
		line phase_3 year_start , ///
		title("`title'", size(medium)) ///
			ytitle("Growth (%)") ///
			ylabel(0(200)2000,angle(0)) ///
			xtitle("Start year") ///
			legend(	lab(1 "Phase I") ///
				lab(2 "Phase II") ///
				lab(3 "Phase III") ///
				rows(1) ///
				) 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	restore
end


/*
*Share of trials by biomarker use
cap program drop trial_share_withbmkr_by_phase
program define trial_share_withbmkr_by_phase	
	syntax, ///
	[figure_path(string)] ///
	[title(string)]

	preserve
	
	prep_phases
	collapse (mean) biomarker_status, by(year_start phase) 
	rename biomarker_status biomarker_share
	replace biomarker_share = biomarker_share * 100
	reshape wide biomarker_share, i(year_start) j(phase)
	
	if "`title'" == "" local title "Share of trials using at least one biomarker"
	graph twoway ///
		line biomarker_share1 year_start || ///
		line biomarker_share2 year_start || ///
		line biomarker_share3 year_start , ///
		title("`title'") ///
		ytitle("Share of trials (%)", size(small))  ///
		ylabel(0(10)100, angle(0)) ///
		xtitle("Start year") ///
		legend(	lab(1 "Phase I") ///
			lab(2 "Phase II") ///
			lab(3 "Phase III") ///
			rows(1) ///
			) 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	restore
end
*/


*Share of trials by biomarker use
cap program drop trial_share_by_phase
program define trial_share_by_phase	
	syntax, ///
	var(string) ///
	[figure_path(string)] ///
	[title(string)] ///
	[ylabel_min(string)] [ylabel_max(string)] [ylabel_by(string)]

	preserve
	
	prep_phases
	collapse (mean) `var', by(year_start phase) 
	replace `var' = `var' * 100
	reshape wide `var', i(year_start) j(phase)
	
	if "`ylabel_min'" == ""	local ylabel_min 0
	if "`ylabel_max'" == "" local ylabel_max 100
	if "`ylabel_by'" == ""  local ylabel_by 10
	
	graph twoway ///
		line `var'1 year_start || ///
		line `var'2 year_start || ///
		line `var'3 year_start , ///
		title("`title'", size(medium)) ///
		ytitle("Share of trials (%)", size(small))  ///
		ylabel(`ylabel_min'(`ylabel_by')`ylabel_max', angle(0)) ///
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
	[title(string)] 

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

	graph twoway ///
		line anthropomorphic_type 	year_start || ///
		line biochemical_type		year_start || ///
		line cellular_type	 	year_start || ///
		line genomic_type	 	year_start || ///
		line physiological_type 	year_start || ///
		line proteomic_type	 	year_start || ///
		line structural_type	 	year_start , ///
		title("`title'", size(medsmall)) ///
		ytitle("Number of trials", size(small))  ///
		ylabel(, angle(0)) ///
		xtitle("Start year") ///
		legend(	rows(3) ) 
	if "`figure_path'" != "" graph export "`figure_path'", replace


	restore
end
