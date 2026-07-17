# Ontology / registry autocomplete. Each source queries an authority and returns
# candidate (label, id) pairs. Offline or on error, an empty result is returned.

.suggest_registry <- new.env(parent = emptyenv())

#' Register an autocomplete source
#'
#' @param name Source name (e.g. `"taxonomy"`, `"ror"`).
#' @param fn A function `function(query, n)` returning a data frame with columns
#'   `label`, `id`, `authority`, `score`, `uri`.
#' @param replace Overwrite an existing source named `name`? Defaults to `FALSE`
#'   so a plugin cannot silently replace a built-in source.
#' @return Invisibly `NULL`.
#' @export
#' @examples
#' "ror" %in% list_suggest_sources()
register_suggest_source <- function(name, fn, replace = FALSE) {
  if (!is.function(fn)) stop("`fn` must be a function.", call. = FALSE)
  if (!isTRUE(replace) && !is.null(.suggest_registry[[name]])) {
    stop(sprintf("A suggest source '%s' is already registered; pass replace = TRUE to override.",
                 name), call. = FALSE)
  }
  .suggest_registry[[name]] <- fn
  invisible(NULL)
}

#' List autocomplete sources
#' @return A character vector of source names.
#' @export
#' @examples
#' list_suggest_sources()
list_suggest_sources <- function() sort(ls(.suggest_registry))

#' @noRd
.empty_suggest <- function() {
  data.frame(label = character(0), id = character(0), authority = character(0),
             score = numeric(0), uri = character(0), stringsAsFactors = FALSE)
}

#' @noRd
.suggest_row <- function(label, id, authority, uri = NA_character_, score = NA_real_) {
  data.frame(label = label, id = id, authority = authority, score = score,
             uri = uri, stringsAsFactors = FALSE)
}

#' Suggest canonical names and identifiers from public authorities
#'
#' Queries ontology and registry search endpoints to autocomplete a resource's
#' canonical name or identifier. Requires network access; returns an empty
#' result offline.
#'
#' @param query The text to search for.
#' @param type Optional resource type hint.
#' @param authority Which authority to query: `"auto"`, or the name of any
#'   registered source (built-ins: `"taxonomy"`, `"cellosaurus"`, `"chebi"`,
#'   `"ror"`; plus any added with [register_suggest_source()]).
#' @param n Maximum number of suggestions.
#' @param resolve Whether to contact the network (default `TRUE`).
#' @return A data frame with columns `label`, `id`, `authority`, `score`, `uri`.
#' @export
#' @examples
#' krt_suggest("dopamine", authority = "chebi", resolve = FALSE)
krt_suggest <- function(query, type = NULL, authority = "auto", n = 10,
                        resolve = TRUE) {
  authority <- as.character(authority)[1]
  known <- c("auto", list_suggest_sources())
  if (!(authority %in% known)) {
    stop(sprintf("Unknown authority '%s'. Options: %s.", authority,
                 paste(known, collapse = ", ")), call. = FALSE)
  }
  if (!isTRUE(resolve) || !is_nonempty_string(query)) return(.empty_suggest())
  sources <- if (identical(authority, "auto")) {
    .auto_sources(type)
  } else authority
  out <- lapply(sources, function(s) {
    fn <- .suggest_registry[[s]]
    if (is.null(fn)) return(.empty_suggest())
    tryCatch(fn(query, n), error = function(e) .empty_suggest())
  })
  df <- do.call(rbind, c(list(.empty_suggest()), out))
  utils::head(df, n)
}

#' @noRd
.auto_sources <- function(type) {
  if (is.null(type)) return(c("ror", "taxonomy"))
  switch(type,
    "Experimental model: Organism/strain" = "taxonomy",
    "Experimental model: Cell line" = "cellosaurus",
    "Chemical, peptide, or recombinant protein" = "chebi",
    c("ror", "taxonomy"))
}

#' @noRd
.suggest_ror <- function(query, n = 10) {
  j <- .resp_json(http_get(sub("/$", "", endpoint("ror")), query = list(query = query)))
  items <- .dig(j, "items")
  if (is.null(items) || !length(items)) return(.empty_suggest())
  rows <- lapply(utils::head(items, n), function(it) {
    id <- .dig(it, "id")
    # ROR API v2 items carry names in names[], not a top-level `name`; reuse the
    # resolver's display-name picker so labels are organization names, not ids.
    label <- .ror_display_name(it) %||% id %||% ""
    .suggest_row(label, sub("https://ror.org/", "", id %||% ""), "ror", uri = id)
  })
  do.call(rbind, rows)
}

#' @noRd
.suggest_chebi <- function(query, n = 10) {
  j <- .resp_json(http_get(paste0(endpoint("ols"), "search"),
                           query = list(q = query, ontology = "chebi", rows = n)))
  docs <- .dig(j, "response", "docs")
  if (is.null(docs) || !length(docs)) return(.empty_suggest())
  rows <- lapply(docs, function(d) {
    .suggest_row(.dig(d, "label") %||% "", .dig(d, "obo_id") %||% .dig(d, "short_form") %||% "",
                 "chebi", uri = .dig(d, "iri"))
  })
  do.call(rbind, rows)
}

#' @noRd
.suggest_taxonomy <- function(query, n = 10) {
  j <- .resp_json(http_get(paste0(endpoint("ncbi_eutils"), "esearch.fcgi"),
                           query = list(db = "taxonomy", term = query, retmode = "json",
                                        retmax = n)))
  ids <- unlist(.dig(j, "esearchresult", "idlist"))
  if (is.null(ids) || !length(ids)) return(.empty_suggest())
  # esearch returns only ids; follow up with esummary so each row is labeled with
  # its scientific name rather than the query string.
  s <- .resp_json(http_get(paste0(endpoint("ncbi_eutils"), "esummary.fcgi"),
                           query = list(db = "taxonomy", id = paste(ids, collapse = ","),
                                        retmode = "json")))
  rows <- lapply(ids, function(id) {
    nm <- .dig(s, "result", id, "scientificname") %||% query
    .suggest_row(nm, id, "taxonomy",
                 uri = paste0("https://www.ncbi.nlm.nih.gov/taxonomy/", id))
  })
  do.call(rbind, rows)
}

#' @noRd
.suggest_cellosaurus <- function(query, n = 10) {
  j <- .resp_json(http_get(paste0(endpoint("cellosaurus"), "search/cell-line"),
                           query = list(q = query, format = "json", rows = n)))
  items <- .dig(j, "Cellosaurus", "cell-line-list") %||% .dig(j, "cell-line-list")
  if (is.null(items) || !length(items)) return(.empty_suggest())
  rows <- lapply(items, function(it) {
    acc <- .dig(it, "accession-list", 1L, "value")
    .suggest_row(.dig(it, "name-list", 1L, "value") %||% "", acc %||% "", "cellosaurus",
                 uri = if (!is.null(acc)) paste0("https://www.cellosaurus.org/", acc) else NA_character_)
  })
  do.call(rbind, rows)
}

#' @noRd
.register_builtin_suggest_sources <- function() {
  register_suggest_source("ror", .suggest_ror)
  register_suggest_source("chebi", .suggest_chebi)
  register_suggest_source("taxonomy", .suggest_taxonomy)
  register_suggest_source("cellosaurus", .suggest_cellosaurus)
  invisible()
}
