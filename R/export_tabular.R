# Tabular and citation exports (lossy views).

#' Export a KRT as a delimited table or spreadsheet
#'
#' @param x A [krt_tbl].
#' @param path Output path, or `NULL` to return the content (csv/tsv only).
#' @param format `"csv"`, `"tsv"`, or `"xlsx"`.
#' @param profile Profile whose columns to use (default the wide core view).
#' @param view Optional explicit view name.
#' @param audience `"author"` (full) or `"public"` (redacted).
#' @param redact Redaction strength for public output, or `FALSE` to disable.
#' @return The path (invisibly) when written, or the delimited text.
#' @export
#' @examples
#' cat(substr(export_tabular(krt_example, format = "csv"), 1, 60))
export_tabular <- function(x, path = NULL, format = c("csv", "tsv", "xlsx"),
                           profile = NULL, view = NULL,
                           audience = c("author", "public"), redact = NULL) {
  stopifnot(is_krt(x))
  format <- match.arg(format)
  x <- .maybe_redact(x, match.arg(audience), redact)
  df <- if (!is.null(view)) {
    as.data.frame(x, view = view)
  } else if (!is.null(profile) && !identical(profile, "generic")) {
    project_profile(x, profile)
  } else {
    as.data.frame(x, view = "wide")
  }
  if (identical(format, "xlsx")) {
    need_pkg("openxlsx", "writing xlsx")
    if (is.null(path)) stop("xlsx export requires a `path`.", call. = FALSE)
    openxlsx::write.xlsx(df, path)
    return(invisible(path))
  }
  sep <- if (identical(format, "tsv")) "\t" else ","
  txt <- .df_to_delim(df, sep)
  if (is.null(path)) return(txt)
  .write_utf8(txt, path)
  invisible(path)
}

#' @noRd
# RIS is line-oriented, so a value must not contain a line break.
#' @noRd
.ris_val <- function(v) gsub("[\r\n]+", " ", as.character(v))

# BibTeX values: collapse line breaks, neutralize backslashes, and escape the
# structural braces so a name or note cannot break the entry.
#' @noRd
.bib_val <- function(v) {
  v <- gsub("[\r\n]+", " ", as.character(v))
  v <- gsub("\\\\", "/", v)
  gsub("([{}])", "\\\\\\1", v)
}

#' @noRd
.citation_entry <- function(r, format, i) {
  key <- gsub("[^A-Za-z0-9_:-]", "_", r$resource_id %||% sprintf("res%d", i))
  title <- r$display_name %||% r$canonical_name %||% key
  doi <- r$doi
  url <- r$url
  year <- if (!is.null(r$release_date)) substr(r$release_date, 1, 4) else NULL
  if (identical(format, "ris")) {
    ty <- switch(r$resource_type %||% "",
                 "Dataset" = "DATA", "Software/code" = "COMP", "GEN")
    lines <- c(sprintf("TY  - %s", ty), sprintf("TI  - %s", .ris_val(title)))
    if (!is.null(doi)) lines <- c(lines, sprintf("DO  - %s", .ris_val(doi)))
    if (!is.null(url)) lines <- c(lines, sprintf("UR  - %s", .ris_val(url)))
    if (!is.null(year)) lines <- c(lines, sprintf("PY  - %s", .ris_val(year)))
    c(lines, "ER  - ")
  } else {
    lines <- c(sprintf("@misc{%s,", key), sprintf("  title = {%s},", .bib_val(title)))
    if (!is.null(doi)) lines <- c(lines, sprintf("  doi = {%s},", .bib_val(doi)))
    if (!is.null(url)) lines <- c(lines, sprintf("  url = {%s},", .bib_val(url)))
    if (!is.null(year)) lines <- c(lines, sprintf("  year = {%s},", .bib_val(year)))
    c(lines, "}")
  }
}

#' Export citable resources as RIS or BibTeX
#'
#' Only resources that are citable scholarly objects (datasets, software,
#' protocols, or anything with a DOI) are emitted. This format cannot encode
#' the full biological or ethics semantics of a KRT; use it for reference
#' managers, not as an archival copy.
#'
#' @param x A [krt_tbl].
#' @param path Output path, or `NULL` to return the text.
#' @param format `"ris"` or `"bibtex"`.
#' @param audience `"author"` (full) or `"public"` (redacted).
#' @param redact Redaction strength (`"basic"`/`"strict"`) for public output, or
#'   `FALSE` to disable; `NULL` uses the profile default.
#' @return The path (invisibly) when written, or the citation text.
#' @export
#' @examples
#' cat(export_citation(krt_example, format = "bibtex"))
export_citation <- function(x, path = NULL, format = c("ris", "bibtex"),
                            audience = c("author", "public"), redact = NULL) {
  stopifnot(is_krt(x))
  format <- match.arg(format)
  audience <- match.arg(audience)
  # Defense in depth: a direct public export redacts too, not only via
  # export_krt() (which already redacts before dispatching here).
  x <- .maybe_redact(x, audience, redact)
  citable <- Filter(function(r) {
    (r$resource_type %in% c("Dataset", "Software/code", "Protocol")) || !is.null(r$doi)
  }, x$resources)
  entries <- lapply(seq_along(citable), function(i)
    paste(.citation_entry(citable[[i]], format, i), collapse = "\n"))
  txt <- paste(unlist(entries), collapse = "\n\n")
  if (is.null(path)) return(txt)
  .write_utf8(txt, path)
  invisible(path)
}
