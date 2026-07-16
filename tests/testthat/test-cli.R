test_that("option parser splits positionals, valued flags, and switches", {
  o <- krt:::.parse_cli_opts(c("file.json", "--profile", "asap", "--verbose"))
  expect_identical(o$positional, "file.json")
  expect_identical(o$flags$profile, "asap")
  expect_true(isTRUE(o$flags$verbose))
})

test_that("validate returns 0 for a valid table and 1 for an invalid one", {
  f <- tempfile(fileext = ".json")
  writeLines(write_krt_json(krt_example), f)
  out <- capture.output(status <- krt_cli(c("validate", f)))
  expect_identical(status, 0L)

  bad <- new_krt("Bad")
  bad$resources <- list(structure(list(resource_id = "r1", resource_type = "Dataset"),
                                  class = "krt_resource"))
  bf <- tempfile(fileext = ".json")
  writeLines(write_krt_json(bad), bf)
  out2 <- capture.output(status2 <- krt_cli(c("validate", bf)))
  expect_identical(status2, 1L)
})

test_that("new and export write files", {
  o <- tempfile(fileext = ".json")
  krt_cli(c("new", "--title", "T", "--out", o))
  expect_true(file.exists(o))

  f <- tempfile(fileext = ".json"); writeLines(write_krt_json(krt_example), f)
  oc <- tempfile(fileext = ".csv")
  suppressWarnings(out <- capture.output(krt_cli(c("export", f, "--out", oc, "--format", "asap"))))
  expect_true(file.exists(oc))

  # With --format omitted, the format is inferred from the path (not JSON).
  oc2 <- tempfile(fileext = ".csv")
  suppressWarnings(capture.output(krt_cli(c("export", f, "--out", oc2))))
  first <- readLines(oc2)[1]
  expect_false(startsWith(trimws(first), "{"))
  expect_true(grepl(",", first))
})

test_that("audit-licenses and help run cleanly", {
  expect_identical(capture.output(s <- krt_cli("audit-licenses")) |> length() > 0, TRUE)
  expect_identical(s, 0L)
  expect_identical({ out <- capture.output(h <- krt_cli("--help")); h }, 0L)
})

test_that("an unknown command reports a nonzero status", {
  out <- capture.output(s <- krt_cli("frobnicate"))
  expect_identical(s, 2L)
})
