
set more off


* LPM Regression models
cap program drop lpm_regs
program define lpm_regs
	syntax, ///
	lpm(string) [quietly] [margins] [estimator(string)]

	estimates clear
	if "`estimator'" == "" local estimator regress
	
	*****All years	
	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm  i.genomic_type any_public, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type ) post
		}
		estimates store reg1a
		
	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm  i.genomic_type any_public_max, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type ) post
		}
		estimates store reg1b	
	
		
	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm  i.genomic_type any_public, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1c
	
	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm  i.genomic_type any_public_max, ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1d	
	
	*****Most recent years only
	local if = "if year_start >= 2005"

	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm  i.genomic_type any_public `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1e

	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial i.neoplasm  i.genomic_type any_public_max `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1f
		
	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm  i.genomic_type any_public `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1g

	`quietly' `estimator' `lpm' ///
		year_start phase_2 phase_3 i.us_trial##i.neoplasm  i.genomic_type any_public_max `if', ///
		vce(cluster most_common_chapter)
		if "`margins'" != "" {
		`quietly' margins, ///
		dydx(year_start phase_2 phase_3 us_trial neoplasm  genomic_type) post
		}
		estimates store reg1h

	local fmt 4
	di "Dependent variable: `lpm'" 
	
	estout reg1*, ///
		cells(b(star fmt(`fmt') ) se(par fmt(`fmt') )) ///
		starlevels($stars) ///
		legend label varlabels(_cons Constant) stats(N r2 , fmt(0 3)) ///
		noomitted nobaselevels style(tex)	

end

	
********************************************************************************
* Trial duration regression models
cap program drop duration_regs
program define duration_regs
	syntax [if], ///
	[end_dates(string)] ///
	[quietly]
		
	preserve
	estimates clear
	if "`if'" != "" keep `if'
	keep if year_start >= 2000
	
	di "`end_dates'"
	if "`end_dates'" != "" keep if date_end_type_ == "`end_dates'"
	
	* All trials
	* LPM
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm  any_public  ///
		if g_lpm == 1 , robust
		estimates store reg1a
		
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm  any_public_max  ///
		if g_lpm == 1 , robust
		estimates store reg1b
				
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm  any_public_max  ///
		if g_lpm == 1 & us_trial == 1 , robust
		estimates store reg1c

	* NON-LPM
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm  any_public  ///
		if g_lpm == 0 , robust
		estimates store reg1d
		
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial neoplasm  any_public_max  ///
		if g_lpm == 0 , robust
		estimates store reg1e
				
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 neoplasm  any_public_max  ///
		if g_lpm == 0 & us_trial == 1 , robust
		estimates store reg1f
	
	di "Printing Table 10a"
	estout reg1*, cells(b(star fmt(3) ) se(par fmt(3) )) ///
		starlevels($stars) legend label varlabels(_cons Constant) stats(N r2, fmt(0 3)) style(tex)	


	* US? Cancer trials
	keep if neoplasm == 1 
	replace year_start = year_start
	local roles  *_drole 	 
	
	* LPM
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public  ///
		if g_lpm == 1 , robust
		estimates store reg2a
		
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public_max  ///
		if g_lpm == 1 , robust
		estimates store reg2b
				
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public_max `roles' ///
		if g_lpm == 1 , robust
		estimates store reg2c
	
	* NON-LPM
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public  ///
		if g_lpm == 0 , robust
		estimates store reg2d
		
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public_max  ///
		if g_lpm == 0 , robust
		estimates store reg2e
				
	`quietly' reg duration_w ///
		i.year_start phase_2 phase_3 us_trial  any_public_max `roles' ///
		if g_lpm == 0 , robust
		estimates store reg2f

	di "Printing Table 10b"
	estout reg2*, cells(b(star fmt(3) ) se(par fmt(3) )) ///
		starlevels($stars) legend label varlabels(_cons Constant) stats(N r2, fmt(0 3)) style(tex)	
		
	restore
	
end

