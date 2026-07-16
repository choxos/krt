# The import dispatcher: detect the format and route to the right reader.

#' @noRd
.detect_import_format <- function(input) {
  if (is.data.frame(input)) {
    hdrs <- tryCatch(.canon_asap_headers(names(input)), error = function(e) character(0))
    if (any(c("RESOURCE_TYPE", "REAGENT_OR_RESOURCE") %in% hdrs)) return("asap")
    return("tabular")
  }
  if (length(input) == 1L && file.exists(input)) {
    ext <- tolower(tools::file_ext(input))
    if (ext == "json") return("json")
    if (ext %in% c("yaml", "yml")) return("yaml")
    if (ext %in% c("csv", "tsv", "xlsx", "xls")) {
      hdrs <- tryCatch(.canon_asap_headers(names(.read_table_any(input))),
                       error = function(e) character(0))
      if (any(c("RESOURCE_TYPE", "REAGENT_OR_RESOURCE") %in% hdrs)) return("asap")
      return("tabular")
    }
  }
  txt <- paste(input, collapse = "\n")
  if (grepl("^\\s*\\{", txt)) return("json")
  "yaml"
}

#' Import a Key Resources Table from a file or string
#'
#' Detects the format (JSON, YAML, ASAP/Cell Press table, or generic tabular)
#' and reads it into a [krt_tbl].
#'
#' @param input A file path, or a JSON/YAML string.
#' @param format One of `"json"`, `"yaml"`, `"asap"`, `"tabular"`; auto-detected
#'   when `NULL`.
#' @param profile Optional profile to assign to the imported table.
#' @param mapping Optional column-to-field mapping for tabular import.
#' @param sheet Worksheet (for xlsx).
#' @return A [krt_tbl].
#' @export
#' @examples
#' k <- import_krt(write_krt_json(krt_example))
#' length(k$resources)
import_krt <- function(input, format = NULL, profile = NULL, mapping = NULL,
                       sheet = 1) {
  format <- format %||% .detect_import_format(input)
  k <- switch(format,
    json = read_krt_json(input),
    yaml = read_krt_yaml(input),
    asap = import_asap(input, sheet = sheet),
    tabular = import_tabular(input, mapping = mapping, sheet = sheet,
                             profile = profile %||% "generic"),
    stop(sprintf("Unknown import format '%s'.", format), call. = FALSE))
  if (!is.null(profile)) k$profile <- profile
  .touch(k, "import", params = list(format = format))
}
