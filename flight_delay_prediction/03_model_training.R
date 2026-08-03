# 1. Load required libraries
library(tidyverse)
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)

# 2. Format columns as factors for classification
model_data <- cleaned_flights %>%
  mutate(
    IS_DELAYED  = factor(IS_DELAYED, levels = c("OnTime", "Delayed")),
    MONTH       = factor(MONTH),
    DAY_OF_WEEK = factor(DAY_OF_WEEK),
    TIME_OF_DAY = factor(TIME_OF_DAY),
    CARRIER     = factor(CARRIER),
    ORIGIN      = factor(ORIGIN),
    DEST        = factor(DEST)
  ) %>%
  drop_na()

# 3. Split dataset (80% Train, 20% Test)
set.seed(42)
train_index <- createDataPartition(model_data$IS_DELAYED, p = 0.80, list = FALSE)
train_set   <- model_data[train_index, ]
test_set    <- model_data[-train_index, ]

# 4. Train the 3 Models
log_model <- glm(IS_DELAYED ~ ., data = train_set, family = binomial)
dt_model  <- rpart(IS_DELAYED ~ ., data = train_set, method = "class")
rf_model  <- randomForest(IS_DELAYED ~ ., data = train_set, ntree = 100, importance = TRUE)

# 5. Generate Predictions
test_set <- test_set %>%
  mutate(
    pred_log_prob = predict(log_model, newdata = test_set, type = "response"),
    pred_log      = factor(ifelse(pred_log_prob > 0.5, "Delayed", "OnTime"), levels = c("OnTime", "Delayed")),
    pred_dt       = predict(dt_model, newdata = test_set, type = "class"),
    pred_rf       = predict(rf_model, newdata = test_set)
  )

# 6. Evaluate Models and Output Summary Table
cm_log <- confusionMatrix(test_set$pred_log, test_set$IS_DELAYED, positive = "Delayed")
cm_dt  <- confusionMatrix(test_set$pred_dt, test_set$IS_DELAYED, positive = "Delayed")
cm_rf  <- confusionMatrix(test_set$pred_rf, test_set$IS_DELAYED, positive = "Delayed")

comparison_table <- tibble(
  Model       = c("Logistic Regression", "Decision Tree", "Random Forest"),
  Accuracy    = c(cm_log$overall["Accuracy"], cm_dt$overall["Accuracy"], cm_rf$overall["Accuracy"]),
  Sensitivity = c(cm_log$byClass["Sensitivity"], cm_dt$byClass["Sensitivity"], cm_rf$byClass["Sensitivity"]),
  Specificity = c(cm_log$byClass["Specificity"], cm_dt$byClass["Specificity"], cm_rf$byClass["Specificity"])
)

print(comparison_table)

# 7. Generate Diagnostic Plots
rpart.plot(dt_model, main = "Decision Tree Structure")
varImpPlot(rf_model, main = "Feature Importance")
