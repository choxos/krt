# Registry of output profiles. Built-in profiles are discovered under
# inst/extdata/profiles in .onLoad; third parties register their own with
# register_profile() (the plugin SDK).

.profile_registry <- new.env(parent = emptyenv())
.profile_cache <- new.env(parent = emptyenv())

#' Register an output profile
#'
#' @param name Profile name. If omitted, taken from the profile's `schema.yml`
#'   or the supplied object.
#' @param path Path to a profile directory containing `schema.yml` and
#'   `mappings.yml` (loaded lazily), or `NULL`.
#' @param profile A pre-built `krt_profile` object, or `NULL`.
#' @return Invisibly the profile name.
#' @export
#' @examples
#' krt_profiles()
register_profile <- function(name = NULL, path = NULL, profile = NULL) {
  if (!is.null(profile)) {
    name <- name %||% profile$name
    .profile_cache[[name]] <- profile
  } else if (!is.null(path)) {
    if (is.null(name)) {
      schema <- yaml::read_yaml(file.path(path, "schema.yml"))
      name <- schema$name
    }
    .profile_registry[[name]] <- list(path = path)
  } else {
    stop("Provide either `path` or `profile`.", call. = FALSE)
  }
  invisible(name)
}

#' Retrieve a registered profile
#'
#' @param name Profile name.
#' @return A `krt_profile` object.
#' @export
#' @examples
#' get_profile("asap")$columns
get_profile <- function(name) {
  if (inherits(name, "krt_profile")) return(name)
  if (!is.null(.profile_cache[[name]])) return(.profile_cache[[name]])
  reg <- .profile_registry[[name]]
  if (is.null(reg)) {
    stop(sprintf("Unknown profile '%s'. See krt_profiles().", name), call. = FALSE)
  }
  p <- load_profile(reg$path)
  .profile_cache[[name]] <- p
  p
}

#' List available profiles
#'
#' @return A data frame with one row per registered profile (name, title,
#'   license, whether it is officially endorsed).
#' @export
#' @examples
#' krt_profiles()
krt_profiles <- function() {
  names <- union(ls(.profile_registry), ls(.profile_cache))
  if (!length(names)) {
    return(data.frame(name = character(0), title = character(0),
                      license = character(0), official = logical(0),
                      stringsAsFactors = FALSE))
  }
  rows <- lapply(sort(names), function(nm) {
    p <- tryCatch(get_profile(nm), error = function(e) NULL)
    data.frame(name = nm, title = p$title %||% NA_character_,
               license = p$license %||% NA_character_,
               official = isTRUE(p$official), stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

# Discover and register the bundled profiles. Called from .onLoad.
#' @noRd
.register_builtin_profiles <- function() {
  root <- system.file("extdata", "profiles", package = "krt")
  if (!nzchar(root) || !dir.exists(root)) return(invisible())
  for (d in list.dirs(root, recursive = FALSE)) {
    nm <- basename(d)
    tryCatch(register_profile(name = nm, path = d),
             error = function(e) NULL)
  }
  invisible()
}
