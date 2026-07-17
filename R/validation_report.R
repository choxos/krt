# The validation report object and its finding records.

# Severity ordering, most to least severe. "off" disables a rule.
.krt_severities <- c("error", "warning", "note", "info")

#' @noRd
new_finding <- function(rule_id, severity, layer, message, resource_id = NA_character_,
                        field = NA_character_, standard = NA_character_,
                        suggestion = NA_character_) {
  structure(
    list(rule_id = rule_id, severity = severity, layer = layer,
         standard = standard, resource_id = resource_id, field = field,
         message = message, suggestion = suggestion),
    class = "krt_finding"
  )
}

# Convenience used inside rule functions to describe one problem. rule_id,
# layer, standard, and the resolved severity are attached by the engine.
#' @noRd
.issue <- function(message, resource_id = NA_character_, field = NA_character_,
                   severity = NULL, suggestion = NA_character_) {
  list(message = message, resource_id = resource_id, field = field,
       severity = severity, suggestion = suggestion)
}

#' @noRd
new_validation_report <- function(profile, layers, resolved, findings) {
  sev <- vapply(findings, function(f) f$severity, character(1))
  counts <- stats::setNames(
    vapply(.krt_severities, function(s) sum(sev == s), integer(1)),
    .krt_severities)
  structure(
    list(
      valid      = counts[["error"]] == 0L,
      profile    = profile,
      layers     = layers,
      resolved   = resolved,
      counts     = as.list(counts),
      findings   = findings,
      created_at = now_iso()
    ),
    class = "krt_validation_report"
  )
}

#' The validation report object
#'
#' [validate_krt()] returns a `krt_validation_report`. It has `print()`,
#' [summary()][summary.krt_validation_report], and
#' [as.data.frame()][as.data.frame.krt_validation_report] methods. `valid` is
#' `TRUE` when there are no `error` findings.
#'
#' @name krt_validation_report
#' @seealso [validate_krt()]
NULL

#' @export
format.krt_validation_report <- function(x, ...) {
  head <- sprintf("<krt_validation_report> profile: %s | %s | %d finding%s",
                  x$profile %||% "generic",
                  if (isTRUE(x$valid)) "VALID" else "INVALID",
                  length(x$findings), if (length(x$findings) == 1L) "" else "s")
  cnt <- sprintf("  errors: %d  warnings: %d  notes: %d  info: %d",
                 x$counts$error, x$counts$warning, x$counts$note, x$counts$info)
  lines <- c(head, cnt)
  order_sev <- match(vapply(x$findings, function(f) f$severity, character(1)),
                     .krt_severities)
  for (f in x$findings[order(order_sev)]) {
    where <- if (!is.na(f$resource_id)) sprintf(" [%s%s]", f$resource_id,
                    if (!is.na(f$field)) paste0("$", f$field) else "") else ""
    lines <- c(lines, sprintf("  %-7s %s%s: %s",
                              toupper(f$severity), f$rule_id, where, f$message))
  }
  paste(lines, collapse = "\n")
}

#' @export
print.krt_validation_report <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}

#' Summarize a validation report
#'
#' @param object A `krt_validation_report`.
#' @param ... Ignored.
#' @return A data frame of finding counts by severity, layer, and standard.
#' @export
summary.krt_validation_report <- function(object, ...) {
  if (!length(object$findings)) {
    return(data.frame(severity = character(0), layer = character(0),
                      standard = character(0), n = integer(0),
                      stringsAsFactors = FALSE))
  }
  df <- as.data.frame(object)
  # aggregate() drops rows whose grouping value is NA, so label the (common)
  # findings with no reporting standard rather than silently omitting them.
  df$standard[is.na(df$standard)] <- "(none)"
  agg <- stats::aggregate(list(n = seq_len(nrow(df))),
                          by = list(severity = df$severity, layer = df$layer,
                                    standard = df$standard),
                          FUN = length)
  agg[order(match(agg$severity, .krt_severities)), ]
}

#' Convert a validation report to a data frame
#'
#' @param x A `krt_validation_report`.
#' @param ... Ignored.
#' @return A data frame with one row per finding.
#' @export
as.data.frame.krt_validation_report <- function(x, ...) {
  if (!length(x$findings)) {
    return(data.frame(rule_id = character(0), severity = character(0),
                      layer = character(0), standard = character(0),
                      resource_id = character(0), field = character(0),
                      message = character(0), suggestion = character(0),
                      stringsAsFactors = FALSE))
  }
  rows <- lapply(x$findings, function(f) {
    data.frame(rule_id = f$rule_id, severity = f$severity, layer = f$layer,
               standard = f$standard %||% NA_character_,
               resource_id = f$resource_id %||% NA_character_,
               field = f$field %||% NA_character_,
               message = f$message,
               suggestion = f$suggestion %||% NA_character_,
               stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}
