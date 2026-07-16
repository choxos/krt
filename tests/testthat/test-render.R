test_that("markdown render produces a table", {
  md <- render_krt(krt_example, format = "md")
  expect_match(md, "\\| RESOURCE TYPE \\|")
  expect_match(md, "Rabbit Anti-TH")
})

test_that("STAR profile groups rows under type headers", {
  md <- render_krt(krt_example, format = "md", profile = "star-methods")
  expect_match(md, "REAGENT or RESOURCE")
  expect_match(md, "\\*\\*Antibody\\*\\*")   # section header row
})

test_that("HTML render is well-formed and escapes content", {
  html <- render_krt(krt_example, format = "html")
  expect_match(html, "<table>")
  expect_match(html, "<th>RESOURCE TYPE</th>")
})

test_that("docx render writes a file", {
  skip_if_not_installed("officer")
  f <- tempfile(fileext = ".docx")
  render_krt(krt_example, format = "docx", f)
  expect_true(file.exists(f))
})
