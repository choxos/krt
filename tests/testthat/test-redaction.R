test_that("redaction removes basic-tagged fields and generalizes others", {
  k <- add_approval(new_krt("Demo"), "IRB", protocol_number = "IRB-1",
                    board_name = "Example IRB", consent_scope = "study-specific")
  red <- redact_krt(k, level = "basic")
  a <- red$approvals[[1]]
  expect_null(a$protocol_number)      # basic drop
  expect_null(a$board_name)           # basic drop
  expect_true(!is.null(a$approval_type))

  strict <- redact_krt(k, level = "strict")
  expect_identical(strict$approvals[[1]]$consent_scope, "[redacted]")  # strict generalize
})

test_that("public export redacts the full sensitive field set", {
  k <- add_approval(krt_example, "IRB", protocol_number = "P-9",
                    institution_name = "Secret U", data_use_restrictions = "no-redistribute",
                    consent_scope = "study-specific", consent_obtained = TRUE)
  e <- suppressWarnings(export_krt(k, format = "json", audience = "public"))
  k2 <- read_krt_json(e)
  appr <- k2$approvals
  for (a in appr) {
    expect_null(a$protocol_number)
    expect_null(a$institution_name)
    expect_true(is.null(a$data_use_restrictions) || a$data_use_restrictions == "[redacted]")
  }
})

test_that("public export drops consent flags and free-text notes (no PHI leak)", {
  k <- add_approval(
    add_resource(new_krt("t"), "Biological sample", "S", organism = "Homo sapiens",
                 notes = "patient MRN 999", new_or_reuse = "new", accession = "SAMN1"),
    "IRB", protocol_number = "P1", consent_obtained = TRUE, consent_scope = "broad")
  e <- suppressWarnings(export_krt(k, format = "json", audience = "public"))
  k2 <- read_krt_json(e)
  expect_null(k2$approvals[[1]]$consent_obtained)   # consent flag dropped
  expect_false(grepl("MRN 999", e))                 # notes redacted at basic
  expect_null(k2$resources[[1]]$protocol_number)
})

test_that("direct ASAP and tabular exports also redact for public audience", {
  k <- add_resource(krt_example, "Biological sample", "Patient sample",
                    organism = "Homo sapiens", new_or_reuse = "new",
                    accession = "SAMN1", notes = "Patient MRN 12345")
  csv <- suppressWarnings(export_asap(k, audience = "public"))
  expect_false(grepl("MRN 12345", csv))     # notes generalized at basic (public default)
})

test_that("public export without redaction warns", {
  expect_warning(export_krt(krt_example, format = "json", audience = "public",
                            redact = FALSE), "without redaction")
})

test_that("redaction policy is a well-formed table", {
  p <- redaction_policy()
  expect_true(all(c("scope", "field", "level", "action") %in% names(p)))
  expect_true(all(p$level %in% c("basic", "strict")))
})
