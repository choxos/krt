# Projecting core records onto a profile's output columns. Columns are declared
# in mappings.yml as direct (a core field or ordered fallback), composed (the
# compound IDENTIFIER), transform (value-mapped), or catchall (folded free text).

#' @noRd
.first_nonempty <- function(resource, fields) {
  for (f in fields) {
    v <- resource[[f]]
    if (!is.null(v) && length(v) && any(nzchar(as.character(v)))) {
      return(paste(as.character(v), collapse = "; "))
    }
  }
  ""
}

#' @noRd
.apply_catchall <- function(resource, include) {
  parts <- character(0)
  for (f in include) {
    v <- resource[[f]]
    if (is.null(v) || !length(v) || !any(nzchar(as.character(v)))) next
    val <- paste(as.character(v), collapse = ", ")
    parts <- c(parts, if (identical(f, "notes")) val else sprintf("%s: %s", field_label(f), val))
  }
  paste(parts, collapse = "; ")
}

#' @noRd
.apply_col <- function(resource, spec) {
  if (is.null(spec)) return("")
  switch(spec$type %||% "direct",
    direct = .first_nonempty(resource, as.character(spec$field)),
    composed = compose_identifier(resource, order = as.character(spec$compose)),
    catchall = .apply_catchall(resource, as.character(spec$include)),
    transform = {
      v <- .first_nonempty(resource, as.character(spec$field))
      m <- spec$map
      if (!is.null(m) && !is.null(m[[v]])) as.character(m[[v]]) else v
    },
    "")
}

#' Map one resource to a profile's columns
#'
#' @param resource A `krt_resource`.
#' @param profile A `krt_profile` or profile name.
#' @return A named list of column values.
#' @export
#' @examples
#' r <- new_resource("Antibody", "Anti-TH", vendor = "Millipore",
#'                   catalog_number = "AB152", rrid = "RRID:AB_390204",
#'                   new_or_reuse = "reuse")
#' apply_mapping(r, "asap")[["IDENTIFIER"]]
apply_mapping <- function(resource, profile) {
  p <- get_profile(profile)
  if (isTRUE(p$passthrough)) return(as.list(unclass(resource)))
  out <- lapply(p$columns, function(col) .apply_col(resource, p$mappings[[col]]))
  stats::setNames(out, p$columns)
}

#' Project a KRT onto a profile as a data frame
#'
#' @param x A [krt_tbl].
#' @param profile A `krt_profile` or profile name.
#' @return A data frame with the profile's columns, one row per resource.
#' @export
#' @examples
#' project_profile(krt_example, "asap")[, c("RESOURCE TYPE", "IDENTIFIER")]
project_profile <- function(x, profile) {
  stopifnot(is_krt(x))
  p <- get_profile(profile)
  if (isTRUE(p$passthrough)) return(as.data.frame(x, view = "wide"))
  cols <- p$columns
  if (!length(x$resources)) {
    df <- as.data.frame(matrix(character(0), ncol = length(cols)),
                        stringsAsFactors = FALSE)
    names(df) <- cols
    return(df)
  }
  rows <- lapply(x$resources, function(r) {
    m <- apply_mapping(r, p)
    vapply(cols, function(cn) as.character(m[[cn]] %||% ""), character(1))
  })
  df <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(df) <- cols
  rownames(df) <- NULL
  df
}

#' Fields lost or folded when projecting to a profile
#'
#' Returns the core fields that are present in the table but are not preserved
#' as their own column by the profile (they are either folded into a free-text
#' catch-all column or dropped). These drive the lossy-export warning.
#'
#' @param x A [krt_tbl].
#' @param profile A `krt_profile` or profile name.
#' @return A character vector of field names (empty for a lossless profile).
#' @export
#' @examples
#' mapping_lossy_fields(krt_example, "asap")
mapping_lossy_fields <- function(x, profile) {
  stopifnot(is_krt(x))
  p <- get_profile(profile)
  if (isTRUE(p$passthrough)) return(character(0))
  preserved <- character(0)
  for (col in p$columns) {
    spec <- p$mappings[[col]]
    if (is.null(spec)) next
    if ((spec$type %||% "direct") %in% c("direct", "transform")) {
      preserved <- c(preserved, as.character(spec$field))
    } else if (identical(spec$type, "composed")) {
      preserved <- c(preserved, as.character(spec$compose))
    }
  }
  present <- setdiff(unique(unlist(lapply(x$resources, names))), "resource_type")
  # resource_type is always carried by the RESOURCE TYPE column, so it is never
  # lost. resource_id, by contrast, has no column in a profile like ASAP, so it
  # IS dropped and must be reported (a reimport cannot restore the same id).
  preserved <- unique(c(preserved, "resource_type"))
  setdiff(present, preserved)
}
