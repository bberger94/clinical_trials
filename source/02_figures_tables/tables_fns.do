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



**MAIN TABLE FUNCTIONS**
**Variable means
cap program drop summary_stats
program define summary_stats
	syntax, ///
	[table_path(string)] ///
	[title(string)]
	
	preserve
	local vars 	biomarker_status *_lpm *_role *_type *_drole ///
			phase_1 phase_2 phase_3 ///
			neoplasm ///
			nih_funding ///
			us_trial 
			
	eststo all: quietly estpost summarize `vars'
	eststo us: quietly estpost summarize `vars' if us_trial == 1

	if "`title'" == "" local title "Summary statistics for selected variables"
	if "`table_path'" != "" local write_tex "using `table_path'"

	esttab all us `write_tex', replace ///
		cells("mean(fmt(4)) count(fmt(%9.0gc))") ///
		scalars(N) ///
		collabels("Mean" "Observations") ///
		mtitles("All trials" "US trials") ///
		nonum noobs label ///
		title("`title'") ///
		sfmt(%9.0gc)

	restore	
		
end



*Biomarker type count
cap program drop bmkrtype_count
program define bmkrtype_count
	syntax [if], ///
	[table_path(string)] ///
	[title(string)]
	
	set more off
	estimates clear
	preserve

	*Subset by `if'
	if "`if'" != "" keep `if'
	*Get overall estimates
	cap drop x
	gen x = 1 
	quietly total biomarker_status *_type
	matrix mymat = e(b)
	matrix mymat = (., mymat)

	*Get yearly estimates
	collapse (sum) biomarker_status *_type, by(year_start)
	mkmat  * , matrix(totals)
	matrix mymat =  mymat \ totals
	matrix mymat = mymat[1..., 2...]

	numlist "1995/2016"
	local rownames "Overall `r(numlist)'"

	matrix rownames mymat = `rownames'

	if "`title'" == "" local title "Number of trials employing biomarkers by type"
	if "`table_path'" != "" local write_tex "using `table_path'"

	esttab matrix(mymat, fmt(%9.2gc)) `write_tex', replace ///
		collabels("Any biomarker" "Anthropomorphic" "Biochemical" "Cellular" ///
			"Genomic" "Physiological" "Proteomic" "Structural" ) ///
		title("`title'") ///
		nomtitle compress 

	restore
end


*Biomarker detailed role count
cap program drop bmkrdrole_count
program define bmkrdrole_count
	syntax [if], ///
	[table_path(string)] ///
	[title(string)]
	
	set more off
	estimates clear
	preserve

	*Subset by `if'
	if "`if'" != "" keep `if'
	*Get overall estimates
	cap drop x
	gen x = 1 
	quietly total biomarker_status *_drole
	matrix mymat = e(b)
	matrix mymat = (., mymat)

	*Get yearly estimates
	collapse (sum) biomarker_status *_drole, by(year_start)
	mkmat  * , matrix(totals)
	matrix mymat =  mymat \ totals
	matrix mymat = mymat[1..., 2...]

	numlist "1995/2016"
	local rownames "Overall `r(numlist)'"

	matrix rownames mymat = `rownames'

	if "`title'" == "" local title "Number of trials employing biomarkers by detailed role"
	if "`table_path'" != "" local write_tex "using `table_path'"

	esttab matrix(mymat, fmt(%9.2gc)) `write_tex', replace ///
		collabels("\shortstack{Any\\biomarker}" ///
			"Diagnosis" ///
			"\shortstack{Differential\\Diagnosis}" ///
			"\shortstack{Predicting\\drug\\resistance}" ///
			"\shortstack{Predicting\\treatment\\efficacy}"  ///
			"\shortstack{Predicting\\treatment\\toxicity}" ///
			"Screening" ///
			"\shortstack{Selection\\for\\therapy}" ///
			) ///
		title("`title'") ///
		nomtitle compress 

	restore
end




cap program drop lpm_count_and_share
program define lpm_count_and_share
	syntax [if], ///
	lpm(string) ///
	[table_path(string)] ///
	[title(string)]



	preserve
	
	*Subset by `if'
	if "`if'" != "" keep `if'
	
	gen lpm_times100 = `lpm' * 100 
	cap label drop year_labels

	eststo C1: quietly total `lpm'				, over(year_start)
	eststo C2: quietly mean lpm_times100			, over(year_start)
	eststo C3: quietly total `lpm' 	if phase_1 == 1		, over(year_start)
	eststo C4: quietly mean lpm_times100 	if phase_1 == 1	, over(year_start)
	eststo C5: quietly total `lpm'	if phase_2 == 1		, over(year_start)
	eststo C6: quietly mean lpm_times100	if phase_2 == 1	, over(year_start)
	eststo C7: quietly total `lpm'	if phase_3 == 1		, over(year_start)
	eststo C8: quietly mean lpm_times100	if phase_3 == 1	, over(year_start)

	if "`table_path'" != "" local write_tex "using `table_path'"
	esttab C* `write_tex', replace ///
		title("`title'") ///
		mtitles("\shortstack{LPM Trials:\\All}" "Share of trials (\%)" ///
			"\shortstack{LPM Trials:\\Phase I}" "\shortstack{Share of\\Phase I trials (\%)}" ///
			"\shortstack{LPM Trials:\\Phase II}" "\shortstack{Share of\\Phase II trials (\%)}" ///
			"\shortstack{LPM Trials:\\Phase III}" "\shortstack{Share of\\Phase III trials (\%)}" ///
			) ///
		collabels(none) eqlabels(none) ///
		cells(b(fmt(%9.3gc))) ///
		noobs ///
		compress 
		
	restore
