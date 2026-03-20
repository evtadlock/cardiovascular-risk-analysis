# Cardiovascular Risk Analysis

This project analyzes the UCI Cleveland Heart Disease dataset to study predictors of cardiovascular events using machine learning and statistical modeling.

---

## Project Overview

The goal is to identify key clinical variables associated with cardiovascular risk and evaluate predictive model performance.

The analysis includes:

* Logistic Regression (baseline model)
* Random Forest (nonlinear model)
* ROC curve comparison (AUC evaluation)
* Confusion matrix visualization
* Feature importance ranking
* Clinical proportion analysis
* Exploratory survival analysis (Kaplan-Meier + Cox model)

---

## Clinical Relevance

This project demonstrates how clinical variables can be translated into interpretable risk predictions.

Applications include:

* Early identification of high-risk patients
* Supporting preventative care strategies
* Assisting clinical decision-making with data-driven insights

---

## Dataset

UCI Cleveland Heart Disease Dataset
https://archive.ics.uci.edu/ml/datasets/heart+disease

The dataset includes:

* Age
* Cholesterol
* Blood pressure
* Maximum heart rate
* Exercise-induced angina
* ST depression

Outcome variable:

* Presence of cardiovascular disease (binary)

---

## Key Results

* Random Forest achieved higher AUC compared to Logistic Regression
* Age and exercise-related variables show strong association with cardiovascular risk
* Feature importance highlights nonlinear relationships
* Confusion matrix shows improved classification balance

---

## Example Outputs

(Add screenshots here after upload)

```
figures/roc.png  
figures/confusion_matrix.png  
figures/importance.png  
figures/km_plot.png  
```

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

## Requirements

* R (>= 4.0)
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
M.S. Data Science & Informatics
Texas Woman’s University

---

## Notes

This project focuses on model interpretability, performance evaluation, and clinical insight generation using real-world healthcare data.
