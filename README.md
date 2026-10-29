# Retail Demand Intelligence: Flight Delay Prediction Project

Here is a project overview designed in the exact style, structure, and depth of your reference documentation, tailored specifically for your **Flight Delay Prediction** data science project:

---

## Table of contents

1. Overview
2. Key results
3. Features
4. Dataset
5. Dashboard preview
6. Getting started
7. Project structure
8. Pipeline targets
9. Tech stack
10. Validation and data-quality findings
11. Troubleshooting
12. Limitations
13. Roadmap
14. Acknowledgments
15. Author and license

---

## Overview

Most analytics dashboards describe what already happened to a flight network after the fact. This project answers the two operational questions an airline or airport control center actually has to act on before departure:

1. How likely is a given flight to suffer a delay of more than 15 minutes, and which models and features drive that prediction reliably?
2. How can we simulate and monitor incoming flight streams dynamically to visualize network-wide status breakdowns and carrier delay vulnerabilities in real time?

It does this on a comprehensive US domestic flight performance dataset containing real operational scheduling and delay quirks. Four machine learning models (Logistic Regression, Decision Tree, Random Forest, and XGBoost) are built, evaluated, and benchmarked against standard performance metrics using the `tidymodels` framework, and an interactive **R Shiny** dashboard (`Flightwise Analytics`) replays operational views with a clean modern interface.

The full workflow (ingest, clean, transform, feature engineer, model, evaluate, export, visualize) is structured cleanly inside a reproducible R project layout.

---

## Key results

### Model Performance & Comparison

Evaluated on a held-out test split, tree-based ensemble models captured non-linear relationships across carriers, routes, and scheduling patterns significantly better than linear baselines.

* **Logistic Regression:** Serves as the interpretable baseline model.
* **Decision Tree:** Provides transparent, rule-based splits for operational inspection.
* **Random Forest & XGBoost:** Delivered the strongest predictive performance on tabular flight metrics, optimized using ROC-AUC and confusion matrix validation.

To inspect performance metrics for your own run, check the outputs saved inside `output/` or inspect the metrics summary table.

---

## Features

* **Standardized Relational ETL:** Clean ingestion pipeline mapping raw scheduling variables into consistent data architecture.
* **Honest Benchmarking:** Rigorous train/test evaluation across multiple machine learning paradigms using `tidymodels`.
* **Advanced Feature Engineering:** Time-block categorization (morning, afternoon, evening, night), weekend/holiday proximity flags, and high-cardinality grouping of minor origin airports into `"OTHER"` to prevent overfitting.
* **Interactive Web Dashboard (`Flightwise Analytics`):** Built with Shiny, `bslib` (Flatly theme), and `plotly`, featuring real-time KPI value cards, status distribution breakdown charts, carrier delay comparisons, and filterable data tables via `DT`.
* **Reproducible Design:** Clean folder isolation (`data/`, `scripts/`, `output/`) ensuring seamless execution from raw CSV to final visualization.

---

## Dataset

US Domestic Flight On-Time Performance / Flight Status Datasets.

| Fact | Value |
| --- | --- |
| **Target Variable** | Binary classification (`delayed`: `yes` if arrival delay > 15 mins, `no` otherwise) |
| **Core Features** | Flight Date, Carrier Code, Origin Airport, Destination Airport, Scheduled Departure Time, Actual Departure Time, Departure Delay, Distance, Cancelled/Diverted status |
| **Recommended Sources** | US DOT / BTS On-Time Performance data or Kaggle Flight Status/Delay datasets (e.g., *Flight Delay Dataset 2024* or *Airlines Dataset to Predict a Delay*) |

*Note: Raw CSV files are stored locally under `data/flights.csv`.*

---

## Dashboard preview

* **Overview Tab:** Displays top-level KPI metrics cards tracking **Total flights**, **Delayed flights**, **Cancelled flights**, and **On-time flights**.
* **Visual Analytics:** Interactive distribution charts mapping flight statuses and carrier-specific delay rates.
* **Data Explorer:** Fully searchable, sortable, and filterable data grid containing all processed flight records.

---

## Getting started

### Prerequisites

* **R** (Version 4.4 or newer recommended)
* **RStudio Desktop**

### 1. Open the project

Clone or download the repository and open **`flight-delay-prediction.Rproj`** directly in RStudio to ensure relative paths and project environments resolve correctly.

