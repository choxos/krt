# Conditional validation packs: rules that apply only when a table contains
# certain resource types, enforcing reporting standards (ICLAC cell-line
# authentication, ARRIVE 2.0 for animals, ethics/consent for human material).

#' @noRd
.pred_has_type <- function(type) {
  function(x) any(vapply(x$resources, function(r) identical(r$resource_type, type),
                         logical(1)))
}

#' @noRd
.is_human_resource <- function(r) {
  identical(r$taxon_id, "9606") ||
    grepl("human|homo sapiens", tolower(paste(r$organism %||% "")))
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
    isTRUE(a$consent_obtained) || !is.null(a$consent_scope)
  }, logical(1)))
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
    if (!.has_value(r, "authentication_method")) {
      issues <- c(issues, list(.issue("Cell line lacks an authentication method (e.g. STR).",
                                       id, "authentication_method")))
    }
    if (!.has_value(r, "mycoplasma_status")) {
      issues <- c(issues, list(.issue("Cell line lacks a mycoplasma status.",
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
.cond_arrive <- function(x, ctx) {
  issues <- .for_resources(x, function(r, id) {
    if (!identical(r$resource_type, "Experimental model: Organism/strain")) return(NULL)
    out <- list()
    if (!.has_value(r, "organism")) {
      out <- c(out, list(.issue("Animal model lacks an organism (species).", id, "organism")))
    }
    if (!.has_value(r, "strain") && !.has_value(r, "taxon_id")) {
      out <- c(out, list(.issue("Animal model lacks a strain or taxon id.", id, "strain")))
    }
    out
  })
  if (.pred_has_type("Experimental model: Organism/strain")(x) &&
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
                     standard = "ICLAC")
  register_validator("cond-software", .cond_software, "semantic", "warning",
                     applies = .pred_has_type("Software/code"))
  register_validator("cond-arrive", .cond_arrive, "semantic", "warning",
                     applies = .pred_has_type("Experimental model: Organism/strain"),
                     standard = "ARRIVE-2.0 (subset)")
  register_validator("cond-ethics", .cond_ethics, "semantic", "warning",
                     applies = .pred_has_human_material, standard = "ethics")
  invisible()
}
