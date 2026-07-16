# Regression tests for the pre-release hardening pass.

test_that("krt_merge does not collapse distinct identifier-less resources", {
  a <- add_resource(new_krt("A"), "Other", "Thing One", new_or_reuse = "new")
  a <- add_resource(a, "Other", "Thing Two", new_or_reuse = "new")
  m <- krt_merge(a, new_krt("B"))
  expect_equal(length(m$resources), 2L)
  nms <- vapply(m$resources, function(r) r$display_name, character(1))
  expect_setequal(nms, c("Thing One", "Thing Two"))
})

test_that("krt_merge keeps approvals and contributors even with zero resources", {
  a <- add_approval(new_krt("A"), "IRB", protocol_number = "P1")
  b <- add_contributor(new_krt("B"), "Jane Doe")
  m <- krt_merge(a, b)
  expect_equal(length(m$approvals), 1L)
  expect_equal(length(m$contributors), 1L)
})

test_that("krt_merge validates every input table, including those in ...", {
  expect_error(krt_merge(new_krt("A"), new_krt("B"), list(not = "a table")),
               "krt_tbl objects")
})

test_that("importing a data frame with unknown headers does not crash", {
  df <- data.frame(foo = 1:2, bar = c("a", "b"), stringsAsFactors = FALSE)
  k <- import_krt(df)
  expect_true(is_krt(k))
  expect_identical(k$profile, "generic")
})

test_that("a generic identifier column is typed, not forced into rrid", {
  df <- data.frame(type = "Dataset", name = "D",
                   identifier = "10.5281/zenodo.123",
                   check.names = FALSE, stringsAsFactors = FALSE)
  r <- import_tabular(df)$resources[[1]]
  expect_identical(r$doi, "10.5281/zenodo.123")
  expect_null(r$rrid)
})

test_that(".has_value rejects NA and whitespace-only values", {
  expect_false(krt:::.has_value(list(display_name = NA_character_), "display_name"))
  expect_false(krt:::.has_value(list(display_name = "   "), "display_name"))
  expect_true(krt:::.has_value(list(display_name = "X"), "display_name"))
})

test_that("table ids are unique across same-titled tables", {
  expect_false(identical(new_krt("Same")$table_id, new_krt("Same")$table_id))
})

test_that("registration rejects silent overwrite of an existing rule", {
  existing <- list_validators()$rule_id[1]
  expect_error(register_validator(existing, function(x, ctx) list()),
               "already registered")
})
