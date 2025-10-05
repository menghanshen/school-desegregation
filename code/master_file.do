/********************************************************************
 master_file.do
 -------------------------------------------------------------------
 Purpose: Reproducible pipeline to run the School Desegregation project
 Stata version: 16
********************************************************************/

version 16.0
clear all
set more off
capture log close _all

/********************************************************************
 1. DEFINE PROJECT PATHS
********************************************************************/

// Adjust only this path to local project folder
global PROJECT "YOUR PROJECT FOLDER"
 
// Define subfolders
global RAW            "$PROJECT/data/raw"
global PROC           "$PROJECT/data/processed"
global ANALYSIS       "$PROJECT/data/analysis"
global LOGS           "$PROJECT/outputs/logs"
global RESULTS        "$PROJECT/outputs/results"

* dofile directory
cd "$PROJECT/code"


/********************************************************************
 2. RUN PIPELINE SEQUENTIALLY
********************************************************************/


*------------------------------------------------------
* Run setup and main scripts
*------------------------------------------------------
do "install_packages.do"

*------------------------------------------------------
* Data processing steps
*------------------------------------------------------
do "step1_build_dataset.do"
do "step2_clean_dataset.do"

*------------------------------------------------------
* Analysis and outputs
*------------------------------------------------------
do "step3_figure.do"
do "step4_descriptive_regression.do"

*******************************************************
* End of master do-file
*******************************************************
