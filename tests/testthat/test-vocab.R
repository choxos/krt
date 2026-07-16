test_that("resource-type vocabulary is the 14 ASAP terms", {
  rt <- krt_resource_types()
  expect_length(rt, 14L)
  expect_true(all(c("Antibody", "Dataset", "Software/code",
                    "Experimental model: Cell line",
                    "Experimental model: Organism/strain",
                    "Chemical, peptide, or recombinant protein",
                    "Viral vector", "Other") %in% rt))
})

test_that("new_or_reuse vocabulary is exactly new/reuse", {
  expect_identical(krt_new_or_reuse(), c("new", "reuse"))
})

test_that("krt_vocab errors on unknown vocabulary", {
  expect_error(krt_vocab("nope"), "Unknown vocabulary")
})

test_that("vocab_match handles exact, case-insensitive, and fuzzy", {
  expect_true(vocab_match("Antibody", "resource_type")$ok)
  m_ci <- vocab_match("antibody", "resource_type")
  expect_true(m_ci$ok)
  expect_identical(m_ci$value, "Antibody")

  m_fuzzy <- vocab_match("antibodies", "resource_type", fuzzy = TRUE)
  expect_false(m_fuzzy$ok)
  expect_identical(m_fuzzy$suggestion, "Antibody")

  m_none <- vocab_match("zzz", "resource_type", fuzzy = FALSE)
  expect_false(m_none$ok)
  expect_true(is.na(m_none$suggestion))
})
