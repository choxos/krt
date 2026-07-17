test_that("markdown render produces a table", {
  md <- render_krt(krt_example, format = "md")
  expect_match(md, "\\| RESOURCE TYPE \\|")
  expect_match(md, "Rabbit Anti-TH")
})

test_that("STAR profile uses the three columns and category section headers", {
  md <- render_krt(krt_example, format = "md", profile = "star-methods")
  # The three Cell Press columns, in order.
  expect_match(md, "\\| REAGENT or RESOURCE \\| SOURCE \\| IDENTIFIER \\|")
  # Section headers are STAR category names, not raw resource types.
  expect_match(md, "\\*\\*Antibodies\\*\\*")
  expect_false(grepl("\\*\\*Antibody\\*\\*", md))
})

test_that("STAR sections follow the template order and map the 14 types onto 12", {
  k <- new_krt("S", profile = "star-methods")
  k <- add_resource(k, "Software/code", "Fiji", rrid = "RRID:SCR_1", new_or_reuse = "reuse")
  k <- add_resource(k, "Antibody", "Ab", vendor = "V", catalog_number = "1", new_or_reuse = "reuse")
  k <- add_resource(k, "Viral vector", "AAV", vendor = "Addgene", new_or_reuse = "reuse")
  k <- add_resource(k, "Bacterial strain", "DH5a", vendor = "NEB", new_or_reuse = "reuse")
  k <- add_resource(k, "Protocol", "P", doi = "10.17504/x", new_or_reuse = "new")
  md <- render_krt(k, format = "md", profile = "star-methods")
  # Antibodies before Bacterial and virus strains before Software before Other.
  pos <- function(h) regexpr(h, md, fixed = TRUE)
  expect_true(pos("**Antibodies**") < pos("**Bacterial and virus strains**"))
  expect_true(pos("**Bacterial and virus strains**") < pos("**Software and algorithms**"))
  expect_true(pos("**Software and algorithms**") < pos("**Other**"))
  # Bacterial strain and viral vector share one category; protocol falls in Other.
  expect_match(md, "\\*\\*Bacterial and virus strains\\*\\*")
  expect_false(grepl("\\*\\*Viral vector\\*\\*", md))
})

test_that("HTML render is well-formed and escapes content", {
  html <- render_krt(krt_example, format = "html")
  expect_match(html, "<table class=\"krt-table\">")
  expect_match(html, "<th>RESOURCE TYPE</th>")
})

test_that("docx render writes a file", {
  skip_if_not_installed("officer")
  f <- tempfile(fileext = ".docx")
  render_krt(krt_example, format = "docx", f)
  expect_true(file.exists(f))
})
