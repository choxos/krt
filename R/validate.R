# The validation orchestrator: runs registered rules over a table, resolving
# each finding's severity from rule default, profile override, and user override.

# Called from .onLoad to populate the registry with the built-in rule packs.
#' @noRd
.register_builtin_validators <- function() {
  .register_structural_validators()
  .register_semantic_validators()
  .register_conditional_validators()
  invisible()
}

# Profile-supplied severity overrides. Wired to the profile system when it is
# available (M4); returns an empty list otherwise.
#' @noRd
.profile_validation_overrides <- function(profile) {
  if (is.null(profile)) return(list())
  if (exists("get_profile", mode = "function")) {
    p <- tryCatch(get_profile(profile), error = function(e) NULL)
    if (!is.null(p)) return(p$validation_overrides %||% list())
  }
  list()
}

#' @noRd
.pick_severity <- function(rule_id, default, overrides, user_sev) {
  if (rule_id %in% names(user_sev)) return(user_sev[[rule_id]])
  if (rule_id %in% names(overrides)) return(overrides[[rule_id]])
  default
}

#' Validate a Key Resources Table
#'
#' Runs the registered validation rules over a table and returns a
#' [krt_validation_report]. Structural rules check schema conformance offline;
#' semantic rules check cross-field consistency and, when `resolve = TRUE`,
#' identifier existence. Conditional packs (cell-line authentication, organism
#' metadata, ethics/consent) apply only when the relevant resource types are
#' present; they are minimal checks, not full ICLAC or ARRIVE assessments.
#'
#' Each finding's severity is resolved from the rule default, then any
#' profile override, then any per-rule value in `severity`. A severity of
#' `"off"` disables the rule.
#'
#' @param x A [krt_tbl].
#' @param profile Profile whose severity overrides apply (default the table's
#'   profile).
#' @param layers Which layers to run: `"structural"`, `"semantic"`, or both.
#' @param resolve If `TRUE`, semantic rules may perform online existence checks
#'   (off by default; never on CRAN).
#' @param severity Optional named list mapping `rule_id` to a severity (or
#'   `"off"`), overriding rule and profile defaults.
#' @param attach If `TRUE`, return the table with the findings stored in its
#'   `validation` slot instead of returning the report.
#' @return A `krt_validation_report`, or the `krt_tbl` when `attach = TRUE`.
#' @export
#' @examples
#' validate_krt(krt_example)
#' validate_krt(krt_example, layers = "structural")
validate_krt <- function(x, profile = NULL, layers = c("structural", "semantic"),
                         resolve = FALSE, severity = NULL, attach = FALSE) {
  stopifnot(is_krt(x))
  profile <- profile %||% x$profile %||% "generic"
  layers <- match.arg(layers, c("structural", "semantic"), several.ok = TRUE)
  overrides <- .profile_validation_overrides(profile)
  user_sev <- severity %||% list()
  ctx <- list(resolve = isTRUE(resolve), profile = profile)

  findings <- list()
  for (v in get_validators()) {
    if (!(v$layer %in% layers)) next
    if (!isTRUE(tryCatch(v$applies(x), error = function(e) FALSE))) next
    rule_sev <- .pick_severity(v$rule_id, v$severity, overrides, user_sev)
    if (identical(rule_sev, "off")) next
    issues <- tryCatch(v$fn(x, ctx), error = function(e) {
      list(.issue(sprintf("rule '%s' errored: %s", v$rule_id, conditionMessage(e)),
                  severity = "warning"))
    })
    for (is in issues) {
      sev <- .pick_severity(v$rule_id, is$severity %||% v$severity, overrides, user_sev)
      if (identical(sev, "off")) next
      findings <- c(findings, list(new_finding(
        v$rule_id, sev, v$layer, is$message,
        resource_id = is$resource_id %||% NA_character_,
        field = is$field %||% NA_character_,
        standard = v$standard %||% NA_character_,
        suggestion = is$suggestion %||% NA_character_)))
    }
  }

  report <- new_validation_report(profile, layers, isTRUE(resolve), findings)
  if (isTRUE(attach)) {
    x$validation <- findings
    return(.touch(x, "validate", params = list(profile = profile, valid = report$valid)))
  }
  report
}
