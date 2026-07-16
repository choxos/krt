# Approval and contributor records. Like resources, these are present-only
# typed records; they live in the table-level `approvals` and `contributors`
# slots and are consumed by the conditional (ethics, ARRIVE) validation packs.

#' Create and add an ethics or governance approval
#'
#' @param approval_type One of [krt_approval_types()] (e.g. `"IACUC"`, `"IRB"`,
#'   `"REB"`, `"ethics"`).
#' @param ... Additional named fields: `board_name`, `protocol_number`,
#'   `institution_name`, `institution_ror`, `jurisdiction`, `approved_on`,
#'   `consent_obtained`, `consent_scope`, `data_use_restrictions`,
#'   `redaction_level`.
#' @param .id Optional explicit approval id.
#' @return `new_approval()` returns a `krt_approval`; `add_approval()` returns
#'   the updated [krt_tbl].
#' @export
#' @examples
#' a <- new_approval("IACUC", protocol_number = "2026-017",
#'                   board_name = "Example IACUC")
#' k <- add_approval(new_krt("Demo"), a)
new_approval <- function(approval_type, ..., .id = NULL) {
  m <- vocab_match(approval_type, "approval_type", fuzzy = TRUE)
  atype <- if (m$ok) m$value else approval_type
  dots <- list(...)
  if (length(dots) && (is.null(names(dots)) || any(!nzchar(names(dots))))) {
    stop("All approval fields must be named.", call. = FALSE)
  }
  if (!is.null(dots$consent_obtained)) dots$consent_obtained <- as.logical(dots$consent_obtained)
  if (!is.null(dots$redaction_level)) {
    rm <- vocab_match(dots$redaction_level, "redaction_level")
    if (rm$ok) dots$redaction_level <- rm$value
  }
  aid <- .id %||% dots$approval_id %||% new_id("appr", atype, dots$protocol_number %||% "")
  dots$approval_id <- NULL
  rec <- c(list(approval_id = aid, approval_type = atype), dots)
  structure(compact(rec), class = "krt_approval")
}

#' @rdname new_approval
#' @param x A [krt_tbl].
#' @export
add_approval <- function(x, ...) {
  stopifnot(is_krt(x))
  args <- list(...)
  a <- if (length(args) == 1L && inherits(args[[1]], "krt_approval")) args[[1]] else do.call(new_approval, args)
  x$approvals <- c(x$approvals, list(a))
  .touch(x, "add_approval", outputs = a$approval_id)
}

#' Create and add a contributor
#'
#' @param name Contributor name.
#' @param ... Additional named fields: `orcid`, `role` (see [krt_roles()]),
#'   `affiliation`, `affiliation_ror`.
#' @param .id Optional explicit contributor id.
#' @return `new_contributor()` returns a `krt_contributor`; `add_contributor()`
#'   returns the updated [krt_tbl].
#' @export
#' @examples
#' k <- add_contributor(new_krt("Demo"), "Ada Researcher",
#'                      orcid = "0000-0002-1825-0097", role = "author")
new_contributor <- function(name, ..., .id = NULL) {
  if (!is_nonempty_string(name)) stop("`name` must be a non-empty string.", call. = FALSE)
  dots <- list(...)
  if (length(dots) && (is.null(names(dots)) || any(!nzchar(names(dots))))) {
    stop("All contributor fields must be named.", call. = FALSE)
  }
  if (!is.null(dots$role)) {
    rm <- vocab_match(dots$role, "role", fuzzy = TRUE)
    if (rm$ok) dots$role <- rm$value
  }
  if (!is.null(dots$orcid)) dots$orcid <- norm_orcid(dots$orcid)
  cid <- .id %||% dots$contributor_id %||% new_id("ctb", name)
  dots$contributor_id <- NULL
  rec <- c(list(contributor_id = cid, name = name), dots)
  structure(compact(rec), class = "krt_contributor")
}

#' @rdname new_contributor
#' @param x A [krt_tbl].
#' @export
add_contributor <- function(x, ...) {
  stopifnot(is_krt(x))
  args <- list(...)
  c_rec <- if (length(args) == 1L && inherits(args[[1]], "krt_contributor")) args[[1]] else do.call(new_contributor, args)
  x$contributors <- c(x$contributors, list(c_rec))
  .touch(x, "add_contributor", outputs = c_rec$contributor_id)
}

#' @export
print.krt_approval <- function(x, ...) {
  cat(sprintf("<krt_approval> [%s] %s\n", x$approval_type %||% "?",
              x$protocol_number %||% x$approval_id %||% ""), sep = "")
  invisible(x)
}

#' @export
print.krt_contributor <- function(x, ...) {
  cat(sprintf("<krt_contributor> %s%s\n", x$name %||% x$contributor_id %||% "",
              if (!is.null(x$orcid)) paste0(" (", x$orcid, ")") else ""), sep = "")
  invisible(x)
}
