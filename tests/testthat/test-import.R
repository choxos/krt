test_that("ASAP round-trip recovers typed identifiers", {
  f <- tempfile(fileext = ".csv")
  suppressWarnings(export_asap(krt_example, f))
  k <- import_krt(f)
  expect_identical(length(k$resources), length(krt_example$resources))
  ab <- k$resources[[1]]
  expect_identical(ab$resource_type, "Antibody")
  expect_identical(ab$catalog_number, "AB152")
  expect_identical(ab$rrid, "RRID:AB_390204")
  expect_identical(k$profile, "asap")
})

test_that("import detects JSON and YAML strings", {
  expect_s3_class(import_krt(write_krt_json(krt_example)), "krt_tbl")
  expect_s3_class(import_krt(write_krt_yaml(krt_example)), "krt_tbl")
})

test_that("generic tabular import guesses a column mapping", {
  df <- data.frame(type = "Antibody", name = "Anti-X", rrid = "RRID:AB_9",
                   "new/reuse" = "reuse", vendor = "Acme", check.names = FALSE)
  k <- import_tabular(df)
  r <- k$resources[[1]]
  expect_identical(r$resource_type, "Antibody")
  expect_identical(r$vendor, "Acme")
  expect_identical(r$rrid, "RRID:AB_9")
})

test_that("Cell Press three-column table maps section headers to types", {
  cp <- data.frame(
    "REAGENT or RESOURCE" = c("Antibodies", "Rabbit Anti-TH",
                              "Experimental Models: Cell Lines", "HEK293T"),
    "SOURCE" = c("", "Millipore", "", "ATCC"),
    "IDENTIFIER" = c("", "Cat# AB152; RRID:AB_390204", "", "RRID:CVCL_0063"),
    check.names = FALSE, stringsAsFactors = FALSE)
  k <- import_asap(cp)
  types <- vapply(k$resources, function(r) r$resource_type, character(1))
  expect_true("Antibody" %in% types)
  expect_true("Experimental model: Cell line" %in% types)
})
