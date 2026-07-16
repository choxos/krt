# Bioconductor-friendly S4 adapter. S3 remains the primary interface; this file
# provides an S4 `KRT` class and coercions so the package composes with
# Bioconductor workflows. `methods` is a base-distributed Imports dependency;
# the optional S4Vectors coercion stays a gated Suggest.

#' The `KRT` S4 class
#'
#' An S4 wrapper around a [krt_tbl], for interoperability with Bioconductor.
#' Convert with `as(x, "KRT")` and `as(y, "krt_tbl")`, or [as_krt()].
#'
#' @slot schema_version,profile,table_id,title Character metadata.
#' @slot resources,approvals,contributors,provenance Record lists.
#' @slot metadata A list of remaining metadata (study type, locale, timestamps).
#' @name KRT-class
#' @exportClass KRT
#' @examples
#' k4 <- methods::as(krt_example, "KRT")
#' methods::is(k4, "KRT")
# Register the S3 classes with S4 so coercions can name them.
methods::setOldClass("krt_tbl")
methods::setOldClass("krt_resource")

methods::setClass("KRT",
  representation(schema_version = "character", profile = "character",
                 table_id = "character", title = "character",
                 resources = "list", approvals = "list",
                 contributors = "list", provenance = "list",
                 metadata = "list"),
  prototype(schema_version = "1.0.0", profile = "generic", title = character(0)))

methods::setAs("krt_tbl", "KRT", function(from) {
  methods::new("KRT",
    schema_version = from$schema_version %||% "1.0.0",
    profile = from$profile %||% "generic",
    table_id = from$table_id %||% "",
    title = from$title %||% character(0),
    resources = from$resources, approvals = from$approvals,
    contributors = from$contributors, provenance = from$provenance,
    metadata = list(study_type = from$study_type, locale = from$locale,
                    created_at = from$created_at, updated_at = from$updated_at,
                    validation = from$validation))
})

methods::setAs("KRT", "krt_tbl", function(from) {
  k <- new_krt(title = if (length(from@title)) from@title else NULL,
               profile = from@profile)
  k$schema_version <- from@schema_version
  k$table_id <- from@table_id
  k$resources <- from@resources
  k$approvals <- from@approvals
  k$contributors <- from@contributors
  k$provenance <- from@provenance
  m <- from@metadata
  k$study_type <- m$study_type %||% character(0)
  k$locale <- m$locale
  k$created_at <- m$created_at %||% k$created_at
  k$updated_at <- m$updated_at %||% k$updated_at
  k$validation <- m$validation %||% list()
  k
})

#' Coerce to and from the S4 `KRT` class
#'
#' These are inverse coercions named after their target class. `as_krt()`
#' returns the S3 [krt_tbl] (the package's primary object): pass it a `krt_tbl`
#' and it is returned unchanged, or an S4 `KRT` and it is converted down. It is
#' the helper to call when a function should accept either representation.
#' `as_KRT()` is the opposite direction, a thin idempotent wrapper over
#' `methods::as(x, "KRT")` for Bioconductor workflows.
#'
#' @param x A [krt_tbl] or `KRT` object.
#' @return `as_krt()` returns a `krt_tbl`; `as_KRT()` returns an S4 `KRT`.
#' @export
#' @examples
#' k4 <- as_KRT(krt_example)
#' identical(length(as_krt(k4)$resources), length(krt_example$resources))
as_krt <- function(x) {
  if (is_krt(x)) return(x)
  if (methods::is(x, "KRT")) return(methods::as(x, "krt_tbl"))
  stop("Cannot coerce object of class ", paste(class(x), collapse = "/"),
       " to krt_tbl.", call. = FALSE)
}

#' @rdname as_krt
#' @export
as_KRT <- function(x) {
  if (methods::is(x, "KRT")) return(x)
  if (is_krt(x)) return(methods::as(x, "KRT"))
  stop("Cannot coerce object of class ", paste(class(x), collapse = "/"),
       " to KRT.", call. = FALSE)
}

#' Coerce a KRT's resources to a DataFrame (Bioconductor)
#'
#' @param x A [krt_tbl].
#' @param view The view to project (default `"wide"`).
#' @return An `S4Vectors::DataFrame` of the resources (requires the `S4Vectors`
#'   package).
#' @export
#' @examples
#' if (requireNamespace("S4Vectors", quietly = TRUE)) krt_as_dataframe(krt_example)
krt_as_dataframe <- function(x, view = "wide") {
  stopifnot(is_krt(x))
  need_pkg("S4Vectors", "coercion to a Bioconductor DataFrame")
  S4Vectors::DataFrame(as.data.frame(x, view = view), check.names = FALSE)
}
