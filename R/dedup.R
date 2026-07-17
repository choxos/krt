# Duplicate detection by normalized resource signature.

#' Normalized signature of a resource
#'
#' Builds a lowercased, trimmed tuple from the identifying fields
#' `(resource_type, vendor, catalog_number, lot_number, rrid, doi, accession)`.
#' Two resources with the same signature are considered duplicates.
#'
#' @param resource A `krt_resource` or named list.
#' @return A single signature string.
#' @export
#' @examples
#' r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
#'                   catalog_number = "AB152", new_or_reuse = "reuse")
#' resource_signature(r)
resource_signature <- function(resource) {
  keys <- c("resource_type", "vendor", "catalog_number", "lot_number", "rrid",
            "doi", "accession")
  # Normalize identifier fields first, so a bare DOI and its URL form (or an
  # unprefixed and "RRID:"-prefixed RRID) produce the same signature.
  normfn <- list(rrid = norm_rrid, doi = norm_doi)
  vals <- vapply(keys, function(k) {
    v <- resource[[k]]
    if (is.null(v) || !length(v)) return("")
    if (!is.null(normfn[[k]])) v <- normfn[[k]](v)
    tolower(trimws(paste(as.character(v), collapse = "|")))
  }, character(1))
  # Join with a unit-separator delimiter (never present in identifiers) so field
  # boundaries are unambiguous: "ab" + "c" no longer collides with "a" + "bc".
  sep <- intToUtf8(31L)  # unit separator: unambiguous field boundary
  paste(paste0(keys, sep, vals), collapse = sep)
}

# A resource has "identity" if it carries a distinguishing field beyond its
# type; only such resources can be confidently called duplicates.
#' @noRd
.has_identity <- function(resource) {
  keys <- c("vendor", "catalog_number", "lot_number", "rrid", "doi", "accession")
  any(vapply(keys, function(k) {
    v <- resource[[k]]
    !is.null(v) && length(v) && any(nzchar(as.character(v)))
  }, logical(1)))
}

#' Find duplicate resources in a KRT
#'
#' @param x A [krt_tbl].
#' @param fuzzy If `TRUE`, also report near-duplicates whose display name and
#'   vendor are close by edit distance.
#' @return A list of duplicate groups; each element is a character vector of
#'   `resource_id`s that share a signature (or are near-duplicates).
#' @export
#' @examples
#' k <- new_krt("Demo")
#' k <- add_resource(k, "Antibody", "Anti-TH", vendor = "Millipore",
#'                   catalog_number = "AB152", new_or_reuse = "reuse")
#' k <- add_resource(k, "Antibody", "Anti-TH (dup)", vendor = "Millipore",
#'                   catalog_number = "AB152", new_or_reuse = "reuse")
#' find_duplicates(k)
find_duplicates <- function(x, fuzzy = FALSE) {
  stopifnot(is_krt(x))
  res <- x$resources
  if (length(res) < 2L) return(list())
  ids <- vapply(res, function(r) r$resource_id %||% NA_character_, character(1))
  has_id <- vapply(res, .has_identity, logical(1))
  sigs <- vapply(res, resource_signature, character(1))
  groups <- list()
  # Only resources with a distinguishing identity can be confidently duplicated,
  # so blank rows (e.g. two datasets with no ids) are not flagged.
  for (s in unique(sigs[has_id])) {
    grp <- ids[has_id & sigs == s]
    if (length(grp) > 1L) groups <- c(groups, list(grp))
  }
  if (isTRUE(fuzzy)) {
    key <- vapply(res, function(r) tolower(paste(r$display_name %||% "",
                  r$vendor %||% "")), character(1))
    seen <- rep(FALSE, length(res))
    for (i in seq_along(res)) {
      if (seen[i]) next
      d <- utils::adist(key[i], key)[1, ]
      near <- which(d > 0L & d <= 2L)
      if (length(near)) {
        grp <- ids[c(i, near)]
        seen[c(i, near)] <- TRUE
        # avoid duplicating an exact group already captured
        if (!any(vapply(groups, function(g) setequal(g, grp), logical(1)))) {
          groups <- c(groups, list(unique(grp)))
        }
      }
    }
  }
  groups
}
