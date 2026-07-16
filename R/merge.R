# Merging and diffing tables for multi-author workflows. Resources are matched
# by their normalized identity signature.

#' @noRd
.merge_records <- function(grp, strategy) {
  fields <- unique(unlist(lapply(grp, names)))
  record <- list()
  conflicts <- list()
  pick <- switch(strategy, prefer_y = length(grp), 1L)  # index into grp on conflict
  for (f in fields) {
    vals <- lapply(grp, function(r) r[[f]])
    present <- vals[!vapply(vals, is.null, logical(1))]
    if (!length(present)) next
    uniq <- unique(lapply(present, as.character))
    if (length(uniq) == 1L) {
      record[[f]] <- present[[1]]
    } else {
      conflicts[[length(conflicts) + 1L]] <- list(
        resource_id = grp[[1]]$resource_id %||% NA_character_, field = f,
        values = unique(unlist(lapply(present, function(v) paste(v, collapse = "; ")))))
      record[[f]] <- if (identical(strategy, "prefer_y")) grp[[length(grp)]][[f]] else grp[[1]][[f]]
    }
  }
  record$resource_id <- grp[[1]]$resource_id
  list(record = structure(compact(record), class = "krt_resource"),
       conflicts = conflicts)
}

#' Merge Key Resources Tables
#'
#' Combines resources from two or more tables, matching by normalized identity
#' signature. Matching resources are merged field by field; the `strategy`
#' resolves field-level conflicts. Conflicts are attached to the result as the
#' `"merge_conflicts"` attribute.
#'
#' @param x,y,... Tables to merge (`x` supplies the result's metadata).
#' @param strategy `"union"`/`"prefer_x"` (x wins conflicts), `"prefer_y"` (later
#'   table wins), or `"manual"` (x wins but every conflict is recorded).
#' @param by A function computing a resource's match key (default
#'   [resource_signature()]).
#' @return The merged [krt_tbl].
#' @export
#' @examples
#' a <- add_resource(new_krt("A"), "Antibody", "Anti-TH", vendor = "Millipore",
#'                   catalog_number = "AB152", new_or_reuse = "reuse")
#' b <- add_resource(new_krt("B"), "Dataset", "D", doi = "10.5281/zenodo.1",
#'                   new_or_reuse = "new")
#' krt_merge(a, b)
krt_merge <- function(x, y, ..., strategy = c("union", "prefer_x", "prefer_y",
                                              "manual"),
                      by = resource_signature) {
  stopifnot(is_krt(x), is_krt(y))
  strategy <- match.arg(strategy)
  others <- c(list(y), list(...))
  all_res <- c(x$resources, unlist(lapply(others, function(k) k$resources),
                                   recursive = FALSE))
  if (!length(all_res)) return(x)
  sigs <- vapply(all_res, by, character(1))
  merged <- list(); conflicts <- list()
  for (s in unique(sigs)) {
    grp <- all_res[sigs == s]
    if (length(grp) == 1L) {
      merged <- c(merged, grp)
    } else {
      m <- .merge_records(grp, strategy)
      merged <- c(merged, list(m$record))
      conflicts <- c(conflicts, m$conflicts)
    }
  }
  dedupe_by <- function(records, key) {
    seen <- character(0); keep <- list()
    for (r in records) {
      id <- r[[key]] %||% ""
      if (!nzchar(id) || !(id %in% seen)) { seen <- c(seen, id); keep <- c(keep, list(r)) }
    }
    keep
  }
  out <- x
  out$resources <- merged
  out$approvals <- dedupe_by(
    c(x$approvals, unlist(lapply(others, function(k) k$approvals), recursive = FALSE)),
    "approval_id")
  out$contributors <- dedupe_by(
    c(x$contributors, unlist(lapply(others, function(k) k$contributors), recursive = FALSE)),
    "contributor_id")
  out <- .touch(out, "merge", params = list(strategy = strategy,
                                            resources = length(merged),
                                            conflicts = length(conflicts)))
  attr(out, "merge_conflicts") <- conflicts
  out
}

#' Diff two Key Resources Tables
#'
#' Compares resources by identity signature and reports which were added,
#' removed, or changed (with field-level deltas).
#'
#' @param x,y Two [krt_tbl] objects (`x` is the baseline).
#' @return A `krt_diff` object with `print()` and `as.data.frame()` methods.
#' @export
#' @examples
#' a <- add_resource(new_krt("A"), "Dataset", "D", doi = "10.5281/zenodo.1",
#'                   new_or_reuse = "new")
#' b <- update_resource(a, a$resources[[1]]$resource_id, notes = "added")
#' as.data.frame(krt_diff(a, b))
krt_diff <- function(x, y) {
  stopifnot(is_krt(x), is_krt(y))
  sx <- vapply(x$resources, resource_signature, character(1))
  sy <- vapply(y$resources, resource_signature, character(1))
  added <- y$resources[!(sy %in% sx)]
  removed <- x$resources[!(sx %in% sy)]
  changed <- list()
  for (s in intersect(sx, sy)) {
    rx <- x$resources[[which(sx == s)[1]]]
    ry <- y$resources[[which(sy == s)[1]]]
    flds <- unique(c(names(rx), names(ry)))
    deltas <- list()
    for (f in flds) {
      vx <- paste(as.character(rx[[f]] %||% ""), collapse = "; ")
      vy <- paste(as.character(ry[[f]] %||% ""), collapse = "; ")
      if (!identical(vx, vy)) deltas[[f]] <- list(from = vx, to = vy)
    }
    if (length(deltas)) {
      changed[[length(changed) + 1L]] <- list(
        resource_id = rx$resource_id %||% NA_character_, deltas = deltas)
    }
  }
  structure(list(added = added, removed = removed, changed = changed),
            class = "krt_diff")
}

#' @export
format.krt_diff <- function(x, ...) {
  paste(sprintf("<krt_diff> +%d added, -%d removed, ~%d changed",
                length(x$added), length(x$removed), length(x$changed)),
        collapse = "\n")
}

#' @export
print.krt_diff <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}

#' @export
as.data.frame.krt_diff <- function(x, row.names = NULL, optional = FALSE, ...) {
  rows <- list()
  for (r in x$added) rows[[length(rows) + 1L]] <- data.frame(
    change = "added", resource_id = r$resource_id %||% NA_character_,
    field = NA_character_, from = NA_character_, to = NA_character_,
    stringsAsFactors = FALSE)
  for (r in x$removed) rows[[length(rows) + 1L]] <- data.frame(
    change = "removed", resource_id = r$resource_id %||% NA_character_,
    field = NA_character_, from = NA_character_, to = NA_character_,
    stringsAsFactors = FALSE)
  for (c in x$changed) for (f in names(c$deltas)) rows[[length(rows) + 1L]] <- data.frame(
    change = "changed", resource_id = c$resource_id, field = f,
    from = c$deltas[[f]]$from, to = c$deltas[[f]]$to, stringsAsFactors = FALSE)
  if (!length(rows)) {
    return(data.frame(change = character(0), resource_id = character(0),
                      field = character(0), from = character(0), to = character(0),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, rows)
}
