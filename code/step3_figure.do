
*======================================================================*
* Project: School Desegregation and Infant Health Outcomes             *
*======================================================================*

*----------------------------------------------------------------------*
* Do-file Purpose: construct event-study figure                        *
*   Step 1: Explore outcomes using scatterplots                        *
*   Step 2: Examine outcomes using event-study figure                  *
*----------------------------------------------------------------------*
*version 16.0
clear all
macro drop all	
set more off
capture log close _all        

* ---- Open log ----
log using "$LOGS/step3_figure.log", text replace  

set more off

*======================================================================*
*                           Main Analysis                              *
*   Baseline FE: county (cntyres) & cohort (birth_year);               *
*   Standard errors clustered by county (cntyres).                     *
*   Outcomes: marriage, father, mother, prenatal, infant outcomes      *
*======================================================================*



*=========================== Outcomes ==============================*
local possible_outcomes ///
    married father_education father_age whitefather ///
    mother_education mother_age teenage ///
    early_prenatal ///
    preterm low_birthweight

	
*================ Check descriptive figure ================*
foreach y of local possible_outcomes {

use "$ANALYSIS/ready_black_analysis.dta", clear

collapse `y', by (treatment_years)	
	
twoway scatter `y' treatment_years, ///
            title("Scatterplot `y'") ///
            ytitle("Mean of `y'") ///
            xtitle("Relative years to desegregation (t)") ///
            name(descript_`y', replace)

        graph save   "descript_`y'.gph", replace
        graph export "descript_`y'.pdf", as(pdf) replace
}
	
*================ Event-time dummies: t in [-6, +12], binned tails ================*
* Uses treatment_years as the relative time (…,-2,-1,0,1,2,…)
* Baseline: t = 0  (omit _post0)

use "$ANALYSIS/ready_black_analysis.dta", clear

capture drop _pre* _post*

* Leads: exact bins for -1,-2,-3,-4,-5
forvalues i = 1/5 {
    gen byte _pre`i' = (treatment_years == -`i')
}

* Lead tail: t <= -6
gen byte _pre6 = (treatment_years <= -6)

* Lags: exact bins for +1 … +11
forvalues i = 1/11 {
    gen byte _post`i' = (treatment_years == `i')
}

* Lag tail: t >= +12
gen byte _post12 = (treatment_years >= 12)

*====================== 2) Loop over outcomes ========================*

foreach y of local possible_outcomes {

    estimates clear
    reghdfe `y' _pre* _post*, absorb(cntyres birth_year) vce(cluster cntyres)
    estimates store e1

    event_plot e1, ///
        stub_lag(_post#) ///
        stub_lead(_pre#) ///
        together trimlead(6) trimlag(12) noautolegend ///
        plottype(scatter) ciplottype(rspike) alpha(0.1) ///
        graph_opt( ///
            title("Event study: `y'", size(medlarge) color(black)) ///
            ytitle("Estimated effect") ///
            xtitle("Relative years to school desegregation") ///
            xlabel(-6 "≤ -6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" ///
                   1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" ///
                   10 "10" 11 "11" 12 "≥ 12") ///
            xline(-0.5, lc(gs8) lp(dash)) ///
            yline(0, lc(gs8) lp(dash)) ///
            legend(off) ///
            graphregion(fcolor(white)) ///
        )

    graph save "event_`y'.gph", replace
    graph export "event_`y'.pdf", as(pdf) replace
}

* log close 
log close 
