# Licensing and attribution introspection. The package code is GPL-3; some
# bundled profile assets (ASAP) are CC BY 4.0 and carry attribution obligations.
# These functions make the licensing programmatically inspectable and emit the
# attribution required alongside outputs.

#' Licensing of a profile
#'
#' @param name A profile name or `krt_profile`.
#' @return `krt_profile_license()` returns the SPDX license id;
#'   `krt_profile_sources()` returns the source metadata list;
#'   `krt_profile_attribution()` returns the attribution text (or `NULL`).
#' @export
#' @examples
#' krt_profile_license("asap")
#' krt_profile_sources("asap")$doi
krt_profile_license <- function(name) get_profile(name)$license

#' @rdname krt_profile_license
#' @export
krt_profile_sources <- function(name) get_profile(name)$source

#' @rdname krt_profile_license
#' @export
krt_profile_attribution <- function(name) get_profile(name)$attribution

#' Attribution text for a table's profile
#'
#' Returns the attribution block that should accompany outputs produced with the
#' table's profile. For the ASAP profile (CC BY 4.0) this is the required
#' attribution; for profiles with no redistribution obligation it is a short
#' note.
#'
#' @param x A [krt_tbl] or a profile name.
#' @return A character string.
#' @export
#' @examples
#' cat(krt_attribution(krt_example))
krt_attribution <- function(x) {
  profile <- if (is_krt(x)) x$profile else x
  p <- tryCatch(get_profile(profile), error = function(e) NULL)
  if (is.null(p)) return("")
  if (!is.null(p$attribution)) return(p$attribution)
  if (!is.null(p$source) && !is.null(p$source$doi)) {
    return(sprintf(paste("Output uses the '%s' profile derived from %s (%s), licensed %s.",
                         "See doi:%s. No endorsement implied."),
                   p$name, p$source$title %||% p$source$creator %||% "the source",
                   p$source$creator %||% "", p$license %||% "its license", p$source$doi))
  }
  sprintf("The '%s' profile imposes no attribution requirement.", p$name)
}

#' Write attribution to a file
#'
#' @param x A [krt_tbl] or profile name.
#' @param path Output file path.
#' @return The path, invisibly.
#' @export
#' @examples
#' f <- tempfile(fileext = ".md")
#' krt_write_attribution(krt_example, f)
krt_write_attribution <- function(x, path) {
  .write_utf8(krt_attribution(x), path)
  invisible(path)
}

#' Audit the licenses of the package and its bundled assets
#'
#' @return A data frame with one row per licensable component (the package
#'   code, each profile, the bundled reference data and license text), giving
#'   its source, license, DOI, whether it is redistributable, and notes.
#' @export
#' @examples
#' krt_audit_licenses()
krt_audit_licenses <- function() {
  redist_ok <- function(lic) {
    !is.null(lic) && grepl("GPL|CC-BY|CC0|MIT|Apache", lic)
  }
  rows <- list(
    data.frame(component = "krt (R source code)", source = "this package",
               license = "GPL-3.0-only", doi = NA_character_,
               redistributable = TRUE, notes = "Package code and validation engine.",
               stringsAsFactors = FALSE),
    data.frame(component = "internal reference tables (R/sysdata.rda)",
               source = "public standards", license = "GPL-3.0-only",
               doi = NA_character_, redistributable = TRUE,
               notes = "KRT vocabularies, RRID prefixes, identifier syntax, endpoints.",
               stringsAsFactors = FALSE)
  )
  for (nm in sort(union(ls(.profile_registry), ls(.profile_cache)))) {
    p <- tryCatch(get_profile(nm), error = function(e) NULL)
    if (is.null(p)) next
    rows <- c(rows, list(data.frame(
      component = sprintf("profile: %s", nm),
      source = p$source$creator %||% "this package",
      license = p$license %||% NA_character_,
      doi = p$source$doi %||% NA_character_,
      redistributable = redist_ok(p$license),
      notes = if (isTRUE(p$official)) "" else "Not officially endorsed.",
      stringsAsFactors = FALSE)))
  }
  rows <- c(rows, list(data.frame(
    component = "inst/licenses/CC-BY-4.0.txt", source = "SPDX License List",
    license = "CC-BY-4.0", doi = NA_character_, redistributable = TRUE,
    notes = "License text for the ASAP-derived profile assets.",
    stringsAsFactors = FALSE)))
  do.call(rbind, rows)
}
