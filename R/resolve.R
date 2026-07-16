# Identifier resolvers. Each returns a normalized result and, when `resolve` is
# TRUE and the network is reachable, enriches it from the authority. Offline or
# on any failure, `resolved` is FALSE and only the normalized form is returned,
# so resolvers are safe to call anywhere (including CRAN checks with resolve
# left FALSE).

#' @noRd
.dig <- function(x, ...) {
  for (k in list(...)) {
    if (is.null(x)) return(NULL)
    x <- tryCatch(x[[k]], error = function(e) NULL)
  }
  x
}

#' @noRd
.rr <- function(input, normalized, resolved, source, name = NA_character_,
                type = NA_character_, url = NA_character_) {
  list(input = input, normalized = normalized, resolved = isTRUE(resolved),
       source = source, name = name %||% NA_character_,
       type = type %||% NA_character_, url = url %||% NA_character_)
}

#' Resolve identifiers against public registries
#'
#' Each resolver normalizes an identifier and, when `resolve = TRUE` and the
#' registry is reachable, retrieves a display name and type. All calls degrade
#' gracefully: offline or on error, `resolved` is `FALSE`.
#'
#' @param rrid,doi,orcid,pmid,ror,cvcl The identifier to resolve.
#' @param resolve Whether to contact the registry (default `TRUE`). Set `FALSE`
#'   for a purely offline, normalize-only result.
#' @param timeout Request timeout in seconds.
#' @return A list with `input`, `normalized`, `resolved`, `source`, `name`,
#'   `type`, and `url`.
#' @name resolvers
#' @examples
#' resolve_rrid("RRID:AB_390204", resolve = FALSE)
#' \donttest{
#' resolve_doi("10.1038/sdata.2016.18")
#' }
NULL

#' @rdname resolvers
#' @export
resolve_rrid <- function(rrid, resolve = TRUE, timeout = 15) {
  norm <- norm_rrid(rrid)
  if (!isTRUE(resolve)) return(.rr(rrid, norm, FALSE, "scicrunch", type = rrid_type(norm)))
  bare <- sub("^RRID:", "", norm)
  j <- .resp_json(http_get(paste0(endpoint("rrid"), "RRID:", bare, ".json"), timeout = timeout))
  if (is.null(j)) return(.rr(rrid, norm, FALSE, "scicrunch", type = rrid_type(norm)))
  name <- .dig(j, "hits", "hits", 1L, "_source", "item", "name") %||%
    .dig(j, "hits", "hits", 1L, "_source", "name")
  .rr(rrid, norm, TRUE, "scicrunch", name = as.character(name %||% NA_character_),
      type = rrid_type(norm), url = paste0("https://scicrunch.org/resolver/", bare))
}

#' @rdname resolvers
#' @export
resolve_doi <- function(doi, resolve = TRUE, timeout = 15) {
  norm <- norm_doi(doi)
  if (!isTRUE(resolve)) return(.rr(doi, norm, FALSE, "crossref"))
  mailto <- Sys.getenv("CROSSREF_MAILTO")
  j <- .resp_json(http_get(paste0(endpoint("crossref"), utils::URLencode(norm, reserved = TRUE)),
                           query = if (nzchar(mailto)) list(mailto = mailto) else NULL,
                           timeout = timeout))
  msg <- .dig(j, "message")
  if (is.null(msg)) return(.rr(doi, norm, FALSE, "crossref"))
  name <- .dig(msg, "title", 1L)
  .rr(doi, norm, TRUE, "crossref", name = as.character(name %||% NA_character_),
      type = as.character(.dig(msg, "type") %||% NA_character_),
      url = paste0("https://doi.org/", norm))
}

#' @rdname resolvers
#' @export
resolve_orcid <- function(orcid, resolve = TRUE, timeout = 15) {
  norm <- norm_orcid(orcid)
  if (!isTRUE(resolve)) return(.rr(orcid, norm, FALSE, "orcid"))
  j <- .resp_json(http_get(paste0(endpoint("orcid_pub"), norm, "/person"), timeout = timeout))
  if (is.null(j)) return(.rr(orcid, norm, FALSE, "orcid"))
  given <- .dig(j, "name", "given-names", "value")
  family <- .dig(j, "name", "family-name", "value")
  nm <- paste(c(given, family), collapse = " ")
  .rr(orcid, norm, TRUE, "orcid", name = if (nzchar(nm)) nm else NA_character_,
      type = "person", url = paste0("https://orcid.org/", norm))
}

#' @rdname resolvers
#' @export
resolve_pubmed <- function(pmid, resolve = TRUE, timeout = 15) {
  norm <- norm_pmid(pmid)
  if (!isTRUE(resolve)) return(.rr(pmid, norm, FALSE, "pubmed"))
  j <- .resp_json(http_get(paste0(endpoint("ncbi_eutils"), "esummary.fcgi"),
                           query = list(db = "pubmed", id = norm, retmode = "json"),
                           timeout = timeout))
  title <- .dig(j, "result", norm, "title")
  if (is.null(title)) return(.rr(pmid, norm, FALSE, "pubmed"))
  .rr(pmid, norm, TRUE, "pubmed", name = as.character(title), type = "article",
      url = paste0("https://pubmed.ncbi.nlm.nih.gov/", norm))
}

#' @rdname resolvers
#' @export
resolve_ror <- function(ror, resolve = TRUE, timeout = 15) {
  norm <- norm_ror(ror)
  if (!isTRUE(resolve)) return(.rr(ror, norm, FALSE, "ror"))
  j <- .resp_json(http_get(paste0(endpoint("ror"), norm), timeout = timeout))
  name <- .dig(j, "name")
  if (is.null(name)) return(.rr(ror, norm, FALSE, "ror"))
  .rr(ror, norm, TRUE, "ror", name = as.character(name), type = "organization",
      url = paste0("https://ror.org/", norm))
}

#' @rdname resolvers
#' @export
resolve_cellosaurus <- function(cvcl, resolve = TRUE, timeout = 15) {
  norm <- toupper(sub("^RRID:", "", cvcl))
  if (!isTRUE(resolve)) return(.rr(cvcl, norm, FALSE, "cellosaurus"))
  j <- .resp_json(http_get(paste0(endpoint("cellosaurus"), norm),
                           query = list(format = "json"), timeout = timeout))
  name <- .dig(j, "Cellosaurus", "cell-line-list", 1L, "name-list", 1L, "value") %||%
    .dig(j, "cell-line-list", 1L, "name-list", 1L, "value")
  if (is.null(name)) return(.rr(cvcl, norm, FALSE, "cellosaurus"))
  .rr(cvcl, norm, TRUE, "cellosaurus", name = as.character(name),
      type = "cell line", url = paste0("https://www.cellosaurus.org/", norm))
}

#' Resolve any identifier by detecting its scheme
#'
#' @param id An identifier string.
#' @param resolve Whether to contact the registry.
#' @param ... Passed to the scheme-specific resolver.
#' @return A resolver result list, or `NULL` if the scheme is unsupported.
#' @export
#' @examples
#' resolve_id("RRID:AB_390204", resolve = FALSE)$normalized
resolve_id <- function(id, resolve = TRUE, ...) {
  pr <- id_parse(id)
  scheme <- pr$scheme
  if (identical(pr$field, "cellosaurus_id")) scheme <- "cellosaurus"
  fn <- get_resolver(scheme)
  if (is.null(fn)) return(NULL)
  fn(id, resolve = resolve, ...)
}
