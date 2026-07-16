# Read a krt_tbl back from its canonical JSON or YAML representation.

#' @noRd
.record_from_list <- function(r, class, coerce = TRUE) {
  r <- as.list(r)
  if (isTRUE(coerce)) {
    fields <- names(all_fields())
    for (nm in names(r)) {
      if (nm %in% fields) r[[nm]] <- coerce_field(nm, r[[nm]])
      else if (is.list(r[[nm]])) r[[nm]] <- unlist(r[[nm]], use.names = FALSE)
    }
  } else {
    for (nm in names(r)) if (is.list(r[[nm]]) && length(r[[nm]])) {
      # flatten simple JSON arrays of scalars back to atomic vectors
      if (all(vapply(r[[nm]], function(v) is.atomic(v) && length(v) == 1L, logical(1)))) {
        r[[nm]] <- unlist(r[[nm]], use.names = FALSE)
      }
    }
  }
  structure(compact(r), class = class)
}

#' Reconstruct a krt_tbl from a parsed list
#' @noRd
.krt_from_list <- function(lst) {
  x <- new_krt(title = lst$title, profile = lst$profile %||% "generic",
               study_type = lst$study_type, locale = lst$locale)
  x$schema_version <- lst$schema_version %||% x$schema_version
  x$table_id       <- lst$table_id %||% x$table_id
  x$created_at     <- lst$created_at %||% x$created_at
  x$updated_at     <- lst$updated_at %||% x$updated_at
  x$resources    <- lapply(lst$resources %||% list(),
                           function(r) .record_from_list(r, "krt_resource", coerce = TRUE))
  x$approvals    <- lapply(lst$approvals %||% list(),
                           function(a) .record_from_list(a, "krt_approval", coerce = FALSE))
  x$contributors <- lapply(lst$contributors %||% list(),
                           function(c) .record_from_list(c, "krt_contributor", coerce = FALSE))
  x$validation   <- lapply(lst$validation %||% list(),
                           function(f) .record_from_list(f, "krt_finding", coerce = FALSE))
  x$provenance   <- lapply(lst$provenance %||% list(),
                           function(p) .record_from_list(p, "krt_prov_entry", coerce = FALSE))
  x
}

#' Read a KRT from canonical JSON
#'
#' @param input A file path or a JSON string.
#' @return A [krt_tbl].
#' @export
#' @examples
#' k <- read_krt_json(write_krt_json(krt_example))
#' identical(length(k$resources), length(krt_example$resources))
read_krt_json <- function(input) {
  lst <- jsonlite::fromJSON(input, simplifyVector = FALSE)
  .krt_from_list(lst)
}

#' Read a KRT from canonical YAML
#'
#' @param input A file path or a YAML string.
#' @return A [krt_tbl].
#' @export
#' @examples
#' k <- read_krt_yaml(write_krt_yaml(krt_example))
#' identical(length(k$resources), length(krt_example$resources))
read_krt_yaml <- function(input) {
  lst <- if (length(input) == 1L && file.exists(input)) {
    yaml::read_yaml(input)
  } else {
    yaml::yaml.load(paste(input, collapse = "\n"))
  }
  .krt_from_list(lst)
}
