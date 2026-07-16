# Identifier normalization: canonicalize DOIs, ORCIDs, RRIDs, RORs, PMIDs, and
# PMCIDs to consistent forms. Pure and offline; idempotent.

#' Normalize identifiers to canonical forms
#'
#' Canonicalizes the identifier fields of a table, a resource, or a bare
#' character vector: strips resolver prefixes from DOIs, hyphenates ORCIDs,
#' ensures the `RRID:` prefix, and so on. Applied consistently, this prevents
#' the same identifier from appearing in several syntactic forms.
#'
#' @param x A [krt_tbl], a `krt_resource`, or a character vector of identifiers.
#' @param ... Ignored.
#' @return An object of the same type as `x`, with identifiers normalized.
#' @export
#' @examples
#' normalize_ids("https://doi.org/10.1038/SDATA.2016.18")
#' r <- new_resource("Software/code", "Fiji", rrid = "SCR_002285",
#'                   new_or_reuse = "reuse")
#' normalize_ids(r)$rrid
normalize_ids <- function(x, ...) UseMethod("normalize_ids")

#' @export
normalize_ids.default <- function(x, ...) {
  stop("normalize_ids() supports krt_tbl, krt_resource, and character inputs.",
       call. = FALSE)
}

#' @export
normalize_ids.character <- function(x, ...) {
  vapply(x, function(v) {
    pr <- id_parse(v)
    .norm_by_scheme(pr$scheme, pr$value)
  }, character(1), USE.NAMES = FALSE)
}

#' @export
normalize_ids.krt_resource <- function(x, ...) {
  if (!is.null(x$doi))          x$doi          <- norm_doi(x$doi)
  if (!is.null(x$rrid))         x$rrid         <- norm_rrid(x$rrid)
  if (!is.null(x$pmid))         x$pmid         <- norm_pmid(x$pmid)
  if (!is.null(x$pmcid))        x$pmcid        <- norm_pmcid(x$pmcid)
  if (!is.null(x$cellosaurus_id)) x$cellosaurus_id <- toupper(sub("^cvcl_", "CVCL_", x$cellosaurus_id, ignore.case = TRUE))
  structure(compact(x), class = "krt_resource")
}

#' @export
normalize_ids.krt_tbl <- function(x, ...) {
  x$resources <- lapply(x$resources, normalize_ids)
  x$contributors <- lapply(x$contributors, function(c) {
    if (!is.null(c$orcid)) c$orcid <- norm_orcid(c$orcid)
    if (!is.null(c$affiliation_ror)) c$affiliation_ror <- norm_ror(c$affiliation_ror)
    c
  })
  x$approvals <- lapply(x$approvals, function(a) {
    if (!is.null(a$institution_ror)) a$institution_ror <- norm_ror(a$institution_ror)
    a
  })
  .touch(x, "normalize_ids")
}

#' @noRd
.norm_by_scheme <- function(scheme, value) {
  if (is.na(scheme)) return(value)
  switch(scheme,
    doi = norm_doi(value),
    orcid = norm_orcid(value),
    ror = norm_ror(value),
    pmid = norm_pmid(value),
    pmcid = norm_pmcid(value),
    rrid = norm_rrid(value),
    value)
}

#' @noRd
norm_doi <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) trimws(.strip_doi(v)), character(1), USE.NAMES = FALSE)
}

#' @noRd
norm_orcid <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) {
    v <- sub("^https?://orcid\\.org/", "", trimws(v), ignore.case = TRUE)
    core <- gsub("[^0-9Xx]", "", v)
    if (nchar(core) == 16L) {
      core <- toupper(core)
      v <- paste(substring(core, c(1, 5, 9, 13), c(4, 8, 12, 16)), collapse = "-")
    }
    v
  }, character(1), USE.NAMES = FALSE)
}

#' @noRd
norm_ror <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) sub("^https?://ror\\.org/", "", trimws(v), ignore.case = TRUE),
         character(1), USE.NAMES = FALSE)
}

#' @noRd
norm_pmid <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) gsub("[^0-9]", "", sub("^pmid:?\\s*", "", trimws(v), ignore.case = TRUE)),
         character(1), USE.NAMES = FALSE)
}

#' @noRd
norm_pmcid <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) {
    v <- toupper(trimws(v))
    if (grepl("^[0-9]+$", v)) paste0("PMC", v) else sub("^PMCID:?\\s*", "", v)
  }, character(1), USE.NAMES = FALSE)
}

#' @noRd
norm_rrid <- function(x) {
  if (is.null(x)) return(NULL)
  vapply(x, function(v) {
    v <- trimws(v)
    if (grepl("^RRID:", v, ignore.case = TRUE)) sub("^rrid:", "RRID:", v, ignore.case = TRUE)
    else paste0("RRID:", v)
  }, character(1), USE.NAMES = FALSE)
}
