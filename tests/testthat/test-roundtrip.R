make_table <- function() {
  k <- new_krt("Round-trip study", study_type = c("wet-lab", "computational"),
               locale = "en-US")
  k <- add_resource(k, "Antibody", "Anti-TH", vendor = "Millipore",
                    catalog_number = "AB152", rrid = "RRID:AB_390204",
                    new_or_reuse = "reuse", notes = "Dilution 1:500")
  k <- add_resource(k, "Dataset", "Counts", source_name = "GEO",
                    accession = c("GSE111", "GSE222"), new_or_reuse = "new")
  k
}

test_that("JSON round-trip preserves resources exactly", {
  k <- make_table()
  k2 <- read_krt_json(write_krt_json(k))
  expect_identical(krt:::.krt_to_list(k)$resources,
                   krt:::.krt_to_list(k2)$resources)
  expect_identical(k2$title, k$title)
  expect_identical(k2$study_type, k$study_type)
  expect_identical(k2$table_id, k$table_id)
})

test_that("YAML round-trip preserves resources exactly", {
  k <- make_table()
  k2 <- read_krt_yaml(write_krt_yaml(k))
  expect_identical(krt:::.krt_to_list(k)$resources,
                   krt:::.krt_to_list(k2)$resources)
})

test_that("present-only fields are not turned into NA", {
  k <- make_table()
  k2 <- read_krt_json(write_krt_json(k))
  ab <- k2$resources[[which(vapply(k2$resources,
                                   function(r) r$resource_type == "Antibody", logical(1)))]]
  expect_false("doi" %in% names(ab))   # absent stays absent, not NA
  expect_true("rrid" %in% names(ab))
})

test_that("multi-valued accession survives round-trip as a vector", {
  k <- make_table()
  k2 <- read_krt_json(write_krt_json(k))
  ds <- k2$resources[[which(vapply(k2$resources,
                                   function(r) r$resource_type == "Dataset", logical(1)))]]
  expect_identical(ds$accession, c("GSE111", "GSE222"))
})

test_that("the example table round-trips through JSON and YAML", {
  expect_identical(krt:::.krt_to_list(read_krt_json(write_krt_json(krt_example)))$resources,
                   krt:::.krt_to_list(krt_example)$resources)
  expect_identical(krt:::.krt_to_list(read_krt_yaml(write_krt_yaml(krt_example)))$resources,
                   krt:::.krt_to_list(krt_example)$resources)
})

test_that("empty table serializes resources as an array and round-trips", {
  k <- new_krt("Empty")
  j <- write_krt_json(k)
  expect_match(j, "\"resources\"\\s*:\\s*\\[\\]")
  k2 <- read_krt_json(j)
  expect_length(k2$resources, 0L)
})
