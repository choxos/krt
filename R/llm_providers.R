# Built-in LLM provider request functions. Each returns the model's text output
# (expected to be a JSON array of resources) or NULL. All read keys from the
# environment and never run during CRAN checks (the extraction tests use a mock
# provider and skip live calls).

#' @noRd
.llm_content <- function(prompt) {
  paste0(
    "You extract a Key Resources Table from a scientific manuscript. ",
    "Return ONLY a JSON array; each element has keys: resource_type (one of the ",
    "14 KRT types), display_name, source_name, vendor, catalog_number, rrid, ",
    "doi, accession, new_or_reuse ('new' or 'reuse'), notes. Omit unknown keys. ",
    "Text:\n", prompt)
}

#' @noRd
llm_openai <- function(prompt, llm) {
  if (!nzchar(llm$api_key %||% "")) return(NULL)
  resp <- http_post_json(
    "https://api.openai.com/v1/chat/completions",
    body = list(model = llm$model, temperature = llm$temperature,
                messages = list(list(role = "user", content = .llm_content(prompt)))),
    token = llm$api_key)
  j <- .resp_json(resp)
  .dig(j, "choices", 1L, "message", "content")
}

#' @noRd
llm_anthropic <- function(prompt, llm) {
  if (!nzchar(llm$api_key %||% "")) return(NULL)
  resp <- http_post_json(
    "https://api.anthropic.com/v1/messages",
    body = list(model = llm$model, max_tokens = llm$max_tokens,
                messages = list(list(role = "user", content = .llm_content(prompt)))),
    headers = list(`x-api-key` = llm$api_key, `anthropic-version` = "2023-06-01"))
  j <- .resp_json(resp)
  .dig(j, "content", 1L, "text")
}

#' @noRd
llm_gemini <- function(prompt, llm) {
  if (!nzchar(llm$api_key %||% "")) return(NULL)
  url <- sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent",
                 llm$model)
  resp <- http_post_json(url,
    body = list(contents = list(list(parts = list(list(text = .llm_content(prompt)))))),
    headers = list(`x-goog-api-key` = llm$api_key))
  j <- .resp_json(resp)
  .dig(j, "candidates", 1L, "content", "parts", 1L, "text")
}

#' @noRd
llm_openai_compat <- function(prompt, llm) {
  base <- llm$base_url %||% ""
  if (!nzchar(base)) return(NULL)
  resp <- http_post_json(
    paste0(sub("/$", "", base), "/v1/chat/completions"),
    body = list(model = llm$model, temperature = llm$temperature,
                messages = list(list(role = "user", content = .llm_content(prompt)))),
    token = if (nzchar(llm$api_key %||% "")) llm$api_key else NULL)
  j <- .resp_json(resp)
  .dig(j, "choices", 1L, "message", "content")
}
