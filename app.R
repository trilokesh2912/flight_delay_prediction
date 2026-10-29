library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(ranger)
library(bslib)
library(DT)

# Load dataset and model
flights <- read_csv("flight_delay_dataset_12000.csv", show_col_types = FALSE)
model <- readRDS("flight_delay_model.rds")

# Modern dark mode professional theme
app_theme <- bs_theme(
  version = 5,
  bootswatch = "darkly",
  primary = "#3498db",
  success = "#2ecc71",
  warning = "#f39c12",
  danger = "#e74c3c",
  "font-base-sans" = "system-ui, -apple-system, sans-serif"
)

ui <- page_navbar(
  title = tags$span(tags$b("✈️ Flight Delay Prediction Model"), style = "color: white; font-size: 18px;"),
  theme = app_theme,
  bg = "#111827",
  inverse = TRUE,
  
  # Custom CSS for dark theme styling & side-by-side layout spacing
  header = tags$head(
    tags$style(HTML("
      body { background-color: #0f172a; color: #f8fafc; }
      .navbar { box-shadow: 0 4px 6px rgba(0,0,0,0.3); background-color: #1e293b !important; }
      .card { border-radius: 14px; box-shadow: 0 6px 15px rgba(0,0,0,0.3); border: 1px solid #334155; margin-bottom: 20px; background: #1e293b; color: #f8fafc; }
      .card-header { background-color: #1e293b; font-weight: bold; font-size: 16px; border-bottom: 1px solid #334155; border-radius: 14px 14px 0 0 !important; padding: 12px 18px; color: #38bdf8; }
      .kpi-card { background: #1e293b; border: 1px solid #334155; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 15px; }
      .kpi-title { font-size: 13px; color: #94a3b8; font-weight: 600; text-transform: uppercase; }
      .kpi-value { font-size: 28px; font-weight: bold; color: #f8fafc; margin-top: 5px; }
      .well { background-color: #1e293b; border-radius: 14px; border: 1px solid #334155; box-shadow: 0 4px 10px rgba(0,0,0,0.3); padding: 20px; color: #f8fafc; }
      .btn-primary { background-color: #2563eb; border: none; border-radius: 8px; font-weight: 600; padding: 10px; }
      .btn-primary:hover { background-color: #1d4ed8; }
      .form-control, .selectize-input { background-color: #0f172a !important; color: #f8fafc !important; border-color: #334155 !important; }
      .dataTables_wrapper { color: #f8fafc !important; }
      table.dataTable tbody tr { background-color: #1e293b !important; color: #f8fafc !important; }
    "))
  ),
  
  # --- TAB 1: EXECUTIVE DASHBOARD ---
  nav_panel("Dashboard",
            # Top KPI Summary Cards
            layout_column_wrap(
              width = "220px",
              div(class = "kpi-card", div(class = "kpi-title", "Total Flights"), div(class = "kpi-value", textOutput("total_flights"))),
              div(class = "kpi-card", div(class = "kpi-title", "Delayed (15m+)"), div(class = "kpi-value", style = "color: #f39c12;", textOutput("delayed_flights"))),
              div(class = "kpi-card", div(class = "kpi-title", "Cancelled Flights"), div(class = "kpi-value", style = "color: #e74c3c;", textOutput("cancelled_flights"))),
              div(class = "kpi-card", div(class = "kpi-title", "Avg Arrival Delay"), div(class = "kpi-value", style = "color: #38bdf8;", textOutput("avg_delay")))
            ),
            br(),
            
            # Row 1: Side-by-Side Charts
            layout_column_wrap(
              width = 1/2,
              card(card_header("📊 Arrival Delay Distribution"), div(style = "padding: 10px;", plotOutput("delay_chart", height = "360px"))),
              card(card_header("✈️ Average Delay by Airline"), div(style = "padding: 10px;", plotOutput("airline_chart", height = "360px")))
            ),
            
            # Row 2: Side-by-Side Charts
            layout_column_wrap(
              width = 1/2,
              card(card_header("❌ Cancelled Flights by Airline"), div(style = "padding: 10px;", plotOutput("cancellation_chart", height = "360px"))),
              card(card_header("🗺️ Top 10 Busiest Flight Routes"), div(style = "padding: 10px;", plotOutput("route_chart", height = "360px")))
            )
  ),
  
  # --- TAB 2: AI PREDICT DELAY ---
  nav_panel("Predict Delay",
            sidebarLayout(
              sidebarPanel(
                class = "well",
                h4("Flight Parameters", style = "color: #38bdf8; font-weight: bold; margin-bottom: 15px;"),
                selectInput("pred_airline", "Airline:", choices = unique(flights$airline)),
                selectInput("pred_origin", "Origin Airport:", choices = unique(flights$origin_airport)),
                selectInput("pred_dest", "Destination Airport:", choices = unique(flights$destination_airport)),
                selectInput("pred_weather", "Weather Condition:", choices = unique(flights$weather_condition)),
                selectInput("pred_dow", "Day of Week:", choices = unique(flights$day_of_week)),
                sliderInput("pred_hour", "Departure Hour (0-23):", min = 0, max = 23, value = 18),
                numericInput("pred_duration", "Scheduled Duration (min):", value = 120, min = 20, max = 600),
                checkboxInput("pred_peak", "Is Peak Hour Traffic?", value = TRUE),
                
                # Auto-calculated distance UI banner
                hr(style = "border-color: #334155;"),
                tags$div(
                  style = "background-color: #0f172a; padding: 12px; border-radius: 8px; border: 1px solid #334155;",
                  tags$span(style = "color: #94a3b8; font-size: 13px;", "Auto-Calculated Distance: "),
                  tags$strong(style = "color: #38bdf8; font-size: 15px;", textOutput("auto_distance_display", inline = TRUE))
                ),
                br(),
                actionButton("predict_btn", "Calculate Delay Risk", class = "btn-primary w-100 mt-2")
              ),
              mainPanel(
                card(
                  card_header("🤖 Machine Learning Prediction Output"),
                  div(style = "padding: 20px;",
                      verbatimTextOutput("prediction_output")
                  ),
                  br(),
                  tags$div(
                    class = "alert alert-warning",
                    style = "border-radius: 10px; background-color: #78350f; color: #fef3c7; border: none;",
                    strong("Disclaimer: "),
                    "Predictions are generated using a Random Forest model trained on flight records (~68.47% test accuracy). Distance is automatically mapped from origin-destination historical routes."
                  )
                )
              )
            )
  ),
  
  # --- TAB 3: FLIGHT EXPLORER ---
  nav_panel("Flight Explorer",
            card(
              card_header("🔍 Searchable Flight Database"),
              div(style = "padding: 15px;",
                  DT::DTOutput("flight_table")
              )
            )
  ),
  
  # --- TAB 4: DATA QUALITY AUDIT ---
  nav_panel("Data Quality",
            card(
              card_header("🛡️ Dataset Missing Values Audit"),
              div(style = "padding: 15px;",
                  tableOutput("missing_summary")
              )
            )
  ),
  
  # --- TAB 5: ABOUT PROJECT ---
  nav_panel("About Project",
            card(
              card_header("📖 Project Overview & Methodology"),
              div(style = "padding: 25px; line-height: 1.6;",
                  h4("Flight Delay Prediction Model", style = "color: #38bdf8;"),
                  p("This application is an end-to-end data science dashboard built in R using Shiny and Machine Learning."),
                  tags$ul(
                    h5(strong("Key Technologies Used:")),
                    tags$li("R & Shiny for reactive web application framework."),
                    tags$li("dplyr & readr for data wrangling and route distance calculation."),
                    tags$li("ranger (Random Forest) for predictive machine learning (~68.47% accuracy)."),
                    tags$li("ggplot2 & bslib for professional dark-mode UI design."),
                    tags$li("DT for interactive searchable data tables.")
                  )
              )
            )
  )
)

server <- function(input, output, session) {
  
  # Dashboard KPI metrics
  output$total_flights <- renderText({ nrow(flights) })
  output$delayed_flights <- renderText({ sum(flights$arrival_delay_min >= 15, na.rm = TRUE) })
  output$cancelled_flights <- renderText({ sum(flights$flight_status == "Cancelled", na.rm = TRUE) })
  output$avg_delay <- renderText({ paste(round(mean(flights$arrival_delay_min, na.rm = TRUE), 1), "mins") })
  
  # Reactive Distance Calculator based on Origin & Destination
  calculated_distance <- reactive({
    route_data <- flights %>% 
      filter(origin_airport == input$pred_origin & destination_airport == input$pred_dest)
    
    if (nrow(route_data) > 0 && !is.na(mean(route_data$distance_km, na.rm = TRUE))) {
      return(round(mean(route_data$distance_km, na.rm = TRUE), 1))
    } else {
      return(850.0) # Fallback distance if route combination isn't found
    }
  })
  
  # Display auto-calculated distance in sidebar
  output$auto_distance_display <- renderText({
    paste(calculated_distance(), "km")
  })
  
  # Side-by-side formatted charts
  output$delay_chart <- renderPlot({
    ggplot(flights, aes(x = arrival_delay_min)) +
      geom_histogram(bins = 30, fill = "#38bdf8", color = "#1e293b") +
      theme_minimal(base_size = 12) +
      labs(x = "Delay (Minutes)", y = "Flight Count") +
      theme(
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#1e293b", color = NA),
        panel.background = element_rect(fill = "#1e293b", color = NA),
        text = element_text(color = "#f8fafc"),
        axis.text = element_text(color = "#94a3b8")
      )
  })
  
  output$airline_chart <- renderPlot({
    flights |>
      group_by(airline) |>
      summarise(avg_delay = mean(arrival_delay_min, na.rm = TRUE)) |>
      ggplot(aes(x = reorder(airline, avg_delay), y = avg_delay)) +
      geom_col(fill = "#2ecc71") +
      coord_flip() +
      theme_minimal(base_size = 12) +
      labs(x = "Airline", y = "Average Delay (min)") +
      theme(
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#1e293b", color = NA),
        panel.background = element_rect(fill = "#1e293b", color = NA),
        text = element_text(color = "#f8fafc"),
        axis.text = element_text(color = "#94a3b8")
      )
  })
  
  output$cancellation_chart <- renderPlot({
    flights |>
      filter(flight_status == "Cancelled") |>
      count(airline, sort = TRUE) |>
      ggplot(aes(x = reorder(airline, n), y = n)) +
      geom_col(fill = "#e74c3c") +
      coord_flip() +
      theme_minimal(base_size = 12) +
      labs(x = "Airline", y = "Cancelled Count") +
      theme(
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#1e293b", color = NA),
        panel.background = element_rect(fill = "#1e293b", color = NA),
        text = element_text(color = "#f8fafc"),
        axis.text = element_text(color = "#94a3b8")
      )
  })
  
  output$route_chart <- renderPlot({
    flights |>
      mutate(route = paste(origin_airport, "->", destination_airport)) |>
      count(route, sort = TRUE) |>
      head(10) |>
      ggplot(aes(x = reorder(route, n), y = n)) +
      geom_col(fill = "#f39c12") +
      coord_flip() +
      theme_minimal(base_size = 12) +
      labs(x = "Route", y = "Number of Flights") +
      theme(
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#1e293b", color = NA),
        panel.background = element_rect(fill = "#1e293b", color = NA),
        text = element_text(color = "#f8fafc"),
        axis.text = element_text(color = "#94a3b8")
      )
  })
  
  # Data Quality Audit Tab
  output$missing_summary <- renderTable({
    data.frame(
      Column = names(flights),
      Missing_Values = sapply(flights, function(x) sum(is.na(x)))
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
  
  # Flight Explorer Tab
  output$flight_table <- DT::renderDT({
    DT::datatable(flights, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # Prediction Logic
  observeEvent(input$predict_btn, {
    peak_flag <- as.logical(input$pred_peak)
    
    new_flight <- data.frame(
      airline = as.factor(input$pred_airline),
      origin_airport = as.factor(input$pred_origin),
      destination_airport = as.factor(input$pred_dest),
      weather_condition = as.factor(input$pred_weather),
      day_of_week = as.factor(input$pred_dow),
      departure_hour = as.integer(input$pred_hour),
      distance_km = as.numeric(calculated_distance()),
      scheduled_duration_min = as.numeric(input$pred_duration),
      is_peak_hour = peak_flag
    )
    
    preds <- predict(model, data = new_flight)$predictions
    prob_delayed <- round(preds[1, "Delayed"] * 100, 2)
    
    output$prediction_output <- renderText({
      paste0(
        "Auto-Calculated Route Distance: ", calculated_distance(), " km\n",
        "Estimated Probability of Delay (15+ mins): ", prob_delayed, "%\n\n",
        ifelse(prob_delayed >= 50, "Status Result: HIGH RISK OF DELAY ⚠️", "Status Result: LOW RISK OF DELAY ✅")
      )
    })
  })
}

shinyApp(ui = ui, server = server)