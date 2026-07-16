#' Launch the interactive KRT editor
#'
#' Starts a Shiny application for importing, editing (in the generic view),
#' validating, normalizing identifiers, and exporting a Key Resources Table.
#' Requires the `shiny`, `bslib`, and `DT` packages.
#'
#' @param ... Passed to [shiny::runApp()].
#' @return Called for its side effect (runs the app).
#' @export
#' @examples
#' if (interactive()) launch_krt()
launch_krt <- function(...) {
  for (p in c("shiny", "bslib", "DT")) need_pkg(p, "the KRT editor")
  app <- system.file("shiny-apps", "krt", package = "krt")
  if (!nzchar(app)) stop("Shiny app not found; reinstall krt.", call. = FALSE)
  shiny::runApp(app, ...)
}
