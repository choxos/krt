# Semantic validation: cross-field and world-knowledge checks. Prefix/type
# consistency is treated as a soft signal (some authorities span several types).

#' @noRd
.sem_rrid_type <- function(x, ctx) {
  # Authorities that legitimately span more than their primary type.
  allow <- list(
    SCR = c("Software/code", "Dataset", "Protocol", "Other"),
    Addgene = c("Recombinant DNA", "Viral vector"))
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "rrid")) return(NULL)
    token <- sub("[_:].*$", "", sub("^RRID:", "", r$rrid, ignore.case = TRUE))
    expected <- rrid_type(r$rrid)
    if (is.na(expected)) return(NULL)
    ok_types <- unique(c(expected, allow[[token]]))
    if (!(r$resource_type %in% ok_types)) {
      list(.issue(sprintf("RRID %s implies type '%s' but resource_type is '%s'.",
                          r$rrid, expected, r$resource_type), id, "rrid"))
    }
  })
}

#' @noRd
.sem_catalog_in_rrid <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "rrid")) return(NULL)
    if (!id_matches("rrid", norm_rrid(r$rrid))) {
      list(.issue(sprintf("rrid value '%s' does not look like an RRID (a catalog number?).",
                          r$rrid), id, "rrid"))
    }
  })
}

#' @noRd
.sem_doi_form <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "doi")) return(NULL)
    if (grepl("doi\\.org|^doi:", tolower(r$doi))) {
      list(.issue("doi is not in normalized bare form; run normalize_ids().",
                  id, "doi", suggestion = norm_doi(r$doi)))
    }
  })
}

#' @noRd
.sem_pending_id <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    hit <- names(r)[vapply(r, function(v) is_pending_identifier(v), logical(1))]
    if (length(hit)) {
      list(.issue("Identifier is marked pending; replace with a persistent id when available.",
                  id, hit[1]))
    }
  })
}

#' @noRd
.sem_cellosaurus_consistency <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "cellosaurus_id") || !.has_value(r, "rrid")) return(NULL)
    if (!grepl("CVCL_", r$rrid, ignore.case = TRUE)) return(NULL)
    rrid_cvcl <- toupper(sub("^RRID:", "", r$rrid, ignore.case = TRUE))
    if (!identical(rrid_cvcl, toupper(r$cellosaurus_id))) {
      list(.issue(sprintf("cellosaurus_id '%s' does not match the CVCL RRID '%s'.",
                          r$cellosaurus_id, r$rrid), id, "cellosaurus_id"))
    }
  })
}

#' @noRd
.sem_software_rrid <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!identical(r$resource_type, "Software/code") || !.has_value(r, "rrid")) return(NULL)
    if (!grepl("^RRID:SCR_", r$rrid, ignore.case = TRUE)) {
      list(.issue("Software RRIDs are normally SciCrunch 'SCR_' identifiers.", id, "rrid"))
    }
  })
}

#' @noRd
.sem_id_exists <- function(x, ctx) {
  if (!isTRUE(ctx$resolve)) return(list())
  .for_resources(x, function(r, id) {
    issues <- list()
    if (.has_value(r, "rrid")) {
      res <- tryCatch(resolve_rrid(r$rrid, resolve = TRUE), error = function(e) NULL)
      if (!is.null(res) && !isTRUE(res$resolved)) {
        issues <- c(issues, list(.issue(sprintf("RRID %s did not resolve.", r$rrid),
                                         id, "rrid")))
      }
    }
    if (.has_value(r, "doi")) {
      res <- tryCatch(resolve_doi(r$doi, resolve = TRUE), error = function(e) NULL)
      if (!is.null(res) && !isTRUE(res$resolved)) {
        issues <- c(issues, list(.issue(sprintf("DOI %s did not resolve.", r$doi),
                                         id, "doi")))
      }
    }
    issues
  })
}

#' @noRd
.sem_duplicates <- function(x, ctx) {
  groups <- find_duplicates(x)
  lapply(groups, function(g) {
    .issue(sprintf("Duplicate resources share an identity signature: %s.",
                   paste(g, collapse = ", ")), g[1], "resource_id")
  })
}

#' @noRd
.register_semantic_validators <- function() {
  register_validator("sem-rrid-type", .sem_rrid_type, "semantic", "warning")
  register_validator("sem-catalog-in-rrid", .sem_catalog_in_rrid, "semantic", "warning")
  register_validator("sem-doi-form", .sem_doi_form, "semantic", "note")
  register_validator("sem-pending-id", .sem_pending_id, "semantic", "note")
  register_validator("sem-cellosaurus-consistency", .sem_cellosaurus_consistency,
                     "semantic", "warning")
  register_validator("sem-software-rrid", .sem_software_rrid, "semantic", "note")
  register_validator("sem-duplicates", .sem_duplicates, "semantic", "warning")
  register_validator("sem-id-exists", .sem_id_exists, "semantic", "note")
  invisible()
}
