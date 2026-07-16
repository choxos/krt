# Registry of identifier resolvers, keyed by scheme.

.resolver_registry <- new.env(parent = emptyenv())

#' Register an identifier resolver
#'
#' @param scheme The identifier scheme (e.g. `"rrid"`, `"doi"`, `"orcid"`).
#' @param fn A function `function(id, resolve = TRUE, ...)` returning a
#'   normalized result list with at least `input`, `normalized`, and `resolved`.
#' @return Invisibly `NULL`.
#' @export
#' @examples
#' "rrid" %in% list_resolvers()
register_resolver <- function(scheme, fn) {
  if (!is.function(fn)) stop("`fn` must be a function.", call. = FALSE)
  .resolver_registry[[scheme]] <- fn
  invisible(NULL)
}

#' @noRd
get_resolver <- function(scheme) .resolver_registry[[scheme]]

#' List registered resolver schemes
#'
#' @return A character vector of scheme names.
#' @export
#' @examples
#' list_resolvers()
list_resolvers <- function() sort(ls(.resolver_registry))

#' @noRd
.register_builtin_resolvers <- function() {
  register_resolver("rrid", resolve_rrid)
  register_resolver("doi", resolve_doi)
  register_resolver("orcid", resolve_orcid)
  register_resolver("pmid", resolve_pubmed)
  register_resolver("ror", resolve_ror)
  register_resolver("cellosaurus", resolve_cellosaurus)
  invisible()
}
