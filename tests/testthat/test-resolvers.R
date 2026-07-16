test_that("all six resolvers are registered", {
  expect_setequal(list_resolvers(),
                  c("cellosaurus", "doi", "orcid", "pmid", "ror", "rrid"))
})

test_that("offline resolution returns a normalized, unresolved result", {
  r <- resolve_rrid("AB_390204", resolve = FALSE)
  expect_identical(r$normalized, "RRID:AB_390204")
  expect_false(r$resolved)
  expect_identical(r$type, "Antibody")

  expect_identical(resolve_doi("https://doi.org/10.1038/X", resolve = FALSE)$normalized,
                   "10.1038/X")
  expect_identical(resolve_orcid("https://orcid.org/0000-0002-1825-0097",
                                 resolve = FALSE)$normalized, "0000-0002-1825-0097")
  expect_identical(resolve_ror("https://ror.org/05xpvk416", resolve = FALSE)$normalized,
                   "05xpvk416")
})

test_that("resolve_id dispatches by detected scheme", {
  expect_identical(resolve_id("RRID:AB_390204", resolve = FALSE)$normalized,
                   "RRID:AB_390204")
  expect_identical(resolve_id("10.5281/zenodo.1", resolve = FALSE)$source, "crossref")
  expect_null(resolve_id("some free text that is not an id", resolve = FALSE))
})

test_that("a custom resolver overrides a built-in", {
  old <- get_resolver("rrid")
  on.exit(register_resolver("rrid", old), add = TRUE)
  register_resolver("rrid", function(id, resolve = TRUE, ...)
    list(input = id, normalized = "RRID:MOCK", resolved = TRUE, source = "mock",
         name = "Mock", type = "Antibody", url = "x"))
  expect_identical(resolve_id("RRID:AB_1")$name, "Mock")
})

test_that("live resolution degrades gracefully and never errors", {
  skip_on_cran()
  skip_if_offline()
  r <- resolve_doi("10.1038/sdata.2016.18", resolve = TRUE)
  expect_true(is.list(r))
  expect_true(all(c("input", "normalized", "resolved", "name") %in% names(r)))
})
