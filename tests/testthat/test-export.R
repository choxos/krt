test_that("ASAP export yields exactly the six columns with a composed identifier", {
  csv <- suppressWarnings(export_asap(krt_example))
  hdr <- strsplit(strsplit(csv, "\n")[[1]][1], ",")[[1]]
  expect_length(hdr, 6L)
  expect_true(grepl("RESOURCE TYPE", csv))
  expect_true(grepl("Cat# AB152; RRID:AB_390204", csv))
})

test_that("lossy formats warn and lossless formats do not", {
  expect_warning(export_krt(krt_example, format = "asap"), "lossy-export")
  expect_warning(export_krt(krt_example, format = "csv"), "lossy-export")
  expect_silent(export_krt(krt_example, format = "json"))
  expect_silent(export_krt(krt_example, format = "yaml"))
})

test_that("format is inferred from the path extension", {
  f <- tempfile(fileext = ".json")
  export_krt(krt_example, f)
  expect_true(file.exists(f))
  expect_s3_class(read_krt_json(f), "krt_tbl")
})

test_that("citation export emits only citable resources", {
  bib <- export_citation(krt_example, format = "bibtex")
  expect_match(bib, "@misc")
  expect_match(bib, "Fiji")             # software is citable
  expect_false(grepl("Anti-TH", bib))   # an antibody is not a citation
  ris <- export_citation(krt_example, format = "ris")
  expect_match(ris, "TY  - ")
})

test_that("attribution sidecar is written for the ASAP profile", {
  k <- krt_example; k$profile <- "asap"
  f <- tempfile(fileext = ".csv")
  suppressWarnings(export_krt(k, f, format = "asap"))
  expect_true(file.exists(paste0(f, ".attribution.md")))
})
