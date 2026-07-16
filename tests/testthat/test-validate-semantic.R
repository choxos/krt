raw_res <- function(...) structure(list(...), class = "krt_resource")
tbl_with <- function(...) { k <- new_krt("Test"); k$resources <- list(...); k }
fires <- function(report, rule) rule %in% as.data.frame(report)$rule_id

test_that("RRID authority prefix vs resource type mismatch warns", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Antibody",
                        display_name = "d", new_or_reuse = "reuse",
                        rrid = "RRID:CVCL_0063"))
  expect_true(fires(validate_krt(k, layers = "semantic"), "sem-rrid-type"))
})

test_that("SCR RRID is accepted on Dataset (broad authority)", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                        display_name = "d", new_or_reuse = "reuse",
                        rrid = "RRID:SCR_002285"))
  expect_false(fires(validate_krt(k, layers = "semantic"), "sem-rrid-type"))
})

test_that("catalog number sitting in the rrid field warns", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Antibody",
                        display_name = "d", new_or_reuse = "reuse",
                        rrid = "AB152"))
  expect_true(fires(validate_krt(k, layers = "semantic"), "sem-catalog-in-rrid"))
})

test_that("un-normalized DOI form is a note", {
  k <- tbl_with(raw_res(resource_id = "r1", resource_type = "Dataset",
                        display_name = "d", new_or_reuse = "new",
                        doi = "https://doi.org/10.5281/zenodo.1"))
  expect_true(fires(validate_krt(k, layers = "semantic"), "sem-doi-form"))
})

test_that("cellosaurus id inconsistent with the CVCL RRID warns", {
  k <- tbl_with(raw_res(resource_id = "r1",
                        resource_type = "Experimental model: Cell line",
                        display_name = "d", new_or_reuse = "reuse",
                        rrid = "RRID:CVCL_0063", cellosaurus_id = "CVCL_9999",
                        authentication_method = "STR", mycoplasma_status = "negative"))
  expect_true(fires(validate_krt(k, layers = "semantic"), "sem-cellosaurus-consistency"))
})

test_that("duplicate resources produce a semantic warning", {
  k <- new_krt("Demo")
  k <- add_resource(k, "Antibody", "A", vendor = "V", catalog_number = "C1",
                    rrid = "RRID:AB_1", new_or_reuse = "reuse")
  k <- add_resource(k, "Antibody", "A2", vendor = "V", catalog_number = "C1",
                    rrid = "RRID:AB_1", new_or_reuse = "reuse")
  expect_true(fires(validate_krt(k, layers = "semantic"), "sem-duplicates"))
})
