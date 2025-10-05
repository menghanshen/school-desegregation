/********************************************************************
 master_file.do
 -------------------------------------------------------------------
 Purpose: Reproducible pipeline to run the School Desegregation project
 Stata version: 16
********************************************************************/

version 16.0
clear all
set more off
set linesize 80
capture log close _all

/********************************************************************
 1. DEFINE PROJECT PATHS
********************************************************************/

// Adjust only this path to your local project folder
global PROJECT "/Users/yourname/path/to/project_root"

// Define subfolders
global CODE      "$PROJECT/src/stata"
global DATA_RAW  "$PROJECT/data/raw"
global DATA_PROC "$PROJECT/data/processed"
global OUT_FIG   "$PROJECT/output/figures"
global OUT_TAB   "$PROJECT/output/tables"
global LOGS      "$PROJECT/output/logs"

// Create folders if missing
cap mkdir "$DATA_PROC"
cap mkdir "$OUT_FIG"
cap mkdir "$OUT_TAB"
cap mkdir "$LOGS"

/********************************************************************
 2. OPEN MASTER LOG
********************************************************************/
log using "$LOGS/master.log", replace text

display as result "-----------------------------------------------------------"
display as result " Starting School Desegregation & Birth Outcomes pipeline"
display as result "-----------------------------------------------------------"

/********************************************************************
 3. RUN PIPELINE SEQUENTIALLY
********************************************************************/

display as text ">>> STEP 1: Build dataset"
capture noisily do "$CODE/step1_build_dataset.do"
if _rc != 0 {
    display as error "Step 1 failed with return code = " _rc
    error _rc
}

display as text ">>> STEP 2: Prepare subgroup data (Black)"
capture noisily do "$CODE/step2_preparedata_black.do"
if _rc != 0 {
    display as error "Step 2 failed with return code = " _rc
    error _rc
}

display as text ">>> STEP 3: Create figures (lags)"
capture noisily do "$CODE/step3_graph_lags.do"
if _rc != 0 {
    display as error "Step 3 failed with return code = " _rc
    error _rc
}

display as text ">>> STEP 4: Run regressions"
capture noisily do "$CODE/step4_regression_1005.do"
if _rc != 0 {
    display as error "Step 4 failed with return code = " _rc
    error _rc
}

/********************************************************************
 4. CLOSE LOG AND WRAP UP
********************************************************************/
display as result "-----------------------------------------------------------"
display as result " All steps completed successfully!"
display as result " Outputs saved in: "
display as result "   Figures  → $OUT_FIG"
display as result "   Tables   → $OUT_TAB"
display as result "   Logs     → $LOGS"
display as result "-----------------------------------------------------------"

log close
exit, clear
