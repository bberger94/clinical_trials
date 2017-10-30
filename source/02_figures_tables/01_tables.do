/*----------------------------------------------------------------------------*\


	Author: Ben Berger; Date Created: 7-30-17              
	This script runs programs (from tables_fns.do) to generate tables
	
		
\*----------------------------------------------------------------------------*/

set more off
use "data/processed/prepared_trials.dta", clear

**Load table programs
do "source/02_figures_tables/tables_fns.do"


/*----------------------------------------------------------------------------*\
	Define output directory
\*----------------------------------------------------------------------------*/

**Define directory for current summary data report
set more off
local report_dir "reports/report_10-20-17"
local table_dir "`report_dir'/tables"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

cap drop any_public*
gen any_public = sponsor_public == 1 | collaborator_public == 1
gen any_public_max = sponsor_public_max == 1 | collaborator_public_max == 1


/*----------------------------------------------------------------------------*\
	Generate tables
\*----------------------------------------------------------------------------*/

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
ppm_count_and_share if neoplasm == 1, 							///
			ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition"		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/05a-ppm_count_and_share_cancer.tex") 
				
ppm_count_and_share if neoplasm == 1,							///
			ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/05b-ppm_count_and_share_cancer.tex") 


*Table 6
ppm_count_and_share if neoplasm == 0, 							///
			ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/06a-ppm_count_and_share_noncancer.tex") 
			
ppm_count_and_share if neoplasm == 0, 							///
		 	ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/06b-ppm_count_and_share_cancer.tex") 

*Table 7
ppm_count_and_share if us_trial == 1,							///
			ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for trials located in US" ) 				///
			table_path("`table_dir'/07a-ppm_count_and_share_us.tex") 
			
ppm_count_and_share if us_trial == 1,							///
			ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition"		///
				"for trials located in US")				/// 
			table_path("`table_dir'/07b-ppm_count_and_share_us.tex") 

*Table 8
ppm_count_and_share if us_trial == 0,							///
			ppm(g_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for trials located outside US") 			///
			table_path("`table_dir'/08a-ppm_count_and_share_non-us.tex") 
ppm_count_and_share if us_trial == 0,							///
			ppm(r_ppm) 							///
			title(	"Potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for trials located outside US") 			///
			table_path("`table_dir'/08b-ppm_count_and_share_non-us.tex") 				

*Table 9
nih_funding_by_ppm_and_phase, 	title(	"Share of trials receiving NIH funding:" 	///
					"Generous precision medicine definition" )	///
				table_path("`table_dir'/09-nih_funding_by_ppm_and_phase.tex") 
				


 ************************************************
/* *Generate Appendix Tables (US trials only) * */
 ************************************************

*Table A2
bmkrtype_count if us_trial == 1,						///
		title("Number of US trials employing biomarkers by type") 	///
		table_path("`table_dir'/A02-bmkrtype_count_us.tex")
*Table A3
bmkrdrole_count if us_trial == 1,							///
		title("Number of US trials employing biomarkers by detailed role") 	///
		table_path("`table_dir'/A03-bmkrdrole_count_us.tex")

*Table A5
ppm_count_and_share if neoplasm == 1 & us_trial == 1, 					///
			ppm(g_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition"		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/A05a-ppm_count_and_share_cancer_us.tex") 
				
ppm_count_and_share if neoplasm == 1 & us_trial == 1,					///
			ppm(r_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs with cancer indications") 			///
			table_path("`table_dir'/A05b-ppm_count_and_share_cancer_us.tex") 

*Table A6
ppm_count_and_share if neoplasm == 0 & us_trial == 1,					///
			ppm(g_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Generous precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/A06a-ppm_count_and_share_noncancer_us.tex") 

ppm_count_and_share if neoplasm == 0 & us_trial == 1,					///
			ppm(r_ppm) 							///
			title(	"US potential precision medicine trials (1995-2016):" 	///
				"Restrictive precision medicine definition" 		///
				"for drugs without cancer indications") 		///
			table_path("`table_dir'/A06b-ppm_count_and_share_cancer_us.tex") 
















