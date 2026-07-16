iso_re <- "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"

test_that("new_krt sets sane defaults", {
  k <- new_krt("My study", study_type = c("wet-lab", "computational"))
  expect_true(is_krt(k))
  expect_identical(k$schema_version, "1.0.0")
  expect_identical(k$profile, "generic")
  expect_true(is_nonempty_string(k$table_id))
  expect_match(k$created_at, iso_re)
  expect_match(k$updated_at, iso_re)
  expect_identical(k$study_type, c("wet-lab", "computational"))
  expect_length(k$resources, 0L)
})

test_that("new_resource validates type and builds a present-only record", {
  r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
                    rrid = "RRID:AB_390204", new_or_reuse = "reuse")
  expect_s3_class(r, "krt_resource")
  expect_identical(r$resource_type, "Antibody")
  expect_true(is_nonempty_string(r$resource_id))
  expect_false("doi" %in% names(r))       # absent fields are not stored as NA
  expect_error(new_resource("Antibodies", "x"), "Unknown resource_type")
  expect_warning(new_resource("Dataset", "D", bogus = 1, new_or_reuse = "new"),
                 "unknown resource field")
})

test_that("add_resource appends and assigns unique ids", {
  k <- new_krt("Demo")
  k <- add_resource(k, "Dataset", "D1", new_or_reuse = "new")
  k <- add_resource(k, "Dataset", "D1", new_or_reuse = "new")  # same content
  expect_length(k$resources, 2L)
  ids <- vapply(k$resources, function(r) r$resource_id, character(1))
  expect_length(unique(ids), 2L)
})

test_that("add_resource accepts a prebuilt resource", {
  r <- new_resource("Software/code", "Fiji", new_or_reuse = "reuse")
  k <- add_resource(new_krt("Demo"), r)
  expect_length(k$resources, 1L)
  expect_identical(k$resources[[1]]$display_name, "Fiji")
})

test_that("update_resource sets and clears fields", {
  k <- add_resource(new_krt("Demo"), "Dataset", "D1", new_or_reuse = "new")
  id <- k$resources[[1]]$resource_id
  k <- update_resource(k, id, notes = "Figure 1")
  expect_identical(get_resource(k, id)$notes, "Figure 1")
  k <- update_resource(k, id, notes = NA)   # NA clears
  expect_false("notes" %in% names(get_resource(k, id)))
  expect_error(update_resource(k, "no-id", notes = "x"), "No resource")
})

test_that("remove_resource and get_resource behave", {
  k <- add_resource(new_krt("Demo"), "Dataset", "D1", new_or_reuse = "new")
  id <- k$resources[[1]]$resource_id
  expect_null(get_resource(k, "missing"))
  k <- remove_resource(k, id)
  expect_length(k$resources, 0L)
  expect_error(remove_resource(k, id), "No resource")
})

test_that("as.data.frame produces a rectangular wide view with NA fill", {
  k <- new_krt("Demo")
  k <- add_resource(k, "Antibody", "Anti-TH", rrid = "RRID:AB_390204",
                    new_or_reuse = "reuse")
  k <- add_resource(k, "Dataset", "Counts", doi = "10.5281/zenodo.1",
                    accession = c("GSE111", "GSE222"), new_or_reuse = "new")
  df <- as.data.frame(k)
  expect_s3_class(df, "data.frame")
  expect_identical(nrow(df), 2L)
  expect_true(all(c("resource_id", "resource_type") %in% names(df)))
  # antibody row has NA doi; dataset row has NA rrid
  expect_true(is.na(df$doi[df$resource_type == "Antibody"]))
  expect_true(is.na(df$rrid[df$resource_type == "Dataset"]))
  # many-valued accession collapses in the view
  expect_identical(df$accession[df$resource_type == "Dataset"], "GSE111; GSE222")
})

test_that("empty table views and summary are well-formed", {
  k <- new_krt("Empty")
  expect_identical(nrow(as.data.frame(k)), 0L)
  expect_identical(nrow(summary(k)), 0L)
})

test_that("summary counts new vs reuse per type", {
  s <- summary(krt_example)
  expect_true(all(c("resource_type", "n", "n_new", "n_reuse") %in% names(s)))
  expect_identical(sum(s$n), length(krt_example$resources))
  ds <- s[s$resource_type == "Dataset", ]
  expect_identical(ds$n_new, 1L)
})

test_that("krt_meta getter and setter", {
  k <- new_krt("Old")
  expect_identical(krt_meta(k)$title, "Old")
  krt_meta(k) <- list(title = "New", study_type = "computational")
  expect_identical(k$title, "New")
  expect_identical(k$study_type, "computational")
})

test_that("print returns object invisibly", {
  expect_output(print(krt_example), "krt_tbl")
  expect_invisible(print(krt_example))
})
