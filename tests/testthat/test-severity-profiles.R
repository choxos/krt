# Profile-driven severity overrides are exercised in the profiles milestone; here
# we test the user-supplied `severity` override and the report object.

raw_res <- function(...) structure(list(...), class = "krt_resource")
tbl_missing_id <- function() {
  k <- new_krt("Test")
  k$resources <- list(raw_res(resource_id = "r1", resource_type = "Dataset",
                              display_name = "d", new_or_reuse = "new"))
  k
}

test_that("user severity can escalate a warning to an error", {
  k <- tbl_missing_id()
  base <- validate_krt(k, layers = "structural")
  expect_true(base$valid)   # warning only
  esc <- validate_krt(k, layers = "structural",
                      severity = list(`struct-missing-identifier` = "error"))
  expect_false(esc$valid)
})

test_that("severity 'off' disables a rule", {
  k <- tbl_missing_id()
  off <- validate_krt(k, layers = "structural",
                      severity = list(`struct-missing-identifier` = "off"))
  expect_false("struct-missing-identifier" %in% as.data.frame(off)$rule_id)
})

test_that("report summary and as.data.frame are well-formed", {
  r <- validate_krt(tbl_missing_id(), layers = "structural")
  df <- as.data.frame(r)
  expect_true(all(c("rule_id", "severity", "layer", "standard", "resource_id",
                    "field", "message", "suggestion") %in% names(df)))
  s <- summary(r)
  expect_true(all(c("severity", "layer", "standard", "n") %in% names(s)))
  expect_output(print(r), "krt_validation_report")
})

test_that("list_validators exposes the registered rules", {
  lv <- list_validators()
  expect_true(all(c("struct-missing-name", "sem-rrid-type", "cond-arrive")
                  %in% lv$rule_id))
})
