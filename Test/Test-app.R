library(testthat)

# ---- 1. Test CSV columns ----
test_that("Uploaded CSV has required columns", {
  df <- data.frame(
    date = Sys.Date() + 0:2,
    type = c("Water", "Gas", "Fuel"),
    value = c(100, 200, 300),
    stringsAsFactors = FALSE
  )
  
  required_cols <- c("date", "type", "value")
  expect_true(all(required_cols %in% names(df)))
})

# ---- 2. Test KPI calculations ----
test_that("KPI calculations work", {
  df <- data.frame(type = c("Water", "Gas"), value = c(100, 200))
  
  total <- sum(df$value)
  avg <- mean(df$value)
  
  expect_equal(total, 300)
  expect_equal(avg, 150)
})

# ---- 3. Test filtering helper ----
filter_by_type <- function(df, selected_types) {
  df[df$type %in% selected_types, ]
}

test_that("Filtering by type works", {
  df <- data.frame(
    type = c("Water", "Gas", "Fuel"),
    value = c(10, 20, 30)
  )
  
  filtered <- filter_by_type(df, "Gas")
  
  expect_equal(nrow(filtered), 1)
  expect_equal(filtered$type, "Gas")
  expect_equal(filtered$value, 20)
})
