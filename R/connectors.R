# Connectors to electronic lab notebooks and protocol repositories. Opt-in and
# token-based; network-gated and never run during CRAN checks.

#' @noRd
.strip_html <- function(s) trimws(gsub("\\s+", " ", gsub("<[^>]+>", " ", s %||% "")))

#' Import resources from an eLabFTW experiment
#'
#' Fetches an experiment and extracts candidate resources from its body text.
#'
#' @param base_url The eLabFTW instance base URL (e.g. `https://elab.example.org`).
#' @param experiment_id The experiment id.
#' @param token API token (defaults to `ELABFTW_TOKEN`).
#' @param timeout Request timeout in seconds.
#' @return A [krt_tbl] of extracted resources.
#' @export
#' @examples
#' \dontrun{
#' krt_import_elabftw("https://elab.example.org", experiment_id = 42)
#' }
krt_import_elabftw <- function(base_url, experiment_id,
                               token = Sys.getenv("ELABFTW_TOKEN"), timeout = 30) {
  if (!nzchar(token)) {
    stop("An eLabFTW token is required (set ELABFTW_TOKEN or pass token=).", call. = FALSE)
  }
  url <- sprintf("%s/api/v2/experiments/%s", sub("/$", "", base_url), experiment_id)
  if (!.credential_url_ok(url, TRUE)) {
    stop("Refusing to send an eLabFTW token to a non-HTTPS, non-loopback URL.",
         call. = FALSE)
  }
  j <- .resp_json(http_get(url, headers = list(Authorization = token), timeout = timeout))
  if (is.null(j)) { warning("eLabFTW experiment could not be fetched.", call. = FALSE)
    return(new_krt(profile = "generic")) }
  text <- paste(.strip_html(.dig(j, "body")), .dig(j, "title") %||% "")
  k <- new_krt(title = .dig(j, "title"), profile = "generic")
  for (r in extract_candidates(text)) k <- add_resource(k, r)
  .touch(k, "import", params = list(source = "elabftw", id = experiment_id))
}

#' Import a protocol from protocols.io
#'
#' Fetches a protocol and records it as a Protocol resource.
#'
#' @param id A protocols.io protocol id or DOI.
#' @param token API token (defaults to `PROTOCOLSIO_TOKEN`).
#' @param timeout Request timeout in seconds.
#' @return A [krt_tbl] with a single Protocol resource.
#' @export
#' @examples
#' \dontrun{
#' krt_import_protocolsio("kxygx3w")
#' }
krt_import_protocolsio <- function(id, token = Sys.getenv("PROTOCOLSIO_TOKEN"),
                                   timeout = 30) {
  url <- sprintf("%sprotocols/%s", endpoint("protocolsio"), id)
  j <- .resp_json(http_get(url, token = if (nzchar(token)) token else NULL,
                           timeout = timeout))
  p <- .dig(j, "protocol") %||% j
  if (is.null(p)) { warning("protocols.io protocol could not be fetched.", call. = FALSE)
    return(new_krt(profile = "generic")) }
  k <- new_krt(profile = "generic")
  args <- list("Protocol", display_name = .dig(p, "title") %||% id,
               new_or_reuse = "reuse", source_name = "protocols.io")
  if (!is.null(.dig(p, "doi"))) args$doi <- .dig(p, "doi")
  if (!is.null(.dig(p, "url"))) args$url <- .dig(p, "url")
  k <- add_resource(k, do.call(new_resource, args))
  .touch(k, "import", params = list(source = "protocols.io", id = id))
}
