mock_llm <- function(provider = "mock") structure(list(provider = provider),
                                                  class = "krt_llm")

test_that("built-in LLM providers are registered", {
  expect_setequal(list_llm_providers(),
                  c("anthropic", "gemini", "openai", "openai_compat"))
})

test_that("a mock provider drives extraction end to end", {
  register_llm_provider("mock", function(prompt, llm)
    'Result: [{"resource_type":"Software/code","display_name":"R","rrid":"RRID:SCR_001905","new_or_reuse":"reuse"}]')
  on.exit(rm("mock", envir = krt:::.llm_registry), add = TRUE)
  cand <- extract_llm("some text", mock_llm())
  expect_length(cand, 1L)
  expect_identical(cand[[1]]$display_name, "R")

  res <- extract_krt("text", engine = "llm", llm = mock_llm())
  expect_identical(length(res$krt$resources), 1L)
})

test_that("JSON embedded in prose is parsed; malformed output yields nothing", {
  register_llm_provider("prose", function(prompt, llm)
    'Sure, here you go:\n[{"resource_type":"Dataset","display_name":"D"}]\nHope that helps!')
  register_llm_provider("bad", function(prompt, llm) "I could not find any resources.")
  on.exit({ rm("prose", envir = krt:::.llm_registry); rm("bad", envir = krt:::.llm_registry) },
          add = TRUE)
  expect_length(extract_llm("t", mock_llm("prose")), 1L)
  expect_length(extract_llm("t", mock_llm("bad")), 0L)
})

test_that("a provider without an API key returns no candidates", {
  expect_length(extract_llm("text", krt_llm("openai", api_key = "")), 0L)
  expect_length(extract_llm("text", krt_llm("anthropic", api_key = "")), 0L)
})

test_that("krt_llm resolves sensible defaults", {
  cfg <- krt_llm("openai", model = "gpt-4o-mini")
  expect_identical(cfg$provider, "openai")
  expect_identical(cfg$model, "gpt-4o-mini")
})
