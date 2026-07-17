# The export dispatcher. Canonical JSON/YAML are lossless; tabular, ASAP, and
# citation formats are lossy views and emit a lossy-export warning naming the
# fields that are folded or dropped. Public exports redact by default.

# Redact a table for public output, or warn if redaction is explicitly disabled.
# Shared by the dispatcher, the ASAP/tabular exporters, and the renderer so no
# public output path can bypass redaction.
#' @noRd
.maybe_redact <- function(x, audience, redact = NULL) {
  if (!identical(audience, "public")) return(x)
  if (isFALSE(redact)) {
    warning("Public output without redaction; sensitive fields are not removed.",
            call. = FALSE)
    return(x)
  }
  level <- if (is.character(redact)) redact else redaction_default(x$profile)
  redact_krt(x, level = level)
}

# Write a profile's attribution block next to `path`, when the profile carries
# one (e.g. the CC BY 4.0 ASAP assets). Shared by the leaf exporters.
#' @noRd
.attribution_sidecar <- function(profile, path, enabled = TRUE) {
  if (!isTRUE(enabled) || is.null(path)) return(invisible())
  p <- tryCatch(get_profile(profile), error = function(e) NULL)
  if (!is.null(p) && !is.null(p$attribution)) {
    krt_write_attribution(profile, paste0(path, ".attribution.md"))
  }
  invisible()
}

#' @noRd
.fmt_from_path <- function(path) {
  if (is.null(path)) return(NULL)
  ext <- tolower(tools::file_ext(path))
  switch(ext, json = "json", yaml = "yaml", yml = "yaml", csv = "csv",
         tsv = "tsv", txt = "tsv", xlsx = "xlsx", ris = "ris", bib = "bibtex",
         bibtex = "bibtex", NULL)
}

#' @noRd
.df_to_delim <- function(df, sep) {
  con <- textConnection("buf", "w", local = TRUE)
  on.exit(close(con))
  utils::write.table(df, con, sep = sep, row.names = FALSE, na = "",
                     qmethod = "double")
  paste(get("buf"), collapse = "\n")
}

#' Warn that an export format is a lower-fidelity view, naming dropped fields.
#' Emitted by every lossy exporter (the dispatcher and each leaf), so a direct
#' `export_asap()`/`export_tabular()`/`export_citation()` call warns too.
#' @noRd
.warn_lossy <- function(x, format, profile = NULL) {
  lossy <- .lossy_fields_for(x, format, profile %||% x$profile %||% "generic")
  msg <- if (length(lossy)) {
    sprintf("lossy-export: %d field(s) are not preserved as columns in '%s': %s.",
            length(lossy), format, paste(utils::head(lossy, 10), collapse = ", "))
  } else {
    sprintf("lossy-export: '%s' is a lower-fidelity view; use 'json' or 'yaml' for a lossless copy.",
            format)
  }
  warning(msg, call. = FALSE)
}

#' @noRd
.lossy_fields_for <- function(x, format, profile) {
  if (format == "asap") return(mapping_lossy_fields(x, "asap"))
  if (format %in% c("csv", "tsv", "xlsx")) return(mapping_lossy_fields(x, profile))
  if (format %in% c("ris", "bibtex")) {
    # only citable objects are representable; everything else is dropped
    present <- setdiff(unique(unlist(lapply(x$resources, names))),
                       c("resource_id", "resource_type", "display_name",
                         "canonical_name", "doi", "url", "version", "release_date"))
    return(present)
  }
  character(0)
}

#' Export a Key Resources Table
#'
#' Writes a table in a chosen format. `"json"` and `"yaml"` are lossless;
#' `"csv"`, `"tsv"`, `"xlsx"`, `"asap"`, `"ris"`, and `"bibtex"` are lossy views
#' and raise a `lossy-export` warning listing fields that are not preserved as
#' columns. When `audience = "public"`, sensitive ethics fields are redacted by
#' default.
#'
#' @param x A [krt_tbl].
#' @param path Output file path, or `NULL` to return the content as a string.
#' @param format Output format; inferred from `path` when possible.
#' @param profile Profile whose columns tabular exports use (default the table's
#'   profile).
#' @param audience `"author"` (full) or `"public"` (redacted).
#' @param redact Redaction strength (`"basic"`/`"strict"`) for public exports,
#'   or `FALSE` to disable (with a warning).
#' @param attribution If `TRUE` (default) and the profile carries an attribution
#'   requirement, write an attribution sidecar next to `path`.
#' @param template Optional template path for ASAP/xlsx export.
#' @param view Optional explicit view for tabular formats.
#' @return The path (invisibly) when written, otherwise the content string.
#' @export
#' @examples
#' export_krt(krt_example, format = "json") |> substr(1, 30)
#' suppressWarnings(export_krt(krt_example, format = "asap")) |> substr(1, 40)
export_krt <- function(x, path = NULL,
                       format = c("json", "yaml", "csv", "tsv", "xlsx", "asap",
                                  "ris", "bibtex"),
                       profile = NULL, audience = c("author", "public"),
                       redact = NULL, attribution = TRUE, template = NULL,
                       view = NULL) {
  stopifnot(is_krt(x))
  profile <- profile %||% x$profile %||% "generic"
  audience <- match.arg(audience)
  if (missing(format)) format <- .fmt_from_path(path) %||% "json"
  format <- match.arg(format)

  x <- .maybe_redact(x, audience, redact)

  # The leaf exporters below emit the lossy-export warning and the attribution
  # sidecar, so a direct call to any of them behaves identically to this path.
  switch(format,
    json = write_krt_json(x, path),
    yaml = write_krt_yaml(x, path),
    asap = export_asap(x, path, template = template, attribution = attribution),
    csv  = export_tabular(x, path, format = "csv", profile = profile, view = view,
                          attribution = attribution),
    tsv  = export_tabular(x, path, format = "tsv", profile = profile, view = view,
                          attribution = attribution),
    xlsx = export_tabular(x, path, format = "xlsx", profile = profile, view = view,
                          attribution = attribution),
    ris  = export_citation(x, path, format = "ris"),
    bibtex = export_citation(x, path, format = "bibtex"))
}

#' @rdname export_krt
#' @export
krt_write <- export_krt
