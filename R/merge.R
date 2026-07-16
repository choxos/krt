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
      # Pick the last (prefer_y) or first present value for this field, not the
      # last/first whole record, so a record missing the field cannot null it out.
      record[[f]] <- if (identical(strategy, "prefer_y")) present[[length(present)]] else present[[1]]
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
  strategy <- match.arg(strategy)
  others <- c(list(y), list(...))
  if (!is_krt(x) || !all(vapply(others, is_krt, logical(1)))) {
    stop("All inputs to krt_merge() must be krt_tbl objects.", call. = FALSE)
  }
  tables <- c(list(x), others)
  all_res <- unlist(lapply(tables, function(k) k$resources), recursive = FALSE)
  # Grouping key: resources that carry a distinguishing identifier merge by their
  # identity signature; a resource with none is merged only when an explicit
  # shared resource_id links two records, and a truly anonymous resource keeps a
  # unique key so distinct identity-less resources are never silently collapsed.
  keyf <- function(r, i) {
    if (.has_identity(r)) paste0("sig:", by(r))
    else if (nzchar(r$resource_id %||% "")) paste0("rid:", r$resource_id)
    else paste0("uniq:", i)
  }
  keys <- if (length(all_res)) {
    vapply(seq_along(all_res), function(i) keyf(all_res[[i]], i), character(1))
  } else character(0)
  merged <- list(); conflicts <- list()
  for (k in unique(keys)) {
    grp <- all_res[keys == k]
    if (length(grp) == 1L) {
      merged <- c(merged, grp)
    } else {
      m <- .merge_records(grp, strategy)
      merged <- c(merged, list(m$record))
      conflicts <- c(conflicts, m$conflicts)
    }
  }
  # Union approvals/contributors across every table by exact content, so
  # identical records collapse but conflicting ones are all kept (never dropped).
  union_records <- function(records) {
    seen <- character(0); keep <- list()
    for (r in records) {
      key <- digest::digest(r)
      if (!(key %in% seen)) { seen <- c(seen, key); keep <- c(keep, list(r)) }
    }
    keep
  }
  out <- x
  out$resources <- merged
  out$approvals <- union_records(
    unlist(lapply(tables, function(k) k$approvals), recursive = FALSE))
  out$contributors <- union_records(
    unlist(lapply(tables, function(k) k$contributors), recursive = FALSE))
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
