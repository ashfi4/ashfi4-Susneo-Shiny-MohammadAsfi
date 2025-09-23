################################################Dashboard Code##########################
mod_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Dashboard"),
    
    # Filters
    fluidRow(
      column(6, uiOutput(ns("date_filter"))),       
      column(6, uiOutput(ns("facility_filter")))   
    ),
    
    # Column selector
    selectInput(ns("col_select"), "Select a column:", choices = NULL),
    
    # KPI cards
    fluidRow(
      column(4, wellPanel(h4("Total Consumption"), textOutput(ns("total_consumption")))),
      column(4, wellPanel(h4("Average Cost"), textOutput(ns("average_cost")))),
      column(4, wellPanel(h4("Total Emissions"), textOutput(ns("total_emissions"))))
    ),
    
    # Plot and summary
    plotOutput(ns("plot")),
    tableOutput(ns("summary"))
  )
}
##################################Server Code#########################################
mod_dashboard_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # 1. Update filters and dropdown dynamically when data changes
    observeEvent(data(), {
      df <- data()
      req(df)
      
      # ---- Date Filter ----
      if ("date" %in% names(df)) {
        df$date <- as.Date(
          lubridate::parse_date_time(df$date, orders = c("ymd", "dmy", "mdy"))
        )
        output$date_filter <- renderUI({
          dateRangeInput(
            session$ns("date_range"), "Select Date Range:",
            start = min(df$date, na.rm = TRUE),
            end   = max(df$date, na.rm = TRUE),
            min   = min(df$date, na.rm = TRUE),
            max   = max(df$date, na.rm = TRUE)
          )
        })
      } else {
        output$date_filter <- renderUI(NULL)
      }
      
      # ---- Type Filter (called facility_filter in UI) ----
      if ("type" %in% names(df)) {
        output$facility_filter <- renderUI({
          selectInput(
            session$ns("facility_select"), "Select Type:",
            choices  = unique(df$type),
            selected = NULL,   # pre-select all
            multiple = TRUE
          )
        })
      } else {
        output$facility_filter <- renderUI(NULL)
      }
      
      # ---- Column Selector ----
      updateSelectInput(session, "col_select", choices = names(df))
    })
    
    # 2. Filtered Data (apply type + date filters)
    filtered_data <- reactive({
      df <- data()
      req(df)
      
      
      # --- Apply Type filter ---
      if ("type" %in% names(df) && !is.null(input$facility_select)) {
        df$type <- trimws(as.character(df$type))   # ensure character
        df <- df[df$type %in% input$facility_select, ]
        df$type <- droplevels(factor(df$type))     # drop unused levels
      }
      
      
      
      # --- Apply Date filter ---
      if ("date" %in% names(df) && !is.null(input$date_range)) {
        req(input$date_range)
        # df$date <- as.Date(lubridate::parse_date_time(
        #   df$date, orders = c("ymd", "dmy", "mdy")
        # ))
        df <- df[df$date >= input$date_range[1] & df$date <= input$date_range[2], ]
        req(nrow(df) > 0)
      }
      
      df
    })
    
    # 3. KPIs (calculated on filtered data)
    output$total_consumption <- renderText({
      df <- filtered_data()
      validate(
    need("value" %in% names(df), "No value column available in data")
      )
      print(paste("Rows in KPI calc:", nrow(df)))
      print(unique(df$type))
      
      if ("value" %in% names(df)) {
        format(sum(df$value, na.rm = TRUE), big.mark = ",")
      } else {
        "N/A"
      }
    })
    output$average_cost <- renderText({
      df <- filtered_data()
      if ("value" %in% names(df)) {
        round(mean(df$value, na.rm = TRUE), 2)
      } else {
        "N/A"
      }
    })
    
    output$total_emissions <- renderText({
      df <- filtered_data()
      if ("carbon.emission.in.kgco2e" %in% names(df)) {
        format(sum(df$carbon.emission.in.kgco2e, na.rm = TRUE), big.mark = ",")
      } else {
        "N/A"
      }
    })
    
    # 4. Column analysis (reactive)
    selected_col <- reactive({
      req(filtered_data(), input$col_select)
      filtered_data()[[input$col_select]]
    })
    
    # 5. Visualization
    output$plot <- renderPlot({
      col_data <- selected_col()
      req(col_data)
      
      if (is.numeric(col_data)) {
        hist(
          col_data,
          main = paste("Histogram of", input$col_select),
          col = "#48D1CC", xaxt = "n"
        )
        axis(1, at = pretty(col_data), labels = pretty(col_data))
      } else {
        barplot(
          table(col_data),
          main = paste("Counts of", input$col_select),
          col = "#008888"
        )
      }
    })
    
    # 6. KPI Summary (per selected column)
    output$summary <- renderTable({
      col_data <- selected_col()
      req(col_data)
      
      if (is.numeric(col_data)) {
        data.frame(
          Mean    = mean(col_data, na.rm = TRUE),
          Median  = median(col_data, na.rm = TRUE),
          Count   = length(col_data),
          Unique  = length(unique(col_data)),
          Missing = sum(is.na(col_data))
        )
      } else {
        as.data.frame(table(col_data, useNA = "ifany"))
      }
    })
    return(filtered_data)
  })
}
