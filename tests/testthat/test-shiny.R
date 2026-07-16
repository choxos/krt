test_that("the Shiny app is present and parses", {
  app <- system.file("shiny-apps", "krt", "app.R", package = "krt")
  expect_true(nzchar(app) && file.exists(app))
  expect_silent(parse(app))
})

test_that("launch_krt is available and errors clearly without its dependencies", {
  expect_true(is.function(launch_krt))
})

test_that("the RStudio addin is registered", {
  dcf <- system.file("rstudio", "addins.dcf", package = "krt")
  expect_true(nzchar(dcf))
  spec <- read.dcf(dcf)
  expect_identical(unname(spec[1, "Binding"]), "launch_krt")
})
