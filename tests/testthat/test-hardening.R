# Regression tests for the pre-release hardening pass.

test_that("krt_merge does not collapse distinct identifier-less resources", {
  a <- add_resource(new_krt("A"), "Other", "Thing One", new_or_reuse = "new")
  a <- add_resource(a, "Other", "Thing Two", new_or_reuse = "new")
  m <- krt_merge(a, new_krt("B"))
  expect_equal(length(m$resources), 2L)
  nms <- vapply(m$resources, function(r) r$display_name, character(1))
  expect_setequal(nms, c("Thing One", "Thing Two"))
})

test_that("krt_merge keeps approvals and contributors even with zero resources", {
  a <- add_approval(new_krt("A"), "IRB", protocol_number = "P1")
  b <- add_contributor(new_krt("B"), "Jane Doe")
  m <- krt_merge(a, b)
  expect_equal(length(m$approvals), 1L)
  expect_equal(length(m$contributors), 1L)
})

test_that("krt_merge validates every input table, including those in ...", {
  expect_error(krt_merge(new_krt("A"), new_krt("B"), list(not = "a table")),
               "krt_tbl objects")
})

test_that("importing a data frame with unknown headers does not crash", {
  df <- data.frame(foo = 1:2, bar = c("a", "b"), stringsAsFactors = FALSE)
  k <- import_krt(df)
  expect_true(is_krt(k))
  expect_identical(k$profile, "generic")
})

test_that("a generic identifier column is typed, not forced into rrid", {
  df <- data.frame(type = "Dataset", name = "D",
                   identifier = "10.5281/zenodo.123",
                   check.names = FALSE, stringsAsFactors = FALSE)
  r <- import_tabular(df)$resources[[1]]
  expect_identical(r$doi, "10.5281/zenodo.123")
  expect_null(r$rrid)
})

test_that(".has_value rejects NA and whitespace-only values", {
  expect_false(krt:::.has_value(list(display_name = NA_character_), "display_name"))
  expect_false(krt:::.has_value(list(display_name = "   "), "display_name"))
  expect_true(krt:::.has_value(list(display_name = "X"), "display_name"))
})

test_that("table ids are unique across same-titled tables", {
  expect_false(identical(new_krt("Same")$table_id, new_krt("Same")$table_id))
})

test_that("registration rejects silent overwrite of an existing rule", {
  existing <- list_validators()$rule_id[1]
  expect_error(register_validator(existing, function(x, ctx) list()),
               "already registered")
})

test_that("bare RRID authority tokens are parsed as RRIDs", {
  expect_identical(id_parse("AB_390204")$field, "rrid")
  expect_identical(id_parse("AB_390204")$value, "RRID:AB_390204")
  expect_identical(id_parse("SCR_002285")$field, "rrid")
  # Cellosaurus keeps its own field.
  expect_identical(id_parse("CVCL_0030")$field, "cellosaurus_id")
})

test_that("a Cellosaurus-only cell line composes a non-empty ASAP IDENTIFIER", {
  expect_identical(compose_identifier(list(cellosaurus_id = "CVCL_0030")),
                   "RRID:CVCL_0030")
  # No doubled prefix from a lowercased input.
  expect_identical(compose_identifier(list(rrid = "rrid:AB_1")), "RRID:AB_1")
})

test_that("multiple accessions round-trip through compose and parse", {
  s <- compose_identifier(list(accession = c("SAMN1", "SAMN2")))
  expect_setequal(parse_compound_identifier(s)$accession, c("SAMN1", "SAMN2"))
})

test_that("contributor identifiers in a compound string are kept, not dropped", {
  p <- parse_compound_identifier(
    "RRID:AB_1; https://orcid.org/0000-0001-6829-0823")
  expect_identical(p$rrid, "RRID:AB_1")
  expect_true(any(grepl("orcid", unlist(p$other))))
  expect_null(p$orcid)
})

test_that("humanized animal models are not treated as human material", {
  hz <- list(organism = "Humanized NSG mouse")
  expect_false(krt:::.is_human_resource(hz))
  expect_true(krt:::.is_human_resource(list(taxon_id = "NCBI:txid9606")))
  expect_true(krt:::.is_human_resource(list(organism = "Homo sapiens")))
})

test_that("a bare consent scope no longer satisfies the ethics rule", {
  k <- add_resource(new_krt("D"), "Biological sample", "Serum",
                    organism = "Homo sapiens", taxon_id = "9606",
                    new_or_reuse = "new", accession = "SAMN1")
  k1 <- add_approval(k, "IRB", consent_scope = "broad")
  expect_true("cond-ethics" %in% as.data.frame(validate_krt(k1))$rule_id)
  k2 <- add_approval(k, "IRB", consent_obtained = TRUE)
  expect_false("cond-ethics" %in% as.data.frame(validate_krt(k2))$rule_id)
})

test_that("cell-line pack rejects meaningless authentication and flags mycoplasma", {
  k <- add_resource(new_krt("D"), "Experimental model: Cell line", "X",
                    rrid = "RRID:CVCL_0030", new_or_reuse = "reuse",
                    authentication_method = "none", mycoplasma_status = "positive")
  msgs <- as.data.frame(validate_krt(k))$message
  expect_true(any(grepl("meaningful authentication", msgs)))
  expect_true(any(grepl("mycoplasma-positive", msgs)))
})

test_that("RO-Crate has datePublished, an author, and a CreateAction", {
  k <- add_contributor(krt_example, "Ada Researcher")
  g <- jsonlite::fromJSON(as_rocrate(k), simplifyVector = FALSE)$`@graph`
  types <- vapply(g, function(e) e$`@type` %||% "", character(1))
  root <- Filter(function(e) identical(e$`@id`, "./"), g)[[1]]
  expect_false(is.null(root$datePublished))
  expect_false(is.null(root$author))
  expect_true("CreateAction" %in% types)
  expect_true("Person" %in% types)
})

test_that("PROV-JSON links activities with prov:informed/prov:informant", {
  k <- normalize_ids(add_resource(new_krt("M"), "Antibody", "A",
                                  rrid = "RRID:AB_1", new_or_reuse = "reuse"))
  d <- jsonlite::fromJSON(as_prov_json(k), simplifyVector = FALSE)
  expect_true(length(d$wasInformedBy) >= 1L)
  rel <- d$wasInformedBy[[1]]
  expect_false(is.null(rel$`prov:informed`))
  expect_false(is.null(rel$`prov:informant`))
})
