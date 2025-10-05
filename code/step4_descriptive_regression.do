
*======================================================================*
* Project: School Desegregation and Infant Health Outcomes             *
*======================================================================*

*----------------------------------------------------------------------*
* Do-file Purpose: Analyze the dataset                                 *
*   Step 1: Descriptive Stats
*   Step 2: Explore outcomes using three treatment definitions         *
*   Step 3: Robustness—add alternative time trends and fixed effects   *
*   Step 4: Heterogeneity analysis                                     *
*----------------------------------------------------------------------*

*version 16.0
clear all
macro drop all	
set more off
capture log close _all        

* ---- Open log ----
log using "$LOGS/step3_regression.log", text replace  
set more off

*=========================== Specify Outcomes ===========================*
local possible_outcomes ///
    married father_education father_age whitefather ///
    mother_education mother_age teenage ///
    early_prenatal ///
    preterm low_birthweight

* (Optional groupings for later use)
* local father_outcomes  married father_education father_age whitefather
* local mother_outcomes  mother_education mother_age teenage
* local prenatal_outcomes early_prenatal  
* local infant_outcomes  preterm low_birthweight 

*======================================================================*
*                         1) Descriptive Tables                        *
*======================================================================*

use "$ANALYSIS/ready_black_analysis.dta", clear 

* Compute stats
eststo clear
estpost summarize `possible_outcomes'

* Export to LaTeX
esttab using "descriptives_outcomes.tex", replace ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") ///
    collabels("N" "Mean" "SD" "Min" "Max") ///
    label nonumber noobs nomtitle ///
    booktabs alignment(c) compress ///
    title("Descriptive statistics")



*======================================================================*
*                         2) Main Analysis                              *
*   Baseline FE: county (cntyres) & cohort (birth_year);               *
*   Standard errors clustered by county (cntyres).                     *
*   Outcomes: marriage, father, mother, prenatal, infant outcomes      *
*======================================================================*


*---------------------- 2A) Single-treatment spec --------------------*
foreach x of local possible_outcomes {
    eststo clear

    eststo: reghdfe `x' treatment, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment if southern_states==1, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment if southern_states==0, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    esttab using "Table1_conttreatment_`x'.tex", replace ///
        keep(treatment) b(5) se(3) ///
        mtitles("All" "Southern" "Non-Southern") ///
        title("`x'") ///
        star(* 0.10 ** 0.05 *** 0.01)
}

*---------------------- 2B) Three-period dummies ---------------------*
foreach x of local possible_outcomes {
    eststo clear

    eststo: reghdfe `x' treatment1 treatment2 treatment3, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment1 treatment2 treatment3 if southern_states==1, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment1 treatment2 treatment3 if southern_states==0, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    esttab using "Table2_disctreatment_`x'.tex", replace ///
        keep(treatment1 treatment2 treatment3) b(5) se(3) ///
        mtitles("All" "Southern" "Non-Southern") ///
        title("`x'") ///
        star(* 0.10 ** 0.05 *** 0.01)
}

*--------------------- 2C) Single dummy treatment --------------------*
foreach x of local possible_outcomes {
    eststo clear

    eststo: reghdfe `x' treatment_dummy, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment_dummy if southern_states==1, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' treatment_dummy if southern_states==0, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    esttab using "Table3_dummytreatment_`x'.tex", replace ///
        keep(treatment_dummy) b(5) se(3) ///
        mtitles("All" "Southern" "Non-Southern") ///
        title("`x'") ///
        star(* 0.10 ** 0.05 *** 0.01)
}

*======================================================================*
*                        Additional Analysis                           *
*======================================================================*

*------------------------- 3D) Trend specifications ------------------*
* Cohort variable is birth_year. Interactions implement:
*   (1) County-specific cohort trends: cntyres × linear(birth_year)
*   (2) County-specific year trends  : same linear slope per county
*   (3) State-specific cohort FE     : stateres × birth_year dummies

foreach x of local possible_outcomes {
    eststo clear

    * (1) County-specific cohort trends (plus county & cohort FE)
    eststo: reghdfe `x' treatment i.county_id_destring#c.birth_year, ///
        absorb(cntyres birth_year) ///
        vce(cluster cntyres)

    * (2) County-specific year trends (linear)
    eststo: reghdfe `x' treatment i.county_id_destring#c.year, ///
        absorb(cntyres birth_year) ///
        vce(cluster cntyres)

    * (3) State-specific cohort FE (state×year dummies) + county FE
    eststo: reghdfe `x' treatment i.stateres_destring#i.birth_year, ///
        absorb(cntyres) ///
        vce(cluster cntyres)

    esttab using "SuppTable1_disctreatment_`x'.tex", replace ///
        keep(treatment) b(5) se(3) ///
        mtitles("County-Specific Cohort Trends" ///
                "County-Specific Year Trends"  ///
                "State-Specific Cohort FE")   ///
        title("`x'") ///
        star(* 0.10 ** 0.05 *** 0.01)
}

*---------------------- 3E) Heterogeneity analysis -------------------*
* Interaction with dissimilarity index (variable: diss)
foreach x of local possible_outcomes {
    eststo clear

    eststo: reghdfe `x' diss_treatment_dummy treatment_dummy diss, ///
        absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' diss_treatment_dummy treatment_dummy diss ///
        if southern_states==1, absorb(cntyres birth_year) vce(cluster cntyres)

    eststo: reghdfe `x' diss_treatment_dummy treatment_dummy diss ///
        if southern_states==0, absorb(cntyres birth_year) vce(cluster cntyres)

    esttab using "SuppTable2_dummytreatment_`x'.tex", replace ///
        keep(diss_treatment_dummy treatment_dummy diss) b(5) se(3) ///
        mtitles("All" "Southern" "Non-Southern") ///
        title("`x'") ///
        star(* 0.10 ** 0.05 *** 0.01)
}

* log close 
log close 
