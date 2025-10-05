
*======================================================================*
* Project: School Desegregation and Infant Health Outcomes             *
*======================================================================*

*----------------------------------------------------------------------*
* Do-file Purpose: Build data for analysis                             *
*   1: Clean school desegregation timeline information                 *
*   2: Merge the state and county information with nchs code           * 
*   3: Append natality (birth certificate) data, 1970–2002             *
*----------------------------------------------------------------------*
*version 16.0
clear all
macro drop all	
set more off
capture log close _all        


* ---- Open log ----
log using "$LOGS/step1_clean.log", text replace  


*======================================================================*
*  1. Clean school desegregation information                           *
*======================================================================*
/***********************************************************************
Tasks:
  1) Clean district-level desegregation timing
  2) Reduce to county-level (earliest year per county)
data source:
*time: downloaded data from Welch & Light (1987). New evidence on school desegregation. 
***********************************************************************/


use "$RAW/time.dta", clear

* -- Focus on ever-desegregated school districts ----------------------*
tab yearofdesegregation
drop if yearofdesegregation==0 | missing(yearofdesegregation)

* -- Check to see the number of duplicates at county level ------------*
* Multiple districts per county are expected.
duplicates list statename countyname

* -- Use the earliest district desegregation year for a unique county--*
* sort so the earliest year is first within each county
sort statename countyname yearofdesegregation

* drop duplicate counties, keeping the first (earliest) by current sort
duplicates drop statename countyname, force

* -- Pre-merge checks on names ----------------------------------------*
tab statename
tab countyname




*======================================================================*
*  2. Merge the state and county information with nchs code            *
*======================================================================*
/***********************************************************************
data source:
*time: downloaded data from Welch & Light (1987). New evidence on school desegregation.
**nchs2fips_county from NBER crosswalk:
https://www.nber.org/research/data/national-center-health-statistics-nchs-federal-information-processing-series-fips-state-county-and
***********************************************************************/

* -- Merge with county crosswalk (by names) ---------------------------*
*Keep only matches present in both datasets (successful matches).
merge 1:1 statename countyname using "$RAW/nchs2fips_county"
tab _merge
keep if _merge==3

* -- Construct county identifier --------------------------------------*
describe nchs_state nchs_county
tab nchs_state
browse nchs_county
*They are all string variables and correctly patted with zeros 

gen cntyres = nchs_state + nchs_county

* -- Retain important outputs and order -------------------------------------*
keep cntyres yearofdesegregation diss 
sort cntyres

save "$PROC/time_ready_merge.dta", replace






*======================================================================*
*  3. Clean and Append natality (birth certificate) data, 1970–2002          *
*======================================================================*
/***********************************************************************
Tasks:
  1) Loop over files to clean each dataset
  2) Append all cleaned files into a single dataset
  3) Generate a subset for Black mothers
  
 source: National Center for Health Statistics (1970-2000)
 https://data.nber.org/nvss/natality/dta/ 
***********************************************************************/


/* -------------------- Clean dataset with Yearly loop ------------- */
forvalues y = 1970/1977 {

    * Load natality file for year y
    use "$RAW/natality/natalityus`y'.dta", clear
    *Source  : NBER natality files 
	
    * Sort by merge key
    sort cntyres

    * Merge with desegregation time data (county-level)
    merge m:1 cntyres using "$PROC/time_ready_merge.dta"

    * Keep only counties that ever desegregated 
    tab _merge 
	keep if _merge==3 

    * Year variables
    gen year = `y'
    gen birth_year = year - dmage
    gen treatment_years = birth_year + 18 - yearofdesegregation
    label var treatment_years "Years to Desegregation"

    * Save per-year cleaned subset
    save "$PROC/natl`y'.dta", replace
}


/* -------------------- Append all years into one file -------- */
use "$PROC/natl1970.dta", clear
forvalues y = 1971/1977 {
    append using "$PROC/natl`y'.dta"
}

save "$ANALYSIS/all.dta", replace 


/* -------------------- keep black mothers only----------------- */
use "$ANALYSIS/all.dta", replace
    * Keep Black mothers (mrace==2)
    keep if mrace == 2

save "$ANALYSIS/black.dta", replace

* log close 
log close 

