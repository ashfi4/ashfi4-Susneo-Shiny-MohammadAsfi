mod_data_upload_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Upload CSV File"),
    textOutput(ns("status")),
    h4("Summary of Data"),
    tableOutput(ns("na_summary")),
    h4("Date Summary"),
    tableOutput(ns("date_summary"))
  )
}

mod_data_upload_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- reactiveVal(NULL)
    
    observeEvent(input$file, {
      req(input$file)
      df <- tryCatch(read.csv(input$file$datapath), error = function(e) NULL)
      if (!is.null(df) && "date" %in% names(df)) {
        df$date <- suppressWarnings(lubridate::parse_date_time(
          df$date, orders = c("ymd", "dmy", "mdy")
        ))
      }
      data(df)
    })
    
    output$na_summary <- renderTable({
      req(data())
      data.frame(
        Column = names(data()),
        DataType = sapply(data(), function(x) class(x)[1]),
        Missing = colSums(is.na(data()))
      )
    })
    
    output$date_summary <- renderTable({
      req(data())
      if ("date" %in% names(data())) {
        data.frame(
          MinDate = min(data()$date, na.rm = TRUE),
          MaxDate = max(data()$date, na.rm = TRUE)
        )
      }
    })
    
    return(data)
  })
}

