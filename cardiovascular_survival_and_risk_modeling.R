############################################################
# Cardiovascular Data Analysis
# Real Dataset: UCI Cleveland Heart Disease
# Author: Evelyn Tadlock
############################################################

###=========================================================
### Load libraries
###=========================================================
library(tidyverse)
library(caret)
library(randomForest)
library(pROC)
library(viridis)
library(scales)
library(survival)
library(broom)
library(patchwork)

set.seed(123)

###=========================================================
### GLOBAL POSTER THEME
###=========================================================
poster_theme <- function(base_size = 18) {
  theme_classic(base_size = base_size) +
    theme(
      plot.title = element_text(size = 22, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 16, hjust = 0.5),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12),
      legend.position = "top",
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

###=========================================================
### Load dataset
###=========================================================
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/processed.cleveland.data"

heart <- read.csv(
  url,
  header = FALSE,
  stringsAsFactors = FALSE
)

colnames(heart) <- c(
  "age", "sex", "cp", "trestbps", "chol", "fbs",
  "restecg", "thalach", "exang", "oldpeak",
  "slope", "ca", "thal", "cv_event"
)

###=========================================================
### Cleaning
###=========================================================
heart[heart == "?"] <- NA
heart <- na.omit(heart)

heart <- heart %>%
  mutate(across(everything(), as.numeric))

heart$cv_event <- ifelse(heart$cv_event > 0, 1, 0)

heart <- heart %>%
  mutate(
    cv_event = factor(cv_event, levels = c(0, 1), labels = c("No", "Yes")),
    sex = factor(sex, levels = c(0, 1), labels = c("Female", "Male")),
    cp = factor(cp),
    fbs = factor(fbs),
    restecg = factor(restecg),
    exang = factor(exang),
    slope = factor(slope),
    ca = factor(ca),
    thal = factor(thal)
  )

cat("Cleaned dataset dimensions:\n")
print(dim(heart))

cat("\nOutcome distribution:\n")
print(table(heart$cv_event))

###=========================================================
### Train/Test Split
###=========================================================
train_index <- createDataPartition(heart$cv_event, p = 0.7, list = FALSE)
train_data <- heart[train_index, ]
test_data  <- heart[-train_index, ]

###=========================================================
### Logistic Regression
###=========================================================
log_model <- glm(
  cv_event ~ .,
  data = train_data,
  family = binomial
)

log_probs <- predict(log_model, newdata = test_data, type = "response")
log_class <- ifelse(log_probs > 0.5, "Yes", "No")
log_class <- factor(log_class, levels = c("No", "Yes"))

log_roc <- roc(
  response = test_data$cv_event,
  predictor = log_probs,
  levels = c("No", "Yes"),
  direction = "<"
)

log_cm <- confusionMatrix(log_class, test_data$cv_event, positive = "Yes")

cat("\nLogistic Regression Summary:\n")
print(summary(log_model))

cat("\nLogistic Regression Confusion Matrix:\n")
print(log_cm)

cat("\nLogistic Regression AUC:\n")
print(auc(log_roc))

###=========================================================
### Random Forest
###=========================================================
rf_model <- randomForest(
  cv_event ~ .,
  data = train_data,
  ntree = 200,
  importance = TRUE
)

rf_probs <- predict(rf_model, newdata = test_data, type = "prob")[, "Yes"]
rf_class <- predict(rf_model, newdata = test_data, type = "response")

rf_roc <- roc(
  response = test_data$cv_event,
  predictor = rf_probs,
  levels = c("No", "Yes"),
  direction = "<"
)

rf_cm <- confusionMatrix(rf_class, test_data$cv_event, positive = "Yes")

cat("\nRandom Forest Model:\n")
print(rf_model)

cat("\nRandom Forest Confusion Matrix:\n")
print(rf_cm)

cat("\nRandom Forest AUC:\n")
print(auc(rf_roc))

###=========================================================
### Confusion Matrix Plot
###=========================================================
cm_rf_df <- as.data.frame(rf_cm$table)

rf_cm_plot <- ggplot(cm_rf_df, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = Freq), size = 6, fontface = "bold") +
  scale_fill_viridis(option = "D") +
  labs(
    title = "Random Forest Confusion Matrix",
    x = "Actual",
    y = "Predicted",
    fill = "Count"
  ) +
  poster_theme()

