# Registry of identifier resolvers, keyed by scheme.

.resolver_registry <- new.env(parent = emptyenv())

#' Register an identifier resolver
#'
#' @param scheme The identifier scheme (e.g. `"rrid"`, `"doi"`, `"orcid"`).
#' @param fn A function `function(id, resolve = TRUE, ...)` returning a
#'   normalized result list with at least `input`, `normalized`, and `resolved`.
#' @param replace Overwrite an existing resolver for `scheme`? Defaults to
#'   `FALSE` so a plugin cannot silently replace a built-in resolver.
#' @return Invisibly `NULL`.
#' @export
#' @examples
#' "rrid" %in% list_resolvers()
register_resolver <- function(scheme, fn, replace = FALSE) {
  if (!is.function(fn)) stop("`fn` must be a function.", call. = FALSE)
  if (!isTRUE(replace) && !is.null(.resolver_registry[[scheme]])) {
    stop(sprintf("A resolver for '%s' is already registered; pass replace = TRUE to override.",
                 scheme), call. = FALSE)
  }
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
