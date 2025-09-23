app_server <- function(input, output, session) {
  # Run upload module
  uploaded_data <- mod_data_upload_server("upload")
  
  # Pass uploaded data to dashboard
  filtered_data <- mod_dashboard_server("dashboard", uploaded_data)
  
  # Pass filtered data to visualization
  mod_visualization_server("viz", filtered_data)
}
