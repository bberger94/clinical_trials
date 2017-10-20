/*----------------------------------------------------------------------------*\


	Author: Ben Berger; Date Created: 8-2-17              
	This script: Runs programs to generate figures

			
\*----------------------------------------------------------------------------*/

set more off
use "data/processed/prepared_trials.dta", clear

**Load figure programs
do "source/02_figures_tables/figures_fns.do"

/*----------------------------------------------------------------------------*\
	Define output directory
\*----------------------------------------------------------------------------*/

**Define directory for reports
set more off


local report_dir "reports/report_10-20-17"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}


/*----------------------------------------------------------------------------*\
	Generate figures
\*----------------------------------------------------------------------------*/

set scheme s1mono

*Figure 1a
trial_count_by_phase, figure_path("`figure_dir'/01a-trial_count_by_phase.eps")
*Figure 1b 
trial_growth_by_phase, figure_path("`figure_dir'/01b-trial_growth_by_phase.eps")

*Figure 2a
trial_count_by_phase if biomarker_status == 1, ///
	title("Number of registered Phase I-III trials using at least one biomarker") ///
	figure_path("`figure_dir'/02a-bmkr_count_by_phase.eps")
	
*Figure 2b
trial_share_by_phase, var(biomarker_status) ///
			title("Share of trials using at least one biomarker") ///
			ylabel("ylabel(0(10)100, angle(0))") ///
			figure_path("`figure_dir'/02b-bmkr_share_by_phase.eps")

*Figure 3
*3a
trial_count_by_phase if g_ppm == 1, ///
	title("Number of registered PPM (generous definition) trials by phase") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/03a-g_ppm_count_by_phase.eps")

*3b
trial_share_by_phase, var(g_ppm) ///
	title("Share of trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(1)12, angle(0))") ///
	figure_path("`figure_dir'/03b-g_ppm_share_by_phase.eps")
*3c
trial_count_by_phase if r_ppm == 1, ///
	title("Number of registered PPM (restrictive definition) trials by phase") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/03c-r_ppm_count_by_phase.eps") 

*3d
trial_share_by_phase, var(r_ppm) ///
	title("Share of trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(1)12, angle(0))") ///
	figure_path("`figure_dir'/03d-r_ppm_share_by_phase.eps")

*Figure 4
*4a
trial_count_by_type if g_ppm == 1 & phase_1 == 1, ///
	title("Number of Phase I PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04a-trial_count_by_type_g_ppm_phase_1.eps")

*4b
trial_count_by_type if g_ppm == 1 & phase_2 == 1, ///
	title("Number of Phase II PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04b-trial_count_by_type_g_ppm_phase_2.eps")

*4c
trial_count_by_type if g_ppm == 1 & phase_3 == 1, ///
	title("Number of Phase III PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04c-trial_count_by_type_g_ppm_phase_3.eps")

*4d
trial_count_by_type if r_ppm == 1 & phase_1 == 1, ///
	title("Number of Phase I PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04d-trial_count_by_type_r_ppm_phase_1.eps")

*4e
trial_count_by_type if r_ppm == 1 & phase_2 == 1, ///
	title("Number of Phase II PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04e-trial_count_by_type_r_ppm_phase_2.eps")

*4f
trial_count_by_type if r_ppm == 1 & phase_3 == 1, ///
	title("Number of Phase III PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/04f-trial_count_by_type_r_ppm_phase_3.eps")

*Figure 5
*5a
trial_count_by_phase if g_ppm == 1 & neoplasm == 1, ///
	title("Number of registered PPM (generous definition) trials by phase: cancer trials") ///
	figure_path("`figure_dir'/05a-g_ppm_count_by_phase_cancer.eps")

*5b
trial_share_by_phase if neoplasm == 1, var(g_ppm) ///
	title("Share of cancer drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(5)50, angle(0))") ///
	figure_path("`figure_dir'/05b-g_ppm_share_by_phase_cancer.eps")