end




*NIH funding by Phase
cap program drop nih_funding_by_lpm_and_phase
program define nih_funding_by_lpm_and_phase
	syntax [if], ///
	[table_path(string)] ///
	[title(string)] ///

	estimates clear
	preserve
	
	*Subset by `if'
	if "`if'" != "" keep `if'
	
	cap label drop year_labels
	
	prep_phases
	
	replace nih_funding = nih_funding * 100
	
	eststo m1: quietly mean nih_funding if phase == 1, over(year_start)
	eststo m2: quietly mean nih_funding if phase == 2, over(year_start)
	eststo m3: quietly mean nih_funding if phase == 3, over(year_start)
	
	eststo m4: quietly mean nih_funding if phase == 1 & g_lpm == 1, over(year_start)
	eststo m5: quietly mean nih_funding if phase == 2 & g_lpm == 1, over(year_start)
	eststo m6: quietly mean nih_funding if phase == 3 & g_lpm == 1, over(year_start)
	
	eststo m7: quietly mean nih_funding if phase == 1 & r_lpm == 1, over(year_start)
	eststo m8: quietly mean nih_funding if phase == 2 & r_lpm == 1, over(year_start)
	eststo m9: quietly mean nih_funding if phase == 3 & r_lpm == 1, over(year_start)
	
	if "`title'" == "" local title "Share of trials receiving NIH funding by phase"
	if "`table_path'" != "" local write_tex "using `table_path'"

	esttab m* `write_tex', replace ///
		title("`title'") ///
		mtitles("\shortstack{Phase I:\\All}" ///
			"\shortstack{Phase II:\\All}" ///
			"\shortstack{Phase III:\\All}" ///
			"\shortstack{Phase I:\\Generous LPM}" ///
			"\shortstack{Phase II:\\Generous LPM}" ///
			"\shortstack{Phase III:\\Generous LPM}" ///
			"\shortstack{Phase I:\\Restrictive LPM}" ///
			"\shortstack{Phase II:\\Restrictive LPM}" ///
			"\shortstack{Phase III:\\Restrictive LPM}" ///
			) ///	
		collabels(none)  ///
		eqlabels("Share funded (\%)") ///
		cells(b(fmt(2))) ///
		compress

	restore
	
end

**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************
**********************************************************************************************

/*
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
		title("`title'", size(medium)) ///
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
	list in 1/20
	
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



/*
	preserve
	prep_phases
	list phase in 1/10
	estimates clear
	eststo p1: quietly mean nih_funding, over(phase)
	eststo p2: quietly mean nih_funding if us_trial == 1, over(phase)
	
	if "`title'" == "" local title "Share of trials receiving NIH funding by Phase"
	if "`table_path'" != "" local write_tex "using `table_path'"

	esttab p1 p2 `write_tex', ///
		title("`title'") ///
		coeflabels(_subpop_1 "Phase I" _subpop_2 "Phase II" _subpop_3 "Phase III") ///
		b(4) se nostar noobs ///
		scalar(N) sfmt(0) ///
		nonum label

	restore
*/







