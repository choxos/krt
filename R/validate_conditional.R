# Conditional validation packs: rules that apply only when a table contains
# certain resource types. These enforce a minimal, honestly scoped set of
# checks (cell-line authentication and mycoplasma, organism metadata,
# ethics/consent for human material); they are not full ICLAC or ARRIVE
# assessments, which require manuscript-level information a KRT does not hold.

#' @noRd
.pred_has_type <- function(type) {
  function(x) any(vapply(x$resources, function(r) identical(r$resource_type, type),
                         logical(1)))
}

#' @noRd
.is_human_resource <- function(r) {
  # Normalize the taxon id to its numeric core so "9606", "NCBI:txid9606", and
  # "NCBITaxon:9606" all match; match the organism on whole words so
  # "humanized" (an animal model) does not count as human material.
  tid <- gsub("[^0-9]", "", as.character(r$taxon_id %||% ""))
  if (identical(tid, "9606")) return(TRUE)
  org <- tolower(paste(r$organism %||% "", collapse = " "))
  grepl("\\bhomo sapiens\\b", org) || grepl("\\bhuman\\b", org)
}

#' @noRd
.pred_has_human_material <- function(x) {
  # Flag only resources explicitly derived from humans (organism or taxon
  # 9606), rather than assuming every biological sample is human.
  any(vapply(x$resources, .is_human_resource, logical(1)))
}

#' @noRd
.has_valid_consent <- function(x) {
  any(vapply(x$approvals, function(a) {
    is_ethics <- tolower(a$approval_type %||% "") %in%
      c("irb", "reb", "ethics", "consent")
    if (!is_ethics) return(FALSE)
    if (isFALSE(a$consent_obtained)) return(FALSE)   # explicit refusal never counts
    # Require an explicit consent decision: consent obtained, or a recorded
    # waiver/exemption. A bare consent_scope no longer counts on its own.
    isTRUE(a$consent_obtained) ||
      tolower(trimws(a$consent_scope %||% "")) %in%
        c("waiver", "waived", "exempt", "exemption", "not applicable", "n/a")
  }, logical(1)))
}

#' @noRd
.is_animal_resource <- function(r) {
  # A conservative list of common regulated laboratory animals, so animal-ethics
  # approval is not demanded for a plant or microbial organism/strain resource.
  org <- tolower(paste(r$organism %||% "", collapse = " "))
  animal_terms <- c("mus musculus", "mouse", "mice", "murine", "rat", "rattus",
    "rabbit", "oryctolagus", "zebrafish", "danio", "drosophila", "fruit fly",
    "caenorhabditis", "c. elegans", "xenopus", "frog", "macaque", "monkey",
    "primate", "pig", "sus scrofa", "porcine", "dog", "canis", "cat", "felis",
    "chicken", "gallus", "sheep", "ovis", "cattle", "bovine", "guinea pig",
    "hamster", "ferret", "gerbil", "marmoset")
  any(vapply(animal_terms, function(t) grepl(t, org, fixed = TRUE), logical(1)))
}

#' @noRd
.has_approval_type <- function(x, types) {
  any(vapply(x$approvals, function(a) tolower(a$approval_type %||% "") %in% types,
             logical(1)))
}

#' @noRd
.cond_cellline <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!identical(r$resource_type, "Experimental model: Cell line")) return(NULL)
    issues <- list()
    auth <- tolower(trimws(as.character(r$authentication_method %||% "")))
    if (!nzchar(auth) ||
        auth %in% c("none", "n/a", "na", "not done", "not performed", "no")) {
      issues <- c(issues, list(.issue(
        "Cell line lacks a meaningful authentication method (e.g. STR profiling).",
        id, "authentication_method")))
    }
    myco <- tolower(trimws(as.character(r$mycoplasma_status %||% "")))
    if (!nzchar(myco)) {
      issues <- c(issues, list(.issue("Cell line lacks a mycoplasma status.",
                                       id, "mycoplasma_status")))
    } else if (grepl("positive|contaminat", myco)) {
      issues <- c(issues, list(.issue("Cell line is recorded as mycoplasma-positive.",
                                       id, "mycoplasma_status")))
    } else if (myco %in% c("not tested", "untested", "unknown", "n/a", "na")) {
      issues <- c(issues, list(.issue("Cell line mycoplasma status is untested or unknown.",
                                       id, "mycoplasma_status")))
    }
    if (.has_value(r, "rrid") && !grepl("CVCL_", r$rrid, ignore.case = TRUE)) {
      issues <- c(issues, list(.issue("Cell-line RRID is normally a Cellosaurus 'CVCL_' id.",
                                       id, "rrid")))
    }
    issues
  })
}

#' @noRd
.cond_software <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!identical(r$resource_type, "Software/code")) return(NULL)
    reproducible <- .has_value(r, "repository_url") ||
      (.has_value(r, "rrid") && grepl("SCR_", r$rrid, ignore.case = TRUE)) ||
      (.has_value(r, "version") && .has_value(r, "commit_sha")) ||
      .has_value(r, "doi")
    if (!reproducible) {
      list(.issue(paste("Software lacks a reproducible pointer (repository URL, SCR RRID,",
                        "DOI, or version + commit)."), id, "repository_url"))
    }
  })
}

#' @noRd
.cond_organism <- function(x, ctx) {
  issues <- .for_resources(x, function(r, id) {
    if (!identical(r$resource_type, "Experimental model: Organism/strain")) return(NULL)
    out <- list()
    if (!.has_value(r, "organism")) {
      out <- c(out, list(.issue("Organism/strain resource lacks an organism (species).",
                                id, "organism")))
    }
    if (!.has_value(r, "strain") && !.has_value(r, "taxon_id")) {
      out <- c(out, list(.issue("Organism/strain resource lacks a strain or taxon id.",
                                id, "strain")))
    }
    out
  })
  # Animal ethics approval is only relevant when the organism is a regulated
  # animal, not for plant or microbial strains.
  if (any(vapply(x$resources, .is_animal_resource, logical(1))) &&
      !.has_approval_type(x, c("iacuc", "ethics"))) {
    issues <- c(issues, list(.issue(paste("Table includes an animal model but no animal",
                                          "ethics approval (IACUC/ethics) is recorded."))))
  }
  issues
}

#' @noRd
.cond_ethics <- function(x, ctx) {
  if (.has_valid_consent(x)) return(list())
  list(.issue(paste("Table includes human-derived material but no valid ethics/consent",
                    "approval (IRB/REB/ethics with consent) is recorded.")))
}

#' @noRd
.register_conditional_validators <- function() {
  register_validator("cond-cellline", .cond_cellline, "semantic", "warning",
                     applies = .pred_has_type("Experimental model: Cell line"),
                     standard = "cell-line-auth-minimum")
  register_validator("cond-software", .cond_software, "semantic", "warning",
                     applies = .pred_has_type("Software/code"))
  register_validator("cond-organism", .cond_organism, "semantic", "warning",
                     applies = .pred_has_type("Experimental model: Organism/strain"),
                     standard = "minimal-organism-metadata")
  register_validator("cond-ethics", .cond_ethics, "semantic", "warning",
                     applies = .pred_has_human_material, standard = "ethics")
  invisible()
}
