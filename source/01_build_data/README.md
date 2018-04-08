The R scripts in this directory format data from trials.csv in a useable form for data analysis. Scripts are numbered in the order to be run. Running build_data.R automates this process.

00_build_functions.R : 
Called by 01_parse_trial_json.R to load functions into R environment. 
No need to run this by itself.

01_parse_trial_json.R : 
Parses CSVs with JSON columns from trials.csv (pulled from Cortellis API by Andrew Marder). 
Returns data frames in long form for each variable of interest in trials.csv.

02_reshape_and_merge.R : 
Reshapes data wide such that each row contains all information on a trial. 
Cleans this data.

03_parse_biomarkers.R : 
Matches detailed biomarker roles to trials by matching on each element of 
the Cartesian product of biomarkers and indications within a trial. 

For example: 
Trial 1 has indications for DISEASE1 and DISEASE2 and biomarkers BMKR1 and BMKR2.
The pairs matched on are
DISEASE1 X BMKR1
DISEASE1 x BMKR2
DISEASE2 X BMKR1 
DISEASE2 X BMKR2

If any of these pairs are used for a particular detailed biomarker role (e.g. screening, selection for therapy),
that role = 1 for Trial 1.



