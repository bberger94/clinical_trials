***********************************************************
** Author: Ben Berger; Date Created: 8-2-17              
** This script:
** 1. Runs programs to generate figures
***********************************************************

set more off
use "data/processed.dta", clear

***************************************************
**** Generate figures and tables ******************
***************************************************

**Define directory for reports
set more off
local report_dir "reports/report_08-08-17"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

**Load figure programs
do "source/02_figures_tables/figures_fns.do"

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
set scheme s1mono


*Figure 1a
trial_count_by_phase, figure_path("`figure_dir'/01a-trial_count_by_phase.eps")
*Figure 1b 
trial_growth_by_phase, figure_path("`figure_dir'/01b-trial_growth_by_phase.eps")
*Figure 2a
preserve
keep if biomarker_status == 1
trial_count_by_phase, 	title("Number of registered Phase I-III trials using at least one biomarker") ///
			figure_path("`figure_dir'/02a-bmkr_count_by_phase.eps")
restore
*Figure 2b
trial_share_by_phase, var(biomarker_status) ///
			title("Share of trials using at least one biomarker") ///
			ylabel("ylabel(0(10)100, angle(0))") ///
			figure_path("`figure_dir'/02b-bmkr_share_by_phase.eps")

*Figure 3
*3a
preserve
keep if g_ppm == 1
trial_count_by_phase, title("Number of registered PPM (generous definition) trials by phase") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/03a-g_ppm_count_by_phase.eps")
restore
*3b
trial_share_by_phase, var(g_ppm) ///
			title("Share of trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(1)12, angle(0))") ///
			figure_path("`figure_dir'/03b-g_ppm_share_by_phase.eps")
*3c
preserve
keep if r_ppm == 1
trial_count_by_phase, title("Number of registered PPM (restrictive definition) trials by phase") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/03c-r_ppm_count_by_phase.eps") 

restore
*3d
trial_share_by_phase, var(r_ppm) ///
			title("Share of trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(1)12, angle(0))") ///
			figure_path("`figure_dir'/03d-r_ppm_share_by_phase.eps")

*Figure 4
*4a
preserve
keep if g_ppm == 1 & phase_1 == 1
trial_count_by_type, title("Number of Phase I PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04a-trial_count_by_type_g_ppm_phase_1.eps")
			
restore
*4b
preserve
keep if g_ppm == 1 & phase_2 == 1
trial_count_by_type, title("Number of Phase II PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04b-trial_count_by_type_g_ppm_phase_2.eps")
restore
*4c
preserve
keep if g_ppm == 1 & phase_3 == 1
trial_count_by_type, title("Number of Phase III PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04c-trial_count_by_type_g_ppm_phase_3.eps")
restore
*4d
preserve
keep if r_ppm == 1 & phase_1 == 1
trial_count_by_type, title("Number of Phase I PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04d-trial_count_by_type_r_ppm_phase_1.eps")
restore
*4e
preserve
keep if r_ppm == 1 & phase_2 == 1
trial_count_by_type, title("Number of Phase II PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04e-trial_count_by_type_r_ppm_phase_2.eps")
restore
*4f
preserve
keep if r_ppm == 1 & phase_3 == 1
trial_count_by_type, title("Number of Phase III PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/04f-trial_count_by_type_r_ppm_phase_3.eps")
restore


*Figure 5
*5a
preserve
keep if g_ppm == 1 & neoplasm == 1
trial_count_by_phase, title("Number of registered PPM (generous definition) trials by phase: cancer trials") ///
			figure_path("`figure_dir'/05a-g_ppm_count_by_phase_cancer.eps")
restore
*5b
preserve
keep if neoplasm == 1
trial_share_by_phase, var(g_ppm) ///
			title("Share of cancer drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(5)50, angle(0))") ///
			figure_path("`figure_dir'/05b-g_ppm_share_by_phase_cancer.eps")
restore
*5c
preserve
keep if r_ppm == 1 & neoplasm == 1
trial_count_by_phase, title("Number of registered PPM (restrictive definition) trials by phase: cancer trials") ///
			figure_path("`figure_dir'/05c-r_ppm_count_by_phase_cancer.eps")

restore
*5d
preserve
keep if neoplasm == 1
trial_share_by_phase, var(r_ppm) ///
			title("Share of cancer drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(5)50, angle(0))") ///
			figure_path("`figure_dir'/05d-r_ppm_share_by_phase_cancer.eps")
restore

*Figure 6
*6a
preserve
keep if g_ppm == 1 & neoplasm == 0
trial_count_by_phase, title("Number of registered PPM (generous definition) trials by phase: non-cancer trials") ///
			figure_path("`figure_dir'/06a-g_ppm_count_by_phase_noncancer.eps")
restore
*6b
preserve
keep if neoplasm == 0
trial_share_by_phase, var(g_ppm) ///
			title("Share of non-cancer drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(.5)3, angle(0))") ///
			figure_path("`figure_dir'/06b-g_ppm_share_by_phase_noncancer.eps")
