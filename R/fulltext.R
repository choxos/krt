# Fetch manuscript full text from public sources for extraction. Network-gated;
# returns NULL offline or on failure.

#' @noRd
.resp_text <- function(resp) {
  if (is.null(resp) || httr2::resp_status(resp) >= 400L) return(NULL)
  tryCatch(httr2::resp_body_string(resp), error = function(e) NULL)
}

#' Fetch manuscript full text
#'
#' Retrieves full text (JATS XML where available) from Europe PMC or bioRxiv, for
#' feeding into [extract_krt()]. Returns `NULL` offline or when the text is not
#' openly available.
#'
#' @param id A PMCID, DOI, or bioRxiv DOI.
#' @param source `"auto"`, `"europepmc"`, or `"biorxiv"`.
#' @param timeout Request timeout in seconds.
#' @return A character string of the full text or abstract, or `NULL`.
#' @export
#' @examples
#' \dontrun{
#' # Contacts Europe PMC / bioRxiv; not run on CRAN.
#' txt <- fetch_fulltext("PMC5334499")
#' }
fetch_fulltext <- function(id, source = c("auto", "europepmc", "biorxiv"),
                           timeout = 30) {
  source <- match.arg(source)
  if (identical(source, "auto")) {
    source <- if (grepl("^PMC", id)) "europepmc"
              else if (grepl("^10\\.1101/", id)) "biorxiv"
              else "europepmc"
  }
  if (identical(source, "europepmc")) {
    pmcid <- sub("^PMC", "", id)
    txt <- .resp_text(http_get(
      sprintf("%sPMC/PMC%s/fullTextXML", endpoint("europepmc"), pmcid),
      accept = "application/xml", timeout = timeout))
    return(txt)
  }
  # bioRxiv: return the abstract from the details API (full JATS needs the
  # requester-pays S3 bucket, which is out of scope for an unauthenticated call).
  j <- .resp_json(http_get(sprintf("%sdetails/biorxiv/%s", endpoint("biorxiv"), id),
                           timeout = timeout))
  as.character(.dig(j, "collection", 1L, "abstract") %||% NULL)
}
