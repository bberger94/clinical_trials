**HELPER FUNCTIONS**
cap program drop prep_phases
program define prep_phases
	syntax, ///
	
	drop phase
	gen phase = .
	replace phase = 1 if phase_1 == 1
	replace phase = 2 if phase_2 == 1
	replace phase = 3 if phase_3 == 1
	gen phase_123 = (phase_1 | phase_2 | phase_3)
end

**MAIN FUNCTIONS**
**All-time xtab of funding count by biomarker presence
cap program drop nih_funding_by_bmkr
program define nih_funding_by_bmkr
	syntax, ///
	[table_path(string)]
		
	preserve
	
	quietly estpost tabulate biomarker_status nih_funding

	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab . `write_tex', ///
		replace ///
		title("Number of trials receiving NIH funding by presence of biomarker") ///
		b(%8.0gc) ///
		compress ///
		unstack ///
		noobs nonotes nonum ///
		label ///
					
	restore	
end


**All-time xtab of funding probability by biomarker presence and location (trial in US)
cap program drop nih_funding_by_bmkr_us
program define nih_funding_by_bmkr_us
	syntax, ///
	[table_path(string)]
		
	preserve
	eststo clear
		
	label variable nih_funding "Number of trials receiving funding"
	
	eststo A: quietly total nih_funding, over(biomarker_status)
	eststo B: quietly total nih_funding if us_trial == 1, over(biomarker_status)
	eststo C: quietly total nih_funding if us_trial == 0, over(biomarker_status)
		
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab A B C  `write_tex', ///
		replace ///
		title("Number of trials receiving NIH funding by presence of biomarker") ///
		label mtitle("All Trials" "US Trials" "Non-US Trials") ///
		cells(b se(fmt(a1) par)) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		noobs ///
		fragment ///
	
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100
	label variable nih_times100 "Percent of trials receiving funding"

	eststo A: quietly mean nih_times100, over(biomarker_status)
	eststo B: quietly mean nih_times100 if us_trial == 1, over(biomarker_status)
	eststo C: quietly mean nih_times100 if us_trial == 0, over(biomarker_status)

	esttab A B C `write_tex', ///
		append ///
		label ///
		mtitle("" "" "") ///
		cells(b(fmt(1)) se(fmt(2) par)) ///
		scalars(N) ///
		sfmt(%8.0gc) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		nonum ///
		fragment 		
					
	restore	
end


**All-time xtab of funding probability by biomarker presence and phase
cap program drop nih_funding_by_bmkr_phase
program define nih_funding_by_bmkr_phase
	syntax, ///
	[table_path(string)]
		
	preserve
	eststo clear
		
	label variable nih_funding "Number of trials receiving funding"
	
	
	eststo A: quietly total nih_funding, over(biomarker_status)
	eststo B: quietly total nih_funding if phase_1 == 1, over(biomarker_status)
	eststo C: quietly total nih_funding if phase_2 == 1, over(biomarker_status)
	eststo D: quietly total nih_funding if phase_3 == 1, over(biomarker_status)
		
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab A B C D `write_tex', ///
		replace ///
		title("Number of trials receiving NIH funding by presence of biomarker") ///
		label mtitle("All Trials" "Phase I" "Phase II" "Phase III") ///
		cells(b se(fmt(a1) par)) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		noobs nonum ///
		fragment ///
 					
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100
	label variable nih_times100 "Percent of trials receiving funding"

	eststo A: quietly mean nih_times100, over(biomarker_status)
	eststo B: quietly mean nih_times100 if phase_1 == 1, over(biomarker_status)
	eststo C: quietly mean nih_times100 if phase_2 == 1, over(biomarker_status)
	eststo D: quietly mean nih_times100 if phase_3 == 1, over(biomarker_status)
					
	esttab A B C D `write_tex', ///
		append ///
		label ///
		mtitle("" "" "" "") ///
		cells(b(fmt(1)) se(fmt(2) par)) ///
		scalars(N) ///
		sfmt(%8.0gc) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		nonum ///
		fragment ///
					
	restore	
end


cap program drop nih_funding_by_bmkrrole
program define nih_funding_by_bmkrrole
	syntax, ///
	[table_path(string)]
		
	preserve
	eststo clear
		
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100
	label variable nih_times100 "Percent receiving funding"
	
	quietly mean nih_times100
	estimates store all
	
	quietly mean nih_times100 if biomarker_status == 0
	estimates store no_biomarker
	
	quietly mean nih_times100 if biomarker_status == 1
	estimates store biomarker
	
	quietly mean nih_times100 if disease_marker_role == 1
	estimates store disease

	quietly mean nih_times100 if therapeutic_marker_role == 1
	estimates store therapeutic_effect
	
	quietly mean nih_times100 if toxic_marker_role == 1
	estimates store toxic_effect
		
	quietly mean nih_times100 if not_determined_marker_role == 1
	estimates store not_determined
		
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab all no_biomarker biomarker disease therapeutic_effect toxic_effect not_determined ///
		`write_tex', ///
		replace ///
		nostar se b(1) ///
		mtitle(	"All Trials" "No Biomarker" "Biomarker present" "Disease" ///
			"Therapeutic effect" "Toxic effect" "Role not determined") ///
		compress ///
		label ///
		title("Percent of trials receiving NIH funding by biomarker role") ///
		addnote("Trials may employ multiple biomarkers with one or more biomarker roles.") 
					
	restore	
