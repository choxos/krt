# Structural validation: schema conformance decidable from the table alone,
# offline. Each rule is `function(x, ctx)` returning a list of issues.

.identifier_fields <- c("rrid", "doi", "catalog_number", "accession", "url",
                        "pmid", "pmcid", "cellosaurus_id")

# Iterate resources, collecting issues; `f(r, id)` returns a list of issues.
#' @noRd
.for_resources <- function(x, f) {
  out <- list()
  for (r in x$resources) {
    issues <- f(r, r$resource_id %||% NA_character_)
    if (length(issues)) out <- c(out, issues)
  }
  out
}

#' @noRd
.has_value <- function(r, field) {
  v <- r[[field]]
  if (is.null(v) || !length(v)) return(FALSE)
  v <- trimws(as.character(v))
  any(!is.na(v) & nzchar(v))
}

#' @noRd
.vs_missing_name <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "display_name") && !.has_value(r, "canonical_name")) {
      list(.issue("Resource has no display_name.", id, "display_name"))
    }
  })
}

#' @noRd
.vs_missing_new_reuse <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!.has_value(r, "new_or_reuse")) {
      list(.issue("Resource has no new_or_reuse value.", id, "new_or_reuse"))
    }
  })
}

#' @noRd
.vs_new_reuse_vocab <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (.has_value(r, "new_or_reuse") &&
        !(tolower(r$new_or_reuse) %in% krt_new_or_reuse())) {
      list(.issue(sprintf("new_or_reuse '%s' is not 'new' or 'reuse'.", r$new_or_reuse),
                  id, "new_or_reuse"))
    }
  })
}

#' @noRd
.vs_resource_type_vocab <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    if (!(r$resource_type %in% krt_resource_types())) {
      m <- vocab_match(r$resource_type %||% "", "resource_type", fuzzy = TRUE)
      list(.issue(sprintf("resource_type '%s' is not one of the 14 KRT types.",
                          r$resource_type %||% ""), id, "resource_type",
                  suggestion = m$suggestion))
    }
  })
}

#' @noRd
.vs_missing_identifier <- function(x, ctx) {
  .for_resources(x, function(r, id) {
    has_id <- any(vapply(.identifier_fields, function(f) .has_value(r, f), logical(1)))
    pending <- any(vapply(r, function(v) is_pending_identifier(v), logical(1)))
    if (!has_id && !pending) {
      list(.issue("Resource has no persistent identifier (and none marked pending).",
                  id, "identifier"))
    }
  })
}

#' @noRd
.vs_id_syntax <- function(x, ctx) {
  checks <- list(doi = "doi", rrid = "rrid", pmid = "pmid", pmcid = "pmcid")
  .for_resources(x, function(r, id) {
    issues <- list()
    for (fld in names(checks)) {
      if (.has_value(r, fld)) {
        vals <- as.character(r[[fld]])
        bad <- vals[!id_matches(checks[[fld]], vals)]
        for (b in bad) {
          issues <- c(issues, list(.issue(
            sprintf("%s value '%s' is not syntactically valid.", fld, b), id, fld)))
        }
      }
    }
    issues
  })
}

#' @noRd
.vs_unknown_field <- function(x, ctx) {
  known <- c(names(all_fields()), "other")
  .for_resources(x, function(r, id) {
    unk <- setdiff(names(r), known)
    if (length(unk)) {
      list(.issue(sprintf("Unknown field(s): %s.", paste(unk, collapse = ", ")),
                  id, paste(unk, collapse = ",")))
    }
  })
}

#' @noRd
.vs_field_applicability <- function(x, ctx) {
  # Compute the field registry and type list once, not per resource.
  field_names <- names(all_fields())
  types <- krt_resource_types()
  .for_resources(x, function(r, id) {
    if (!(r$resource_type %in% types)) return(NULL)
    allowed <- fields_for_type(r$resource_type)
    present <- intersect(names(r), field_names)
    off <- setdiff(present, c(allowed, "resource_id"))
    if (length(off)) {
      list(.issue(sprintf("Field(s) not typical for %s: %s.",
                          r$resource_type, paste(off, collapse = ", ")),
                  id, paste(off, collapse = ",")))
    }
  })
}

#' @noRd
.vs_enum <- function(x, ctx) {
  # Enforce every declared enum field against its controlled vocabulary. The
  # resource_type and new_or_reuse enums have dedicated error-level rules, so
  # they are skipped here to avoid duplicate findings.
  covered <- c("resource_type", "new_or_reuse")
  enum_fields <- Filter(function(d) !is.null(d$enum) && !(d$name %in% covered),
                        all_fields())
  .for_resources(x, function(r, id) {
    issues <- list()
    for (d in enum_fields) {
      if (!.has_value(r, d$name)) next
      val <- as.character(r[[d$name]])
      if (!isTRUE(vocab_match(val, d$enum, fuzzy = FALSE)$ok)) {
        issues <- c(issues, list(.issue(sprintf(
          "Field '%s' value '%s' is not an allowed %s value.", d$name, val, d$enum),
          id, d$name)))
      }
    }
    issues
  })
}

#' @noRd
.register_structural_validators <- function() {
  register_validator("struct-missing-name", .vs_missing_name, "structural", "error")
  register_validator("struct-missing-new-reuse", .vs_missing_new_reuse, "structural", "error")
  register_validator("struct-new-reuse-vocab", .vs_new_reuse_vocab, "structural", "error")
  register_validator("struct-resource-type-vocab", .vs_resource_type_vocab, "structural", "error")
  register_validator("struct-enum-vocab", .vs_enum, "structural", "warning")
  register_validator("struct-missing-identifier", .vs_missing_identifier, "structural", "warning")
  register_validator("struct-id-syntax", .vs_id_syntax, "structural", "warning")
  register_validator("struct-unknown-field", .vs_unknown_field, "structural", "note")
  register_validator("struct-field-applicability", .vs_field_applicability, "structural", "note")
  invisible()
}
