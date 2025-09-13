# ----------------------------
# ##################################################### Visualization UI Module
# ----------------------------
library(ggplot2)
library(ggplot2)
library(dplyr)      # for %>% and group_by / summarise
library(viridis)    # for scale_fill_viridis

mod_visualization_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Visualizations"),
    plotOutput(ns("time_series_plot")),
    plotOutput(ns("comparison_plot")),
    
    h3("Summary Table"),
    tableOutput(ns("summary_table"))
  )
}

# ----------------------------
# ################################################# Visualization Server Module###################################
# ----------------------------
mod_visualization_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # 1. Time Series Plot
    output$time_series_plot <- renderPlot({
      df <- data()
      req(df, nrow(df) > 0)
      if ("date" %in% names(df) && "value" %in% names(df) && "type" %in% names(df)) {
        library(ggplot2)
        ggplot(df, aes(x = date, y = value, color = type)) +
          geom_line(size = 1) +
          scale_fill_viridis(discrete = TRUE, option = "C")+
          labs(title = "Energy Consumption Over Time",
               x = "Date", y = "Consumption") +
          theme_minimal()
      }
    })
    
    # 2. Comparison Plot
    output$comparison_plot <- renderPlot({
      df <- data()
      req(df, nrow(df) > 0)
      if ("type" %in% names(df) && "value" %in% names(df)) {
        library(ggplot2)
        df_summary <- df %>%
          dplyr::group_by(type) %>%
          dplyr::summarise(total_value = sum(value, na.rm = TRUE))
        
        ggplot(df_summary, aes(x = type, y = total_value, fill = type)) +
          geom_col() +
          scale_fill_viridis(discrete = TRUE, option = "C")+
          labs(title = "Total Consumption by Facility",
               x = "Facility Type", y = "Total Consumption") +
          theme_minimal()
      }
    })
    
    # 3. Summary Table
    output$summary_table <- renderTable({
      df <- data()
      req(df, nrow(df) > 0)
      if ("type" %in% names(df) && "value" %in% names(df)) {
        df %>%
          dplyr::group_by(type) %>%
          dplyr::summarise(
            Total = sum(value, na.rm = TRUE),
            Average = round(mean(value, na.rm = TRUE), 2),
            Count = dplyr::n()
          )
      }
    })
    
  })
}
