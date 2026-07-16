# Registry of LLM providers for the optional AI extraction engine. Each provider
# is a function that takes a prompt and a config and returns the model's text
# output (or NULL on failure). Keys are read from environment variables; nothing
# is sent anywhere unless the user explicitly runs the LLM engine.

.llm_registry <- new.env(parent = emptyenv())

#' Register an LLM provider
#'
#' @param name Provider name (e.g. `"openai"`, `"anthropic"`, a local endpoint).
#' @param request_fn A function `function(prompt, llm)` returning the model's
#'   text output, or `NULL` on failure.
#' @param parse_fn Optional custom parser `function(text)`; defaults to JSON
#'   array extraction.
#' @return Invisibly `NULL`.
#' @export
#' @examples
#' register_llm_provider("echo", function(prompt, llm) "[]")
#' "echo" %in% list_llm_providers()
register_llm_provider <- function(name, request_fn, parse_fn = NULL) {
  if (!is.function(request_fn)) stop("`request_fn` must be a function.", call. = FALSE)
  .llm_registry[[name]] <- list(request = request_fn, parse = parse_fn)
  invisible(NULL)
}

#' @noRd
get_llm_provider <- function(name) .llm_registry[[name]]

#' List registered LLM providers
#' @return A character vector of provider names.
#' @export
#' @examples
#' list_llm_providers()
list_llm_providers <- function() sort(ls(.llm_registry))

#' Configure an LLM for extraction
#'
#' @param provider One of the registered providers (`"openai"`, `"anthropic"`,
#'   `"gemini"`, `"openai_compat"` for local/OpenAI-compatible servers).
#' @param model Model id (a sensible default per provider when `NULL`).
#' @param base_url Base URL for `"openai_compat"` (e.g. a local server).
#' @param api_key API key; defaults to the provider's environment variable.
#' @param temperature,max_tokens Generation parameters.
#' @return A `krt_llm` configuration object.
#' @export
#' @examples
#' krt_llm("openai", model = "gpt-4o-mini")$provider
krt_llm <- function(provider = c("openai", "anthropic", "gemini", "openai_compat"),
                    model = NULL, base_url = NULL, api_key = NULL,
                    temperature = 0, max_tokens = 4096) {
  provider <- match.arg(provider)
  key <- api_key %||% switch(provider,
    openai = Sys.getenv("OPENAI_API_KEY"),
    anthropic = Sys.getenv("ANTHROPIC_API_KEY"),
    gemini = { g <- Sys.getenv("GEMINI_API_KEY"); if (nzchar(g)) g else Sys.getenv("GOOGLE_API_KEY") },
    openai_compat = Sys.getenv("KRT_LLM_API_KEY"))
  model <- model %||% switch(provider,
    openai = "gpt-4o-mini", anthropic = "claude-3-5-sonnet-latest",
    gemini = "gemini-1.5-flash",
    openai_compat = { m <- Sys.getenv("KRT_LLM_MODEL"); if (nzchar(m)) m else "local-model" })
  base_url <- base_url %||% if (identical(provider, "openai_compat")) Sys.getenv("KRT_LLM_BASE_URL") else NULL
  structure(list(provider = provider, model = model, base_url = base_url,
                 api_key = key, temperature = temperature, max_tokens = max_tokens),
            class = "krt_llm")
}

#' @noRd
.register_builtin_llm_providers <- function() {
  register_llm_provider("openai", llm_openai)
  register_llm_provider("anthropic", llm_anthropic)
  register_llm_provider("gemini", llm_gemini)
  register_llm_provider("openai_compat", llm_openai_compat)
  invisible()
}