*5c
trial_count_by_phase if r_ppm == 1 & neoplasm == 1, ///
	title("Number of registered PPM (restrictive definition) trials by phase: cancer trials") ///
	figure_path("`figure_dir'/05c-r_ppm_count_by_phase_cancer.eps")

*5d
trial_share_by_phase if neoplasm == 1, var(r_ppm) ///
	title("Share of cancer drug trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(5)50, angle(0))") ///
	figure_path("`figure_dir'/05d-r_ppm_share_by_phase_cancer.eps")


*Figure 6
*6a
trial_count_by_phase if g_ppm == 1 & neoplasm == 0, ///
	title("Number of registered PPM (generous definition) trials by phase: non-cancer trials") ///
	figure_path("`figure_dir'/06a-g_ppm_count_by_phase_noncancer.eps")

*6b
trial_share_by_phase if neoplasm == 0, var(g_ppm) ///
	title("Share of non-cancer drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(.5)3, angle(0))") ///
	figure_path("`figure_dir'/06b-g_ppm_share_by_phase_noncancer.eps")

*6c
trial_count_by_phase if r_ppm == 1 & neoplasm == 0, ///
	title("Number of registered PPM (restrictive definition) trials by phase: non-cancer trials") ///
	ylabel("ylabel(0(20)100, angle(0))") ///
	figure_path("`figure_dir'/06c-r_ppm_count_by_phase_noncancer.eps")

*6d
trial_share_by_phase if neoplasm == 0, var(r_ppm) ///
			title("Share of non-cancer drug trials with PPM biomarkers (restrictive definition)") ///
			ylabel("ylabel(0(.5)3, angle(0))") ///
			figure_path("`figure_dir'/06d-r_ppm_share_by_phase_noncancer.eps")


*Figure 7
*7a
trial_count_by_phase if g_ppm == 1 & us_trial == 1, ///
	title("Number of registered PPM (generous definition) trials by phase: US trials") ///
	ylabel("ylabel(0(50)250, angle(0))") ///			
	figure_path("`figure_dir'/07a-g_ppm_count_by_phase_us.eps")

*7b
trial_share_by_phase if us_trial == 1, var(g_ppm) ///
	title("Share of US drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/07b-g_ppm_share_by_phase_us.eps")

*7c
trial_count_by_phase if r_ppm == 1 & us_trial == 1, ///
	title("Number of registered PPM (restrictive definition) trials by phase: US trials") ///
	ylabel("ylabel(0(50)250, angle(0))") ///							
	figure_path("`figure_dir'/07c-r_ppm_count_by_phase_us.eps")

*7d
trial_share_by_phase if us_trial == 1, var(r_ppm) ///
	title("Share of US drug trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/07d-r_ppm_share_by_phase_us.eps")


*Figure 8
*8a
trial_count_by_phase if g_ppm == 1 & us_trial == 0, ///
	title("Number of registered PPM (generous definition) trials by phase: non-US trials") ///
	figure_path("`figure_dir'/08a-g_ppm_count_by_phase_non-us.eps")

*8b
trial_share_by_phase if us_trial == 0, var(g_ppm) ///
	title("Share of non-US drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/08b-g_ppm_share_by_phase_non-us.eps")

*8c
trial_count_by_phase if r_ppm == 1 & us_trial == 0, ///
	title("Number of registered PPM (restrictive definition) trials by phase: non-US trials") ///
	figure_path("`figure_dir'/08c-r_ppm_count_by_phase_non-us.eps")

*8d
trial_share_by_phase if us_trial == 0, var(r_ppm) ///
	title("Share of non-US drug trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/08d-r_ppm_share_by_phase_non-us.eps")


*Figure 9
*9a
trial_share_by_phase if us_trial == 1, var(nih_funding) ///
	title("Share of US trials receiving NIH funding by phase") ///
	ylabel("ylabel(0(5)30, angle(0))") ///
	figure_path("`figure_dir'/09a-nih_share_by_phase.eps")

