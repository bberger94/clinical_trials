
**All-time xtab of funding count by biomarker presence
cap program drop nih_bmkr_count
program define nih_bmkr_count
	syntax, /// 
	[report_directory(string)]

	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/nih-bmkr-count.tex"	
	preserve
	
	estpost tabulate biomarker_status nih_funding

	esttab . `outfile', ///
		replace ///
		title("Number of trials receiving NIH funding by presence of biomarker") ///
		b(%8.0gc) ///
		compress ///
		unstack ///
		noobs ///
		nonotes ///
		nonumbers ///
		label ///
	
	restore

end




**All-time xtab of funding probability by biomarker presence
cap program drop nih_bmkr_us_pct
program define nih_bmkr_us_pct
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/interim/nih-bmkr-us-pct_appended.tex"
	preserve 
	
	label variable nih_funding "Number of trials receiving funding"
	
	quietly total nih_funding, over(biomarker_status)
	est sto A
	quietly total nih_funding if us_trial == 1, over(biomarker_status)
	est sto B
	quietly total nih_funding if us_trial == 0, over(biomarker_status)
	est sto C
	
	esttab A B C `outfile', ///
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

	quietly mean nih_times100, over(biomarker_status)
	est sto A
	quietly mean nih_times100 if us_trial == 1, over(biomarker_status)
	est sto B
	quietly mean nih_times100 if us_trial == 0, over(biomarker_status)
	est sto C
	
	esttab A B C `outfile', ///
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
cap program drop nih_bmkr_phase_pct
program define nih_bmkr_phase_pct
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/interim/nih-bmkr-phase-pct_appended.tex"
	eststo clear
	preserve 
	
	label variable nih_funding "Number of trials receiving funding"
	
	eststo A: quietly total nih_funding, over(biomarker_status)
	eststo B: quietly total nih_funding if phase_1 == 1, over(biomarker_status)
	eststo C: quietly total nih_funding if phase_2 == 1, over(biomarker_status)
	eststo D: quietly total nih_funding if phase_3 == 1, over(biomarker_status)
		
	esttab A B C D `outfile', ///
		replace ///
		title("Number of trials receiving NIH funding by presence of biomarker") ///
		label mtitle("All Trials" "Phase I" "Phase II" "Phase III") ///
		cells(b se(fmt(a1) par)) ///
		collabels(none) ///
		rename(_subpop_1 "No biomarker") ///
		noobs ///
		fragment ///

	cap drop nih_times100
	gen nih_times100 = nih_funding * 100
	label variable nih_times100 "Percent of trials receiving funding"

	eststo A: quietly mean nih_times100, over(biomarker_status)
	
	eststo B: quietly mean nih_times100 if phase_1 == 1, over(biomarker_status)
	
	eststo C: quietly mean nih_times100 if phase_2 == 1, over(biomarker_status)
	
	eststo D: quietly mean nih_times100 if phase_3 == 1, over(biomarker_status)
	
	
	esttab A B C D `outfile', ///
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
		
		
		
	restore
end





*all-time xtab of funding probability by biomarker role
cap program drop nih_bmkrrole
program define nih_bmkrrole
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/nih-bmkrrole.tex"
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
		
	esttab all no_biomarker biomarker disease therapeutic_effect toxic_effect not_determined ///
		`outfile', ///
		replace ///
		nostar se b(1) ///
		mtitle("All Trials" "No Biomarker" "Biomarker present" "Disease" "Therapeutic effect" "Toxic effect" "Role not determined") ///
		compress ///
		label ///
		title("Percent of trials receiving NIH funding by biomarker role") ///
		addnote("Trials may employ multiple biomarkers with one or more biomarker roles.") ///
		
	restore
end



