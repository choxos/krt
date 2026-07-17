# ASAP six-column export. Writes CSV by default (the ASAP compliance-submission
# format) or fills an xlsx template.

#' Export a KRT in the ASAP six-column format
#'
#' Projects the table to the ASAP columns and writes it as CSV or into an xlsx
#' template. If `template` is supplied (or the bundled ASAP template is used),
#' the data is written into its `KRT` sheet, preserving its dropdowns and
#' attribution worksheet.
#'
#' @param x A [krt_tbl].
#' @param path Output path, or `NULL` to return CSV text.
#' @param template Optional xlsx template path. When supplied, output is xlsx.
#' @param format `"csv"` or `"xlsx"`; inferred from `path`/`template`.
#' @param audience `"author"` (full) or `"public"` (redacted).
#' @param redact Redaction strength for public output, or `FALSE` to disable.
#' @param attribution If `TRUE` (default) and a `path` is given, write the ASAP
#'   CC BY 4.0 attribution block as a sidecar next to it.
#' @return The path (invisibly) when written, or CSV text.
#' @export
#' @examples
#' cat(substr(export_asap(krt_example), 1, 60))
export_asap <- function(x, path = NULL, template = NULL, format = NULL,
                        audience = c("author", "public"), redact = NULL,
                        attribution = TRUE) {
  stopifnot(is_krt(x))
  x <- .maybe_redact(x, match.arg(audience), redact)
  .warn_lossy(x, "asap")
  .attribution_sidecar("asap", path, attribution)
  df <- project_profile(x, "asap")
  format <- format %||% .fmt_from_path(path) %||% (if (!is.null(template)) "xlsx" else "csv")

  if (identical(format, "xlsx")) {
    need_pkg("openxlsx", "writing xlsx")
    if (is.null(path)) stop("xlsx export requires a `path`.", call. = FALSE)
    tmpl <- template %||% get_profile("asap")$template_path
    if (!is.null(tmpl) && file.exists(tmpl)) {
      wb <- openxlsx::loadWorkbook(tmpl)
      sheets <- openxlsx::sheets(wb)
      sheet <- if ("KRT" %in% sheets) "KRT" else sheets[1]
      openxlsx::writeData(wb, sheet, df, startRow = 2, colNames = FALSE)
      openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
    } else {
      openxlsx::write.xlsx(df, path)
    }
    return(invisible(path))
  }

  txt <- .df_to_delim(df, ",")
  if (is.null(path)) return(txt)
  .write_utf8(txt, path)
  invisible(path)
}
