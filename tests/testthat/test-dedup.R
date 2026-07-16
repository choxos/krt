test_that("resource_signature is stable over identity fields", {
  r1 <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
                     catalog_number = "AB152", new_or_reuse = "reuse")
  r2 <- new_resource("Antibody", "A different display name", vendor = "millipore",
                     catalog_number = "AB152", new_or_reuse = "reuse")
  expect_identical(resource_signature(r1), resource_signature(r2))
})

test_that("find_duplicates groups exact duplicates", {
  k <- new_krt("Demo")
  k <- add_resource(k, "Antibody", "Anti-TH", vendor = "Millipore",
                    catalog_number = "AB152", new_or_reuse = "reuse")
  k <- add_resource(k, "Antibody", "Anti-TH copy", vendor = "Millipore",
                    catalog_number = "AB152", new_or_reuse = "reuse")
  k <- add_resource(k, "Dataset", "Unrelated", new_or_reuse = "new")
  dups <- find_duplicates(k)
  expect_length(dups, 1L)
  expect_length(dups[[1]], 2L)
})

test_that("no duplicates reported for distinct resources", {
  expect_length(find_duplicates(krt_example), 0L)
})
