clear all

do setup.do

use $processed/clinical-trials.dta

program define trials_vs_year
  preserve
  contract start_year, freq(n)
  graph bar (asis) n, over(start_year, label(angle(45))) stack title("Count of Clinical Trials by Trial Start Year")
  restore
end

program define trials_vs_x_vs_year
  syntax varlist(min=1 max=1) [if], title(string)
  local x = "`varlist'"
  display "if contains |`if'|"

  // copy value labels
  local xlabels : value label `x'
  summarize `x'
  local xmin = r(min)
  local xmax = r(max)
  foreach i of numlist `xmin'/`xmax' {
    local l`i' : label `xlabels' `i'
  }

  preserve
  if "`if'" != "" {
      keep `if'
  }
  collapse (count) n=row_id, by(start_year `x')
  reshape wide n, i(start_year) j(`x')

  // apply value labels
  foreach i of numlist `xmin'/`xmax' {
    label variable n`i' "`l`i''"
  }

  graph bar (asis) n*, over(start_year, label(angle(45))) stack title(`title')
  restore
end

// pre: varname should be string variable that is semicolon delimited
program define my_hist
  syntax varlist(min=1 max=1)
  local y = "`varlist'"
  local ylabel : variable label `y'

  preserve
  drop if `y' == ""
  keep `y'
  split `y', parse("; ")
  drop `y'
  generate id = _n
  reshape long `y', i(id) j(j)
  drop if `y' == ""
  replace `y' = strproper(`y')
  graph bar (count), over(`y', label(angle(45))) title("Frequency of `ylabel's Among Clinical Trials that" "Include One or More Biomarkers") ytitle("")
  restore
end

program define reshape_wide
  syntax varlist, i(varlist) j(varlist) value_labels(string)

  summarize `j'
  local j_max = r(max)
  foreach k of numlist 1/`j_max' {
      local l`k' : label `value_labels' `k'
  }
  reshape wide `varlist', i(`i') j(`j')
  foreach k of numlist 1/`j_max' {
      foreach x in `varlist' {
          local my_label = strproper("`l`k''")
          label variable `x'`k' "`my_label'"
      }
  }
end

program define my_hist_vs_year
  syntax varlist(min=1 max=1)
  local y = "`varlist'"
  local ylabel : variable label `y'

  preserve
  drop if `y' == ""
  keep `y' start_year
  split `y', parse("; ")
  drop `y'
  generate id = _n
  reshape long `y', i(id) j(j)
  drop if `y' == ""
  collapse (count) n=id, by(start_year `y')
  encode `y' , generate(role)
  drop `y'

  reshape_wide n, i(start_year) j(role) value_labels(role)

  graph bar (asis) n*, over(start_year, label(angle(45))) title("Frequency of `ylabel's Among Clinical Trials that" "Include One or More Biomarkers by Trial Start Year")
  restore
end

program define my_export
  // graph export to eps, then use convert to create png
  // http://teaching.sociology.ul.ie/bhalpin/wordpress/?p=135
  syntax anything

  graph export "../reports/figures/`anything'", replace
end

program define main
  trials_vs_year
  my_export 1-trials-by-year.eps

  label define biomarker_labels 0 "No Biomarker" 1 "Biomarker"
  label values biomarker_included biomarker_labels
  label define usa_labels 0 "Non-US" 1 "US"
  label values us_trial usa_labels
  label define nih_labels 0 "Not NIH Funded" 1 "NIH Funded"
  label values nih_yes nih_labels

  trials_vs_x_vs_year biomarker_included, title(`""Count of Clinical Trials that Inlcude One or More Biomarkers" "by Trial Year""')
  my_export 2-trials-by-year-biomarker.eps
  trials_vs_x_vs_year us_trial, title(`""Count of Clinical Trials Conducted in the U.S." "by Trial Start Year""')
  my_export 7-trials-by-year-usa.eps
  trials_vs_x_vs_year nih_yes, title(`""Count of Clinical Trials Supported by NIH Funding Per Year""')
  my_export 8-trials-by-year-nih.eps
  trials_vs_x_vs_year nih_yes if biomarker_included, title(`""Count of Clinical Trials that Include One or More Biomarkers" "by Trial Start Year and NIH Funding""')
  my_export 9-trials-by-year-nih-with-biomarker.eps
  trials_vs_x_vs_year nih_yes if !biomarker_included, title(`""Count of Clinical Trials that do not Include a Biomarker" "by Trial Start Year and NIH Funding""')
  my_export 10-trials-by-year-nih-without-biomarker.eps

  my_hist biomarker_role
  my_export 3-trials-by-role.eps
  my_hist biomarker_type
  my_export 5-trials-by-type.eps

  my_hist_vs_year biomarker_role
  my_export 4-trials-by-year-role.eps
  my_hist_vs_year biomarker_type
  my_export 6-trials-by-year-type.eps

  graph pie , over(nih_yes) by(biomarker_included, title("Percent of Clinical Trials Supported by NIH Funding" "By Presence of Biomarkers")) plabel(_all percent, format(%9.1fc) size(5))
  my_export 11-nih-funding-by-biomarker.eps
end

main

/*
program define my_hist2
  syntax [if], title(string)

  preserve
  if "`if'" != "" {
      keep `if'
  }

  drop if biomarker_type == ""

  count
  local N = r(N)

  keep biomarker_type nih_yes
  split biomarker_type, parse("; ")
  drop biomarker_type
  generate id = _n
  reshape long biomarker_type, i(id) j(j)
  drop if biomarker_type == ""
  replace biomarker_type = strproper(biomarker_type)

  collapse (count) n=id, by(biomarker_type nih_yes)
  egen denominator =
  generate pct = 100 * n / `N'
  keep pct biomarker_type nih_yes
  reshape_wide pct, i(biomarker_type) j(nih_yes) value_labels(nih_yes)

  label variable pct0 "Non-NIH Funded"
  label variable pct1 "NIH-Funded"
  graph bar (asis) pct*, over(biomarker_type, label(angle(45))) title(`title')
  restore
end

my_hist2 , title("All Years")
my_export 13-nih-funding-by-biomarker.eps
my_hist2 if start_year >= 2010, title("2010-2015 Trials Only")
*/
