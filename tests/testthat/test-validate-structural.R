# Build a raw resource record, bypassing new_resource() validation, to exercise
# the structural validators on invalid states that the constructor would reject.
raw_res <- function(...) structure(list(...), class = "krt_resource")
tbl_with <- function(...) {
  k <- new_krt("Test")
  k$resources <- list(...)
  k
}

fires <- function(report, rule) rule %in% as.data.frame(report)$rule_id

test_that("missing name and new_or_reuse are errors", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                        rrid = "RRID:SCR_1"))
  r <- validate_krt(k, layers = "structural")
  expect_true(fires(r, "struct-missing-name"))
  expect_true(fires(r, "struct-missing-new-reuse"))
  expect_false(r$valid)
})

test_that("bad enums are errors", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Bogus",
                        display_name = "d", new_or_reuse = "maybe",
                        rrid = "RRID:SCR_1"))
  r <- validate_krt(k, layers = "structural")
  expect_true(fires(r, "struct-resource-type-vocab"))
  expect_true(fires(r, "struct-new-reuse-vocab"))
})

test_that("missing identifier warns unless pending", {
  k1 <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                         display_name = "d", new_or_reuse = "new"))
  expect_true(fires(validate_krt(k1, layers = "structural"), "struct-missing-identifier"))

  k2 <- tbl_with(raw_res(resource_id = "r1", resource_type = "Experimental model: Cell line",
                         display_name = "d", new_or_reuse = "new",
                         notes = "Identifier from Cellosaurus pending"))
  expect_false(fires(validate_krt(k2, layers = "structural"), "struct-missing-identifier"))
})

test_that("malformed identifier syntax warns", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                        display_name = "d", new_or_reuse = "new",
                        doi = "not-a-doi"))
  expect_true(fires(validate_krt(k, layers = "structural"), "struct-id-syntax"))
})

test_that("unknown and inapplicable fields are notes", {
  k1 <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                         display_name = "d", new_or_reuse = "new",
                         doi = "10.5281/zenodo.1", made_up = "x"))
  expect_true(fires(validate_krt(k1, layers = "structural"), "struct-unknown-field"))

  k2 <- tbl_with(raw_res(resource_id = "r1", resource_type = "Antibody",
                         display_name = "d", new_or_reuse = "reuse",
                         rrid = "RRID:AB_1", repository_url = "https://x"))
  expect_true(fires(validate_krt(k2, layers = "structural"), "struct-field-applicability"))
})

test_that("a clean table has no structural findings", {
  expect_length(validate_krt(krt_example, layers = "structural")$findings, 0L)
})
