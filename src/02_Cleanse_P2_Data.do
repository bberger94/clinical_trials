/***********************************************************************************
File        : 1_Cleanse_P2_Data.do
Authors     : Alice Ndikumana
Created     : 20 Jun 2016
Modified    : 02 Sept 2016
Description : Format data from cortellis export including: changing variable type to
numeric or calendar date, change variable names to lowercase, separate multiple
word variable names by '_'
***********************************************************************************/

run setup.do

use "$interim/P2_Clinical_Trial_Starts_1995-2015_merged.dta"

* Change NumberOfSites to Int
destring numberofsites enrollment cortellisclinicaltrialid evaluablesubjectcount, replace

* Change date variables into date format
generate start_date = date(startdate,"DMY")
generate end_date = date(enddate,"DMY")
generate primary_endpoint_completion_date = date(primaryendpointcompletiondate,"DMY")
generate last_change_date = date(lastchangedate,"DMY")
generate added_date = date(addeddate,"DMY")

format start_date end_date primary_endpoint_completion_date last_change_date added_date %td

* label newly generated variables
label var start_date "Start Date"
label var end_date "End Date"
label var primary_endpoint_completion_date "Primary Endpoint Completion Date"
label var last_change_date "Last Change Date"
label var added_date "Added Date"

* Drop previous variables
drop startdate enddate primaryendpointcompletiondate lastchangedate addeddate

* Change Trial Duration from "x months" string to x as int and revise label
split trialduration, destring
drop trialduration2 trialduration
rename trialduration1 trial_duration_in_months
label var trial_dur "Trial Duration in Months"

* Change all other variables with multiple words, seperated by "_" if multiple words
rename patientsegment patient_segment
rename primaryinterventions primary_interventions
rename recruitmentstatus recruitment_status
rename numberofsites number_of_sites
rename sitename site_name
rename contactname contact_name
rename organizationtype organization_type
rename sponsoronly sponsor_only
rename collaboratoronly collaborator_only
rename activecontrols active_controls
rename enrollmentcount enrollment_count
rename ageracehealthyvolunteers age_race_healthy_volunteers
rename endpointtypes endpoint_types
rename adverseevents adverse_events
rename scientifictitle  scientific_title
rename cortellisclinicaltrialid cortellis_clinical_trial_id
rename evaluablesubjectcount evaluable_subject_count
rename aimsandscope aims_and_scope
rename protocoldescriptiontext protocol_description_text
rename resultstext results_text
rename adverseeventstext adverse_events_text
rename inclusioncriteriatext inclusion_criteria_text
rename exclusioncriteriatext exclusion_criteria_text
rename inclusioncriteriaindex inclusion_criteria_index
rename exclusioncriteriaindex exclusion_criteria_index
rename biomarkerrole biomarker_role
rename biomarkertype biomarker_type
rename stateprovincecounty state_province_county

*this makes the file size as small as possible, useful with large dataset
compress

*save new formatted dataset
save "$interim/P2_Clinical_Trial_Starts_1995-2015_clean.dta", replace
