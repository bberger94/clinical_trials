/*----------------------------------------------------------------------------*\

	Author: Ben Berger; Date Created: 7-30-17              
	This script runs programs (from tables_fns.do) to generate tables
	
\*----------------------------------------------------------------------------*/

set more off
use "data/prepared_trials.dta", clear

**Load table programs
do "source/02_figures_tables/tables_fns.do"


/*----------------------------------------------------------------------------*\



	Generate figures and tables


	
\*----------------------------------------------------------------------------*/

**Define directory for current report
set more off
local report_dir "reports/report_08-29-17"
local table_dir "`report_dir'/tables"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

*Table 1
summary_stats, table_path("`table_dir'/01-summary_stats.tex")
*Table 2
bmkrtype_count, table_path("`table_dir'/02-bmkrtype_count.tex")
*Table 3
bmkrdrole_count, table_path("`table_dir'/03-bmkrdrole_count.tex")
*Table 4
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition") 		///
			table_path("`table_dir'/04a-ppm_count_and_share.tex") 
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition") 		///
			table_path("`table_dir'/04b-ppm_count_and_share.tex") 

*Table 5
preserve
keep if neoplasm == 1
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition"		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/05a-ppm_count_and_share_cancer.tex") 
				
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/05b-ppm_count_and_share_cancer.tex") 
restore

*Table 6
preserve
keep if neoplasm == 0
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/06a-ppm_count_and_share_noncancer.tex") 
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/06b-ppm_count_and_share_cancer.tex") 
restore

*Table 7
preserve
keep if us_trial == 1
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for trials located in US" ) 				///
			table_path("`table_dir'/07a-ppm_count_and_share_us.tex") 
			
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition"		///
				"for trials located in US")				/// 
			table_path("`table_dir'/07b-ppm_count_and_share_us.tex") 
restore

*Table 8
preserve
keep if us_trial == 0
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for trials located outside US") 			///
			table_path("`table_dir'/08a-ppm_count_and_share_non-us.tex") 
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for trials located outside US") 			///
			table_path("`table_dir'/08b-ppm_count_and_share_non-us.tex") 				
restore

*Table 9
nih_funding_by_ppm_and_phase, 	title(	"Share of trials receiving NIH funding:" 	///
					"Generous precision medicine definition" )	///
				table_path("`table_dir'/09-nih_funding_by_ppm_and_phase.tex") 
				


 ************************************************
/* *Generate Appendix Tables (US trials only) * */
 ************************************************

preserve
keep if us_trial == 1
*Table A2
bmkrtype_count,	title("Number of US trials employing biomarkers by type") ///
		table_path("`table_dir'/A02-bmkrtype_count_us.tex")
*Table A3
bmkrdrole_count,title("Number of US trials employing biomarkers by detailed role") ///
		table_path("`table_dir'/A03-bmkrdrole_count_us.tex")
restore

*Table A5
preserve
keep if neoplasm == 1 & us_trial == 1
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition"		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/A05a-ppm_count_and_share_cancer_us.tex") 
				
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/A05b-ppm_count_and_share_cancer_us.tex") 
restore

*Table A6
preserve
keep if neoplasm == 0 & us_trial == 1
ppm_count_and_share, 	ppm(g_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/A06a-ppm_count_and_share_noncancer_us.tex") 
ppm_count_and_share, 	ppm(r_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/A06b-ppm_count_and_share_cancer_us.tex") 
restore















