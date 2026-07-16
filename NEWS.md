# krt 0.1.0

First release.

## Core

- A neutral, typed core object ([new_krt()], [add_resource()], [new_resource()])
  storing resources as present-only records, with the 14 ASAP resource types and
  identifiers kept in their own typed fields.
- Lossless canonical serialization to JSON and YAML; CSV, Excel, ASAP, RIS, and
  BibTeX are computed views that emit explicit lossy-export warnings.
- A rectangular-view coercion ([as.data.frame()][as.data.frame.krt_tbl]) and a
  `tibble` method.

## Validation

- A registry-driven validation engine with structural and semantic layers and
  conditional packs for cell lines (ICLAC), animals (ARRIVE 2.0 subset),
  software reproducibility, and human-subject ethics/consent.
- Per-profile severity overrides; duplicate detection.

## Identifiers

- Identifier parsing, normalization, and composition; resolvers for RRID, DOI,
  ORCID, PubMed, ROR, and Cellosaurus, all offline-first and graceful.
- Ontology and registry autocomplete ([krt_suggest()]).

## Profiles and licensing

- A profile registry (`generic`, `asap`, `star-methods`, and custom) with
  programmatic license and attribution introspection ([krt_audit_licenses()]).
- The bundled ASAP profile assets are CC BY 4.0 (from Zenodo
  doi:10.5281/zenodo.17917979); package code is GPL-3.

## Sharing

- Redaction of ethics and consent metadata by default for public exports, on
  every export and render path.
- Manuscript extraction (regex and optional LLM) from PDF, JATS, DOCX, and text.
- Provenance recording with W3C PROV-JSON and RO-Crate export.
- Deposit to Zenodo and Figshare; connectors for eLabFTW and protocols.io.
- Merge and diff for multi-author workflows.

## Interfaces and extension

- A command-line interface, a Shiny editor ([launch_krt()]), and an RStudio
  addin.
- A plugin SDK ([krt_plugin_api()]) and a Bioconductor-friendly S4 adapter.
- Internationalization scaffolding (`po/`) with example French and Spanish
  catalogs.
