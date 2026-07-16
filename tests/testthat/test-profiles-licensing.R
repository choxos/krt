test_that("built-in profiles are registered", {
  p <- krt_profiles()
  expect_true(all(c("asap", "generic", "star-methods") %in% p$name))
  expect_identical(p$license[p$name == "asap"], "CC-BY-4.0")
})

test_that("asap profile has the six ASAP columns; generic is passthrough", {
  expect_identical(get_profile("asap")$columns,
                   c("RESOURCE TYPE", "RESOURCE NAME", "SOURCE", "IDENTIFIER",
                     "NEW/REUSE", "ADDITIONAL INFORMATION"))
  expect_true(isTRUE(get_profile("generic")$passthrough))
  expect_error(get_profile("nope"), "Unknown profile")
})

test_that("projection composes the ASAP IDENTIFIER and maps direct columns", {
  r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
                    catalog_number = "AB152", rrid = "RRID:AB_390204",
                    new_or_reuse = "reuse")
  m <- apply_mapping(r, "asap")
  expect_identical(m[["RESOURCE TYPE"]], "Antibody")
  expect_match(m[["IDENTIFIER"]], "Cat# AB152")
  expect_match(m[["IDENTIFIER"]], "RRID:AB_390204")

  df <- project_profile(krt_example, "asap")
  expect_identical(names(df), get_profile("asap")$columns)
  expect_identical(nrow(df), length(krt_example$resources))
  expect_identical(as.data.frame(krt_example, view = "asap"), df)
})

test_that("lossy fields are reported for ASAP but not for generic", {
  lossy <- mapping_lossy_fields(krt_example, "asap")
  expect_true(length(lossy) > 0L)
  expect_true("target" %in% lossy || "antibody_host" %in% lossy)
  expect_length(mapping_lossy_fields(krt_example, "generic"), 0L)
})

test_that("profile severity overrides change validity", {
  k <- new_krt("x")
  k$resources <- list(structure(list(resource_id = "r1", resource_type = "Dataset",
                                     display_name = "d", new_or_reuse = "new"),
                                class = "krt_resource"))
  expect_true(validate_krt(k, profile = "generic")$valid)
  expect_false(validate_krt(k, profile = "asap")$valid)
})

test_that("license introspection and audit", {
  expect_identical(krt_profile_license("asap"), "CC-BY-4.0")
  expect_identical(krt_profile_sources("asap")$doi, "10.5281/zenodo.17917979")
  aud <- krt_audit_licenses()
  expect_true(all(c("component", "license", "redistributable") %in% names(aud)))
  expect_true(any(aud$license == "CC-BY-4.0"))
  expect_true(any(aud$license == "GPL-3.0-only"))
})

test_that("attribution is emitted for the ASAP profile", {
  att <- krt_attribution("asap")
  expect_match(att, "ASAP")
  expect_match(att, "CC BY 4.0")
  f <- tempfile(fileext = ".md")
  krt_write_attribution("asap", f)
  expect_true(file.exists(f))
})

test_that("a custom profile can be registered (plugin SDK)", {
  dir <- file.path(tempfile("prof"))
  dir.create(dir)
  writeLines(c("name: mytest", "version: '1.0.0'", "title: Test",
               "license: MIT", "passthrough: true"),
             file.path(dir, "schema.yml"))
  writeLines("passthrough: true", file.path(dir, "mappings.yml"))
  register_profile(name = "mytest", path = dir)
  on.exit(rm("mytest", envir = krt:::.profile_registry), add = TRUE)
  expect_true("mytest" %in% krt_profiles()$name)
  expect_true(isTRUE(get_profile("mytest")$passthrough))
})
