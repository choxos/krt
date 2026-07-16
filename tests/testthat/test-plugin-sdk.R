test_that("the plugin API lists all five extension points", {
  api <- krt_plugin_api()
  expect_setequal(api$kind, c("profile", "validator", "resolver", "llm_provider",
                              "suggest_source"))
  expect_true(all(api$register %in% c("register_profile", "register_validator",
    "register_resolver", "register_llm_provider", "register_suggest_source")))
})

test_that("validate_plugin_contract accepts conforming objects", {
  expect_true(validate_plugin_contract("validator", function(x, ctx) list()))
  expect_true(validate_plugin_contract("resolver", function(id, resolve = TRUE) NULL))
  expect_true(validate_plugin_contract("llm_provider", function(prompt, llm) ""))
  expect_true(validate_plugin_contract("suggest_source", function(query, n) NULL))
})

test_that("validate_plugin_contract rejects nonconforming objects", {
  expect_error(validate_plugin_contract("resolver", function() NULL), "contract")
  expect_error(validate_plugin_contract("llm_provider", function(only_one) NULL), "contract")
  expect_error(validate_plugin_contract("profile", 42), "contract")
})

test_that("the five registration entry points are all exported functions", {
  for (fn in krt_plugin_api()$register) {
    expect_true(is.function(get(fn, envir = asNamespace("krt"))))
  }
})
