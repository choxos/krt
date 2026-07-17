# STAR Methods template compliance, and Shiny/package rendering harmony.

# The twelve fixed Cell Press STAR category subheadings, in template order.
star_cats <- c(
  "Antibodies", "Bacterial and virus strains", "Biological samples",
  "Chemicals, peptides, and recombinant proteins", "Critical commercial assays",
  "Deposited data", "Experimental models: Cell lines",
  "Experimental models: Organisms/strains", "Oligonucleotides",
  "Recombinant DNA", "Software and algorithms", "Other")

test_that("the star-methods profile matches the Cell Press template", {
  p <- get_profile("star-methods")
  expect_identical(as.character(unlist(p$sections$order)), star_cats)
  expect_identical(p$columns, c("REAGENT or RESOURCE", "SOURCE", "IDENTIFIER"))
  # every one of the 14 core types maps to one of the 12 template categories
  mapped <- vapply(krt_resource_types(),
                   function(ty) as.character(p$sections$map[[ty]] %||% "Other"),
                   character(1))
  expect_true(all(mapped %in% star_cats))
})

test_that("STAR render groups resources under category headers, in order", {
  html <- render_krt(krt_example, format = "html", profile = "star-methods")
  expect_match(html, "class=\"krt-section\"")                    # section rows exist
  # categories that appear must be in the template order
  present <- star_cats[vapply(star_cats, function(c) grepl(c, html, fixed = TRUE),
                              logical(1))]
  pos <- vapply(present, function(c) regexpr(c, html, fixed = TRUE)[1], integer(1))
  expect_identical(pos, sort(pos))
  # a resource sits under its category, not in a flat list
  md <- render_krt(krt_example, format = "md", profile = "star-methods")
  expect_match(md, "\\*\\*Antibodies\\*\\*")
})

test_that("ASAP renders as the flat six-column format, not grouped", {
  expect_identical(get_profile("asap")$columns,
                   c("RESOURCE TYPE", "RESOURCE NAME", "SOURCE", "IDENTIFIER",
                     "NEW/REUSE", "ADDITIONAL INFORMATION"))
  html <- render_krt(krt_example, format = "html", profile = "asap")
  expect_false(grepl("krt-section", html))                       # no category rows
})

test_that("the Shiny app renders grouped profiles through render_krt (harmony)", {
  skip_on_cran()
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("DT")
  app_dir <- system.file("shiny-apps", "krt", package = "krt")
  skip_if(!nzchar(app_dir))
  shiny::testServer(app_dir, {
    session$setInputs(profile = "star-methods")
    expect_true(is_grouped())                                    # STAR -> grouped render
    expect_false(is_wide())
    session$setInputs(profile = "asap")
    expect_false(is_grouped())                                   # ASAP -> flat table
    session$setInputs(profile = "generic")
    expect_true(is_wide())                                       # generic -> editable
  })
})
