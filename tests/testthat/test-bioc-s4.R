test_that("krt_tbl coerces to the S4 KRT class and back losslessly", {
  k4 <- methods::as(krt_example, "KRT")
  expect_true(methods::is(k4, "KRT"))
  expect_identical(length(k4@resources), length(krt_example$resources))
  back <- methods::as(k4, "krt_tbl")
  expect_true(is_krt(back))
  expect_identical(krt:::.krt_to_list(back)$resources,
                   krt:::.krt_to_list(krt_example)$resources)
  expect_identical(back$table_id, krt_example$table_id)
})

test_that("as_krt and as_KRT are convenient wrappers", {
  expect_true(methods::is(as_KRT(krt_example), "KRT"))
  expect_true(is_krt(as_krt(as_KRT(krt_example))))
  expect_true(is_krt(as_krt(krt_example)))          # idempotent
  expect_error(as_krt(42), "Cannot coerce")
})

test_that("DataFrame coercion is available when S4Vectors is installed", {
  skip_if_not_installed("S4Vectors")
  df <- krt_as_dataframe(krt_example)
  expect_s4_class(df, "DataFrame")
  expect_identical(nrow(df), length(krt_example$resources))
})
