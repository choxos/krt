# data-raw/01-build-sysdata.R
#
# Build R/sysdata.rda, which bakes the internal reference tables (the single
# object `krt_ref`) into the package. These tables encode public standards and
# registry facts: the KRT controlled vocabularies, RRID authority prefixes,
# identifier syntax patterns, registry/resolver endpoints, a minimal SPDX
# license table, and the default redaction policy.
#
# The tables are authored here from public specifications (they are facts about
# the standards, not code copied from any third party). Run from the package
# root; the output R/sysdata.rda is checked in.
#
# Usage:
#   Rscript data-raw/01-build-sysdata.R

find_pkg_root <- function(start = getwd()) {
  d <- normalizePath(start, mustWork = FALSE)
  repeat {
    if (file.exists(file.path(d, "DESCRIPTION"))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) stop("Could not find package root (DESCRIPTION).")
    d <- parent
  }
}
pkg_root <- find_pkg_root()

## ---------------------------------------------------------------------------
## 1. Controlled vocabularies
## ---------------------------------------------------------------------------
# The 14 ASAP RESOURCE TYPE values (13 concrete types + "Other"), verbatim.
resource_types <- c(
  "Antibody",
  "Bacterial strain",
  "Biological sample",
  "Chemical, peptide, or recombinant protein",
  "Critical commercial assay",
  "Dataset",
  "Experimental model: Cell line",
  "Experimental model: Organism/strain",
  "Oligonucleotide",
  "Other",
  "Protocol",
  "Recombinant DNA",
  "Software/code",
  "Viral vector"
)

controlled_vocab <- list(
  resource_type   = resource_types,
  new_or_reuse    = c("new", "reuse"),
  status          = c("active", "deprecated", "retracted", "problematic", "pending"),
  approval_type   = c("IACUC", "IRB", "REB", "ethics", "biosafety", "consent", "other"),
  role            = c("author", "corresponding_author", "contributor",
                      "principal_investigator", "data_curator", "software_developer"),
  # Redaction level applied to an approval's public visibility.
  redaction_level = c("public", "public-safe", "restricted", "private"),
  # Antibody clonality controlled values (used by conditional validation).
  clonality       = c("monoclonal", "polyclonal", "recombinant monoclonal"),
  mycoplasma      = c("negative", "positive", "not tested")
)

## ---------------------------------------------------------------------------
## 2. RRID authority prefix map
## ---------------------------------------------------------------------------
# Maps the authority token that follows "RRID:" to the resource type it implies.
# Used by the semantic validator to flag prefix / resource-type inconsistency
# and by extraction to infer a resource type from a bare RRID.
rrid_prefix_map <- data.frame(
  token = c("AB", "CVCL", "SCR", "Addgene",
            "IMSR", "MGI", "BDSC", "FlyBase", "FB", "ZFIN", "RGD", "WB",
            "SGD", "MMRRC", "CGC", "NXR", "SAMN"),
  authority = c(
    "Antibody Registry", "Cellosaurus", "SciCrunch Registry", "Addgene",
    "International Mouse Strain Resource", "Mouse Genome Informatics",
    "Bloomington Drosophila Stock Center", "FlyBase", "FlyBase",
    "Zebrafish Information Network", "Rat Genome Database", "WormBase",
    "Saccharomyces Genome Database", "Mutant Mouse Resource and Research Centers",
    "Caenorhabditis Genetics Center", "Xenopus Resource", "BioSample"),
  resource_type = c(
    "Antibody", "Experimental model: Cell line", "Software/code",
    "Recombinant DNA",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Experimental model: Organism/strain", "Experimental model: Organism/strain",
    "Biological sample"),
  stringsAsFactors = FALSE
)

## ---------------------------------------------------------------------------
## 3. Identifier syntax patterns (PCRE-compatible regular expressions)
## ---------------------------------------------------------------------------
id_patterns <- list(
  doi         = "^10\\.[0-9]{4,9}/[-._;()/:A-Za-z0-9%]+$",
  orcid       = "^(?:https?://orcid\\.org/)?[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$",
  ror         = "^(?:https?://ror\\.org/)?0[0-9a-hjkmnp-z]{6}[0-9]{2}$",
  pmid        = "^[0-9]{1,9}$",
  pmcid       = "^PMC[0-9]+$",
  rrid        = "^RRID:[A-Za-z0-9]+[_:][-.:A-Za-z0-9]+$",
  url         = "^https?://[^ ]+$",
  geo_series  = "^GSE[0-9]+$",
  geo_sample  = "^GSM[0-9]+$",
  sra         = "^SR[RXPSA][0-9]+$",
  ena         = "^ER[RXPSA][0-9]+$",
  bioproject  = "^PRJ[A-Z]{2}[0-9]+$",
  biosample   = "^SAM[NED][A-Z]?[0-9]+$",
  pdb         = "^[0-9][A-Za-z0-9]{3}$",
  uniprot     = "^(?:[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9](?:[A-Z][A-Z0-9]{2}[0-9]){1,2})$",
  ensembl     = "^ENS[A-Z]*[GTP][0-9]{11}$",
  addgene     = "^[0-9]{3,7}$",
  cellosaurus = "^CVCL_[A-Z0-9]{4}$",
  taxonomy    = "^(?:NCBI:txid)?[0-9]+$",
  chebi       = "^CHEBI:[0-9]+$",
  catalog     = "^[A-Za-z0-9][-A-Za-z0-9._/ ]*$"
)

