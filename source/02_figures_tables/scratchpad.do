set scheme s1mono

cap program drop duration_by_yr_phase
program define duration_by_yr_phase
	syntax 	[if], ///
	[figure_path(string)] [table_path(string)] ///
	[title(string)] [subtitle(string)] ///
	[ylabel(string)] ///
	[first_year_end(string)] [last_year_end(string)] ///
	[statistic(string)] ///
	[keepActualDates] ///
	[reg] ///
	

	if "`first_year_end'" == "" local first_year_end 2005
	if "`last_year_end'" == "" local last_year_end 2016
		
	preserve
	
	*Recode phase for convenience
	prep_phases
	
	*Keep according to user inputted if exp
	if "`if'" != "" keep `if'
	*Select subset of trials by end year and duration 
	keep if year_end >= `first_year_end' & year_end <= `last_year_end'
	replace duration = duration / 12
	lab var duration "Duration in years"
	keep if duration <= 10	
		
	if "`keepActualDates'" != "" keep if date_end_type_ == "actual"
	
	*Estimate linear trend 
	if "`reg'" == "reg" reg duration year_end 
	
	*Collapse by year
	if "`statistic'" == "" local statistic mean
	collapse (`statistic') duration , by(year_end phase)
	
	*Reshape wide
	reshape wide duration, i(year_end) j(phase) 
	
	if "`title'" == "" local title "Average trial duration in years by trial phase"				
	
	*Plot
	graph twoway ///
		line duration1 year_end, lpat(solid) 	|| ///
		line duration2 year_end, lpat(dash) 	|| ///
		line duration3 year_end, lpat(dash_dot)    ///
		title(`title') subtitle(`subtitle') ///
		ytitle("Duration in years") ///
		ylabel(`ylabel', angle(0)) ///
		xlabel(`first_year_end'(1)`last_year_end', angle(300)) ///
		legend(lab(1 "Phase I") lab(2 "Phase II") lab(3 "Phase III") rows(1))
	
	
	
	
	if "`figure_path'" != "" graph export "`figure_path'", replace

	restore	
end

*Run programs

**Define directory for reports
set more off
local report_dir "reports/trial_duration_08-10-17"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

**Load table programs
do "source/02_figures_tables/tables_fns.do"


duration_by_yr_phase, ///
	subtitle("All trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration.eps")

duration_by_yr_phase if neoplasm == 1, ///
	subtitle("Cancer trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_cancer.eps")
	
duration_by_yr_phase if neoplasm == 1 & g_ppm == 0, ///
	subtitle("Non-PPM (generous) cancer trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_cancer_non-gppm.eps")
	
duration_by_yr_phase if neoplasm == 1 & r_ppm == 0, ///
	subtitle("Non-PPM (restrictive) cancer trials") ylabel(0(1)6)  ///
	figure_path("`figure_dir'/duration_cancer_non-rppm.eps")	
	
duration_by_yr_phase if neoplasm == 1 & g_ppm == 1, ///
	subtitle("PPM (generous) cancer trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_cancer_gppm.eps")	
	
duration_by_yr_phase if neoplasm == 1 & r_ppm == 1, ///
	subtitle("PPM (restrictive) cancer trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_cancer_rppm.eps")	
	
duration_by_yr_phase if neoplasm == 1 & genomic_type == 1, ///
	subtitle("Cancer trials using genomic biomarkers") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_cancer_genomic.eps")	
	
duration_by_yr_phase if us_trial == 1, ///
	subtitle("US trials") ylabel(0(1)6) ///
	figure_path("`figure_dir'/duration_us.eps")	

duration_by_yr_phase if us_trial == 0, ///
	subtitle("Non-US trials") ylabel(0(1)6) /// 
	figure_path("`figure_dir'/duration_non-us.eps")	


