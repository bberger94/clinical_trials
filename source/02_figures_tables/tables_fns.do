
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
		fragment ///
		addnotes("The number of trials in columns (2) and (3) do not add up to those in (1)" ///
			"because the location of some trials was not able to be ascertained.") ///
		
		
	restore
end



**All-time xtab of funding probability by biomarker presence and phase
cap program drop nih_bmkr_phase_pct
program define nih_bmkr_phase_pct
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/interim/nih-bmkr-phase-pct_appended.tex"
	preserve 
	
	label variable nih_funding "Number of trials receiving funding"
	
	quietly total nih_funding, over(biomarker_status)
	est sto A
	quietly total nih_funding if phase_1 == 1, over(biomarker_status)
	est sto B
	quietly total nih_funding if phase_2 == 1, over(biomarker_status)
	est sto C
	quietly total nih_funding if phase_3 == 1, over(biomarker_status)
	est sto D
	
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

	quietly mean nih_times100, over(biomarker_status)
	est sto A
	quietly mean nih_times100 if phase_1 == 1, over(biomarker_status)
	est sto B
	quietly mean nih_times100 if phase_2 == 1, over(biomarker_status)
	est sto C
	quietly mean nih_times100 if phase_3 == 1, over(biomarker_status)
	est sto D
	
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
		addnotes("The number of trials in columns (2) and (3) do not add up to those in (1)" ///
			"because the location of some trials was not able to be ascertained.") ///
		
		
	restore
end





*all-time xtab of funding probability by biomarker role
cap program drop nih_bmkrrole
program define nih_bmkrrole
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/interim/nih-bmkr-phase-pct_appended.tex"
	preserve
	eststo clear
		
	cap drop nih_times100
	gen nih_times100 = nih_funding * 100
	label variable nih_times100 "Percent receiving funding"
	
	quietly mean nih_times100
	estimates store all

	quietly mean nih_times100 if biomarker_status == 1
	estimates store biomarker
	
	quietly mean nih_times100 if disease_biomarker_role == 1
	estimates store disease

	quietly mean nih_times100 if therapeutic_biomarker_role == 1
	estimates store therapeutic_effect
	
	quietly mean nih_times100 if toxic_biomarker_role == 1
	estimates store toxic_effect
		
	quietly mean nih_times100 if not_determined_biomarker_role == 1
	estimates store not_determined
		
	esttab all biomarker disease therapeutic_effect toxic_effect not_determined ///
		`report_directory', ///
		replace ///
		nostar ///
		se ///
		mtitle("All Trials" "Biomarker Present" "Disease" "Therapeutic effect" "Toxic effect" "Not determined") ///
		b(1) ///
		label ///
		title("Percent of Phase II trials receiving NIH funding by biomarker role") ///
		addnote("Trials may have several biomarkers with several biomarker roles.") ///
		
	restore
end



*table of trial count by phase 
cap program drop trial_phase
program define trial_phase
	syntax, ///
	[report_directory(string)]
	
	if "`report_directory'" != "" local outfile "using `report_directory'/tables/interim/nih-bmkr-phase-pct_appended.tex"
	quietly estpost tabulate phase

	esttab . `outfile',					///
		replace 					///
		cells("b(fmt(%8.0gc)) pct(fmt(1))") 		///
		title("Trials by Phase") 			///
		collabels("Trial count" "Percent of all Phase II") ///
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
	
	keep if year_end >= 2000 & year_end <= 2016
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
	if "`report_directory'" != "" local outfile "using `report_directory'/figures/nih-means.tex"
	esttab . `outfile', ///
		replace ///
		cells("b(fmt(1)) _N(fmt(%8.0gc))") ///
		title("Average trial duration in months") ///
		not nostar nonum ///
		label ///
		collabels("Duration" "\# of trials with nonmissing duration", lhs("End year"))
	
	restore		
end
