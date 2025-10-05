
*======================================================================*
* Project: School Desegregation and Infant Health Outcomes             *
*======================================================================*

*----------------------------------------------------------------------*
* Do-file Purpose: Clean final files                                   *
*   1: Harmonize variables and labels                                  *
*   2: Keep key variables                                              *
*----------------------------------------------------------------------*
*version 16.0

clear all
macro drop all	
set more off
capture log close _all        

* ---- Open log ----
log using "$LOGS/step2_clean_dataset.log", text replace  

use "$ANALYSIS/black.dta", clear

* Keep in-state births
keep if stateres == statenat

* Keep first birth only (later births would confound health outcomes)
tab totord9
keep if totord9==1

* ========================== 1) Marital status ==========================
tab legit3
gen married = 1 if legit3==1
recode married (.=0)
label var married "Married at birth"

* ========== 2) Father info: education (years), age, teenage father, race ==========

* Education (dfeduc; measured in years; missing: 66, 77, 88, 99)
tab dfeduc
gen father_education = dfeduc
replace father_education = . if father_education==66 | father_education==77 | father_education==88 | father_education==99
label var father_education "Father's education (years)"

* Age (dfage; measured in years; missing: 99) 
tab dfage
gen father_age = dfage
replace father_age = . if father_age == 99
label var father_age "Father's age"

* Teenager (dfage; if age is missing, then information on teenager is missing)
gen teenagefather =1  if father_age < 20 
replace teenagefather = 0 if father_age >= 20 & father_age!=. 
label var teenagefather "Father teen (<20)"

* Race: Father is white (frace: 1 white father; 2 black father; other race: 0 or 3-8; missing: 9)
gen whitefather =1 if frace==1
recode whitefather (.=0)
label var whitefather "Father is white"


* ======= 3) Mother info: education (years), age dummies, behaviors =======

* Education (dmeduc; measured in years; missing: 66, 77, 88, 99)
tab dmeduc
gen mother_education = dmeduc
replace mother_education = . if mother_education==66 | mother_education==77 | mother_education==88 | mother_education==99
label var mother_education "Mother's education (years)"

* Age (dmage; measured in years; no missing for mothers)
tab dmage 
gen mother_age = dmage
label var mother_age "Mother's age"

* Teenager (no missing for mothers)
gen byte teenage   = (dmage < 20)
label var teenage   "Mother teen (<20)"

* ==================== 4) Prenatal care & birth outcomes ===================
* Prenatal care (mpre10: 0 missing; 1/2 early)
tab mpre10
gen early_prenatal =1 if mpre10==1 | mpre10==2
recode early_prenatal (.=0)
replace early_prenatal=. if mpre10==0 
label var early_prenatal "Prenatal care (early)"

* Preterm births (gestat3; 0 does not report; 1 under 37 weeks; 2 over 37 weeks; 3 missing )
tab gestat3
gen preterm =1 if gestat3==1
recode preterm (.=0)
replace preterm=. if gestat3==0 | gestat3==3 
label var preterm "Premature births"

* Low birthweight (dbirwt=9999 missing; otherwise okay)
tab dbirwt
sum dbirwt
gen byte low_birthweight=1 if dbirwt < 2500
recode low_birthweight (.=0)
replace low_birthweight = . if dbirwt == 9999
label var low_birthweight "Low birthweight"



* ========================= 5) Location  ======================
describe stateres 
tab stateres 
gen byte southern_states = regexm(" 01 05 10 11 12 13 21 22 24 28 37 40 45 47 48 51 54 ", " "+stateres+" ")
	
* ========================= 6) Desegregation exposure ======================

* Continuous exposure index (0 if not yet exposed; count the number of years as actual)
gen treatment = treatment_years
replace treatment = 0 if treatment_years<=0
label var treatment "Years exposed to school desegregation"

*Discrete exposure index: 1-4 years; 5-8 years; more than 8 years  
gen treatment1=1 if treatment_years>0 & treatment_years<=4
gen treatment2=1 if treatment_years>4 & treatment_years<=8
gen treatment3=1 if treatment_years>8 
recode treatment1 treatment2 treatment3 (.=0)

*Treatment (0/1)
gen treatment_dummy=1 if treatment_years>0
recode treatment_dummy (.=0)


* ========================= 6) Prepation for differential trend   ======================
*gen destringed version of county to prepare 
destring cntyres, gen (county_id_destring)
destring stateres, gen (stateres_destring)
gen birth_year_center=birth_year-1924 
gen year_center=year-1970

* ========================= 7) Prepation for hetergeneity analysis   ======================
sum diss 
gen diss_treatment_dummy=diss*treatment_dummy  

* ============================== 6) Housekeeping =============================
local basic_info year birth_year cntyres county_id_destring stateres stateres_destring southern_states diss

local possible_outcomes ///
    married father_education father_age whitefather ///
    mother_education mother_age teenage ///
    early_prenatal  ///
    preterm low_birthweight 

local treatment_info treatment_years treatment treatment1 treatment2 treatment3 treatment_dummy 


	keep `basic_info'  `treatment_info' `possible_outcomes'
	order `basic_info' `treatment_info' `possible_outcomes'

save "$ANALYSIS/ready_black_analysis.dta", replace

* log close 
log close 
