# ----------------------------
# ##################################################### Visualization UI Module
# ----------------------------
library(ggplot2)
library(ggplot2)
library(dplyr)      # for %>% and group_by / summarise
library(viridis)    # for scale_fill_viridis

# ----------------------------
# Visualization UI Module
# ----------------------------
mod_visualization_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Visualizations"),
    
    # Add dropdown selector for plot type
    selectInput(ns("ts_plot_type"), "Select Time Series Style:",
                choices = c("Line", "Faceted Line", "Stacked Area", "Smoothed Trend", "Heatmap"),
                selected = "Smoothed Trend"),
    
    # Plot output
    plotOutput(ns("time_series_plot")),
    
    plotOutput(ns("comparison_plot")),
    
    h3("Summary Table"),
    tableOutput(ns("summary_table"))
  )
}


# ----------------------------
# Visualization Server Module
# ----------------------------
mod_visualization_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # 1. Time Series Plot
    # 1. Time Series Plot with selectable style

output$time_series_plot <- renderPlot({
  df <- data()
  req(df, nrow(df) > 0)
  
  if (all(c("date", "value", "type") %in% names(df))) {
    
    plot_type <- input$ts_plot_type  # user’s choice
    
    p <- ggplot(df, aes(x = date, y = value, color = type, fill = type))
    
    if (plot_type == "Line") {
      p <- p + geom_line(size = 1) +
        scale_color_viridis(discrete = TRUE, option = "C")
      
    } else if (plot_type == "Faceted Line") {
      p <- p + geom_line(size = 1) +
        scale_color_viridis(discrete = TRUE, option = "C") +
        facet_wrap(~ type, scales = "free_y")
      
    } else if (plot_type == "Stacked Area") {
      p <- ggplot(df, aes(x = date, y = value, fill = type)) +
        geom_area(alpha = 0.7, position = "stack") +
        scale_fill_viridis(discrete = TRUE, option = "C")
      
    } else if (plot_type == "Smoothed Trend") {
      p <- p + geom_smooth(se = FALSE, size = 1.2) +
        scale_color_viridis(discrete = TRUE, option = "C")
      
    } else if (plot_type == "Heatmap") {
      p <- ggplot(df, aes(x = date, y = type, fill = value)) +
        geom_tile() +
        scale_fill_viridis(option = "C")
    }
    
    p + labs(title = paste("Energy Consumption Over Time -", plot_type),
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
