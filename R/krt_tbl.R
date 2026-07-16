# The top-level krt_tbl object and its S3 methods.

#' Create a Key Resources Table
#'
#' Constructs an empty (or pre-populated) `krt_tbl`: the neutral, typed core
#' object of the package. Resources, approvals, and contributors are stored as
#' present-only records; the rectangular table an author sees is a *view*
#' produced on demand by [as.data.frame()][as.data.frame.krt_tbl].
#'
#' @aliases krt_tbl
#' @param title A short table or study title.
#' @param profile Output profile name (default `"generic"`); see
#'   `krt_profiles()`.
#' @param study_type Optional character vector describing the study (e.g.
#'   `c("wet-lab", "computational")`).
#' @param locale Optional locale string (e.g. `"en-US"`).
#' @param resources,approvals,contributors Optional lists of records to seed the
#'   table with.
#' @return An object of class `krt_tbl`.
#' @export
#' @examples
#' k <- new_krt("Example study", study_type = "wet-lab")
#' k <- add_resource(k, "Antibody", "Rabbit Anti-TH", vendor = "Millipore",
#'                   catalog_number = "AB152", rrid = "RRID:AB_390204",
#'                   new_or_reuse = "reuse")
#' k
new_krt <- function(title = NULL, profile = "generic", study_type = NULL,
                    locale = NULL, resources = list(), approvals = list(),
                    contributors = list()) {
  if (!is.null(title) && !is_nonempty_string(title)) {
    stop("`title` must be a single string or NULL.", call. = FALSE)
  }
  if (length(resources) && !all(vapply(resources, is_resource, logical(1)))) {
    stop("`resources` must be a list of krt_resource objects (see new_resource()).",
         call. = FALSE)
  }
  now <- now_iso()
  structure(
    list(
      schema_version = ref_data("schema_version") %||% "1.0.0",
      profile        = profile %||% "generic",
      # Seed the id with a session-unique token plus a high-resolution
      # timestamp so two same-titled tables created in the same second do not
      # collide (tempfile() yields a within-session-unique name and consumes no
      # RNG state, so table creation stays reproducible).
      table_id       = new_id("krt", title %||% "", now,
                              basename(tempfile("")),
                              sprintf("%.6f", as.numeric(Sys.time()))),
      title          = title,
      study_type     = as_chr(study_type),
      locale         = locale,
      created_at     = now,
      updated_at     = now,
      resources      = unname(resources),
      approvals      = unname(approvals),
      contributors   = unname(contributors),
      validation     = list(),
      provenance     = list()
    ),
    class = "krt_tbl"
  )
}

#' @rdname new_krt
#' @export
krt_new <- new_krt

#' @rdname new_krt
#' @param x An object to test.
#' @export
is_krt <- function(x) inherits(x, "krt_tbl")

# Record a mutation: bump `updated_at` and (once provenance is available) append
# a provenance entry describing the activity. Kept in one place so every
# mutating operation is uniformly tracked.
#' @noRd
.touch <- function(x, activity = NULL, inputs = NULL, outputs = NULL,
                   params = NULL) {
  x$updated_at <- now_iso()
  if (!is.null(activity)) {
    x <- append_provenance(x, activity = activity, inputs = inputs,
                           outputs = outputs, params = params)
  }
  x
}

#' Get or set KRT metadata
#'
#' @param x A [krt_tbl].
#' @param value A named list of metadata fields to set (any of `title`,
#'   `profile`, `study_type`, `locale`).
#' @return `krt_meta()` returns a named list of the table's metadata.
#' @export
#' @examples
#' k <- new_krt("Demo")
#' krt_meta(k)$title
#' krt_meta(k) <- list(title = "Renamed")
krt_meta <- function(x) {
  stopifnot(is_krt(x))
  list(schema_version = x$schema_version, profile = x$profile,
       table_id = x$table_id, title = x$title, study_type = x$study_type,
       locale = x$locale, created_at = x$created_at, updated_at = x$updated_at)
}

#' @rdname krt_meta
#' @export
`krt_meta<-` <- function(x, value) {
  stopifnot(is_krt(x), is.list(value))
  for (nm in intersect(names(value), c("title", "profile", "study_type", "locale"))) {
    x[[nm]] <- if (nm == "study_type") as_chr(value[[nm]]) else value[[nm]]
  }
  .touch(x, "set_meta")
}

