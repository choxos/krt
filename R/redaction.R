# Redaction of sensitive ethics and consent metadata for public sharing. The
# default policy lives in R/sysdata.rda; public exports redact by default.

#' The default redaction policy
#'
#' @return A data frame with columns `scope` (`"approval"` or `"resource"`),
#'   `field`, `level` (the strip strength at which the field is removed:
#'   `"basic"` fields are removed at both `"basic"` and `"strict"`; `"strict"`
#'   fields only at `"strict"`), and `action` (`"drop"` or `"generalize"`).
#' @export
#' @examples
#' redaction_policy()
redaction_policy <- function() ref_data("redaction_policy")

#' Default redaction strength for a profile's public exports
#'
#' @param profile A profile name or `krt_profile`. A profile may declare a
#'   `redaction_default` in its `schema.yml`; otherwise the strength is `"basic"`.
#' @return `"basic"` or `"strict"`.
#' @export
#' @examples
#' redaction_default("asap")
redaction_default <- function(profile = NULL) {
  if (is.null(profile)) return("basic")
  p <- tryCatch(get_profile(profile), error = function(e) NULL)
  lvl <- p$redaction_default %||% "basic"
  if (lvl %in% c("basic", "strict")) lvl else "basic"
}

#' @noRd
.apply_redaction <- function(rec, rules) {
  if (!nrow(rules)) return(rec)
  for (i in seq_len(nrow(rules))) {
    fld <- rules$field[i]
    if (is.null(rec[[fld]])) next
    if (identical(rules$action[i], "generalize")) rec[[fld]] <- "[redacted]"
    else rec[[fld]] <- NULL
  }
  rec
}

#' Redact sensitive fields for public sharing
#'
#' Removes or generalizes fields flagged by the redaction policy, so a table can
#' be shared publicly without exposing internal ethics or consent details.
#'
#' @param x A [krt_tbl].
#' @param level `"basic"` (default) removes basic-tagged fields;
#'   `"strict"` removes basic- and strict-tagged fields.
#' @param policy An optional policy data frame overriding [redaction_policy()].
#' @return The redacted `krt_tbl`.
#' @export
#' @examples
#' k <- add_approval(new_krt("Demo"), "IRB", protocol_number = "IRB-1",
#'                   consent_scope = "study-specific")
#' redact_krt(k)$approvals[[1]]$protocol_number
redact_krt <- function(x, level = c("basic", "strict"), policy = NULL) {
  stopifnot(is_krt(x))
  level <- match.arg(level)
  pol <- policy %||% redaction_policy()
  active_levels <- if (identical(level, "strict")) c("basic", "strict") else "basic"
  active <- pol[pol$level %in% active_levels, , drop = FALSE]

  appr_rules <- active[active$scope == "approval", , drop = FALSE]
  res_rules  <- active[active$scope == "resource", , drop = FALSE]

  # Allowlists close the gap a denylist leaves open: any field not known to the
  # schema or named by the redaction policy is treated as potentially sensitive
  # and removed from a public export, so a custom or free-text field cannot
  # smuggle protected information past redaction.
  safe_appr <- unique(c("approval_id", "approval_type",
                        pol$field[pol$scope == "approval"]))
  safe_res  <- names(all_fields())
  safe_ctb  <- c("contributor_id", "name", "orcid", "role", "credit_role",
                 "affiliation_ror")
  keep_only <- function(rec, fields, cls) {
    structure(compact(rec[intersect(names(rec), fields)]), class = cls)
  }

  x$approvals <- lapply(x$approvals, function(a)
    keep_only(.apply_redaction(a, appr_rules), safe_appr, "krt_approval"))
  x$resources <- lapply(x$resources, function(r)
    keep_only(.apply_redaction(r, res_rules), safe_res, "krt_resource"))
  x$contributors <- lapply(x$contributors, function(ct)
    keep_only(ct, safe_ctb, "krt_contributor"))
  x <- .touch(x, "redact", params = list(level = level))
  # Provenance parameters can echo sensitive input values; drop them for public
  # output (after recording the redaction step) while keeping the activity and
  # timestamp history.
  x$provenance <- lapply(x$provenance, function(e) { e$params <- NULL; e })
  # Validation findings can quote a sensitive input value (a protocol or patient
  # id inside a message); they are derived, so drop them from a public export.
  x$validation <- list()
  x
}
