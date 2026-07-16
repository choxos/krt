test_that("mutating operations append provenance", {
  k <- new_krt("Demo")
  expect_length(krt_provenance(k), 0L)
  k <- add_resource(k, "Dataset", "D", doi = "10.5281/zenodo.1", new_or_reuse = "new")
  expect_length(krt_provenance(k), 1L)
  k <- normalize_ids(k)
  expect_length(krt_provenance(k), 2L)
  k <- validate_krt(k, attach = TRUE)
  acts <- vapply(krt_provenance(k), function(e) e$activity, character(1))
  expect_true(all(c("add_resource", "normalize_ids", "validate") %in% acts))
})

test_that("provenance object prints and coerces to a data frame", {
  p <- krt_provenance(normalize_ids(krt_example))
  expect_s3_class(p, "krt_provenance")
  expect_output(print(p), "krt_provenance")
  df <- as.data.frame(p)
  expect_true(all(c("activity", "timestamp", "software") %in% names(df)))
})

test_that("PROV-JSON is valid and describes activities", {
  k <- normalize_ids(add_resource(new_krt("x"), "Dataset", "D",
                                  doi = "10.5281/zenodo.1", new_or_reuse = "new"))
  j <- as_prov_json(k)
  expect_true(jsonlite::validate(j))
  expect_match(j, "prov:SoftwareAgent")
  expect_match(j, "normalize_ids")
})

test_that("RO-Crate is valid JSON-LD with a graph", {
  j <- as_rocrate(krt_example)
  expect_true(jsonlite::validate(j))
  expect_match(j, "@graph")
  expect_match(j, "ro/crate/1.1")
  expect_identical(as_rdf(krt_example, "jsonld"), j)
})

test_that("Turtle serialization works when rdflib is available", {
  skip_if_not_installed("rdflib")
  tt <- as_rdf(krt_example, "turtle")
  expect_true(nchar(tt) > 0L)
  expect_match(tt, "schema.org|purl.org")
})