## ---------------------------------------------------------------------------
## 4. Registry / resolver endpoints
## ---------------------------------------------------------------------------
resolver_endpoints <- list(
  doi              = "https://doi.org/",
  datacite         = "https://api.datacite.org/dois/",
  crossref         = "https://api.crossref.org/works/",
  orcid_pub        = "https://pub.orcid.org/v3.0/",
  orcid_token      = "https://orcid.org/oauth/token",
  rrid             = "https://scicrunch.org/resolver/",
  n2t              = "https://n2t.net/",
  ror              = "https://api.ror.org/organizations/",
  cellosaurus      = "https://api.cellosaurus.org/cell-line/",
  ncbi_eutils      = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/",
  ols              = "https://www.ebi.ac.uk/ols4/api/",
  europepmc        = "https://www.ebi.ac.uk/europepmc/webservices/rest/",
  biorxiv          = "https://api.biorxiv.org/",
  zenodo           = "https://zenodo.org/api/",
  zenodo_sandbox   = "https://sandbox.zenodo.org/api/",
  figshare         = "https://api.figshare.com/v2/",
  figshare_sandbox = "https://api.figsh.com/v2/",
  protocolsio      = "https://www.protocols.io/api/v3/"
)

## ---------------------------------------------------------------------------
## 5. Minimal SPDX license table (for krt_audit_licenses())
## ---------------------------------------------------------------------------
spdx_min <- data.frame(
  id = c("GPL-3.0-only", "GPL-3.0-or-later", "CC-BY-4.0", "CC0-1.0",
         "MIT", "Apache-2.0"),
  name = c("GNU General Public License v3.0 only",
           "GNU General Public License v3.0 or later",
           "Creative Commons Attribution 4.0 International",
           "Creative Commons Zero v1.0 Universal",
           "MIT License", "Apache License 2.0"),
  url = c("https://spdx.org/licenses/GPL-3.0-only.html",
          "https://spdx.org/licenses/GPL-3.0-or-later.html",
          "https://spdx.org/licenses/CC-BY-4.0.html",
          "https://spdx.org/licenses/CC0-1.0.html",
          "https://spdx.org/licenses/MIT.html",
          "https://spdx.org/licenses/Apache-2.0.html"),
  osi_approved = c(TRUE, TRUE, FALSE, FALSE, TRUE, TRUE),
  attribution_required = c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

## ---------------------------------------------------------------------------
## 6. Default redaction policy
## ---------------------------------------------------------------------------
# `level` is the lowest redaction strength at which the field is removed from a
# public export: fields tagged "basic" are removed at both "basic" and "strict";
# fields tagged "strict" are removed only at "strict".
redaction_policy <- data.frame(
  scope = c("approval", "approval", "approval", "approval", "approval",
            "approval", "approval", "approval", "approval",
            "resource", "resource", "resource"),
  field = c("protocol_number", "board_name", "institution_name",
            "institution_ror", "approved_on", "jurisdiction", "consent_scope",
            "data_use_restrictions", "consent_obtained",
            "lot_number", "batch_number", "notes"),
  level = c("basic", "basic", "basic", "basic", "basic", "basic", "basic",
            "basic", "basic",
            "basic", "basic", "basic"),
  action = c("drop", "drop", "drop", "drop", "drop", "generalize", "generalize",
             "generalize", "drop",
             "drop", "drop", "generalize"),
  stringsAsFactors = FALSE
)

## ---------------------------------------------------------------------------
## Assemble + save
## ---------------------------------------------------------------------------
krt_ref <- list(
  schema_version     = "1.0.0",
  controlled_vocab   = controlled_vocab,
  rrid_prefix_map    = rrid_prefix_map,
  id_patterns        = id_patterns,
  resolver_endpoints = resolver_endpoints,
  spdx_min           = spdx_min,
  redaction_policy   = redaction_policy,
  provenance         = list(
    built_on       = as.character(Sys.Date()),
    schema_version = "1.0.0",
    asap_source    = list(
      title   = "ASAP Key Resource Table resources",
      creator = "Aligning Science Across Parkinson's",
      doi     = "10.5281/zenodo.17917979",
      version = "8",
      license = "CC-BY-4.0"
    )
  )
)

out_file <- file.path(pkg_root, "R", "sysdata.rda")
save(krt_ref, file = out_file, compress = "xz", version = 2)

message(sprintf("Wrote %s (%s)", out_file,
                format(structure(file.size(out_file), class = "object_size"),
                       units = "auto")))
message(sprintf("  resource types: %d | rrid prefixes: %d | id patterns: %d | endpoints: %d",
                length(resource_types), nrow(rrid_prefix_map),
                length(id_patterns), length(resolver_endpoints)))