*9b
trial_share_by_phase if g_ppm == 1 & us_trial == 1 & year_start >= 1996, var(nih_funding) ///
	title("Share of US trials with PPM biomarkers (generous) receiving NIH funding") ///
	ylabel("ylabel(0(5)30, angle(0))") ///
	figure_path("`figure_dir'/09b-nih_share_by_phase_g_ppm.eps")

*9c
trial_share_by_phase if r_ppm == 1 & us_trial == 1 & year_start >= 1996, var(nih_funding) ///
	title("Share of US trials with PPM biomarkers (restrictive) receiving NIH funding") ///
	ylabel("ylabel(0(5)35, angle(0))") ///
	figure_path("`figure_dir'/09c-nih_share_by_phase_r_ppm.eps")









/*----------------------------------------------------------------------------*\
	Generate Appendix Figures
\*----------------------------------------------------------------------------*/

*Figure A1
*A1a
trial_count_by_phase if us_trial == 1, ///
	title("Number of registered Phase I-III US trials (1995-2016)") ///
	ylabel("ylabel(0(1000)4000, angle(0))") ///
	figure_path("`figure_dir'/A01a-trial_count_by_phase_us.eps")

*A1b 
trial_growth_by_phase if us_trial == 1, ///
	title("Growth in number of registered Phase I-III US trials since 1995") ///
	ylabel("ylabel(0(1000)9000, angle(0))") ///
	figure_path("`figure_dir'/A01b-trial_growth_by_phase_us.eps")

*A1c
trial_count_by_phase if us_trial == 0, ///
 	title("Number of registered Phase I-III non-US trials (1995-2016)") ///
	ylabel("ylabel(0(1000)4000, angle(0))") ///
	figure_path("`figure_dir'/A01c-trial_count_by_phase_non-us.eps")
	
*A1d 
/*	note that growth in number of non-US trials is likely primarily driven by
	increased drug trial REGISTRATION, not increased drug development	 */
trial_growth_by_phase if us_trial == 0, ///
 	title("Growth in number of registered Phase I-III non-US trials since 1995") ///
	ylabel("ylabel(0(1000)9000, angle(0))") ///
	figure_path("`figure_dir'/A01d-trial_growth_by_phase_non-us.eps")

*Figure A2
*A2a
trial_count_by_phase if biomarker_status == 1 & us_trial == 1, ///
	title("Number of registered Phase I-III US trials using at least one biomarker") ///
	figure_path("`figure_dir'/A02a-bmkr_count_by_phase_us.eps")

*A2b
trial_share_by_phase if us_trial == 1, var(biomarker_status) ///
	title("Share of US trials using at least one biomarker") ///
	ylabel("ylabel(0(10)100, angle(0))") ///
	figure_path("`figure_dir'/A02b-bmkr_share_by_phase_us.eps")


*Figure A3
*A3a
trial_count_by_phase if g_ppm == 1 & us_trial == 1, ///
	title("Number of registered US PPM (generous definition) trials by phase") ///
	ylabel("ylabel(0(50)250, angle(0))") ///
	figure_path("`figure_dir'/A03a-g_ppm_count_by_phase_us.eps")
	
*A3b
trial_share_by_phase if us_trial == 1, var(g_ppm) ///
	title("Share of US trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/A03b-g_ppm_share_by_phase_us.eps")

*A3c
trial_count_by_phase if r_ppm == 1 & us_trial == 1, ///
	title("Number of registered US PPM (restrictive definition) trials by phase") ///
	ylabel("ylabel(0(50)250, angle(0))") ///
	figure_path("`figure_dir'/A03c-r_ppm_count_by_phase_us.eps") 

*A3d
trial_share_by_phase if us_trial == 1, var(r_ppm) ///
	title("Share of US trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(2)20, angle(0))") ///
	figure_path("`figure_dir'/A03d-r_ppm_share_by_phase_us.eps")

