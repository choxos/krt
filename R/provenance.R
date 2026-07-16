# Provenance recording. Every mutating operation appends an entry describing
# the activity, so a table carries an auditable history of how it was built.
# This module provides the recorder; graph export (PROV-JSON, RO-Crate) is added
# in R/rocrate.R.

#' @noRd
new_prov_entry <- function(activity, inputs = NULL, outputs = NULL,
                           params = NULL) {
  structure(
    compact(list(
      activity  = activity,
      timestamp = now_iso(),
      inputs    = as_chr(inputs),
      outputs   = as_chr(outputs),
      params    = params,
      software  = paste0("krt ", as.character(utils::packageVersion("krt")))
    )),
    class = "krt_prov_entry"
  )
}

#' Append a provenance entry to a KRT
#'
#' Records that an `activity` (for example `"normalize_ids"`, `"import"`,
#' `"validate"`, `"resolve"`, `"export"`) was applied to the table. Called
#' automatically by the mutating functions; exported so custom pipelines can
#' record their own steps.
#'
#' @param x A [krt_tbl].
#' @param activity A short activity label.
#' @param inputs,outputs Optional character vectors of input/output identifiers.
#' @param params Optional named list of parameters for the activity.
#' @return The `krt_tbl` with the entry appended.
#' @export
#' @examples
#' k <- append_provenance(new_krt("Demo"), "import", params = list(format = "csv"))
#' length(krt_provenance(k))
append_provenance <- function(x, activity, inputs = NULL, outputs = NULL,
                              params = NULL) {
  stopifnot(is_krt(x))
  if (!is_nonempty_string(activity)) {
    stop("`activity` must be a non-empty string.", call. = FALSE)
  }
  entry <- new_prov_entry(activity, inputs = inputs, outputs = outputs,
                          params = params)
  x$provenance <- c(x$provenance, list(entry))
  x
}

#' Provenance of a KRT
#'
#' Returns the ordered provenance entries as a `krt_provenance` object (a list
#' of `krt_prov_entry`, so `length()` gives the number of steps). It has
#' `print()` and `as.data.frame()` methods; serialize the provenance graph with
#' [as_prov_json()] and [as_rocrate()].
#'
#' @param x A [krt_tbl].
#' @return A `krt_provenance` object.
#' @export
#' @examples
#' krt_provenance(normalize_ids(krt_example))
krt_provenance <- function(x) {
  stopifnot(is_krt(x))
  structure(x$provenance, class = "krt_provenance", table_id = x$table_id)
}

#' @export
format.krt_provenance <- function(x, ...) {
  if (!length(x)) return("<krt_provenance> (no recorded steps)")
  lines <- c(sprintf("<krt_provenance> %d step%s", length(x),
                     if (length(x) == 1L) "" else "s"))
  for (e in x) {
    lines <- c(lines, sprintf("  %s  %s%s", e$timestamp %||% "?", e$activity %||% "?",
                              if (length(e$outputs)) sprintf(" -> %s", paste(e$outputs, collapse = ", ")) else ""))
  }
  paste(lines, collapse = "\n")
}

#' @export
print.krt_provenance <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.krt_provenance <- function(x, row.names = NULL, optional = FALSE, ...) {
  if (!length(x)) {
    return(data.frame(activity = character(0), timestamp = character(0),
                      inputs = character(0), outputs = character(0),
                      software = character(0), stringsAsFactors = FALSE))
  }
  do.call(rbind, lapply(x, function(e) data.frame(
    activity = e$activity %||% NA_character_,
    timestamp = e$timestamp %||% NA_character_,
    inputs = paste(e$inputs, collapse = ", "),
    outputs = paste(e$outputs, collapse = ", "),
    software = e$software %||% NA_character_,
    stringsAsFactors = FALSE)))
}
