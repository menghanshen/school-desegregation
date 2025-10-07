# School Desegregation and Birth Outcomes

This README file contains instructions on how to replicate the results of the paper.

---

## 📁 Project Folders

The following diagram shows the high-level structure of the project:

```
Project/
├── README.pdf
├── code/
│   ├── master_file.do
│   ├── install_packages.do
│   ├── step1_build_dataset.do
│   ├── step2_clean_dataset.do
│   ├── step3_figure.do
│   └── step4_descriptive_regression.do
```

---

## Setup Instructions

Before running the code, update the global paths in the `master_file.do` to match your computer’s directory structure.  

If you set up your folders as in the diagram above, you only need to update the global variable:

```
$DISSERTATION
```

to point to the location of your **project folder**.

To run all code at once, execute the main do-file:

```
code/master_file.do
```

---

## Data Sources

| Dataset | Description | Use | Access |
|----------|--------------|-----|--------|
| **School Desegregation Timeline** | Contains information on school district names, desegregation timing, county names, and state names. | Used to calculate the number of treatment years. | Downloaded data from ["Desegregation and black dropout rates." American Economic Review 94.4 (2004): 919-943.](https://www.aeaweb.org/articles?id=10.1257/0002828042002679). |
| **FIPS Crosswalk Files** | Provides geographic code outlines linking NCHS state, county, and MSA codes with the corresponding NCHS codes. | Used to connect state and county info from the school desegregation data to NCHS codes. | Downloaded from [NBER website](https://www.nber.org/research/data/national-center-health-statistics-nchs-federal-information-processing-series-fips-state-county-and). |
| **Natality Dataset** | Provides demographic and health data for births occurring during the calendar year. | Provides outcome variables. | Downloaded from [NBER website](https://data.nber.org/nvss/natality/dta/). |

---

## Summary

This project examines the relationship between **school desegregation** and **birth outcomes**.  
The provided Stata scripts perform data preparation, cleaning, visualization, and regression analysis in sequence.  

---

**Author:** *Menghan Shen*  
**Contact:** *shenmenghan@gmail.com*  
**Last Updated:** *October 2025*
