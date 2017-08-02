***********************************************************
** Author: Ben Berger; Date Created: 7-30-17              
** This script:
** 1. Runs programs to generate tables
***********************************************************

set more off
use "data/processed.dta", clear

***************************************************
**** Generate figures and tables ******************
***************************************************

**Define directory for reports
set more off
local report_dir "reports/report_08-01-17"
local table_dir "`report_dir'/tables"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

**Load table programs
do "source/02_figures_tables/tables_fns_08-01-17_final.do"

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

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
				


/*
**Run programs to generate tables/figures
*Table 1
summary_stats, table_path("`table_dir'/01-summary_stats.tex")

*Table 9 
nih_funding_by_phase, table_path("`table_dir'/09-nih_funding_by_phase.tex")

*Figure 1a
trial_count_by_phase, figure_path("`figure_dir'/01a-trial_count_by_phase.eps")
*Figure 1b
trial_growth_by_phase, figure_path("`figure_dir'/01b-trial_growth_by_phase.eps")

*Figure 2a
preserve
keep if biomarker_status == 1
trial_count_by_phase, ///
	figure_path("`figure_dir'/02a-trial_count_by_phase_withbmkr.eps") ///
	title("Number of registered Phase I-III trials using biomarkers (1995-2016)")
restore
*Figure 2b
trial_share_withbmkr_by_phase, figure_path("`figure_dir'/02b-trial_share_withbmkr_by_phase.eps")

*Figure 9a
nih_funding_by_yr_phase , figure_path("`figure_dir'/09a-nih_funding_by_yr_phase.eps")






/*
nih_funding_by_bmkr, 		table_path("`table_dir'/01-nih_funding_by_bmkr.tex")
nih_funding_by_bmkr_us, 	table_path("`table_dir'/fragment-02-nih_funding_by_bmkr_us.tex")
nih_funding_by_bmkr_phase, 	table_path("`table_dir'/fragment-03-nih_funding_by_bmkr_phase.tex")
nih_funding_by_bmkrrole, 	table_path("`table_dir'/04-nih_funding_by_bmkrrole.tex")
trial_phase, 			table_path("`table_dir'/05-trial_phase.tex")
trial_duration_by_yr, 		table_path("`table_dir'/06-trial_duration_by_yr.tex") ///
					figure_path("`figure_dir'/06-trial_duration_by_yr.eps")
nih_funding_means, 		table_path("`table_dir'/07-nih_funding_means.tex")
trial_duration_by_yr_phase, 	figure_path("`figure_dir'/05-trial_duration_by_yr_phase.eps")
trial_duration_by_yr_bmkr, 	table_path("`table_dir'/11-trial_duration_by_yr_bmkr.tex") ///
					figure_path("`figure_dir'/04-trial_duration_by_yr_bmkr.eps")
nih_funding_by_yr_bmkr, 	table_path("`table_dir'/08-nih_funding_by_yr_bmkr.tex") ///
					figure_path("`figure_dir'/01-nih_funding_by_yr_bmkr.eps")

preserve
keep if us_trial == 1					
nih_funding_by_yr_bmkr, 	table_path("`table_dir'/09-nih_funding_by_yr_bmkr_us.tex") ///
					figure_path("`figure_dir'/02-nih_funding_by_yr_bmkr_us.eps")					
restore
					
nih_funding_by_yr_phase, 	table_path("`table_dir'/10-nih_funding_by_yr_phase.tex") ///
					figure_path("`figure_dir'/03-nih_funding_by_yr_phase.eps")






