test_that("eLabFTW connector requires a token", {
  expect_error(krt_import_elabftw("https://elab.example.org", 1, token = ""),
               "token is required")
})

test_that("protocols.io connector degrades to an empty table offline", {
  skip_on_cran()
  k <- suppressWarnings(krt_import_protocolsio("nonexistent-id", token = ""))
  expect_s3_class(k, "krt_tbl")
  expect_length(k$resources, 0L)
})
