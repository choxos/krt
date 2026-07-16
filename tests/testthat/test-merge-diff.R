mk <- function(name, notes = NULL) {
  add_resource(new_krt(name), "Antibody", "Anti-TH", vendor = "Millipore",
               catalog_number = "AB152", rrid = "RRID:AB_390204",
               new_or_reuse = "reuse", notes = notes)
}

test_that("merge combines distinct resources and merges matching ones", {
  a <- mk("A")
  b <- add_resource(mk("B"), "Dataset", "D", doi = "10.5281/zenodo.1",
                    new_or_reuse = "new")
  m <- krt_merge(a, b)
  expect_identical(length(m$resources), 2L)   # antibody merged, dataset added
})

test_that("field conflicts are resolved by strategy and recorded", {
  a <- mk("A", notes = "from A")
  b <- mk("B", notes = "from B")
  mx <- krt_merge(a, b, strategy = "prefer_x")
  my <- krt_merge(a, b, strategy = "prefer_y")
  expect_identical(mx$resources[[1]]$notes, "from A")
  expect_identical(my$resources[[1]]$notes, "from B")
  expect_length(attr(mx, "merge_conflicts"), 1L)
})

test_that("merge records provenance", {
  m <- krt_merge(mk("A"), mk("B"))
  acts <- vapply(krt_provenance(m), function(e) e$activity, character(1))
  expect_true("merge" %in% acts)
})

test_that("diff reports added, removed, and changed resources", {
  a <- add_resource(new_krt("A"), "Dataset", "D", doi = "10.5281/zenodo.1",
                    new_or_reuse = "new")
  id <- a$resources[[1]]$resource_id
  b <- update_resource(a, id, notes = "added note")
  b <- add_resource(b, "Software/code", "Fiji", rrid = "RRID:SCR_002285",
                    new_or_reuse = "reuse")
  d <- krt_diff(a, b)
  expect_length(d$added, 1L)
  expect_length(d$removed, 0L)
  expect_length(d$changed, 1L)
  df <- as.data.frame(d)
  expect_true("notes" %in% df$field)
  expect_true("added" %in% df$change)
})