**All-time xtab of funding count by biomarker presence
cap program drop nih_funding_by_bmkr
program define nih_funding_by_bmkr
	syntax, ///
	[table_path(string)] ///
	[title(string)]
		
	preserve
	
	quietly estpost tabulate biomarker_status nih_funding

	if "`title'" == "" local title "Number of trials receiving NIH funding by presence of biomarker"
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab . `write_tex', ///
		replace ///
		title(`title') ///
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
	[table_path(string)] ///
	[title(string)]
		
	preserve
	eststo clear
		
	label variable nih_funding "Number of trials receiving funding"
	
	eststo A: quietly total nih_funding, over(biomarker_status)
	eststo B: quietly total nih_funding if us_trial == 1, over(biomarker_status)
	eststo C: quietly total nih_funding if us_trial == 0, over(biomarker_status)
		
	if "`title'" == "" local title "Number of trials receiving NIH funding by presence of biomarker"
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab A B C  `write_tex', ///
		replace ///
		title("`title'") ///
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
	[table_path(string)] ///
	[title(string)]
		
	preserve
	eststo clear
		
	label variable nih_funding "Number of trials receiving funding"
	
	
	eststo A: quietly total nih_funding, over(biomarker_status)
	eststo B: quietly total nih_funding if phase_1 == 1, over(biomarker_status)
	eststo C: quietly total nih_funding if phase_2 == 1, over(biomarker_status)
	eststo D: quietly total nih_funding if phase_3 == 1, over(biomarker_status)

	if "`title'" == "" local title "Number of trials receiving NIH funding by presence of biomarker"		
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab A B C D `write_tex', ///
		replace ///
		title("`title'") ///
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
	[table_path(string)] ///
	[title(string)]
		
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

	if "`title'" == "" local title "Percent of trials receiving NIH funding by biomarker role"				
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
	[table_path(string)] ///
	[title(string)]
		
	preserve
	
	quietly estpost tabulate phase

	if "`title'" == "" local title "Share of trials by Phase"				
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab . `write_tex', ///
		replace 					///
		cells("b(fmt(%8.0gc)) pct(fmt(1))") 		///
		title("`title'") 			///
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
	[table_path(string)] ///
	[title(string)]
		
	preserve
	
	local vars 	us_trial ///
			biomarker_status ///
			patient_count_enrollment ///
			duration		

	eststo all: quietly mean `vars'
	eststo nih_yes: quietly mean `vars' if nih_funding == 0
	eststo nih_no: quietly mean `vars' if nih_funding == 1

	if "`title'" == "" local title "Selected averages by NIH funding status"				
	if "`table_path'" != "" local write_tex "using `table_path'"
	
	esttab all nih_yes nih_no `write_tex', ///
		replace ///
		unstack ///
		cells("b(fmt(a2)) se(fmt(a2))") ///
		title("`title'") ///
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
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
	prep_phases
	if "`title'" == "" local title "Average trial duration in months"				

	*Plot
	quietly reg duration i.year_end
	quietly margins, over(year_end) post
	marginsplot, ///
		title("`title'") ///
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
		title("`title'") ///
		not nostar nonum ///
		label ///
		collabels("Duration (months)" "\# of trials with nonmissing duration", lhs("End year"))
			
	restore	
end


**Table of average trial duration over years by phase
cap program drop trial_duration_by_yr_phase
program define trial_duration_by_yr_phase
	syntax, ///
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
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



**Table of average trial duration over years by biomarker status
cap program drop trial_duration_by_yr_bmkr
program define trial_duration_by_yr_bmkr
	syntax, ///
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve
	
	local first_year 2000 
	local last_year 2016
	prep_duration, first_year(`first_year') last_year(`last_year') 
	
	if "`title'" == "" local title "Average trial duration in months by use of biomarker"				

	*Plot
	quietly reg duration i.year_end##i.biomarker_status
	quietly margins, over(year_end biomarker_status) post
	marginsplot, ///
		title("`title'") ///
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
			title("`title'") ///
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
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve

	*define subset of trials
	local first_year 1995
	local last_year 2016
	keep if year_start >= `first_year' & year_start <= `last_year'

	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	if "`title'" == "" local title "Share of trials receiving NIH funding by use of biomarker"				
	
	*Plot
	quietly reg nih_times100 i.year_start##i.biomarker_status
	quietly margins, over(year_start biomarker_status) post
	marginsplot, ///
		title("`title'") ///
		xlabel(1995(5)2015) ///
		ylabel(0(5)20) ///
		xtitle("Trial Start Year") ///
		ytitle("Share of trials receiving funding") ///
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
			title("`title'") ///
			collabels("Number of trials" "Percent funded", lhs("Start year")) ///
			mtitles("All trials with start and end dates" ///
				"No biomarkers" ///
				"Biomarker(s) used" ///
				)	
	restore	
end

**Table of NIH funding probability over year by phase
cap program drop nih_funding_by_yr_phase
program define nih_funding_by_yr_phase
	syntax, ///
	[figure_path(string)] [table_path(string)] ///
	[title(string)]
		
	preserve

	*define subset of trials
	local first_year 1995
	local last_year 2016
	keep if year_start >= `first_year' & year_start <= `last_year'
	prep_phases

	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	if "`title'" == "" local title "Share of trials receiving NIH funding by Phase"				
	
	*Plot
	quietly reg nih_times100 i.year_start##i.phase
	quietly margins, over(year_start phase) post
	marginsplot, ///
		title("`title'") ///
		xtitle("Trial Start Year") ///
		ytitle("Share of trials receiving funding (%)") ///
		xlabel(1995(5)2015) ///
		ylabel(0(1)10, angle(0)) ///
		legend(rows(1)) ///
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
			title("`title'") ///
			mtitle("Phase I-III" "Phase I" "Phase II" "Phase III") ///
			coeflabels(`labels') ///
			collabels("Number of trials" "Percent funded", lhs("Start year")) ///
			not nostar nogaps nonum ///
			scalars(N) ///
			compress  label ///
			cells("_N(fmt(%8.0gc)) b(fmt(1))" ) ///
			
	restore	
end





