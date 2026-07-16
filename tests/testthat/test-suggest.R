test_that("built-in suggest sources are registered", {
  expect_setequal(list_suggest_sources(),
                  c("cellosaurus", "chebi", "ror", "taxonomy"))
})

test_that("offline suggest returns an empty, well-formed frame", {
  s <- krt_suggest("dopamine", authority = "chebi", resolve = FALSE)
  expect_identical(nrow(s), 0L)
  expect_true(all(c("label", "id", "authority", "score", "uri") %in% names(s)))
})

test_that("a custom suggest source is used", {
  register_suggest_source("mock", function(query, n)
    data.frame(label = "Hit", id = "X:1", authority = "mock", score = 1,
               uri = "http://x", stringsAsFactors = FALSE))
  on.exit(rm("mock", envir = krt:::.suggest_registry), add = TRUE)
  s <- krt_suggest("q", authority = "mock")
  expect_identical(s$label[1], "Hit")
})

test_that("a source that errors is caught and yields no rows", {
  register_suggest_source("boom", function(query, n) stop("kaboom"))
  on.exit(rm("boom", envir = krt:::.suggest_registry), add = TRUE)
  expect_identical(nrow(krt_suggest("q", authority = "boom")), 0L)
})

test_that("live suggest degrades gracefully", {
  skip_on_cran()
  skip_if_offline()
  s <- krt_suggest("Homo sapiens", authority = "taxonomy")
  expect_true(is.data.frame(s))
})
