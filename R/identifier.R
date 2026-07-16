# Identifier parsing, typing, and composition.
#
# The internal model stores each identifier in its own typed field. The ASAP
# "IDENTIFIER" column is a single compound string that joins several of them
# (e.g. "Cat# AB152; RRID:AB_390204"). These helpers convert between the two.

#' Parse and classify an identifier string
#'
#' Detects the scheme of a single identifier token (DOI, ORCID, ROR, RRID,
#' PMID, PMCID, URL, or a database accession) using the bundled syntax
#' patterns.
#'
#' @param idstring A single identifier token.
#' @return A list with `scheme` (character, or `NA` if unrecognized), `value`
#'   (the cleaned identifier), and `field` (the resource field the value belongs
#'   in, e.g. `"doi"`, `"rrid"`, `"accession"`).
#' @export
#' @examples
#' id_parse("https://doi.org/10.5281/zenodo.123")
#' id_parse("RRID:AB_390204")
#' id_parse("GSE12345")
id_parse <- function(idstring) {
  x <- trimws(as.character(idstring))
  p <- ref_data("id_patterns")
  if (!nzchar(x)) return(list(scheme = NA_character_, value = x, field = NA_character_))

  # Prefixed forms first.
  if (grepl("^RRID:", x, ignore.case = TRUE)) {
    return(list(scheme = "rrid", value = sub("^rrid:", "RRID:", x, ignore.case = TRUE),
                field = "rrid"))
  }
  if (grepl("^(cat#|cat\\.?\\s*no\\.?|catalog(ue)?\\s*(no\\.?|number|#)?)\\s*:?", x, ignore.case = TRUE)) {
    val <- sub("^(cat#|cat\\.?\\s*no\\.?|catalog(ue)?\\s*(no\\.?|number|#)?)\\s*:?\\s*", "",
               x, ignore.case = TRUE)
    return(list(scheme = "catalog", value = trimws(val), field = "catalog_number"))
  }
  if (grepl("^doi:", x, ignore.case = TRUE) ||
      grepl("^https?://(dx\\.)?doi\\.org/", x, ignore.case = TRUE)) {
    return(list(scheme = "doi", value = .strip_doi(x), field = "doi"))
  }
  if (grepl("^https?://orcid\\.org/", x, ignore.case = TRUE)) {
    return(list(scheme = "orcid", value = sub("^https?://orcid\\.org/", "", x, ignore.case = TRUE),
                field = "orcid"))
  }
  if (grepl("^https?://ror\\.org/", x, ignore.case = TRUE)) {
    return(list(scheme = "ror", value = sub("^https?://ror\\.org/", "", x, ignore.case = TRUE),
                field = "affiliation_ror"))
  }
  if (grepl("^PMID:?\\s*", x, ignore.case = TRUE)) {
    return(list(scheme = "pmid", value = sub("^pmid:?\\s*", "", x, ignore.case = TRUE),
                field = "pmid"))
  }

  # Pattern-based classification (order matters: specific before generic URL).
  tests <- list(
    doi = "doi", orcid = "orcid", pmcid = "pmcid",
    geo_series = "accession", geo_sample = "accession", sra = "accession",
    ena = "accession", bioproject = "accession", biosample = "accession",
    ensembl = "accession", chebi = "accession", cellosaurus = "cellosaurus_id",
    ror = "affiliation_ror"
  )
  for (nm in names(tests)) {
    if (grepl(p[[nm]], x, perl = TRUE)) {
      return(list(scheme = nm, value = x, field = tests[[nm]]))
    }
  }
  # A bare RRID authority token without the "RRID:" prefix (e.g. "AB_390204",
  # "SCR_002285"), common in manuscripts and spreadsheets. Cellosaurus CVCL_ is
  # already handled above as `cellosaurus_id`.
  if (grepl("^[A-Za-z]+[_:][-.:A-Za-z0-9]+$", x)) {
    token <- sub("[_:].*$", "", x)
    if (token %in% ref_data("rrid_prefix_map")$token) {
      return(list(scheme = "rrid", value = paste0("RRID:", x), field = "rrid"))
    }
  }
  if (grepl(p$url, x, perl = TRUE)) {
    return(list(scheme = "url", value = x, field = "url"))
  }
  list(scheme = NA_character_, value = x, field = NA_character_)
}

#' Test a string against a bundled identifier pattern.
#'
#' Always uses PCRE (`perl = TRUE`); several bundled patterns use PCRE-only
#' syntax, so this is the single place identifier syntax is checked.
#' @noRd
id_matches <- function(kind, x) {
  pat <- ref_data("id_patterns")[[kind]]
  if (is.null(pat)) return(rep(FALSE, length(x)))
  grepl(pat, x, perl = TRUE)
}

#' @noRd
.strip_doi <- function(x) {
  x <- sub("^doi:", "", x, ignore.case = TRUE)
  x <- sub("^https?://(dx\\.)?doi\\.org/", "", x, ignore.case = TRUE)
  trimws(x)
}