*Figure A4
*A4a
trial_count_by_type if g_ppm == 1 & phase_1 == 1 & us_trial == 1, ///
	title("Number of Phase I US PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04a-trial_count_by_type_g_ppm_phase_1_us.eps")
			
*A4b
trial_count_by_type if g_ppm == 1 & phase_2 == 1 & us_trial == 1, ///
	title("Number of Phase II US PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04b-trial_count_by_type_g_ppm_phase_2_us.eps")

*A4c
trial_count_by_type if g_ppm == 1 & phase_3 == 1 & us_trial == 1, ///
	title("Number of Phase III US PPM trials (generous definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04c-trial_count_by_type_g_ppm_phase_3_us.eps")

*A4d
trial_count_by_type if r_ppm == 1 & phase_1 == 1 & us_trial == 1, ///
	title("Number of Phase I US PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04d-trial_count_by_type_r_ppm_phase_1_us.eps")

*A4e
trial_count_by_type if r_ppm == 1 & phase_2 == 1 & us_trial == 1, ///
	title("Number of Phase II US PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04e-trial_count_by_type_r_ppm_phase_2_us.eps")
	
*A4f
trial_count_by_type if r_ppm == 1 & phase_3 == 1 & us_trial == 1, ///
	title("Number of Phase III US PPM trials (restrictive definition) by biomarker types used") ///
	ylabel("ylabel(0(100)500, angle(0))") ///
	figure_path("`figure_dir'/A04f-trial_count_by_type_r_ppm_phase_3_us.eps")

*Figure A5
*A5a
trial_count_by_phase if g_ppm == 1 & neoplasm == 1 & us_trial == 1, ///
	title("Number of registered US PPM (generous definition) trials by phase: cancer trials") ///
	ylabel("ylabel(0(50)250, angle(0))") ///
	figure_path("`figure_dir'/A05a-g_ppm_count_by_phase_cancer_us.eps")

*A5b
trial_share_by_phase if neoplasm == 1 & us_trial == 1, var(g_ppm) ///
	title("Share of US cancer drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(5)60, angle(0))") ///
	figure_path("`figure_dir'/A05b-g_ppm_share_by_phase_cancer_us.eps")

*A5c
trial_count_by_phase if r_ppm == 1 & neoplasm == 1 & us_trial == 1, ///
	title("Number of registered US PPM (restrictive definition) trials by phase: cancer trials") ///
	ylabel("ylabel(0(50)250, angle(0))") ///
	figure_path("`figure_dir'/A05c-r_ppm_count_by_phase_cancer_us.eps")

*A5d
trial_share_by_phase if neoplasm == 1 & us_trial == 1, var(r_ppm) ///
	title("Share of US cancer drug trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(5)60, angle(0))") ///
	figure_path("`figure_dir'/A05d-r_ppm_share_by_phase_cancer_us.eps")

*Figure A6
*A6a
trial_count_by_phase if g_ppm == 1 & neoplasm == 0 & us_trial == 1, ///
	title("Number of registered US PPM (generous definition) trials by phase: non-cancer trials") ///
	ylabel("ylabel(0(20)100, angle(0))") ///
	figure_path("`figure_dir'/A06a-g_ppm_count_by_phase_noncancer_us.eps")

*A6b
trial_share_by_phase if neoplasm == 0 & us_trial == 1, var(g_ppm) ///
	title("Share of US non-cancer drug trials with PPM biomarkers (generous definition)") ///
	ylabel("ylabel(0(.5)5, angle(0))") ///
	figure_path("`figure_dir'/A06b-g_ppm_share_by_phase_noncancer_us.eps")

*A6c
trial_count_by_phase if r_ppm == 1 & neoplasm == 0 & us_trial == 1, ///
	title("Number of registered US PPM (restrictive definition)trials by phase: non-cancer trials") ///
	ylabel("ylabel(0(20)100, angle(0))") ///
	figure_path("`figure_dir'/A06c-r_ppm_count_by_phase_noncancer_us.eps")

