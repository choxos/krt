# The public plugin SDK: five registration entry points let institutions add
# profiles, validators, resolvers, LLM providers, and suggest sources without
# forking the package. See vignette("extending-krt").

#' Extend krt with plugins
#'
#' krt is extensible through five registries. Register custom components with the
#' corresponding function; [krt_plugin_api()] lists the entry points and their
#' contracts, and [validate_plugin_contract()] checks an object before you
#' register it.
#'
#' @seealso [register_profile()], [register_validator()], [register_resolver()],
#'   [register_llm_provider()], [register_suggest_source()].
#' @name krt_plugins
NULL

#' The krt plugin API
#'
#' @return A data frame describing each plugin kind, its registration function,
#'   and its contract.
#' @export
#' @examples
#' krt_plugin_api()
krt_plugin_api <- function() {
  data.frame(
    kind = c("profile", "validator", "resolver", "llm_provider", "suggest_source"),
    register = c("register_profile", "register_validator", "register_resolver",
                 "register_llm_provider", "register_suggest_source"),
    contract = c(
      "a directory with schema.yml + mappings.yml, or a krt_profile object",
      "function(x, ctx) returning a list of issues",
      "function(id, resolve = TRUE, ...) returning a normalized result list",
      "function(prompt, llm) returning the model's text output",
      "function(query, n) returning a data frame (label, id, authority, score, uri)"),
    stringsAsFactors = FALSE)
}

#' Check that an object satisfies a plugin contract
#'
#' @param kind One of `"profile"`, `"validator"`, `"resolver"`,
#'   `"llm_provider"`, `"suggest_source"`.
#' @param obj The plugin object or function to check.
#' @return Invisibly `TRUE`; errors early if the contract is not met.
#' @export
#' @examples
#' validate_plugin_contract("validator", function(x, ctx) list())
#' validate_plugin_contract("suggest_source", function(query, n) NULL)
validate_plugin_contract <- function(kind, obj) {
  kind <- match.arg(kind, c("profile", "validator", "resolver", "llm_provider",
                            "suggest_source"))
  has_args <- function(fn, min) is.function(fn) && length(formals(fn)) >= min
  ok <- switch(kind,
    validator = has_args(obj, 2L),  # the engine calls fn(x, ctx)
    resolver = has_args(obj, 1L),   # first argument is the identifier, any name
    llm_provider = has_args(obj, 2L),
    suggest_source = has_args(obj, 2L),
    profile = is_profile(obj) ||
      (is.list(obj) && !is.null(obj$name)) ||
      (is.character(obj) && length(obj) == 1L && dir.exists(obj)))
  if (!isTRUE(ok)) {
    stop(sprintf("Object does not satisfy the '%s' plugin contract; see krt_plugin_api().",
                 kind), call. = FALSE)
  }
  invisible(TRUE)
}
