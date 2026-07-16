# Resource records: the typed, present-only building blocks of a krt_tbl.

#' Create a resource record
#'
#' Builds a single `krt_resource`: a flat, present-only record describing one
#' research resource. Identifier fields are stored separately by type
#' (`catalog_number`, `rrid`, `doi`, ...); they are only combined into a
#' compound identifier string at export time.
#'
#' @param resource_type One of [krt_resource_types()].
#' @param display_name The resource name as it appears in the manuscript.
#' @param ... Additional named fields (see [all_fields()] for the vocabulary),
#'   for example `vendor`, `catalog_number`, `rrid`, `doi`, `new_or_reuse`,
#'   `notes`.
#' @param .id Optional explicit resource id; generated from content if omitted.
#' @param .validate If `TRUE` (default), check `resource_type` against the
#'   controlled vocabulary and warn about unknown fields.
#' @return An object of class `krt_resource`.
#' @export
#' @examples
#' new_resource("Antibody", "Rabbit Anti-TH", vendor = "Millipore",
#'              catalog_number = "AB152", rrid = "RRID:AB_390204",
#'              new_or_reuse = "reuse")
new_resource <- function(resource_type, display_name = NULL, ..., .id = NULL,
                         .validate = TRUE) {
  if (!is_nonempty_string(resource_type)) {
    stop("`resource_type` must be a single non-empty string.", call. = FALSE)
  }
  if (isTRUE(.validate)) {
    m <- vocab_match(resource_type, "resource_type", fuzzy = TRUE)
    if (!m$ok) {
      hint <- if (!is.na(m$suggestion)) sprintf(" Did you mean '%s'?", m$suggestion) else ""
      stop(sprintf("Unknown resource_type '%s'.%s See krt_resource_types().",
                   resource_type, hint), call. = FALSE)
    }
    resource_type <- m$value
  }

  dots <- list(...)
  if (length(dots) && (is.null(names(dots)) || any(!nzchar(names(dots))))) {
    stop("All resource fields passed through `...` must be named.", call. = FALSE)
  }
  if (!is.null(display_name)) dots$display_name <- display_name

  # Split known vs unknown fields.
  known <- names(dots) %in% names(all_fields())
  known[names(dots) %in% c("resource_id")] <- TRUE
  if (any(!known)) {
    warning(sprintf("Dropping unknown resource field(s): %s.",
                    paste(names(dots)[!known], collapse = ", ")), call. = FALSE)
  }
  dots <- dots[known]

  # Coerce each field to its declared type.
  for (nm in names(dots)) dots[[nm]] <- coerce_field(nm, dots[[nm]])

  rid <- .id %||% dots$resource_id %||%
    new_id("res", resource_type, dots$display_name %||% "", dots$rrid %||% dots$catalog_number %||% "")
  dots$resource_id <- NULL

  record <- c(list(resource_id = rid, resource_type = resource_type), dots)
  structure(compact(record), class = "krt_resource")
}

#' @rdname new_resource
#' @param x An object to test.
#' @export
is_resource <- function(x) inherits(x, "krt_resource")

#' Add, update, remove, or get a resource in a KRT
#'
#' @param x A [krt_tbl].
#' @param ... For `add_resource()`, either a single `krt_resource` (from
#'   [new_resource()]) or the arguments of [new_resource()] (`resource_type`,
#'   `display_name`, and named fields).
#' @param resource_id The id of the resource to update, remove, or get.
#' @return `add_resource()`, `update_resource()`, and `remove_resource()` return
#'   the modified `krt_tbl`; `get_resource()` returns a `krt_resource` or `NULL`.
#' @export
#' @examples
#' k <- new_krt("Demo")
#' k <- add_resource(k, "Software/code", "R", version = "4.4.0",
#'                   new_or_reuse = "reuse", rrid = "RRID:SCR_001905")
#' get_resource(k, k$resources[[1]]$resource_id)
add_resource <- function(x, ...) {
  stopifnot(is_krt(x))
  args <- list(...)
  if (length(args) == 1L && is_resource(args[[1]])) {
    res <- args[[1]]
  } else {
    res <- do.call(new_resource, args)
  }
  res$resource_id <- .unique_resource_id(x, res$resource_id)
  x$resources <- c(x$resources, list(res))
  .touch(x, "add_resource", outputs = res$resource_id)
}

