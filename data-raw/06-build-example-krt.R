# data-raw/06-build-example-krt.R
#
# Build data/krt_example.rda: a small, fictional Key Resources Table spanning
# several resource types, used for offline examples, tests, and vignettes.
# Identifiers are real, publicly resolvable examples.
#
# Usage (from the package root):
#   Rscript data-raw/06-build-example-krt.R

devtools::load_all(quiet = TRUE)

krt_example <- new_krt(
  title = "Example dopaminergic neuron study",
  study_type = c("wet-lab", "computational"),
  locale = "en-US"
)

krt_example <- add_resource(
  krt_example, "Antibody", "Rabbit Anti-TH",
  vendor = "Millipore", source_name = "Millipore", catalog_number = "AB152",
  rrid = "RRID:AB_390204", antibody_host = "Rabbit",
  antibody_clonality = "polyclonal", target = "Tyrosine hydroxylase",
  new_or_reuse = "reuse", notes = "Dilution 1:500"
)

krt_example <- add_resource(
  krt_example, "Experimental model: Cell line", "HEK293T",
  vendor = "ATCC", source_name = "ATCC", catalog_number = "CRL-3216",
  rrid = "RRID:CVCL_0063", cellosaurus_id = "CVCL_0063",
  authentication_method = "STR", authentication_date = "2026-01-20",
  mycoplasma_status = "negative", organism = "Homo sapiens",
  taxon_id = "9606", new_or_reuse = "reuse"
)

krt_example <- add_resource(
  krt_example, "Software/code", "Fiji",
  version = "2.14.0", source_name = "NIH", url = "https://imagej.net/software/fiji/",
  rrid = "RRID:SCR_002285", language = "Java", new_or_reuse = "reuse"
)

krt_example <- add_resource(
  krt_example, "Dataset", "Processed RNA-seq counts",
  source_name = "Zenodo", doi = "10.5281/zenodo.11111111",
  new_or_reuse = "new", notes = "Tabular data underlying Figure 2A."
)

krt_example <- add_resource(
  krt_example, "Experimental model: Organism/strain", "C57BL/6J mice",
  source_name = "The Jackson Laboratory", rrid = "RRID:IMSR_JAX:000664",
  organism = "Mus musculus", taxon_id = "10090", strain = "C57BL/6J",
  new_or_reuse = "reuse"
)

krt_example <- add_resource(
  krt_example, "Protocol", "Immunohistochemistry protocol",
  source_name = "protocols.io", doi = "10.17504/protocols.io.abcde123",
  new_or_reuse = "new"
)

# Governance approvals so the example is a complete, validation-clean KRT.
krt_example <- add_approval(
  krt_example, "IACUC", protocol_number = "IACUC-2026-017",
  board_name = "Example University IACUC", approved_on = "2026-01-05",
  jurisdiction = "US"
)

krt_example <- add_approval(
  krt_example, "IRB", protocol_number = "IRB-2026-004",
  board_name = "Example University IRB", consent_obtained = TRUE,
  consent_scope = "study-specific", approved_on = "2026-01-05"
)

krt_example <- add_contributor(
  krt_example, "Ada Researcher", orcid = "0000-0002-1825-0097",
  role = "corresponding_author", affiliation = "Example University",
  affiliation_ror = "05xpvk416"
)

# Freeze timestamps and clear provenance so the bundled object is reproducible
# across rebuilds (the build time would otherwise vary).
krt_example$created_at <- "2026-01-01T00:00:00Z"
krt_example$updated_at <- "2026-01-01T00:00:00Z"
krt_example$provenance <- list()

usethis::use_data(krt_example, overwrite = TRUE, compress = "xz")
message(sprintf("Wrote data/krt_example.rda with %d resources.",
                length(krt_example$resources)))
