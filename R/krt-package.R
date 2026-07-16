#' krt: Author, Validate, and Export Key Resources Tables
#'
#' krt is a toolkit for working with Key Resources Tables (KRTs). A KRT lists
#' the resources used and generated in a study (antibodies, cell lines,
#' organisms, chemicals, software, datasets, protocols, and more), each paired
#' with a persistent identifier so that resources are unambiguously identifiable
#' and machine-actionable.
#'
#' The package is built around a neutral, typed core object [krt_tbl] and a
#' registry of output *profiles* (generic, ASAP, STAR Methods, and custom) that
#' the core maps to. The author-facing table is a view; the underlying record
#' set stays structured, typed, and losslessly round-trippable through JSON and
#' YAML.
#'
#' Start with [new_krt()] and [add_resource()], validate with `validate_krt()`,
#' normalize identifiers with `normalize_ids()`, and write output with
#' `export_krt()` or `render_krt()`. See the package vignettes and
#' <https://choxos.github.io/krt/> for details.
#'
#' @keywords internal
"_PACKAGE"
