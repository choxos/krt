# The LLM extraction engine: prompt a provider, parse its JSON into resources,
# then funnel them through the same normalize + validate pipeline as every other
# import path. Non-deterministic, so it is never the default and always
# provenance-stamped with the provider and model.

#' @noRd
.parse_llm_json <- function(text) {
  if (is.null(text) || !nzchar(text)) return(list())
  start <- regexpr("[", text, fixed = TRUE)
  end <- .last_index(text, "]")
  if (start < 1L || end < start) return(list())
  frag <- substr(text, start, end)
  parsed <- tryCatch(jsonlite::fromJSON(frag, simplifyVector = FALSE),
                     error = function(e) NULL)
  if (is.null(parsed) || !is.list(parsed)) return(list())
  parsed
}

#' @noRd
.last_index <- function(text, ch) {
  pos <- gregexpr(ch, text, fixed = TRUE)[[1]]
  if (length(pos) && pos[1] > 0L) pos[length(pos)] else -1L
}

#' @noRd
.spec_to_resource <- function(spec) {
  if (!is.list(spec)) return(NULL)
  rt <- spec$resource_type %||% "Other"
  dn <- spec$display_name %||% spec$name
  spec$resource_type <- NULL; spec$display_name <- NULL; spec$name <- NULL
  spec <- Filter(function(v) !is.null(v) && length(v) && nzchar(as.character(v)[1]), spec)
  tryCatch(suppressWarnings(do.call(new_resource, c(list(rt, display_name = dn), spec))),
           error = function(e) NULL)
}

#' Extract resources from text with an LLM
#'
#' Sends the text to the configured provider and parses the returned JSON into
#' candidate resources. Requires an API key (from the environment); returns an
#' empty list if none is configured or the call fails.
#'
#' @param text Manuscript text.
#' @param llm A [krt_llm()] configuration.
#' @param ... Reserved.
#' @return A list of `krt_resource` candidates.
#' @export
#' @examples
#' # Uses a mock provider so no network or key is needed:
#' register_llm_provider("mock",
#'   function(prompt, llm) '[{"resource_type":"Software/code","display_name":"R"}]')
#' extract_llm("text", krt_llm("openai"))  # empty without a key
#' extract_llm("text", structure(list(provider = "mock"), class = "krt_llm"))
extract_llm <- function(text, llm = krt_llm(), ...) {
  prov <- get_llm_provider(llm$provider)
  if (is.null(prov)) stop(sprintf("Unknown LLM provider '%s'.", llm$provider), call. = FALSE)
  out <- tryCatch(prov$request(text, llm), error = function(e) NULL)
  if (is.null(out)) return(list())
  parsed <- if (!is.null(prov$parse)) prov$parse(out) else .parse_llm_json(out)
  Filter(Negate(is.null), lapply(parsed, .spec_to_resource))
}
