# Internal utilities shared across the package.

# `krt_ref` is the internal reference-data list baked into R/sysdata.rda by
# data-raw/01-build-sysdata.R. R loads it into the package namespace at install.
utils::globalVariables("krt_ref")

#' Null/empty coalescing operator.
#' @noRd
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

#' Access a baked-in reference table from R/sysdata.rda.
#' @param key Name of the table (e.g. "controlled_vocab", "id_patterns").
#' @noRd
ref_data <- function(key) {
  d <- krt_ref[[key]]
  if (is.null(d)) {
    stop(sprintf("krt reference data '%s' not found; reinstall the package.", key),
         call. = FALSE)
  }
  d
}

#' Is `x` a length-one, non-NA, non-empty character string?
#' @noRd
is_nonempty_string <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
}

#' Is `x` a (possibly empty) named list?
#' @noRd
is_named_list <- function(x) {
  is.list(x) && (length(x) == 0L || !is.null(names(x)))
}

#' Coerce a value to a character vector, dropping NULLs, NAs, and empties.
#' @noRd
as_chr <- function(x) {
  if (is.null(x)) return(character(0))
  x <- unlist(x, use.names = FALSE)
  x <- as.character(x)
  x[!is.na(x) & nzchar(x)]
}

#' Drop NULL, NA-scalar, and empty-string entries from a named list.
#'
#' Used to keep records "present-only" so that an absent field is distinct from
#' an `NA` field once serialized.
#' @noRd
compact <- function(x) {
  if (!is.list(x)) return(x)
  keep <- vapply(x, function(v) {
    if (is.null(v)) return(FALSE)
    if (length(v) == 0L) return(FALSE)
    if (length(v) == 1L && is.atomic(v) && is.na(v)) return(FALSE)
    if (is.character(v) && length(v) == 1L && !nzchar(v)) return(FALSE)
    TRUE
  }, logical(1))
  x[keep]
}

#' Deterministic short identifier from one or more parts.
#'
#' @param prefix Short type tag (e.g. "res", "krt").
#' @param ... Character parts hashed into the id; if none, a random-free stable
#'   token is derived from the prefix and the current object contents supplied
#'   by the caller.
#' @noRd
new_id <- function(prefix, ...) {
  parts <- as_chr(list(...))
  seed <- if (length(parts)) paste(parts, collapse = "") else prefix
  paste0(prefix, "-", substr(digest::digest(seed, algo = "xxhash64"), 1L, 10L))
}

#' Current time as an ISO-8601 UTC string.
#' @noRd
now_iso <- function() {
  format(as.POSIXlt(Sys.time(), tz = "UTC"), "%Y-%m-%dT%H:%M:%SZ")
}

#' Translate a message through the package gettext domain.
#'
#' Thin wrappers so that all user-facing strings share one translation domain
#' (`R-krt`) and can be localized via the catalogues in `po/`.
#' @noRd
tr <- function(fmt, ...) {
  dots <- list(...)
  if (length(dots)) do.call(gettextf, c(list(fmt), dots, list(domain = "R-krt")))
  else gettext(fmt, domain = "R-krt")
}

#' @noRd
.msg <- function(fmt) gettext(fmt, domain = "R-krt")

#' Write text to a file as UTF-8, independent of the session locale.
#' @noRd
.write_utf8 <- function(text, path) {
  con <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(con))
  writeLines(enc2utf8(as.character(text)), con)
  invisible(path)
}

#' Is a suggested package available?
#' @noRd
has_pkg <- function(pkg) requireNamespace(pkg, quietly = TRUE)

#' Stop unless a suggested package is installed.
#' @noRd
need_pkg <- function(pkg, what = NULL) {
  if (!has_pkg(pkg)) {
    stop(sprintf("Package '%s' is required%s. Install it with install.packages('%s').",
                 pkg, if (is.null(what)) "" else paste0(" for ", what), pkg),
         call. = FALSE)
  }
  invisible(TRUE)
}