*A6d
trial_share_by_phase if neoplasm == 0 & us_trial == 1, var(r_ppm) ///
	title("Share of US non-cancer drug trials with PPM biomarkers (restrictive definition)") ///
	ylabel("ylabel(0(.5)5, angle(0))") ///
	figure_path("`figure_dir'/A06d-r_ppm_share_by_phase_noncancer_us.eps")




/*

/* In development */

trial_count_by_phase if sponsor_public_ancestor == 1 & year_start >= 2010, ///
	title("Number of registered trials by phase: public sponsor firms") 

trial_share_by_phase, var(sponsor_public_max) title("Share of trials sponsored by public firm or firm with public ancestor")
trial_share_by_phase, var(sponsor_public) title("Share of trials sponsored by public firm")

trial_share_by_phase if sponsor_public_ancestor == 0, var(r_ppm) ylabel("ylabel(0(1)10, angle(0))")
trial_share_by_phase if sponsor_public_ancestor == 1, var(r_ppm) ylabel("ylabel(0(1)10, angle(0))")



set more off
cap drop any_public*
gen any_public = sponsor_public == 1 | collaborator_public == 1
gen any_public_max = sponsor_public_max == 1 | collaborator_public_max == 1

* Bounded shares 
bounded_share if year_start >= 2005, ///
	lb(sponsor_public) ub(sponsor_public_max)  ///
	xlabel(xlabel(2005(1)2016, angle(300) ) ) ///
	title("Share of trials with public firm sponsor") 

bounded_share if year_start >= 2005, ///
	lb(any_public) ub(any_public_max) ///
	xlabel(xlabel(2005(1)2016, angle(300) ) ) ///
	title("Share of trials with public firm involvement") 

* Bounded share (PPM)
bounded_share if g_ppm == 1 & year_start >= 2005, ///
	lb(sponsor_public) ub(sponsor_public_max) ///
	xlabel(xlabel(2005(1)2016, angle(300) ) ) ///
	title("Share of generous PPM trials with public firm sponsor")
	
bounded_share if g_ppm == 1 & year_start >= 2005, ///
	lb(any_public) ub(any_public_max) ///
	xlabel(xlabel(2005(1)2016, angle(300) ) ) ///
	title("Share of generous PPM trials with public firm involvement")





* Bounded counts
set more off
bounded_count if year_start >= 2005, lb(sponsor_public) ub(sponsor_public_max) ///
	ylabel(ylabel(0(100)1500, angle(0))) ///
	xlabel(xlabel(2005(1)2016, angle(300)) ) ///
	title("Count of trials with public firm sponsor") 

set more off
bounded_count if year_start >= 2005, lb(any_public) ub(any_public_max) ///
	ylabel(ylabel(0(100)1500, angle(0))) ///
	xlabel(xlabel(2005(1)2016, angle(300)) ) ///
	title("Count of trials with public firm involvement") 




bounded_count if year_start >= 2005 & neoplasm == 1, lb(sponsor_public) ub(sponsor_public_max) ///
	ylabel(ylabel(0(100)500, angle(0))) ///
	title("Bounded count of cancer trials with public sponsors") 

bounded_count if year_start >= 2005 & neoplasm == 1 & g_ppm == 1, lb(sponsor_public) ub(sponsor_public_max) ///
	ylabel(ylabel(0(20)180, angle(0))) ///
	xlabel(xlabel(2005(1)2016, angle(300)) ) ///
	title("Bounded count of generous PPM cancer trials with public firm sponsors") 

bounded_count if year_start >= 2005 & neoplasm == 1 & g_ppm == 1, lb(any_public) ub(any_public_max) ///
	ylabel(ylabel(0(20)180, angle(0))) ///
	xlabel(xlabel(2005(1)2016, angle(300)) ) ///
	title("Bounded count of generous PPM cancer trials with public firm involvement") 