print(rf_cm_plot)

ggsave(
  filename = "confusion_matrix.png",
  plot = rf_cm_plot,
  width = 6,
  height = 6,
  dpi = 600
)

###=========================================================
### Mirrored Density Plot
###=========================================================
density_plot <- ggplot(heart, aes(x = age, fill = cv_event)) +
  geom_density(
    data = subset(heart, cv_event == "Yes"),
    aes(y = after_stat(density)),
    alpha = 0.6
  ) +
  geom_density(
    data = subset(heart, cv_event == "No"),
    aes(y = -after_stat(density)),
    alpha = 0.6
  ) +
  geom_hline(yintercept = 0, color = "gray40") +
  scale_fill_viridis_d(option = "D") +
  labs(
    title = "Age Distribution and Cardiovascular Risk",
    subtitle = "Older patients show higher event density",
    x = "Age",
    y = "Density",
    fill = "Event"
  ) +
  annotate("text", x = max(heart$age) - 5, y = 0.025, label = "Event = Yes", size = 5, hjust = 1) +
  annotate("text", x = max(heart$age) - 5, y = -0.025, label = "Event = No", size = 5, hjust = 1) +
  poster_theme()

print(density_plot)

ggsave(
  filename = "density.png",
  plot = density_plot,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### ROC Curve Plot
###=========================================================
roc_plot <- ggplot() +
  geom_line(
    aes(x = 1 - log_roc$specificities, y = log_roc$sensitivities, color = "Logistic Regression"),
    linewidth = 1.5
  ) +
  geom_line(
    aes(x = 1 - rf_roc$specificities, y = rf_roc$sensitivities, color = "Random Forest"),
    linewidth = 1.5
  ) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  scale_color_viridis_d(option = "D") +
  labs(
    title = "ROC Curve Comparison",
    subtitle = "Classification performance for cardiovascular event prediction",
    x = "False Positive Rate",
    y = "True Positive Rate",
    color = "Model"
  ) +
  annotate(
    "text",
    x = 0.62,
    y = 0.22,
    label = paste0(
      "Logistic AUC = ", round(as.numeric(auc(log_roc)), 3),
      "\nRandom Forest AUC = ", round(as.numeric(auc(rf_roc)), 3)
    ),
    size = 5,
    fontface = "italic",
    hjust = 0
  ) +
  poster_theme()

print(roc_plot)

ggsave(
  filename = "roc.png",
  plot = roc_plot,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### Variable Importance Plot
###=========================================================
imp_df <- as.data.frame(importance(rf_model))
imp_df$Feature <- rownames(imp_df)

importance_plot <- imp_df %>%
  arrange(desc(MeanDecreaseGini)) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = reorder(Feature, MeanDecreaseGini), y = MeanDecreaseGini, fill = Feature)) +
  geom_col(width = 0.8) +
  coord_flip() +
  scale_fill_viridis_d(option = "D") +
  labs(
    title = "Top Predictors of Cardiovascular Risk",
    subtitle = "Random Forest Variable Importance",
    x = "Feature",
    y = "Mean Decrease in Gini"
  ) +
  poster_theme() +
  theme(legend.position = "none")

print(importance_plot)

ggsave(
  filename = "importance.png",
  plot = importance_plot,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### Clinical Proportion Plot
###=========================================================
prop_plot <- heart %>%
  count(exang, cv_event) %>%
  group_by(exang) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = factor(exang), y = prop, fill = cv_event)) +
  geom_col(position = "fill", width = 0.65) +
  scale_fill_viridis_d(option = "D") +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "Event Rate by Exercise-Induced Angina",
    subtitle = "Clinical event proportions by angina status",
    x = "Exercise-Induced Angina",
    y = "Proportion",
    fill = "Event"
  ) +
  poster_theme()

print(prop_plot)

