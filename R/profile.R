# Loading a profile directory into a krt_profile object, and its methods.

#' Load a profile from a directory
#'
#' Reads `schema.yml`, `mappings.yml`, and (optionally) `validation.yml`,
#' `provenance.json`, and `ATTRIBUTION.md` from a profile directory.
#'
#' @param path Path to the profile directory.
#' @return A `krt_profile` object.
#' @export
#' @examples
#' p <- load_profile(system.file("extdata", "profiles", "asap", package = "krt"))
#' p$columns
load_profile <- function(path) {
  if (!dir.exists(path)) stop(sprintf("Profile directory not found: %s", path), call. = FALSE)
  schema <- yaml::read_yaml(file.path(path, "schema.yml"))
  read_if <- function(f, fn) { p <- file.path(path, f); if (file.exists(p)) fn(p) else NULL }
  mappings <- read_if("mappings.yml", yaml::read_yaml)
  val <- read_if("validation.yml", yaml::read_yaml)
  prov <- read_if("provenance.json", function(p) jsonlite::fromJSON(p, simplifyVector = TRUE))
  attribution <- read_if("ATTRIBUTION.md", function(p) paste(readLines(p, warn = FALSE), collapse = "\n"))
  template <- file.path(path, "template.xlsx")

  structure(
    list(
      name        = schema$name,
      version     = as.character(schema$version %||% "1.0.0"),
      title       = schema$title,
      description = schema$description,
      license     = schema$license,
      official    = isTRUE(schema$official),
      source      = schema$source,
      resource_types = schema$resource_types,
      passthrough = isTRUE(schema$passthrough) || isTRUE(mappings$passthrough),
      columns     = mappings$columns %||% schema$columns,
      mappings    = mappings$mappings,
      sections    = mappings$sections,
      validation_overrides = val$overrides %||% list(),
      template_path = if (file.exists(template)) template else NULL,
      attribution = attribution,
      provenance  = prov,
      path        = path
    ),
    class = "krt_profile"
  )
}

#' @rdname load_profile
#' @param x An object to test.
#' @export
is_profile <- function(x) inherits(x, "krt_profile")

#' Describe a profile
#'
#' @param name A profile name or a `krt_profile`.
#' @return The `krt_profile` (invisibly); prints a human-readable summary
#'   including its license and redistribution status.
#' @export
#' @examples
#' krt_profile_info("asap")
krt_profile_info <- function(name) {
  p <- get_profile(name)
  print(p)
  invisible(p)
}

#' @export
format.krt_profile <- function(x, ...) {
  redist <- if (!is.null(x$license) && grepl("CC-BY|CC0|MIT|Apache|GPL", x$license)) "yes" else "profile rules only"
  lines <- c(
    sprintf("<krt_profile> %s (v%s)", x$name, x$version %||% "?"),
    sprintf("  %s", x$title %||% ""),
    sprintf("  license: %s | redistributable assets: %s | officially endorsed: %s",
            x$license %||% "unspecified", redist, if (isTRUE(x$official)) "yes" else "no"),
    if (!is.null(x$columns)) sprintf("  columns: %s", paste(x$columns, collapse = ", ")),
    if (isTRUE(x$passthrough)) "  columns: (passthrough: full core view)",
    if (!is.null(x$source$doi)) sprintf("  source: %s (doi:%s)", x$source$creator %||% "", x$source$doi)
  )
  paste(Filter(Negate(is.null), lines), collapse = "\n")
}

#' @export
print.krt_profile <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
  invisible(x)
}
