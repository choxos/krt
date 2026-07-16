test_that("deposit requires a token", {
  expect_error(krt_deposit_zenodo(krt_example, token = ""), "token is required")
  expect_error(krt_deposit_figshare(krt_example, token = ""), "token is required")
})

test_that("deposit redacts for a public audience before upload", {
  # With a token set but the network unavailable, the call must not error; it
  # returns a NULL deposit and a table that has been redacted.
  skip_on_cran()
  res <- suppressWarnings(krt_deposit_zenodo(krt_example, token = "dummy-token",
                                             sandbox = TRUE, audience = "public"))
  expect_true(is.list(res))
  expect_true(all(c("deposit", "doi", "x") %in% names(res)))
  expect_null(res$x$approvals[[1]]$protocol_number)  # redacted regardless of network
})