ggsave(
  filename = "proportion.png",
  plot = prop_plot,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### Simulated Survival Data
###=========================================================
# This dataset has no true time-to-event variable.
# Time is simulated only to demonstrate survival methods.

heart$time <- rexp(nrow(heart), rate = 0.01)
heart$status <- ifelse(heart$cv_event == "Yes", 1, 0)

###=========================================================
### Cox Proportional Hazards Model
###=========================================================
cox_model <- coxph(
  Surv(time, status) ~ age + chol + trestbps + thalach + oldpeak,
  data = heart
)

cox_summary <- summary(cox_model)

cat("\nCox Proportional Hazards Summary:\n")
print(cox_summary)

###=========================================================
### Survival Results Table
###=========================================================
surv_results <- data.frame(
  Variable = rownames(cox_summary$coefficients),
  HR = exp(cox_summary$coefficients[, "coef"]),
  CI_Lower = cox_summary$conf.int[, "lower .95"],
  CI_Upper = cox_summary$conf.int[, "upper .95"],
  p_value = cox_summary$coefficients[, "Pr(>|z|)"]
)

cat("\nSurvival Results:\n")
print(surv_results)

write.csv(surv_results, "survival_results.csv", row.names = FALSE)

###=========================================================
### Forest Plot
###=========================================================
forest_df <- surv_results %>%
  mutate(Variable = factor(Variable, levels = rev(Variable)))

forest_plot <- ggplot(forest_df, aes(x = Variable, y = HR)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper), width = 0.2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  coord_flip() +
  scale_y_log10() +
  labs(
    title = "Hazard Ratios for Cardiovascular Risk Factors",
    subtitle = "Cox Proportional Hazards Model",
    x = "Variable",
    y = "Hazard Ratio (log scale)"
  ) +
  poster_theme()

print(forest_plot)

ggsave(
  filename = "forest_plot.png",
  plot = forest_plot,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### Kaplan-Meier Curve Data
###=========================================================
km_fit <- survfit(Surv(time, status) ~ cv_event, data = heart)
km_df <- broom::tidy(km_fit)

###=========================================================
### Manual Risk Table Data
###=========================================================
risk_summary <- summary(km_fit, times = pretty(heart$time, n = 6))

risk_table <- data.frame(
  time = risk_summary$time,
  strata = risk_summary$strata,
  n_risk = risk_summary$n.risk
)

risk_table$strata <- factor(
  risk_table$strata,
  levels = c("cv_event=No", "cv_event=Yes")
)

###=========================================================
### Kaplan-Meier Plot
###=========================================================
km_plot <- ggplot(km_df, aes(x = time, y = estimate, color = strata)) +
  geom_step(linewidth = 1.5) +
  scale_color_viridis_d(
    option = "D",
    labels = c("No Event", "Event")
  ) +
  labs(
    title = "Kaplan-Meier Survival Curve",
    subtitle = "Time-to-event comparison with risk table",
    x = "Time",
    y = "Survival Probability",
    color = "Group"
  ) +
  poster_theme()

###=========================================================
### Manual Risk Table Plot
###=========================================================
risk_plot <- ggplot(risk_table, aes(x = time, y = strata, label = n_risk)) +
  geom_text(size = 5, fontface = "bold") +
  scale_y_discrete(labels = c("No Event", "Event")) +
  labs(
    x = "Time",
    y = "At Risk"
  ) +
  poster_theme(base_size = 12) +
  theme(
    legend.position = "none",
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 11),
    axis.text.y = element_text(size = 11)
  )

###=========================================================
### Combined Kaplan-Meier + Risk Table
###=========================================================
km_with_risk <- km_plot / risk_plot +
  plot_layout(heights = c(3, 1))

print(km_with_risk)

ggsave(
  filename = "km_with_risk_table.png",
  plot = km_with_risk,
  width = 11.77,
  height = 7.28,
  dpi = 300
)

###=========================================================
### Results Summary Tables
###=========================================================
model_results <- data.frame(
  Model = c("Logistic Regression", "Random Forest"),
  AUC = c(as.numeric(auc(log_roc)), as.numeric(auc(rf_roc)))
)

cat("\nModel Results:\n")
print(model_results)

write.csv(model_results, "model_results.csv", row.names = FALSE)

###=========================================================
### Session Info
###=========================================================
cat("\nSession Info:\n")
print(sessionInfo())