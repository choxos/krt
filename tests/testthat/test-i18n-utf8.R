test_that("UTF-8 content survives JSON and YAML round-trips", {
  k <- add_resource(new_krt("Estudio café"), "Antibody", "Anticorps anti-é",
                    vendor = "Fabricant français", new_or_reuse = "reuse",
                    rrid = "RRID:AB_1")
  k2 <- read_krt_json(write_krt_json(k))
  expect_identical(k2$resources[[1]]$display_name, "Anticorps anti-é")
  expect_identical(k2$title, "Estudio café")
  k3 <- read_krt_yaml(write_krt_yaml(k))
  expect_identical(k3$resources[[1]]$vendor, "Fabricant français")
})

test_that("translation catalogs are present and compiled", {
  expect_true(file.exists(file.path("..", "..", "po", "R-krt.pot")) ||
                nzchar(system.file("po", package = "krt")))
  # Installed .mo catalogs (fr, es) ship with the package.
  mo <- system.file("po", "fr", "LC_MESSAGES", "R-krt.mo", package = "krt")
  if (nzchar(system.file("po", package = "krt"))) expect_true(nzchar(mo))
})

test_that("field_label passes through the translation domain without error", {
  expect_identical(field_label("catalog_number"), "Catalog number")
  expect_type(field_label("rrid"), "character")
})

test_that("locale is preserved on the table", {
  k <- new_krt("t", locale = "fr-FR")
  expect_identical(k$locale, "fr-FR")
  expect_identical(read_krt_json(write_krt_json(k))$locale, "fr-FR")
})
