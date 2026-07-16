test_that("scan_identifiers finds and types identifiers", {
  txt <- "Anti-TH (RRID:AB_390204), FIJI (RRID:SCR_002285), HEK293T (RRID:CVCL_0063), GEO GSE12345, DOI 10.5281/zenodo.99."
  ids <- scan_identifiers(txt)
  expect_true("AB_390204" %in% ids$value)
  expect_identical(ids$type[ids$value == "SCR_002285"], "Software/code")
  expect_identical(ids$type[ids$value == "CVCL_0063"], "Experimental model: Cell line")
  expect_true("GSE12345" %in% ids$value[ids$field == "accession"])
  # trailing sentence punctuation is stripped from the DOI
  expect_true("10.5281/zenodo.99" %in% ids$value[ids$field == "doi"])
})

test_that("extract_candidates and extract_krt (regex) build resources", {
  res <- extract_krt("Anti-TH (RRID:AB_390204); FIJI (RRID:SCR_002285)")
  types <- vapply(res$krt$resources, function(r) r$resource_type, character(1))
  expect_true("Antibody" %in% types)
  expect_true("Software/code" %in% types)
  expect_s3_class(res$report, "krt_validation_report")
  # every extraction is provenance-stamped with the engine
  acts <- vapply(krt_provenance(res$krt), function(e) e$activity, character(1))
  expect_true("extract" %in% acts)
})

test_that("JATS reading parses tables and detects an embedded KRT", {
  jats <- system.file("extdata", "examples", "sample.jats.xml", package = "krt")
  doc <- read_input_text(jats)
  expect_length(doc$tables, 1L)
  res <- extract_krt(jats)
  expect_true(length(res$candidates) > 0L)
  expect_s3_class(res$existing_krt, "krt_tbl")
  expect_identical(length(res$existing_krt$resources), 2L)
  expect_identical(res$existing_krt$resources[[1]]$rrid, "RRID:AB_390204")
})

test_that("a plain-text input with no identifiers yields no candidates", {
  expect_length(extract_candidates("This sentence has no identifiers."), 0L)
})