### 2. Install required packages

Run the setup script to install all necessary dependencies:

```R
source("scripts/00_install_packages.R")

```

### 3. Add your dataset

Download your chosen flight dataset CSV file and place it inside the `data/` directory as **`data/flights.csv`**.

### 4. Run the pipeline scripts sequentially

Execute the processing scripts from `01` to `06` to process data, train models, and generate evaluations:

```R
source("scripts/01_import_data.R")
source("scripts/02_data_cleaning.R")
source("scripts/03_eda.R")
source("scripts/04_feature_engineering.R")
source("scripts/05_modeling.R")
source("scripts/06_evaluation.R")

```

### 5. Launch the interactive dashboard

To fire up the Shiny dashboard (`Flightwise Analytics`):

```R
shiny::runApp()

```

---

## Project structure

```text
flight-delay-prediction/
├── README.md
├── flight-delay-prediction.Rproj   <- Project workspace file
├── app.R                           <- Shiny dashboard application
├── data/
│   └── flights.csv                 <- Raw dataset (local)
├── scripts/
│   ├── 00_install_packages.R       <- Package dependency manager
│   ├── 01_import_data.R            <- Raw data ingestion & renaming
│   ├── 02_data_cleaning.R          <- Outlier handling & target creation
│   ├── 03_eda.R                    <- Exploratory data analysis & plots
│   ├── 04_feature_engineering.R    <- Time blocks, aggregations & formatting
│   ├── 05_modeling.R               <- Train/test split & model training (tidymodels)
│   └── 06_evaluation.R             <- Metrics computation, ROC & confusion matrix
├── output/                          <- Generated models, metrics, and visual plots
└── report.Rmd                      <- R Markdown source for compiled reports

```

---

## Tech stack

| Area | Tools & Libraries |
| --- | --- |
| **Language** | R |
| **Dashboard & UI** | Shiny, `bslib` (Flatly Bootstrap 5 theme), `plotly`, `DT` |
| **Data Wrangling** | `tidyverse` (`dplyr`, `ggplot2`, `readr`, `tidyr`), `lubridate`, `data.table`, `janitor` |
| **Machine Learning** | `tidymodels` (`rsample`, `recipes`, `parsnip`, `workflows`, `yardstick`), `randomForest`, `xgboost`, `rpart`, `vip` |
| **Reporting** | `rmarkdown`, `knitr` |

---

## Validation and data-quality findings

* **Cancelled & Diverted Filtering:** Removed upfront because flights that never departed cannot accrue a meaningful arrival delay value, preserving classification focus on active routes.
* **Outlier Capping:** Extreme data-entry anomalies (such as arrival delays exceeding 24 hours) were filtered out to stabilize model training.
* **High-Cardinality Management:** Grouping low-frequency origin airports into an `"OTHER"` category prevented tree models from overfitting on sparse route categories.

---

## Troubleshooting

* **Missing packages error:** Ensure you have sourced `scripts/00_install_packages.R` completely.
* **File path errors:** Always open RStudio via the `flight-delay-prediction.Rproj` file so relative project roots are respected.
* **CSV Column Mismatch:** If your dataset uses custom column names, adjust the `rename_map` array inside `scripts/01_import_data.R`.

---

## Limitations

* **Predictive Horizon:** Models rely strictly on information available prior to departure; unexpected in-flight weather shifts or mid-air congestion cannot be dynamically captured.
* **Imbalanced Classes:** On-time flights typically outnumber delayed flights, requiring careful threshold or metric evaluation (such as ROC-AUC and F1-score rather than raw accuracy alone).

---

## Roadmap

* Relational ETL and data cleaning pipeline
* Exploratory Data Analysis and automated plotting
* Multi-model training and evaluation via `tidymodels`
* Interactive R Shiny dashboard (`Flightwise Analytics`) integration
* Advanced hyperparameter tuning for XGBoost models
* Cloud deployment of the Shiny web application

---

## Acknowledgments

* The tidyverse and tidymodels core teams for building robust, elegant data science infrastructure in R.
* The open-source data community for providing accessible aviation and flight performance records.

---

## Author and license

Built by **Trilokesh (Reg. No.: 24BDS1095)**, Vellore Institute of Technology, as part of a computer science and data science project portfolio.

Released under the MIT License.
