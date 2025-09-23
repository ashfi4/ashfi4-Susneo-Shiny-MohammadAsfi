app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fluidPage(
      titlePanel("Welcome To SUSNEO"),
      fluidRow(
        column(6, h3("Upload Data"), mod_data_upload_ui("upload")),
        column(6, h3("Key Insights"), mod_dashboard_ui("dashboard"))
      ),
      fluidRow(
        column(12, h3("Time Series"), mod_visualization_ui("viz"))
      ),
      br(),
      hr(),
      p("⚡ Powered by Golem", style = "color: grey; font-size: 12px; text-align: center;")
    )
  )
}
# Helper
golem_add_external_resources <- function(){
  addResourcePath(
    'www', system.file('app/www', package = 'SusneoApp')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = system.file('app/www', package = 'SusneoApp'),
      app_title = 'SusneoApp'
    )
  )
}




