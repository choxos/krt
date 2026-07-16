# Deterministic manuscript-extraction engine: scan free text for identifiers and
# build candidate resources. Fully offline and the default extraction engine.

#' @noRd
.scan <- function(text, pattern, group = 1L) {
  text <- paste(text, collapse = "\n")
  hits <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
  if (!length(hits)) return(character(0))
  if (group == 0L) return(hits)
  caps <- regmatches(hits, regexec(pattern, hits, perl = TRUE))
  out <- vapply(caps, function(c) if (length(c) >= group + 1L) c[group + 1L] else NA_character_,
                character(1))
  out[!is.na(out) & nzchar(out)]
}

#' Scan free text for research identifiers
#'
#' Finds RRIDs, DOIs, catalog numbers, database accessions, ORCIDs, and PMIDs in
#' a block of text and classifies each. Used by the regex extraction engine and
#' available on its own.
#'
#' @param text A character vector of text.
#' @return A data frame with columns `value`, `field`, `type` (an inferred
#'   resource type, or `NA`), and `confidence` (`"high"` for precisely anchored
#'   schemes such as RRID/DOI/accession/PMID, `"medium"` for looser catalog-number
#'   matches) so the results can be triaged before acceptance.
#' @export
#' @examples
#' scan_identifiers("We used anti-TH (RRID:AB_390204) and FIJI (RRID:SCR_002285).")
scan_identifiers <- function(text) {
  rows <- list()
  add <- function(values, field, type = NA_character_) {
    conf <- if (field == "catalog_number") "medium" else "high"
    for (v in unique(values)) {
      ty <- if (field == "rrid") { t <- rrid_type(v); if (is.na(t)) type else t } else type
      rows[[length(rows) + 1L]] <<- data.frame(value = v, field = field,
                                               type = ty %||% NA_character_,
                                               confidence = conf,
                                               stringsAsFactors = FALSE)
    }
  }
  add(sub("[.,;)]+$", "", .scan(text, "RRID:\\s?([A-Za-z]+[_:][-.:A-Za-z0-9]+)")), "rrid")
  add(sub("[.,;)]+$", "", .scan(text, "\\b(10\\.[0-9]{4,9}/[-._;()/:A-Za-z0-9]+)")),
      "doi", "Dataset")
  add(.scan(text, "Cat(?:alog)?(?:ue)?\\s*(?:no\\.?|number|#)\\s*:?\\s*([A-Za-z0-9][-A-Za-z0-9._/]{1,})",
            group = 1L), "catalog_number")
  add(.scan(text, "\\b(GSE[0-9]+|GSM[0-9]+|SR[RXPSA][0-9]+|ER[RXPSA][0-9]+|PRJ[A-Z]{2}[0-9]+|SAM[NED][A-Z]?[0-9]+)\\b",
            group = 1L), "accession", "Dataset")
  add(.scan(text, "Addgene\\s*(?:plasmid\\s*)?#?\\s*([0-9]{3,7})", group = 1L),
      "catalog_number", "Recombinant DNA")
  add(.scan(text, "PMID:?\\s*([0-9]{1,9})", group = 1L), "pmid", "Other")
  if (!length(rows)) {
    return(data.frame(value = character(0), field = character(0),
                      type = character(0), confidence = character(0),
                      stringsAsFactors = FALSE))
  }
  df <- do.call(rbind, rows)
  df[!duplicated(paste(df$field, df$value)), , drop = FALSE]
}

#' Extract candidate resources from text (regex engine)
#'
#' @param text A character vector of manuscript text.
#' @return A list of `krt_resource` candidates.
#' @export
#' @examples
#' cand <- extract_candidates("Anti-TH (RRID:AB_390204); FIJI (RRID:SCR_002285)")
#' length(cand)
extract_candidates <- function(text) {
  ids <- scan_identifiers(text)
  if (!nrow(ids)) return(list())
  # Anchor a resource on each RRID, accession, and standalone DOI.
  anchors <- ids[ids$field %in% c("rrid", "accession", "doi"), , drop = FALSE]
  resources <- list()
  seen <- character(0)
  for (i in seq_len(nrow(anchors))) {
    a <- anchors[i, ]
    if (a$value %in% seen) next
    seen <- c(seen, a$value)
    type <- if (!is.na(a$type)) a$type else "Other"
    args <- list(type, display_name = a$value, new_or_reuse = "reuse")
    args[[a$field]] <- a$value
    resources[[length(resources) + 1L]] <- tryCatch(do.call(new_resource, args),
                                                     error = function(e) NULL)
  }
  Filter(Negate(is.null), resources)
}
