FLIGHTWISE ANALYTICS — STARTER PROJECT

Files:
- app.R: initial R Shiny dashboard
- flight_delay_dataset_12000.csv: synthetic sample dataset (copy this file into this folder)

REQUIREMENTS:
Install R and RStudio Desktop. In RStudio, open this folder as a project or set it as the working directory.

FIRST RUN:
1. Open app.R in RStudio.
2. In the Console, install missing packages:
   install.packages(c("shiny","bslib","readr","dplyr","tidyr","janitor","ggplot2","plotly","DT","lubridate","skimr"))
3. Wait until all package installations finish.
4. Click Run App near the top of app.R.
5. If it says it cannot find the sample CSV, put flight_delay_dataset_12000.csv in the same folder as app.R.
6. Use Upload data to upload the CSV. Overview and Analytics charts update from the loaded data.

IMPORTANT:
- The included data is synthetic, not real airline information.
- This is Milestone 1: CSV upload, basic data quality checks, dashboard statistics and exploratory visualizations.
- Prediction models are not added yet. We will add them after confirming this starter app works and reviewing target columns carefully.
- Do not use outcome columns such as flight_status, is_cancelled, arrival_delay_min, cancellation_reason or actual_arrival as predictors when predicting future outcomes.