end

*Table of trial count by phase 
cap program drop trial_phase
program define trial_phase
	syntax, ///
	[table_path(string)]
		
	preserve
	
	quietly estpost tabulate phase

	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab . `write_tex', ///
		replace 					///
		cells("b(fmt(%8.0gc)) pct(fmt(1))") 		///
		title("Trials by Phase") 			///
		collabels("Trial count" "Percent of all Phase I-III") ///
		nomtitle					///
		compress 					///
		noobs						///
		nonum						///
					
	restore	
end


**Table of variable means over nih funding status
cap program drop nih_funding_means
program define nih_funding_means
	syntax, ///
	[table_path(string)]
		
	preserve
	
	local vars 	us_trial ///
			biomarker_status ///
			patient_count_enrollment ///
			duration		

	eststo all: quietly mean `vars'
	eststo nih_yes: quietly mean `vars' if nih_funding == 0
	eststo nih_no: quietly mean `vars' if nih_funding == 1

	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab all nih_yes nih_no `write_tex', ///
		replace ///
		unstack ///
		cells("b(fmt(a2)) se(fmt(a2))") ///
		title("Selected averages by NIH funding status") ///
		mtitles("All trials" "No NIH funding" "NIH funding") ///
		varlabels(	us_trial "US trial" biomarker_status "Biomarker used" ///
				patient_count_enrollment "Subjects enrolled" duration "Duration") ///
		collabels("Average" "Standard error") ///
		noobs compress
					
	restore	
end


**Table of average trial duration over years
cap program drop trial_duration_by_yr
program define trial_duration_by_yr
	syntax, ///
	[figure_path(string)] [table_path(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
	prep_phases

	*Plot
	quietly reg duration i.year_end
	quietly margins, over(year_end) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)54) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") 
	if "`figure_path'" != "" graph export "`figure_path'", replace
	
	*Table
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab . `write_tex', ///
		replace ///
		cells("b(fmt(1)) _N(fmt(%8.0gc))") ///
		title("Average trial duration in months") ///
		not nostar nonum ///
		label ///
		collabels("Duration (months)" "\# of trials with nonmissing duration", lhs("End year"))
			
	restore	
end


**Table of average trial duration over years by phase
cap program drop trial_duration_by_yr_phase
program define trial_duration_by_yr_phase
	syntax, ///
	[figure_path(string)] [table_path(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
	prep_phases

	*Plot
	quietly reg duration i.year_end##i.phase
	quietly margins, over(year_end phase) post
	marginsplot, ///
		title("Average trial duration in months") ///
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
			title("Average trial duration in months") ///
			collabels("Number of trials" "Average duration", lhs("End year")) ///
			mtitles("All trials with start and end dates" ///
				"Phase I" ///
				"Phase II" ///
				"Phase III" ///
				) 	
	restore	
end



**Table of average trial duration over years by biomarker status
cap program drop trial_duration_by_yr_bmkr
program define trial_duration_by_yr_bmkr
	syntax, ///
	[figure_path(string)] [table_path(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	prep_duration, first_year(`first_year') last_year(`last_year') 

	*Plot
	quietly reg duration i.year_end##i.biomarker_status
	quietly margins, over(year_end biomarker_status) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)42) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") 
	if "`figure_path'" != "" graph export "`figure_path'", replace

	*Table	
	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}

	eststo A: quietly mean duration, over(year_end)
	eststo B: quietly mean duration if biomarker_status == 0, over(year_end)
	eststo C: quietly mean duration if biomarker_status == 1, over(year_end)

	label variable duration " "
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab A B C 	`write_tex', ///
			coeflabels(`labels') not nostar nonum ///
			replace ///
			label ///
			cells(" _N(fmt(%8.0gc)) b(fmt(1))") ///
			title("Average trial duration in months") ///
			collabels("Number of trials" "Average duration", lhs("End year")) ///
			mtitles("All trials with start and end dates" ///
				"No biomarkers" ///
				"Biomarker(s) used" ///
				) 	
	restore	