restore
*6c
preserve
keep if r_ppm == 1 & neoplasm == 0
trial_count_by_phase, title("Number of registered PPM (restrictive definition)" ///
				"trials by phase: non-cancer trials") ///
			ylabel("ylabel(0(20)100, angle(0))") ///
			figure_path("`figure_dir'/06c-r_ppm_count_by_phase_noncancer.eps")

restore
*6d
preserve
keep if neoplasm == 0
trial_share_by_phase, var(r_ppm) ///
			title("Share of non-cancer drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(.5)3, angle(0))") ///
			figure_path("`figure_dir'/06d-r_ppm_share_by_phase_noncancer.eps")

restore




*Figure 7
*7a
preserve
keep if g_ppm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered PPM (generous definition) trials by phase: US trials") ///
			ylabel("ylabel(0(50)250, angle(0))") ///			
			figure_path("`figure_dir'/07a-g_ppm_count_by_phase_us.eps")

restore
*7b
preserve
keep if us_trial == 1
trial_share_by_phase, var(g_ppm) ///
			title("Share of US drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/07b-g_ppm_share_by_phase_us.eps")
restore
*7c
preserve
keep if r_ppm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered PPM (restrictive definition)" ///
				"trials by phase: US trials") ///
			ylabel("ylabel(0(50)250, angle(0))") ///							
			figure_path("`figure_dir'/07c-r_ppm_count_by_phase_us.eps")
restore
*7d
preserve
keep if us_trial == 1
trial_share_by_phase, var(r_ppm) ///
			title("Share of US drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/07d-r_ppm_share_by_phase_us.eps")
restore

*Figure 8
*8a
preserve
keep if g_ppm == 1 & us_trial == 0
trial_count_by_phase, title("Number of registered PPM (generous definition) trials by phase: non-US trials") ///
			figure_path("`figure_dir'/08a-g_ppm_count_by_phase_non-us.eps")
restore
*8b
preserve
keep if us_trial == 0
trial_share_by_phase, var(g_ppm) ///
			title("Share of non-US drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/08b-g_ppm_share_by_phase_non-us.eps")
restore
*8c
preserve
keep if r_ppm == 1 & us_trial == 0
trial_count_by_phase, title("Number of registered PPM (restrictive definition)" ///
				"trials by phase: non-US trials") ///
			figure_path("`figure_dir'/08c-r_ppm_count_by_phase_non-us.eps")
restore
*8d
preserve
keep if us_trial == 0
trial_share_by_phase, var(r_ppm) ///
			title("Share of non-US drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/08d-r_ppm_share_by_phase_non-us.eps")
restore

*Figure 9
*9a
trial_share_by_phase, var(nih_funding) ///
			title("Share of registered trials receiving NIH funding by phase") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/09a-nih_share_by_phase.eps")
*9b
preserve
keep if g_ppm == 1 & year_start >= 1996
trial_share_by_phase, var(nih_funding) ///
			title("Share of trials with PPM biomarkers (generous) receiving NIH funding") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/09b-nih_share_by_phase_g_ppm.eps")
restore
*9c
preserve
keep if r_ppm == 1 & year_start >= 1996
trial_share_by_phase, var(nih_funding) ///
			title("Share of trials with PPM biomarkers (restrictive) receiving NIH funding") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/09c-nih_share_by_phase_r_ppm.eps")
restore


 *******************************
/* *Generate Appendix Figures* */
 *******************************

**Define directory for reports
set more off
local report_dir "reports/report_08-08-17"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

**Load figure programs
do "source/02_figures_tables/figures_fns.do"



*Figure 1
preserve
keep if us_trial == 1
*1a
trial_count_by_phase, 	title("Number of registered Phase I-III US trials (1995-2016)") ///
			ylabel("ylabel(0(1000)4000, angle(0))") ///
			figure_path("`figure_dir'/A01a-trial_count_by_phase_us.eps")
*1b 
trial_growth_by_phase, 	title("Growth in number of registered Phase I-III US trials since 1995") ///
			ylabel("ylabel(0(1000)9000, angle(0))") ///
			figure_path("`figure_dir'/A01b-trial_growth_by_phase_us.eps")
restore

preserve
keep if us_trial == 0
*1c
trial_count_by_phase, 	title("Number of registered Phase I-III non-US trials (1995-2016)") ///
			ylabel("ylabel(0(1000)4000, angle(0))") ///
			figure_path("`figure_dir'/A01c-trial_count_by_phase_non-us.eps")
*1d 
trial_growth_by_phase, 	title("Growth in number of registered Phase I-III non-US trials since 1995") ///
			ylabel("ylabel(0(1000)9000, angle(0))") ///
			figure_path("`figure_dir'/A01d-trial_growth_by_phase_non-us.eps")
restore

*Figure 2
*2a
preserve
keep if biomarker_status == 1 & us_trial == 1
trial_count_by_phase, 	title("Number of registered Phase I-III US trials using at least one biomarker") ///
			figure_path("`figure_dir'/A02a-bmkr_count_by_phase_us.eps")
