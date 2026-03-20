# Cardiovascular Risk Analysis

This project analyzes the UCI Cleveland Heart Disease dataset to study predictors of cardiovascular events using classification models and exploratory survival analysis.

---

## Project Overview

The goal is to understand which clinical features are most associated with cardiovascular risk and evaluate model performance for prediction.

The analysis includes:

* Logistic Regression (baseline model)
* Random Forest (nonlinear model)
* ROC curve comparison (AUC evaluation)
* Confusion matrix visualization
* Feature importance ranking
* Clinical proportion analysis
* Exploratory survival analysis (Kaplan-Meier + Cox model)

---

## Dataset

UCI Cleveland Heart Disease Dataset
https://archive.ics.uci.edu/ml/datasets/heart+disease

The dataset contains patient-level clinical variables such as:

* Age
* Cholesterol
* Blood pressure
* Maximum heart rate
* Exercise-induced angina
* ST depression (oldpeak)

The outcome variable is whether a cardiovascular event is present.

---

## Key Results

* Random Forest achieved higher AUC compared to Logistic Regression
* Age, cholesterol, and exercise-related variables show strong association with risk
* Feature importance highlights nonlinear relationships not captured by logistic regression
* Confusion matrix shows improved classification balance in Random Forest

---

## Survival Analysis Note

The dataset does not include time-to-event data.

A simulated time variable was generated to demonstrate:

* Kaplan-Meier survival curves
* Cox proportional hazards modeling
* Risk table construction

These results are included for methodological demonstration only.

---

## Files

* cardiovascular_analysis_full_notebook.Rmd
* cardiovascular_analysis_full_notebook.html

---

## How to Run

1. Open the `.Rmd` file in RStudio
2. Install required packages if needed
3. Click **Knit → HTML**

---

## Tools Used

* R
* tidyverse
* caret
* randomForest
* pROC
* survival
* ggplot2
* patchwork

---

## Author

Evelyn Tadlock


---

## Notes

This project focuses on model comparison, interpretability, and visualization of clinical risk factors. It is intended as a portfolio piece demonstrating applied machine learning and statistical analysis in healthcare data.