end


**Table of NIH funding probability over year by biomarker status
cap program drop nih_funding_by_yr_bmkr
program define nih_funding_by_yr_bmkr
	syntax, ///
	[figure_path(string)] [table_path(string)]
		
	preserve

	*define subset of trials
	local first_year 1995
	local last_year 2016
	keep if year_start >= `first_year' & year_start <= `last_year'

	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	*Plot
	quietly reg nih_times100 i.year_start##i.biomarker_status
	quietly margins, over(year_start biomarker_status) post
	marginsplot, ///
		title("Percent of trials receiving NIH funding: `samplestring'") ///
		xlabel(1995(5)2015) ///
		ylabel(0(5)20) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(0 20)) ///
		noci
	if "`figure_path'" != "" graph export "`figure_path'", replace

	*Table
	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}

	eststo A: quietly mean nih_times100, over(year_start)
	eststo B: quietly mean nih_times100 if biomarker_status == 0, over(year_start)
	eststo C: quietly mean nih_times100 if biomarker_status == 1, over(year_start)

	label variable nih_times100 " "
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab A B C 	`write_tex', ///
			coeflabels(`labels') not nostar nonum ///
			replace ///
			label ///
			cells("_N(fmt(%8.0gc)) b(fmt(1))") ///
			title("Percent of trials receiving NIH funding by presence of biomarker") ///
			collabels("Number of trials" "Percent funded", lhs("Start year")) ///
			mtitles("All trials with start and end dates" ///
				"No biomarkers" ///
				"Biomarker(s) used" ///
				)	
	restore	
end

cap program drop nih_funding_by_yr_phase
program define nih_funding_by_yr_phase
	syntax, ///
	[figure_path(string)] [table_path(string)]
		
	preserve

	*define subset of trials
	local first_year 1995
	local last_year 2016
	keep if year_start >= `first_year' & year_start <= `last_year'
	prep_phases

	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	*Plot
	quietly reg nih_times100 i.year_start##i.phase
	quietly margins, over(year_start phase) post
	marginsplot, ///
		title("Percent of trials receiving NIH funding by trial phase") ///
		xlabel(1995(5)2015) ///
		ylabel(0(1)10) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(0 10)) ///
		noci
	if "`figure_path'" != "" graph export "`figure_path'", replace

	*Table
	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}
	
	format nih_times100 %1.0f
	format phase_123 %16H

	eststo clear	
	eststo A: quietly mean nih_times100 if phase_123 == 1 , over(year_start)
	eststo B: quietly mean nih_times100 if phase == 1 , over(year_start)
	eststo C: quietly mean nih_times100 if phase == 2 , over(year_start)
	eststo D: quietly mean nih_times100 if phase == 3 , over(year_start)

	label variable nih_times100 " "
	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab A B C D `write_tex', ///
			replace ///
			title("Percent of trials receiving NIH funding by phase") ///
			mtitle("Phase I-III" "Phase I" "Phase II" "Phase III") ///
			coeflabels(`labels') ///
			collabels("Number of trials" "Percent funded", lhs("Start year")) ///
			not nostar nogaps nonum ///
			scalars(N) ///
			compress  label ///
			cells("_N(fmt(%8.0gc)) b(fmt(1))" ) ///
			
	restore	
end