*table of trial count by phase 
cap program drop trial_phase
program define trial_phase
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/trial-phase.tex"
	quietly estpost tabulate phase

	esttab . `outfile',					///
		replace 					///
		cells("b(fmt(%8.0gc)) pct(fmt(1))") 		///
		title("Trials by Phase") 			///
		collabels("Trial count" "Percent of all Phase I-III") ///
		nomtitle					///
		compress 					///
		noobs						///
		nonum						///
		
end


**Table of variable means over nih funding status
cap program drop nih_means
program define nih_means
	syntax, ///
	[report_directory(string)]

	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/nih-means.tex"
	eststo clear
	
	local vars 	us_trial ///
			biomarker_status ///
			patient_count_enrollment ///
			duration		
		
	eststo all: quietly mean `vars'
	eststo nih_yes: quietly mean `vars' if nih_funding == 0
	eststo nih_no: quietly mean `vars' if nih_funding == 1

	esttab all nih_yes nih_no `outfile', ///
		replace ///
		unstack ///
		cells("b(fmt(a2)) se(fmt(a2))") ///
		title("Selected averages by NIH funding status") ///
		mtitles("All trials" "No NIH funding" "NIH funding") ///
		varlabels(	us_trial "US trial" biomarker_status "Biomarker used" ///
				patient_count_enrollment "Subjects enrolled" duration "Duration") ///
		collabels("Average" "Standard error") ///
		noobs nonum compress
	
end


**Table of average trial duration over years
cap program drop trial_duration
program define trial_duration
	syntax, ///
	[report_directory(string)]
		
	preserve
	
	local first_year 2000
	local last_year 2016
	keep if year_end >= `first_year' & year_end <= `last_year'
	//keep if date_end_type == "actual"
	keep if us_trial == 1
	
	drop phase
	gen phase = .
	replace phase = 1 if phase_1 == 1
	replace phase = 2 if phase_2 == 1
	replace phase = 3 if phase_3 == 1
	
	*make plots
	reg duration i.year_end##i.phase
	margins, over(year_end phase) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)54) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") ///
		noci
	if "`report_directory'" != "" {
	graph export "`report_directory'/figures/trial-duration-by-phase.eps", replace
	}
	
	reg duration i.year_end##i.biomarker_status
	margins, over(year_end biomarker_status) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)54) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") ///
		noci
	if "`report_directory'" != "" {
	graph export "`report_directory'/figures/trial-duration-by-bmkr.eps", replace
	}
	
*Table of duration on biomarker status by end year
	keep if year_end >= `first_year' & year_end <= `last_year'

	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}

	eststo A: quietly mean duration, over(year_end)
	eststo B: quietly mean duration if biomarker_status == 0, over(year_end)
	eststo C: quietly mean duration if biomarker_status == 1, over(year_end)

	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/trial-duration-by-bmkr.tex"
	esttab A B C, coeflabels(`labels') not nostar nonum ///
			replace ///
			cells("b(fmt(1)) _N(fmt(%8.0gc))") ///
			title("Average trial duration in months") ///
			collabels("Duration" "Number of trials", lhs("End year")) ///
			mtitles("All trials with start and end dates" ///
				"No biomarkers" ///
				"Biomarker(s) used" ///
				) 	

*Duration by year plot & table	
	reg duration i.year_end
	margins, over(year_end) post
	marginsplot, ///
		title("Average trial duration in months") ///
		xlabel(2000(5)2015) ///
		ylabel(18(6)54) ///
		xtitle("Trial end year") ///
		ytitle("Trial duration in months") 
	if "`report_directory'" != "" {
	graph export "`report_directory'/figures/trial-duration.eps", replace
	}
	
	*make table
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/trial-duration.tex"
	esttab . `outfile', ///
		replace ///
		cells("b(fmt(1)) _N(fmt(%8.0gc))") ///
		title("Average trial duration in months") ///
		not nostar nonum ///
		label ///
		collabels("Duration (months)" "\# of trials with nonmissing duration", lhs("End year"))
	
	restore		
end





*make yearly xtab of funding probability by biomarker presence; plot and tabulate
cap program drop nih_bmkr_yr
program define nih_bmkr_yr
	syntax, ///
	[report_directory(string)]
	
	foreach subset in "all" "us" {
	preserve
	
	*define subset of trials
	keep if year_start >= 1995 & year_start <= 2016
	
	if  "`subset'" == "all"	local samplestring "All trials"	
	
	else if "`subset'" == "us"{
	keep if us_trial == 1
	local samplestring "US trials"
	}	
	
	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	*make plot
	reg nih_times100 i.year_start##i.biomarker_status
	margins, over(year_start biomarker_status) post
	marginsplot, ///
		title("Percent of trials receiving NIH funding: `samplestring'") ///
		xlabel(1995(5)2015) ///
		ylabel(0(5)20) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(0 20)) ///
		noci ///

	if "`report_directory'" != "" {
	graph export "`report_directory'/figures/nih-bmkr-yr-`subset'.eps", replace
	}
	
	*make table
	eststo clear	
	
	quietly reg nih_times100 i.year_start
	quietly margins, over(year_start) post
	eststo all
	
	gen biomarker_excluded = 1 - biomarker_status
	quietly reg nih_times100 i.year_start##i.biomarker_status
	quietly margins, over(year_start) subpop(biomarker_excluded) post
	eststo no_biomarker
	
	quietly reg nih_times100 i.year_start##i.biomarker_status
	quietly margins, over(year_start) subpop(biomarker_status) post
	eststo biomarker

	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/nih-bmkr-yr-`subset'.tex"
	esttab all no_biomarker biomarker `outfile', ///
			replace ///
			title("Percent of trials receiving NIH funding by presence of biomarker: `samplestring'") ///
			mtitle("All trials" "No biomarker" "Biomarker") ///
			not ///
			nostar ///
			b(1) ///
			nogaps ///
			noobs ///
			label ///
	
	restore
	}
	
