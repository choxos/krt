# Registry of validation rules. Rules are registered in .onLoad (built-ins) or
# by third parties through the plugin SDK, and dispatched by validate_krt().

.validator_registry <- new.env(parent = emptyenv())

#' Register a validation rule
#'
#' Adds a rule to the validation engine. A rule is a function `fn(x, ctx)` that
#' inspects a [krt_tbl] and returns a list of issues (each created with the
#' internal issue helper); the engine attaches the rule id, layer, standard, and
#' resolved severity.
#'
#' @param rule_id A unique rule identifier, e.g. `"struct-missing-name"`.
#' @param fn The rule function `function(x, ctx)` returning a list of issues.
#' @param layer Either `"structural"` or `"semantic"`.
#' @param severity Default severity: one of `"error"`, `"warning"`, `"note"`,
#'   `"info"`.
#' @param applies A predicate `function(x)`; the rule runs only when it returns
#'   `TRUE` (used by conditional rule packs).
#' @param standard Optional reporting standard the rule enforces (e.g.
#'   `"ARRIVE-2.0"`).
#' @param replace Overwrite an existing rule with the same `rule_id`? Defaults to
#'   `FALSE`, so a plugin cannot silently replace a built-in rule; pass `TRUE` to
#'   deliberately override one.
#' @return Invisibly `NULL`; called for its side effect.
#' @export
#' @examples
#' # A rule flags resources whose display name is very long.
#' long_name_rule <- function(x, ctx) list()
#' # register_validator("demo-long-name", long_name_rule, severity = "note")
#' head(list_validators(), 3)
register_validator <- function(rule_id, fn, layer = c("structural", "semantic"),
                               severity = c("error", "warning", "note", "info"),
                               applies = function(x) TRUE, standard = NA_character_,
                               replace = FALSE) {
  layer <- match.arg(layer)
  severity <- match.arg(severity)
  if (!is.function(fn)) stop("`fn` must be a function.", call. = FALSE)
  if (!is.function(applies)) stop("`applies` must be a function.", call. = FALSE)
  if (!isTRUE(replace) && !is.null(.validator_registry[[rule_id]])) {
    stop(sprintf("A validator '%s' is already registered; pass replace = TRUE to override.",
                 rule_id), call. = FALSE)
  }
  .validator_registry[[rule_id]] <- list(
    rule_id = rule_id, fn = fn, layer = layer, severity = severity,
    applies = applies, standard = standard)
  invisible(NULL)
}

#' @noRd
get_validators <- function(layer = NULL) {
  vs <- as.list(.validator_registry)
  if (!is.null(layer)) vs <- Filter(function(v) v$layer %in% layer, vs)
  vs[order(names(vs))]
}

#' List registered validation rules
#'
#' @return A data frame of registered rules (id, layer, default severity,
#'   standard).
#' @export
#' @examples
#' head(list_validators())
list_validators <- function() {
  vs <- get_validators()
  if (!length(vs)) {
    return(data.frame(rule_id = character(0), layer = character(0),
                      severity = character(0), standard = character(0),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, lapply(vs, function(v) data.frame(
    rule_id = v$rule_id, layer = v$layer, severity = v$severity,
    standard = v$standard %||% NA_character_, stringsAsFactors = FALSE)))
}
