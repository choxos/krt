test_that("fetch_fulltext validates its source argument", {
  expect_error(fetch_fulltext("PMC1", source = "nope"))
})

test_that("fetch_fulltext degrades gracefully and never errors", {
  skip_on_cran()
  skip_if_offline()
  # An implausible id should return NULL (or a string), not error.
  out <- fetch_fulltext("PMC0000000", source = "europepmc")
  expect_true(is.null(out) || is.character(out))
})