#' Coerce a KRT to a data frame (a rectangular view)
#'
#' Produces a rectangular *view* of the table by filling the union of present
#' fields with `NA`. Many-valued fields are collapsed with `"; "` in this view;
#' the lossless representation is the JSON/YAML export.
#'
#' @param x A [krt_tbl].
#' @param row.names,optional Present for consistency with the [as.data.frame()]
#'   generic; not used.
#' @param view The view to produce: `"wide"` (the full union of core fields) or
#'   a profile name such as `"asap"` (a profile projection). Must be named.
#' @param ... Ignored.
#' @return A data frame with one row per resource.
#' @export
#' @examples
#' k <- add_resource(new_krt("Demo"), "Dataset", "RNA-seq",
#'                   new_or_reuse = "new", doi = "10.5281/zenodo.123")
#' as.data.frame(k)
#' as.data.frame(krt_example, view = "asap")
as.data.frame.krt_tbl <- function(x, row.names = NULL, optional = FALSE, ...,
                                  view = "wide") {
  if (!identical(view, "wide")) {
    if (exists("project_profile", mode = "function", inherits = TRUE)) {
      return(project_profile(x, view))
    }
    stop(sprintf("View '%s' requires the profile system; use view = 'wide'.", view),
         call. = FALSE)
  }
  resources <- x$resources
  if (!length(resources)) {
    return(data.frame(resource_id = character(0), resource_type = character(0),
                      stringsAsFactors = FALSE))
  }
  field_order <- names(all_fields())
  present <- unique(unlist(lapply(resources, names)))
  cols <- c(field_order[field_order %in% present], setdiff(present, field_order))
  mat <- lapply(resources, function(r) {
    vapply(cols, function(cn) {
      v <- r[[cn]]
      if (is.null(v)) return(NA_character_)
      if (length(v) > 1L) return(paste(as.character(v), collapse = "; "))
      as.character(v)
    }, character(1))
  })
  df <- as.data.frame(do.call(rbind, mat), stringsAsFactors = FALSE)
  names(df) <- cols
  rownames(df) <- NULL
  df
}

# Optional tibble method, registered in .onLoad only when tibble is installed.
as_tibble.krt_tbl <- function(x, view = "wide", ...) {
  tibble::as_tibble(as.data.frame(x, view = view), ...)
}

#' Summarize a KRT
#'
#' @param object A [krt_tbl].
#' @param ... Ignored.
#' @return A data frame with resource counts per resource type, including the
#'   number of newly generated versus reused resources.
#' @export
#' @examples
#' summary(krt_example)
summary.krt_tbl <- function(object, ...) {
  resources <- object$resources
  if (!length(resources)) {
    return(data.frame(resource_type = character(0), n = integer(0),
                      n_new = integer(0), n_reuse = integer(0),
                      stringsAsFactors = FALSE))
  }
  types <- vapply(resources, function(r) r$resource_type %||% NA_character_, character(1))
  nr <- vapply(resources, function(r) tolower(r$new_or_reuse %||% ""), character(1))
  utypes <- sort(unique(types))
  df <- data.frame(
    resource_type = utypes,
    n = vapply(utypes, function(t) sum(types == t), integer(1)),
    n_new = vapply(utypes, function(t) sum(types == t & nr == "new"), integer(1)),
    n_reuse = vapply(utypes, function(t) sum(types == t & nr == "reuse"), integer(1)),
    row.names = NULL, stringsAsFactors = FALSE
  )
  df
}

#' @export
format.krt_tbl <- function(x, ...) {
  n <- length(x$resources)
  lines <- c(
    sprintf("<krt_tbl> %s", x$title %||% "(untitled)"),
    sprintf("  profile: %s | schema: %s | resources: %d",
            x$profile %||% "generic", x$schema_version %||% "?", n)
  )
  if (n) {
    s <- summary(x)
    for (i in seq_len(nrow(s))) {
      lines <- c(lines, sprintf("    %-42s %d (new %d, reuse %d)",
                                s$resource_type[i], s$n[i], s$n_new[i], s$n_reuse[i]))
    }
  }
  if (length(x$approvals)) lines <- c(lines, sprintf("  approvals: %d", length(x$approvals)))
  if (length(x$contributors)) lines <- c(lines, sprintf("  contributors: %d", length(x$contributors)))
  if (length(x$validation)) {
    nerr <- sum(vapply(x$validation, function(f) identical(f$severity, "error"), logical(1)))
    lines <- c(lines, sprintf("  validation: %s (%d finding%s)",
                              if (nerr == 0L) "valid" else "INVALID",
                              length(x$validation), if (length(x$validation) == 1L) "" else "s"))
  }
  paste(lines, collapse = "\n")
}

#' @export
print.krt_tbl <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}
