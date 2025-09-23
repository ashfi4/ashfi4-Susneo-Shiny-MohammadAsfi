library(shiny)
options(warn = -1)
# Source all module files
source("R/mod_data_upload.R")
source("R/mod_dashboard.R")
source("R/mod_visualization.R")

mod_data_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Upload CSV File"),
    textOutput(ns("status")),
    h4("Summary of Data"),
    tableOutput(ns("na_summary")),
    
  )
}

ui <- fluidPage(
  titlePanel("Welcome To SUSNEO"),
  fluidRow(
    column(6, h3("Upload Data"), mod_data_upload_ui("upload")),
    column(6, h3("Key Insights"), mod_dashboard_ui("dashboard"))
  ),
  fluidRow(
    column(12, h3("Time Series"), mod_visualization_ui("viz"))
  )
)


server <- function(input, output, session) {
  # Run upload module
  uploaded_data <- mod_data_upload_server("upload")
  
  # Pass uploaded data to dashboard
  filtered_data <- mod_dashboard_server("dashboard", uploaded_data)
  
  # Pass filtered data to visualization
  mod_visualization_server("viz", filtered_data)
}

# shinyApp(ui = ui, server = server)

shinyApp(ui = ui, server = server)