end



cap program drop nih_phase_yr
program define nih_phase_yr
	syntax, ///
	[report_directory(string)]
	
	preserve
	*define subset of trials
	local first_year 1995
	local last_year 2016
	keep if year_start >= `first_year' & year_start <= `last_year'
	
	*scale response variable to percentage scale
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100 
	
	*make categorical variable for phase
	drop phase
	gen phase = .
	replace phase = 1 if phase_1 == 1
	replace phase = 2 if phase_2 == 1
	replace phase = 3 if phase_3 == 1
	gen phase_123 = phase_1 | phase_2 | phase_3
	
	*make plot
	quietly reg nih_times100 i.year_start##i.phase
	quietly margins, over(year_start phase) post
	marginsplot, ///
		title("Percent of trials receiving NIH funding by trial phase") ///
		xlabel(1995(5)2015) ///
		ylabel(0(1)10) ///
		xtitle("Trial Start Year") ///
		ytitle("Percent of trials funded by the NIH") ///
		yscale(r(0 10)) ///
		noci ///

	if "`report_directory'" != "" {
	graph export "`report_directory'/figures/nih-phase-yr.eps", replace
	}
	
	*make table
	eststo clear	
	eststo A: quietly mean nih_times100 if phase_123 == 1 , over(year_start)
	eststo B: quietly mean nih_times100 if phase == 1 , over(year_start)
	eststo C: quietly mean nih_times100 if phase == 2 , over(year_start)
	eststo D: quietly mean nih_times100 if phase == 3 , over(year_start)
	eststo E: quietly total phase_123 , over(year_start)
	
	keep if year_end >= `first_year' & year_end <= `last_year'

	foreach year of numlist `first_year'/`last_year' {
	local i = `year' - `first_year' + 1
	local labels `labels' _subpop_`i' `year'
	}

	if "`report_directory'" != "" local outfile "using `report_directory'/tables/finished/nih-phase-yr.tex"
	esttab A B C D E `outfile', ///
			replace ///
			title("Percent of trials receiving NIH funding by phase") ///
			mtitle("Phase I-III" "Phase I" "Phase II" "Phase III" "Number of trials") ///
			coeflabels(`labels') ///
			collabels("", lhs("Start year")) ///
			not nostar nogaps noobs nonum ///
			compress nodepvars ///
			b(1) ///
	
	restore
	
end






