# School Desegregation and Birth Outcomes

This README file contains instructions on how to replicate the results of the project.

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

| Dataset | Description | Input Format | Output Format | Use | Access |
|----------|--------------|--------------|---------------|-----|--------|
| **School Desegregation Timeline** | Contains information on school district names, desegregation timing, county names, and state names. | School district level | County level | Used to calculate the number of treatment years. | Downloaded data from [*Guryan.* (2004). *"Desegregation and Black Dropout Rates."* *American Economic Review*, 94(4), 919–943.](https://www.aeaweb.org/articles?id=10.1257/0002828042002679) |
| **FIPS Crosswalk Files** | Provides geographic code outlines linking NCHS state, county, and MSA codes with the corresponding NCHS codes. | County level | County level | Used to connect state and county info from the school desegregation data to NCHS codes. | Downloaded from [NBER website](https://www.nber.org/research/data/national-center-health-statistics-nchs-federal-information-processing-series-fips-state-county-and). |
| **Natality Dataset** | Provides demographic and health data for births occurring during the calendar year. | Individual level | Individual level | Provides outcome variables. | Downloaded from [NBER website](https://data.nber.org/nvss/natality/dta/). |

---
## Research Project: School Desegregation and Birth Outcomes

## Background 

This project examines the relationship between **school desegregation** and **birth outcomes**.

In the United States, a Black infant is twice as likely as a White infant to be born prematurely. Preterm birth is a major determinant of health complications in infants (Moster et al., 2008). It can present significant emotional and economic costs for families and societies (Butler et al., 2007). It is also correlated with lower educational attainment and lower earnings later in life (Behrman and Rosenzweig, 2002; Currie and Hyson, 1999; Moster et al., 2008).

The multitude of negative consequences of preterm births makes the cause of the disparity in preterm birth rates between Black and White infants a pressing question for research and policy. Evidence suggests that segregation is one of the leading causes of inequality in health (Almond et al., 2006; Williams and Collins, 2001; Osypuk and Acevedo-Garcia, 2008).

## Research Question 

This project aims to examine whether **school desegregation affects the health of infants born to Black mothers**.  

The staggered rollout of court-ordered school desegregation provides a quasi-experimental setting to identify the causal effects of school desegregation on intergenerational outcomes.

## Method

- **Data Source:** Individual-level birth certificate data providing information on parental characteristics and infant health.  
- **Design:** Exploits county and cohort variation, leveraging differences in implementation timing across counties and exposure to desegregated schools across cohorts.  

## Key Findings

- In Southern counties, school desegregation **improves infant health** among Black mothers.  
- Desegregation increases:
  - The probability of **biracial births**  
  - **Maternal education** at birth  
  - **Prenatal visits** in the first trimester  
- Desegregation decreases:
  - The probability that the **father is a teenager**  
- Counties with higher initial Black enrollment experience **larger gains** among Black populations, suggesting that **increased per-pupil funding** plays a significant role in improving maternal education and infant health.

## References

- Shen, M. (2018). *The effects of school desegregation on infant health.* **Economics & Human Biology, 30**, 104–118.  
- Shen, M. (2018). *How I met your mother: The effect of school desegregation on birth outcomes.* **Economics of Education Review, 63**, 31–50.  

---


**Author:** *Menghan Shen*  
**Contact:** *shenmenghan@gmail.com*  
**Last Updated:** *October 2025*
