fires <- function(report, rule) rule %in% as.data.frame(report)$rule_id

test_that("cell-line pack fires only for cell lines and needs authentication", {
  k <- new_krt("Demo")
  k <- add_resource(k, "Experimental model: Cell line", "HeLa",
                    rrid = "RRID:CVCL_0030", new_or_reuse = "reuse")
  r <- validate_krt(k)
  expect_true(fires(r, "cond-cellline"))

  k2 <- add_resource(new_krt("Demo"), "Dataset", "D",
                     doi = "10.5281/zenodo.1", new_or_reuse = "new")
  expect_false(fires(validate_krt(k2), "cond-cellline"))
})

test_that("software pack requires a reproducible pointer", {
  bad <- add_resource(new_krt("Demo"), "Software/code", "MyTool",
                      new_or_reuse = "new", url = "https://example.org")
  expect_true(fires(validate_krt(bad), "cond-software"))

  good <- add_resource(new_krt("Demo"), "Software/code", "MyTool",
                       new_or_reuse = "new", repository_url = "https://github.com/x/y")
  expect_false(fires(validate_krt(good), "cond-software"))
})

test_that("organism pack fires for animal models without ethics approval", {
  k <- add_resource(new_krt("Demo"), "Experimental model: Organism/strain",
                    "C57BL/6J", organism = "Mus musculus", strain = "C57BL/6J",
                    rrid = "RRID:IMSR_JAX:000664", new_or_reuse = "reuse")
  expect_true(fires(validate_krt(k), "cond-organism"))
  k2 <- add_approval(k, "IACUC", protocol_number = "X-1")
  expect_false(fires(validate_krt(k2), "cond-organism"))
})

test_that("a non-animal organism model does not demand animal ethics approval", {
  k <- add_resource(new_krt("Demo"), "Experimental model: Organism/strain",
                    "Arabidopsis", organism = "Arabidopsis thaliana",
                    taxon_id = "3702", new_or_reuse = "new")
  # The organism-metadata check is satisfied; no animal-ethics finding is added.
  msgs <- as.data.frame(validate_krt(k))
  animal <- grepl("animal ethics", msgs$message)
  expect_false(any(animal))
})

test_that("ethics pack fires for human material without valid consent", {
  k <- add_resource(new_krt("Demo"), "Biological sample", "Patient serum",
                    organism = "Homo sapiens", taxon_id = "9606",
                    new_or_reuse = "new", accession = "SAMN123")
  expect_true(fires(validate_krt(k), "cond-ethics"))
  # An explicit consent refusal must not satisfy the rule.
  k_refused <- add_approval(k, "IRB", consent_obtained = FALSE)
  expect_true(fires(validate_krt(k_refused), "cond-ethics"))
  k2 <- add_approval(k, "IRB", consent_obtained = TRUE, consent_scope = "broad")
  expect_false(fires(validate_krt(k2), "cond-ethics"))
})

test_that("a non-human biological sample does not trigger the ethics pack", {
  k <- add_resource(new_krt("Demo"), "Biological sample", "Mouse liver",
                    organism = "Mus musculus", new_or_reuse = "new",
                    accession = "SAMN999")
  expect_false(fires(validate_krt(k), "cond-ethics"))
})

test_that("the complete example triggers no conditional findings", {
  r <- validate_krt(krt_example)
  expect_false(fires(r, "cond-organism"))
  expect_false(fires(r, "cond-ethics"))
  expect_false(fires(r, "cond-cellline"))
  expect_false(fires(r, "cond-software"))
})
