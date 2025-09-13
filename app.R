library(shiny)

# Source all module files
source("R/mod_data_upload.R")
source("R/mod_dashboard.R")
source("R/mod_visualization.R")

ui <- fluidPage(
  titlePanel("Welcome To SUSNEO"),
  fluidRow(
    column(6, h3("Upload Data"), mod_data_upload_ui("upload")),
    column(6, h3("Key Insights"), mod_dashboard_ui("dashboard"))
  ),
  fluidRow(
    column(12, h3("Visualizations"), mod_visualization_ui("viz"))
  )
)

server <- function(input, output, session) {
  uploaded_data <- mod_data_upload_server("upload")
  mod_dashboard_server("dashboard", uploaded_data)
  mod_visualization_server("viz", uploaded_data)
}

shinyApp(ui = ui, server = server)
