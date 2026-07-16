# A single release-readiness gate that combines the checks a user would
# otherwise run piecemeal: validation, lossless round-trip, redaction safety,
# attribution, and profile-projection loss.

#' @noRd
.pf_check <- function(name, status, detail) {
  data.frame(check = name, status = status, detail = detail,
             stringsAsFactors = FALSE)
}

#' Pre-flight release readiness check for a Key Resources Table
#'
#' Runs the checks that together decide whether a table is ready to share or
#' deposit, and returns a single machine-readable verdict plus a human-readable
#' checklist: profile validation (no errors), lossless JSON round-trip, a working
#' public (redacted) export that leaks none of the policy's dropped fields,
#' attribution availability, and whether the profile projection would drop
#' fields.
#'
#' @param x A [krt_tbl].
#' @param profile Profile to check against (defaults to the table's profile).
#' @return A `krt_preflight` object: a list with `profile`, `ok` (TRUE when no
#'   check fails), and `checks` (a data frame of `check`, `status`, `detail`),
#'   with `print()`, `format()`, and `as.data.frame()` methods.
#' @export
#' @examples
#' pf <- krt_preflight(krt_example)
#' pf$ok
krt_preflight <- function(x, profile = NULL) {
  stopifnot(is_krt(x))
  profile <- profile %||% x$profile %||% "generic"
  rows <- list()
  add <- function(...) rows[[length(rows) + 1L]] <<- .pf_check(...)

  rep <- validate_krt(x, profile = profile)
  n_err <- sum(as.data.frame(rep)$severity == "error")
  add("validation", if (n_err == 0L) "pass" else "fail",
      sprintf("%d error(s) under profile '%s'", n_err, profile))

  rt_ok <- tryCatch(
    identical(read_krt_json(write_krt_json(x))$resources, x$resources),
    error = function(e) FALSE)
  add("round_trip", if (rt_ok) "pass" else "warn",
      if (rt_ok) "JSON round-trip preserves every resource"
      else "JSON round-trip is not byte-for-byte identical")

  # Public export must succeed and must not leak a field the policy drops.
  red_ok <- tryCatch({
    e <- suppressWarnings(export_krt(x, format = "json", audience = "public"))
    k2 <- read_krt_json(e)
    pol <- redaction_policy()
    drop_appr <- pol$field[pol$scope == "approval" & pol$action == "drop" &
                           pol$level == "basic"]
    !any(vapply(k2$approvals, function(a) any(names(a) %in% drop_appr), logical(1)))
  }, error = function(e) FALSE)
  add("redaction_safety", if (red_ok) "pass" else "fail",
      if (red_ok) "Public export succeeds and drops sensitive approval fields"
      else "Public export failed or retained a sensitive field")

  attr_txt <- tryCatch(krt_attribution(profile), error = function(e) "")
  add("attribution", if (nzchar(attr_txt)) "pass" else "warn",
      if (nzchar(attr_txt)) "Attribution text is available"
      else "No attribution text for this profile (fine for 'generic')")

  lossy <- tryCatch(mapping_lossy_fields(x, profile), error = function(e) character(0))
  add("lossy_projection", if (!length(lossy)) "pass" else "warn",
      if (!length(lossy)) sprintf("The '%s' projection drops no fields", profile)
      else sprintf("The '%s' projection drops: %s", profile,
                   paste(lossy, collapse = ", ")))

  df <- do.call(rbind, rows)
  structure(list(profile = profile, ok = !any(df$status == "fail"), checks = df),
            class = "krt_preflight")
}

#' @export
format.krt_preflight <- function(x, ...) {
  mark <- c(pass = "PASS", warn = "WARN", fail = "FAIL")
  lines <- sprintf("  [%s] %-16s %s", mark[x$checks$status], x$checks$check,
                   x$checks$detail)
  c(sprintf("<krt_preflight> profile '%s': %s", x$profile,
            if (x$ok) "READY" else "NOT READY"),
    lines)
}

#' @export
print.krt_preflight <- function(x, ...) {
  cat(paste(format(x, ...), collapse = "\n"), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.krt_preflight <- function(x, row.names = NULL, optional = FALSE, ...) {
  x$checks
}
