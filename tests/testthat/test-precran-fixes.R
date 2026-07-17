# Regression tests for the pre-0.1.0 correctness, security, and honesty fixes.

test_that("canonical round-trip preserves provenance params and validation findings", {
  k <- new_krt("RT", study_type = "wet-lab")
  k <- add_resource(k, "Antibody", "No id here", new_or_reuse = "reuse")
  k <- normalize_ids(k)
  k <- validate_krt(k, profile = "asap", attach = TRUE)
  expect_gt(length(k$validation), 0L)                 # a finding exists
  k2 <- read_krt_json(write_krt_json(k))
  expect_identical(k, k2)                              # whole object, not just resources
  # the named provenance params survive as a named list, not a flattened vector
  last <- k2$provenance[[length(k2$provenance)]]
  expect_true(is.list(last$params) && !is.null(names(last$params)))
})

test_that("print.krt_llm never reveals the api key", {
  llm <- krt_llm("openai", model = "gpt-4o-mini", api_key = "sk-supersecret-123")
  out <- paste(capture.output(print(llm)), collapse = "\n")
  expect_false(grepl("supersecret", out))
  expect_match(out, "api_key:  <hidden>")
})

test_that("register_profile refuses to silently replace a built-in", {
  expect_error(register_profile("asap", profile = list(name = "asap")),
               "already registered")
  expect_silent(register_profile("asap", profile = get_profile("asap"), replace = TRUE))
})

test_that("Cell Press import gets the star-methods profile", {
  csv <- paste("REAGENT or RESOURCE,SOURCE,IDENTIFIER",
               "Antibodies,,", "Anti-TH,Millipore,RRID:AB_390204", sep = "\n")
  f <- tempfile(fileext = ".csv"); writeLines(csv, f)
  k <- import_krt(f)
  expect_identical(k$profile, "star-methods")
})

test_that("identifier normalization is safe and canonical", {
  expect_identical(norm_rrid("RRID:RRID:AB_1"), "RRID:AB_1")   # doubled prefix collapsed
  expect_identical(norm_rrid("rrid:ab_390204"), "RRID:AB_390204")
  expect_identical(norm_doi("10.1/ABC"), "10.1/abc")           # DOIs lowercased
  expect_identical(norm_pmid("PMID:12abc34"), "12abc34")       # malformed left intact
  expect_true(is.na(id_parse("AB_152")$field))                 # short token not an RRID
  expect_identical(id_parse("AB_390204")$field, "rrid")
  expect_identical(id_parse("P12345")$field, "accession")      # UniProt
})

test_that("an invalid ORCID check digit is flagged", {
  k <- new_krt("D")
  k$contributors <- list(structure(list(contributor_id = "c1", name = "X",
                                         orcid = "0000-0001-6829-0824"),
                                    class = "krt_contributor"))
  rep <- validate_krt(k, layers = "semantic")
  expect_true(any(vapply(rep$findings, function(f) f$rule_id == "sem-orcid-checksum",
                         logical(1))))
})

test_that("validate_krt fails closed on unknown profile or severity", {
  expect_error(validate_krt(krt_example, profile = "does-not-exist"), "Unknown profile")
  expect_error(validate_krt(krt_example, severity = list(x = "critical")),
               "Unknown severity")
})

test_that("duplicate resource ids are an error and resource_id is immutable", {
  k <- new_krt("D")
  k <- add_resource(k, "Antibody", "A", rrid = "RRID:AB_1", new_or_reuse = "reuse")
  k <- add_resource(k, "Antibody", "B", rrid = "RRID:AB_2", new_or_reuse = "reuse")
  id2 <- k$resources[[2]]$resource_id
  expect_identical(update_resource(k, id2, vendor = "V")$resources[[2]]$resource_id, id2)
  k$resources[[2]]$resource_id <- k$resources[[1]]$resource_id  # force a duplicate
  rep <- validate_krt(k, layers = "structural")
  expect_false(rep$valid)
  expect_true(any(vapply(rep$findings, function(f) f$rule_id == "struct-duplicate-id",
                         logical(1))))
})

test_that("duplicate detection matches a bare DOI against its URL form", {
  k <- new_krt("D")
  k <- add_resource(k, "Dataset", "D1", doi = "10.5281/zenodo.1", new_or_reuse = "new")
  k <- add_resource(k, "Dataset", "D2", doi = "https://doi.org/10.5281/ZENODO.1",
                    new_or_reuse = "new")
  expect_length(find_duplicates(k), 1L)
})

test_that("public redaction removes the validation channel", {
  k <- add_approval(new_krt("D"), "IRB", protocol_number = "SECRET-1")
  k <- add_resource(k, "Antibody", "A", new_or_reuse = "reuse")
  k <- validate_krt(k, profile = "asap", attach = TRUE)
  r <- redact_krt(k)
  expect_length(r$validation, 0L)
})

test_that("render honors the selected profile", {
  expect_match(render_krt(krt_example, format = "md"), "RESOURCE TYPE")           # generic -> ASAP
  expect_match(render_krt(krt_example, format = "md", profile = "star-methods"),
               "REAGENT or RESOURCE")
})

test_that("ASAP lossy report names the dropped resource_id", {
  expect_true("resource_id" %in% mapping_lossy_fields(krt_example, "asap"))
})

test_that("regex extraction does not force DOIs to Dataset and keeps catalogs", {
  ids <- scan_identifiers("See Millipore Cat# AB152 and dataset 10.5281/zenodo.9.")
  doi_row <- ids[ids$field == "doi", ]
  expect_true(is.na(doi_row$type))                                   # not "Dataset"
  cand <- extract_candidates("Anti-X (RRID:AB_390204); Cat# AB152.")
  fields <- unlist(lapply(cand, function(r) names(r)))
  expect_true("catalog_number" %in% fields)                          # catalog not orphaned
})

test_that("preflight fails closed on an unknown profile and checks the whole object", {
  pf <- krt_preflight(krt_example, profile = "does-not-exist")
  expect_false(pf$ok)
  expect_true(any(pf$checks$check == "validation" & pf$checks$status == "fail"))
  pf2 <- krt_preflight(krt_example)
  expect_true("pass" %in% pf2$checks$status[pf2$checks$check == "round_trip"])
})

test_that("a microbe is not misread as a regulated animal", {
  k <- new_krt("D")
  k <- add_resource(k, "Experimental model: Organism/strain", "Serratia marcescens",
                    organism = "Serratia marcescens", new_or_reuse = "reuse")
  rep <- validate_krt(k, profile = "generic")
  expect_false(any(vapply(rep$findings,
                          function(f) grepl("animal", f$message, ignore.case = TRUE),
                          logical(1))))
})
