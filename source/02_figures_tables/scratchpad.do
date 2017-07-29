set more off

*Percent/count of trials that are phase 2/3
cap drop phase_2_3
gen phase_2_3 = (phase == "Phase 2/Phase 3 Clinical")

preserve

keep if year_start >= 1990 & year_start <= 2016
collapse (sum) phase_2_3, by(year_start) 
graph bar phase_2_3, over(year_start)

restore

preserve

keep if year_start >= 1990 & year_start <= 2016
collapse (mean) phase_2_3, by(year_start) 
graph bar phase_2_3, over(year_start)

restore



preserve

keep if year_start >= 1990 & year_start <= 2016
collapse (mean) phase_* , by(year_start) 
graph twoway line phase_1 year_start || line phase_2 year_start || line phase_3 year_start

restore





preserve

keep if year_start >= 1990 & year_start <= 2016
collapse (sum) phase_3 phase_2_3, by(year_start) 
replace phase_3 = phase_3 + phase_2_3
graph bar phase_3, over(year_start)

restore




*Count of registered trials by phase
preserve
keep if year_start >= 1990 & year_start <= 2016
collapse (sum) phase_1 phase_2 phase_3, by(year_start) 

graph bar phase_*, 	over(year_start, label(angle(300))) ///
			stack ///
			title("Number of registered Phase I-III trials (1990-2016)") ///
			ytitle("Number of trials") ///
			ylabel(,angle(0)) ///
			legend(	lab(1 "Phase 1") ///
				lab(2 "Phase 2") ///
				lab(3 "Phase 3") ///
				rows(1) ///
				) 
			
			
restore


*Share of registered trials by phase
preserve
sample 5
keep if year_start >= 1990 & year_start <= 2016
collapse (mean) phase_1 phase_2 phase_3, by(year_start) 

graph twoway	line phase_1 year_start || ///
		line phase_2 year_start || ///
		line phase_3 year_start , ///
			title("Share of all registered trials by phase") ///
			ytitle("Share of trials") ///
			ylabel(,angle(0)) ///
			xtitle("Start year") ///
			legend(	lab(1 "Phase 1") ///
				lab(2 "Phase 2") ///
				lab(3 "Phase 3") ///
				rows(1) ///
				) 
			
restore