restore
*2b
preserve
keep if us_trial == 1
trial_share_by_phase, var(biomarker_status) ///
			title("Share of US trials using at least one biomarker") ///
			ylabel("ylabel(0(10)100, angle(0))") ///
			figure_path("`figure_dir'/A02b-bmkr_share_by_phase_us.eps")
restore

*Figure 3
*3a
preserve
keep if g_ppm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (generous definition) trials by phase") ///
			ylabel("ylabel(0(50)250, angle(0))") ///
			figure_path("`figure_dir'/A03a-g_ppm_count_by_phase_us.eps")
restore
*3b
preserve
keep if us_trial == 1
trial_share_by_phase, var(g_ppm) ///
			title("Share of US trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/A03b-g_ppm_share_by_phase_us.eps")
restore

*3c
preserve
keep if r_ppm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (restrictive definition) trials by phase") ///
			ylabel("ylabel(0(50)250, angle(0))") ///
			figure_path("`figure_dir'/A03c-r_ppm_count_by_phase_us.eps") 
restore
*3d
preserve
keep if us_trial == 1
trial_share_by_phase, var(r_ppm) ///
			title("Share of US trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(2)20, angle(0))") ///
			figure_path("`figure_dir'/A03d-r_ppm_share_by_phase_us.eps")
restore
*Figure 4
*4a
preserve
keep if g_ppm == 1 & phase_1 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase I US PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04a-trial_count_by_type_g_ppm_phase_1_us.eps")
			
restore
*4b
preserve
keep if g_ppm == 1 & phase_2 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase II US PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04b-trial_count_by_type_g_ppm_phase_2_us.eps")
restore
*4c
preserve
keep if g_ppm == 1 & phase_3 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase III US PPM trials (generous definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04c-trial_count_by_type_g_ppm_phase_3_us.eps")
restore
*4d
preserve
keep if r_ppm == 1 & phase_1 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase I US PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04d-trial_count_by_type_r_ppm_phase_1_us.eps")
restore
*4e
preserve
keep if r_ppm == 1 & phase_2 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase II US PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04e-trial_count_by_type_r_ppm_phase_2_us.eps")
restore
*4f
preserve
keep if r_ppm == 1 & phase_3 == 1 & us_trial == 1
trial_count_by_type, title("Number of Phase III US PPM trials (restrictive definition) by biomarker types used") ///
			ylabel("ylabel(0(100)500, angle(0))") ///
			figure_path("`figure_dir'/A04f-trial_count_by_type_r_ppm_phase_3_us.eps")
restore


*Figure 5
*5a
preserve
keep if g_ppm == 1 & neoplasm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (generous definition) trials by phase: cancer trials") ///
			ylabel("ylabel(0(50)250, angle(0))") ///
			figure_path("`figure_dir'/A05a-g_ppm_count_by_phase_cancer_us.eps")
restore
*5b
preserve
keep if neoplasm == 1 & us_trial == 1
trial_share_by_phase, var(g_ppm) ///
			title("Share of US cancer drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(5)60, angle(0))") ///
			figure_path("`figure_dir'/A05b-g_ppm_share_by_phase_cancer_us.eps")
restore
*5c
preserve
keep if r_ppm == 1 & neoplasm == 1 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (restrictive definition) trials by phase: cancer trials") ///
			ylabel("ylabel(0(50)250, angle(0))") ///
			figure_path("`figure_dir'/A05c-r_ppm_count_by_phase_cancer_us.eps")

restore
*5d
preserve
keep if neoplasm == 1 & us_trial == 1
trial_share_by_phase, var(r_ppm) ///
			title("Share of US cancer drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(5)60, angle(0))") ///
			figure_path("`figure_dir'/A05d-r_ppm_share_by_phase_cancer_us.eps")
restore

*Figure 6
*6a
preserve
keep if g_ppm == 1 & neoplasm == 0 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (generous definition) trials by phase: non-cancer trials") ///
			ylabel("ylabel(0(20)100, angle(0))") ///
			figure_path("`figure_dir'/A06a-g_ppm_count_by_phase_noncancer_us.eps")
restore
*6b
preserve
keep if neoplasm == 0 & us_trial == 1
trial_share_by_phase, var(g_ppm) ///
			title("Share of US non-cancer drug trials with PPM biomarkers (generous definition)") ///
			ylabel("ylabel(0(.5)5, angle(0))") ///
			figure_path("`figure_dir'/A06b-g_ppm_share_by_phase_noncancer_us.eps")
restore
*6c
preserve
keep if r_ppm == 1 & neoplasm == 0 & us_trial == 1
trial_count_by_phase, title("Number of registered US PPM (restrictive definition)" ///
				"trials by phase: non-cancer trials") ///
			ylabel("ylabel(0(20)100, angle(0))") ///
			figure_path("`figure_dir'/A06c-r_ppm_count_by_phase_noncancer_us.eps")

restore
*6d
preserve
keep if neoplasm == 0 & us_trial == 1
trial_share_by_phase, var(r_ppm) ///
			title("Share of US non-cancer drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(.5)5, angle(0))") ///
			figure_path("`figure_dir'/A06d-r_ppm_share_by_phase_noncancer_us.eps")

restore















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






