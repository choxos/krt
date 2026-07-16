# Canonical, lossless serialization of a krt_tbl to JSON and YAML. These formats
# preserve the present-only record structure exactly (an absent field is a key
# that is not present, never an NA), so a table round-trips without loss.

#' @noRd
.record_to_list <- function(r) {
  # Drop the S3 class; keep key order and values as-is.
  as.list(unclass(r))
}

#' Convert a krt_tbl to a plain nested list
#'
#' Strips S3 classes and produces the plain nested list that is serialized to
#' JSON or YAML. Metadata fields that are absent are dropped; the record lists
#' are always present (possibly empty).
#' @noRd
.krt_to_list <- function(x) {
  meta <- compact(list(
    schema_version = x$schema_version,
    profile        = x$profile,
    table_id       = x$table_id,
    title          = x$title,
    study_type     = x$study_type,
    locale         = x$locale,
    created_at     = x$created_at,
    updated_at     = x$updated_at
  ))
  c(meta, list(
    resources    = lapply(x$resources, .record_to_list),
    approvals    = lapply(x$approvals, .record_to_list),
    contributors = lapply(x$contributors, .record_to_list),
    validation   = lapply(x$validation, .record_to_list),
    provenance   = lapply(x$provenance, .record_to_list)
  ))
}

#' Write a KRT to canonical JSON
#'
#' @param x A [krt_tbl].
#' @param path Output file path, or `NULL` to return the JSON as a string.
#' @param pretty Whether to pretty-print (default `TRUE`).
#' @return The JSON string (invisibly, the path when written to a file).
#' @export
#' @examples
#' json <- write_krt_json(krt_example)
#' substr(json, 1, 40)
write_krt_json <- function(x, path = NULL, pretty = TRUE) {
  stopifnot(is_krt(x))
  json <- jsonlite::toJSON(.krt_to_list(x), auto_unbox = TRUE, null = "null",
                           na = "null", pretty = pretty, digits = NA)
  json <- as.character(json)
  if (is.null(path)) return(json)
  .write_utf8(json, path)
  invisible(path)
}

#' Write a KRT to canonical YAML
#'
#' @param x A [krt_tbl].
#' @param path Output file path, or `NULL` to return the YAML as a string.
#' @return The YAML string (invisibly, the path when written to a file).
#' @export
#' @examples
#' cat(substr(write_krt_yaml(krt_example), 1, 40))
write_krt_yaml <- function(x, path = NULL) {
  stopifnot(is_krt(x))
  y <- yaml::as.yaml(.krt_to_list(x), precision = 15)
  if (is.null(path)) return(y)
  .write_utf8(y, path)
  invisible(path)
}
