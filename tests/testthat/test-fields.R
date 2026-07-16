test_that("field registry is internally consistent", {
  f <- all_fields()
  expect_true(is.list(f))
  expect_true(length(f) > 20L)
  for (nm in names(f)) {
    spec <- f[[nm]]
    expect_identical(spec$name, nm)
    expect_true(is_nonempty_string(spec$group))
    expect_true(spec$type %in% c("string", "enum", "date", "uri", "integer",
                                 "logical", "list"))
    expect_true(spec$cardinality %in% c("one", "many"))
    expect_true(!is.null(spec$applies_to))
    expect_true(is_nonempty_string(spec$label_key))
  }
})

test_that("field_spec and fields_for_type resolve correctly", {
  expect_identical(field_spec("rrid")$group, "identifier")
  expect_identical(field_spec("repository_url")$group, "software")
  expect_null(field_spec("no_such_field"))

  ab <- fields_for_type("Antibody")
  expect_true("antibody_clone" %in% ab)
  expect_true("rrid" %in% ab)              # "all" fields apply everywhere
  expect_false("repository_url" %in% ab)   # software-only field

  sw <- fields_for_type("Software/code")
  expect_true("repository_url" %in% sw)
  expect_false("antibody_clone" %in% sw)
})

test_that("coerce_field applies declared types", {
  expect_identical(coerce_field("new_or_reuse", "NEW"), "new")
  expect_identical(coerce_field("new_or_reuse", "Reuse"), "reuse")
  expect_identical(coerce_field("pmid", 12345), "12345")
  expect_identical(coerce_field("resource_type", "Antibody"), "Antibody")
  expect_null(coerce_field("notes", NULL))
})

test_that("field_label is human readable", {
  expect_identical(field_label("catalog_number"), "Catalog number")
  expect_identical(field_label("rrid"), "Rrid")
})
