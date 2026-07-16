test_that("id_parse classifies common schemes", {
  expect_identical(id_parse("RRID:AB_390204")$field, "rrid")
  d <- id_parse("https://doi.org/10.5281/zenodo.123")
  expect_identical(d$field, "doi")
  expect_identical(d$value, "10.5281/zenodo.123")
  expect_identical(id_parse("GSE12345")$field, "accession")
  expect_identical(id_parse("Cat# AB152")$field, "catalog_number")
  expect_identical(id_parse("Cat# AB152")$value, "AB152")
  expect_true(is.na(id_parse("just some text with spaces")$scheme))
})

test_that("rrid_type maps authority prefixes to resource types", {
  expect_identical(rrid_type("RRID:AB_390204"), "Antibody")
  expect_identical(rrid_type("CVCL_0063"), "Experimental model: Cell line")
  expect_identical(rrid_type("RRID:SCR_002285"), "Software/code")
  expect_identical(rrid_type("RRID:IMSR_JAX:000664"),
                   "Experimental model: Organism/strain")
  expect_true(is.na(rrid_type("RRID:ZZ_1")))
})

test_that("parse_compound_identifier splits into typed fields", {
  out <- parse_compound_identifier("Cat# AB152; RRID:AB_390204")
  expect_identical(out$catalog_number, "AB152")
  expect_identical(out$rrid, "RRID:AB_390204")

  out2 <- parse_compound_identifier(
    "GEO Accession #: GSE12345; https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi")
  expect_true("GSE12345" %in% out2$accession)
})

test_that("compose_identifier is the inverse for typed fields", {
  r <- new_resource("Antibody", "Anti-TH", catalog_number = "AB152",
                    rrid = "RRID:AB_390204", new_or_reuse = "reuse")
  s <- compose_identifier(r)
  expect_match(s, "Cat# AB152")
  expect_match(s, "RRID:AB_390204")
  back <- parse_compound_identifier(s)
  expect_identical(back$catalog_number, "AB152")
  expect_identical(back$rrid, "RRID:AB_390204")
})

test_that("is_pending_identifier recognizes the ASAP convention", {
  expect_true(is_pending_identifier("Identifier from Cellosaurus pending"))
  expect_false(is_pending_identifier("RRID:AB_390204"))
})
