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


local report_dir "reports/orphan_drug_project"
local figure_dir "`report_dir'/figures"

foreach dir in `report_dir' `table_dir' `figure_dir' {
	!mkdir "`dir'"
}

set scheme s1mono

*Figure 3
trial_share_by_phase, var(r_lpm) ///
	title("Share of trials with precision medicine biomarkers") ///
	ylabel("ylabel(0(1)12, angle(0))") ///
	figure_path("`figure_dir'/pm_share.eps")
