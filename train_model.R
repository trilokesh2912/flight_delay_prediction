library(readr)
library(dplyr)
library(ranger)

flights <- read_csv("flight_delay_dataset_12000.csv", show_col_types = FALSE)

model_data <- flights |>
  filter(flight_status != "Cancelled") |>
  mutate(
    delayed = factor(
      ifelse(arrival_delay_min >= 15, "Delayed", "Not Delayed"),
      levels = c("Not Delayed", "Delayed")
    ),
    airline = as.factor(airline),
    origin_airport = as.factor(origin_airport),
    destination_airport = as.factor(destination_airport),
    weather_condition = as.factor(weather_condition),
    day_of_week = as.factor(day_of_week),
    departure_hour = as.integer(substr(scheduled_departure, 1, 2))
  ) |>
  select(
    delayed,
    airline,
    origin_airport,
    destination_airport,
    weather_condition,
    day_of_week,
    departure_hour,
    distance_km,
    scheduled_duration_min,
    is_peak_hour
  ) |>
  na.omit()

set.seed(123)
train_rows <- sample(
  seq_len(nrow(model_data)),
  size = floor(0.8 * nrow(model_data))
)

train_data <- model_data[train_rows, ]
test_data <- model_data[-train_rows, ]

delay_model <- ranger(
  delayed ~ .,
  data = train_data,
  num.trees = 300,
  probability = TRUE,
  importance = "impurity",
  seed = 123
)

predictions <- predict(delay_model, data = test_data)$predictions
predicted_class <- colnames(predictions)[
  max.col(predictions, ties.method = "first")
]
actual_class <- as.character(test_data$delayed)

confusion_matrix <- table(
  Actual = actual_class,
  Predicted = predicted_class
)
print(confusion_matrix)

accuracy <- mean(predicted_class == actual_class)
cat("Test accuracy:", round(accuracy * 100, 2), "%\n")

importance <- sort(
  delay_model$variable.importance,
  decreasing = TRUE
)
print(importance)

saveRDS(delay_model, "flight_delay_model.rds")