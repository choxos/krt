test_that("character normalization canonicalizes by scheme", {
  expect_identical(normalize_ids("https://doi.org/10.1038/SDATA.2016.18"),
                   "10.1038/SDATA.2016.18")
  expect_identical(normalize_ids("doi:10.1/xyz"), "10.1/xyz")
  expect_identical(normalize_ids("https://orcid.org/0000-0002-1825-0097"),
                   "0000-0002-1825-0097")
  expect_identical(normalize_ids("PMID: 12345"), "12345")
})

test_that("orcid normalization inserts hyphens", {
  expect_identical(norm_orcid("0000000218250097"), "0000-0002-1825-0097")
  expect_identical(norm_orcid("https://orcid.org/0000-0002-1825-009X"),
                   "0000-0002-1825-009X")
})

test_that("rrid and pmcid normalization add prefixes idempotently", {
  expect_identical(norm_rrid("SCR_002285"), "RRID:SCR_002285")
  expect_identical(norm_rrid("RRID:SCR_002285"), "RRID:SCR_002285")
  expect_identical(norm_pmcid("12345"), "PMC12345")
  expect_identical(norm_pmcid("PMC12345"), "PMC12345")
})

test_that("resource normalization fixes identifier fields", {
  r <- new_resource("Software/code", "Fiji", rrid = "SCR_002285",
                    new_or_reuse = "reuse")
  r <- normalize_ids(r)
  expect_identical(r$rrid, "RRID:SCR_002285")
})

test_that("table normalization is idempotent", {
  k <- add_resource(new_krt("Demo"), "Software/code", "Fiji",
                    rrid = "SCR_002285", new_or_reuse = "reuse")
  once <- normalize_ids(k)
  twice <- normalize_ids(once)
  expect_identical(once$resources, twice$resources)
  expect_identical(once$resources[[1]]$rrid, "RRID:SCR_002285")
})