#' Resource type implied by an RRID
#'
#' @param rrid An RRID string (with or without the `RRID:` prefix).
#' @return The implied resource type (character) or `NA` if the authority is
#'   unknown.
#' @export
#' @examples
#' rrid_type("RRID:AB_390204")
#' rrid_type("CVCL_0063")
rrid_type <- function(rrid) {
  x <- sub("^RRID:", "", as.character(rrid), ignore.case = TRUE)
  token <- sub("[_:].*$", "", x)
  map <- ref_data("rrid_prefix_map")
  i <- match(token, map$token)
  if (is.na(i)) return(NA_character_)
  map$resource_type[i]
}

#' Parse a compound identifier string into typed fields
#'
#' Splits an ASAP-style `IDENTIFIER` value (parts joined by `;` or newlines)
#' and classifies each part into a resource field.
#'
#' @param str A compound identifier string.
#' @return A named list of fields (e.g. `catalog_number`, `rrid`, `doi`,
#'   `accession`, `url`), plus `other` for unclassified parts.
#' @export
#' @examples
#' parse_compound_identifier("Cat# AB152; RRID:AB_390204")
parse_compound_identifier <- function(str) {
  if (is.null(str) || !nzchar(trimws(as.character(str)))) return(list())
  parts <- trimws(unlist(strsplit(as.character(str), "[;\n]+")))
  parts <- parts[nzchar(parts)]
  out <- list()
  other <- character(0)
  # A compound IDENTIFIER lives on a resource, so only fields that exist on a
  # resource record are stored; contributor-level tokens (ORCID, ROR) are kept
  # verbatim in `other` rather than dropped into a phantom field.
  res_fields <- names(all_fields())
  for (part in parts) {
    pr <- id_parse(part)
    if (!is.na(pr$field) && pr$field %in% res_fields) {
      out[[pr$field]] <- c(out[[pr$field]], pr$value)
      next
    }
    # "Label: value" form (e.g. "GEO Accession #: GSE12345"): parse the value.
    if (is.na(pr$field) && grepl(":", part)) {
      val <- trimws(sub("^[^:]*:\\s*", "", part))
      if (nzchar(val) && !identical(val, part)) {
        pr2 <- id_parse(val)
        if (!is.na(pr2$field) && pr2$field %in% res_fields) {
          out[[pr2$field]] <- c(out[[pr2$field]], pr2$value)
          next
        }
      }
    }
    other <- c(other, part)
  }
  # Collapse single-valued fields to scalars; keep accession as a vector.
  for (nm in names(out)) {
    if (nm != "accession" && length(out[[nm]]) == 1L) out[[nm]] <- out[[nm]][[1]]
  }
  if (length(other)) out$other <- other
  out
}

#' Compose a compound identifier string from a resource's typed fields
#'
#' @param resource A `krt_resource` (or a named list of fields).
#' @param order Optional character vector giving the field order; defaults to a
#'   sensible canonical order.
#' @return A single `"; "`-joined identifier string.
#' @export
#' @examples
#' r <- new_resource("Antibody", "Anti-TH", catalog_number = "AB152",
#'                   rrid = "RRID:AB_390204", new_or_reuse = "reuse")
#' compose_identifier(r)
compose_identifier <- function(resource, order = NULL) {
  as_rrid <- function(v) paste0("RRID:", sub("^\\s*RRID:\\s*", "", v, ignore.case = TRUE))
  fmt <- list(
    catalog_number = function(v) paste0("Cat# ", v),
    rrid           = as_rrid,
    # A Cellosaurus id is a cell-line RRID; render it so a CVCL-only cell line
    # still produces a non-empty ASAP IDENTIFIER.
    cellosaurus_id = as_rrid,
    doi            = function(v) paste0("https://doi.org/", .strip_doi(v)),
    # Join with "; " (what parse_compound_identifier splits on) so multiple
    # accessions round-trip back to separate values.
    accession      = function(v) paste(v, collapse = "; "),
    pmid           = function(v) paste0("PMID: ", v),
    pmcid          = function(v) v,
    url            = function(v) v
  )
  ord <- order %||% c("catalog_number", "rrid", "cellosaurus_id", "doi",
                      "accession", "pmid", "pmcid", "url")
  parts <- character(0)
  for (nm in ord) {
    v <- resource[[nm]]
    if (is.null(v) || !length(v) || all(!nzchar(as.character(v)))) next
    f <- fmt[[nm]] %||% function(v) as.character(v)
    parts <- c(parts, f(v))
  }
  # Drop duplicates so a resource carrying the same CVCL in both `rrid` and
  # `cellosaurus_id` yields a single RRID entry.
  paste(unique(parts), collapse = "; ")
}

#' Is a value the ASAP "identifier pending" placeholder?
#'
#' @param str A candidate identifier string.
#' @return `TRUE` if the string matches the "Identifier from ... pending"
#'   convention.
#' @export
#' @examples
#' is_pending_identifier("Identifier from Cellosaurus pending")
is_pending_identifier <- function(str) {
  if (is.null(str) || !length(str)) return(FALSE)
  any(grepl("identifier\\s+from\\s+.+\\s+pending", as.character(str),
            ignore.case = TRUE))
}