#' @rdname add_resource
#' @export
update_resource <- function(x, resource_id, ...) {
  stopifnot(is_krt(x))
  i <- .resource_index(x, resource_id)
  if (is.na(i)) stop(sprintf("No resource with id '%s'.", resource_id), call. = FALSE)
  cur <- x$resources[[i]]
  updates <- list(...)
  if (length(updates) && (is.null(names(updates)) || any(!nzchar(names(updates))))) {
    stop("All updates must be named.", call. = FALSE)
  }
  for (nm in names(updates)) {
    val <- updates[[nm]]
    if (identical(nm, "resource_type")) {
      m <- vocab_match(val, "resource_type", fuzzy = TRUE)
      if (!m$ok) {
        hint <- if (!is.na(m$suggestion)) sprintf(" Did you mean '%s'?", m$suggestion) else ""
        stop(sprintf("Unknown resource_type '%s'.%s", val, hint), call. = FALSE)
      }
      cur$resource_type <- m$value
    } else if (is.null(val) || (length(val) == 1L && is.atomic(val) && is.na(val))) {
      cur[[nm]] <- NULL
    } else if (nm %in% names(all_fields())) {
      cur[[nm]] <- coerce_field(nm, val)
    } else {
      warning(sprintf("Ignoring unknown field '%s'.", nm), call. = FALSE)
    }
  }
  x$resources[[i]] <- structure(compact(cur), class = "krt_resource")
  .touch(x, "update_resource", outputs = resource_id)
}

#' @rdname add_resource
#' @export
remove_resource <- function(x, resource_id) {
  stopifnot(is_krt(x))
  i <- .resource_index(x, resource_id)
  if (is.na(i)) stop(sprintf("No resource with id '%s'.", resource_id), call. = FALSE)
  x$resources[[i]] <- NULL
  .touch(x, "remove_resource", outputs = resource_id)
}

#' @rdname add_resource
#' @export
get_resource <- function(x, resource_id) {
  stopifnot(is_krt(x))
  i <- .resource_index(x, resource_id)
  if (is.na(i)) return(NULL)
  x$resources[[i]]
}

#' @noRd
.resource_index <- function(x, resource_id) {
  ids <- vapply(x$resources, function(r) r$resource_id %||% NA_character_, character(1))
  match(resource_id, ids)
}

#' @noRd
.unique_resource_id <- function(x, id) {
  ids <- vapply(x$resources, function(r) r$resource_id %||% NA_character_, character(1))
  if (!(id %in% ids)) return(id)
  i <- 2L
  repeat {
    cand <- sprintf("%s-%d", id, i)
    if (!(cand %in% ids)) return(cand)
    i <- i + 1L
  }
}

#' @export
format.krt_resource <- function(x, ...) {
  head <- sprintf("<krt_resource> [%s] %s",
                  x$resource_type %||% "?", x$display_name %||% x$resource_id %||% "")
  ids <- compact(list(RRID = x$rrid, DOI = x$doi, `Cat#` = x$catalog_number,
                      Accession = if (!is.null(x$accession)) paste(x$accession, collapse = ", "),
                      URL = x$url))
  idline <- if (length(ids)) {
    paste0("  ", paste(sprintf("%s: %s", names(ids), unlist(ids)), collapse = "; "))
  }
  nr <- if (!is.null(x$new_or_reuse)) sprintf("  (%s)", x$new_or_reuse)
  paste(c(paste0(head, nr %||% ""), idline), collapse = "\n")
}

#' @export
print.krt_resource <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}
