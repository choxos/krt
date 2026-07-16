# Deposit a KRT to a repository and mint a DOI. Network-gated; tokens come from
# the environment or are passed explicitly and are sent as headers (never in the
# URL). Deposits default to the redacted public audience. Never run during CRAN
# checks.

#' @noRd
.deposit_metadata <- function(x, metadata) {
  metadata %||% list(
    title = x$title %||% "Key Resources Table",
    upload_type = "dataset",
    description = "A Key Resources Table deposited with the krt R package.",
    creators = list(list(name = "Unknown")))
}

#' Deposit a KRT to Zenodo
#'
#' Creates a Zenodo deposition, uploads the table as JSON, sets metadata, and
#' optionally publishes. The minted (pre-reserved) DOI is written back into the
#' table's provenance and `table_id`. Deposits default to the redacted public
#' audience, since a deposit is a shared artifact.
#'
#' @param x A [krt_tbl].
#' @param token Zenodo access token (defaults to `ZENODO_TOKEN`).
#' @param sandbox Use the Zenodo sandbox (default `TRUE`).
#' @param metadata Optional Zenodo metadata list (a sensible default otherwise).
#' @param publish Whether to publish immediately (default `FALSE`).
#' @param audience `"public"` (redacted, the default) or `"author"` (full).
#' @param timeout Request timeout in seconds.
#' @return A list with `deposit` (the API response), `doi`, and `x` (the table
#'   with the DOI recorded). On failure, `deposit` is `NULL`.
#' @export
#' @examples
#' \dontrun{
#' res <- krt_deposit_zenodo(krt_example, sandbox = TRUE)
#' res$doi
#' }
krt_deposit_zenodo <- function(x, token = Sys.getenv("ZENODO_TOKEN"),
                               sandbox = TRUE, metadata = NULL, publish = FALSE,
                               audience = c("public", "author"), timeout = 60) {
  stopifnot(is_krt(x))
  if (!nzchar(token)) {
    stop("A Zenodo token is required (set ZENODO_TOKEN or pass token=).", call. = FALSE)
  }
  x <- .maybe_redact(x, match.arg(audience), NULL)
  base <- endpoint(if (isTRUE(sandbox)) "zenodo_sandbox" else "zenodo")

  j <- .resp_json(http_post_json(paste0(base, "deposit/depositions"),
                                 body = stats::setNames(list(), character(0)),
                                 token = token, timeout = timeout))
  if (is.null(j)) { warning("Zenodo deposition could not be created.", call. = FALSE)
    return(list(deposit = NULL, doi = NA_character_, x = x)) }
  dep_id <- .dig(j, "id")
  bucket <- .dig(j, "links", "bucket")
  doi <- .dig(j, "metadata", "prereserve_doi", "doi") %||% NA_character_

  if (!is.null(bucket)) {
    http_put_bytes(paste0(bucket, "/key-resources-table.json"),
                   data = write_krt_json(x), type = "application/json",
                   token = token, timeout = timeout)
  }
  http_put_json(paste0(base, "deposit/depositions/", dep_id),
                body = list(metadata = .deposit_metadata(x, metadata)),
                token = token, timeout = timeout)
  if (isTRUE(publish)) {
    http_post_json(paste0(base, "deposit/depositions/", dep_id, "/actions/publish"),
                   body = stats::setNames(list(), character(0)), token = token,
                   timeout = timeout)
  }
  x <- append_provenance(x, "deposit", params = list(repository = "zenodo",
                                                     doi = doi, sandbox = sandbox))
  if (!is.na(doi)) x$table_id <- doi
  list(deposit = j, doi = doi, x = x)
}

#' @noRd
.figshare_upload <- function(base, article_id, data, hdr, timeout) {
  md5 <- digest::digest(data, algo = "md5", serialize = FALSE)
  size <- nchar(data, type = "bytes")
  # 1. announce the file
  f <- .resp_json(http_post_json(
    sprintf("%saccount/articles/%s/files", base, article_id),
    body = list(name = "key-resources-table.json", md5 = md5, size = size),
    headers = hdr, timeout = timeout))
  loc <- .dig(f, "location")
  if (is.null(loc)) return(FALSE)
  # 2. get the upload URL and part layout
  info <- .resp_json(http_get(loc, headers = hdr, timeout = timeout))
  up <- .dig(info, "upload_url")
  if (is.null(up)) return(FALSE)
  parts <- .dig(.resp_json(http_get(up, headers = hdr, timeout = timeout)), "parts")
  # 3. upload each part (a single small part in practice)
  raw <- charToRaw(data)
  for (p in parts %||% list(list(partNo = 1L, startOffset = 0L, endOffset = size - 1L))) {
    s <- (.dig(p, "startOffset") %||% 0L) + 1L
    e <- (.dig(p, "endOffset") %||% (size - 1L)) + 1L
    http_put_bytes(sprintf("%s/%s", up, .dig(p, "partNo") %||% 1L),
                   data = rawToChar(raw[s:e]), headers = hdr, timeout = timeout)
  }
  # 4. complete
  http_post_json(loc, body = stats::setNames(list(), character(0)),
                 headers = hdr, timeout = timeout)
  TRUE
}

#' Deposit a KRT to Figshare
#'
#' Creates a Figshare article, reserves a DOI, and uploads the table as JSON.
#' The DOI is recorded in the table's provenance. Deposits default to the
#' redacted public audience.
#'
#' @param x A [krt_tbl].
#' @param token Figshare token (defaults to `FIGSHARE_TOKEN`).
#' @param sandbox Use the Figshare sandbox (default `TRUE`).
#' @param metadata Optional article metadata.
#' @param audience `"public"` (redacted, the default) or `"author"` (full).
#' @param timeout Request timeout in seconds.
#' @return A list with `article` (the API response), `doi`, `uploaded`
#'   (logical), and `x`.
#' @export
#' @examples
#' \dontrun{
#' krt_deposit_figshare(krt_example)
#' }
krt_deposit_figshare <- function(x, token = Sys.getenv("FIGSHARE_TOKEN"),
                                 sandbox = TRUE, metadata = NULL,
                                 audience = c("public", "author"), timeout = 60) {
  stopifnot(is_krt(x))
  if (!nzchar(token)) {
    stop("A Figshare token is required (set FIGSHARE_TOKEN or pass token=).", call. = FALSE)
  }
  x <- .maybe_redact(x, match.arg(audience), NULL)
  base <- endpoint(if (isTRUE(sandbox)) "figshare_sandbox" else "figshare")
  hdr <- list(Authorization = paste("token", token))
  meta <- metadata %||% list(title = x$title %||% "Key Resources Table",
                             description = "Deposited with the krt R package.",
                             defined_type = "dataset")
  j <- .resp_json(http_post_json(paste0(base, "account/articles"), body = meta,
                                 headers = hdr, timeout = timeout))
  article_id <- .dig(j, "entity_id") %||% sub(".*/", "", .dig(j, "location") %||% "")
  if (is.null(j) || !nzchar(article_id)) {
    warning("Figshare article could not be created.", call. = FALSE)
    return(list(article = NULL, doi = NA_character_, uploaded = FALSE, x = x))
  }
  doi <- .dig(.resp_json(http_post_json(
    sprintf("%saccount/articles/%s/reserve_doi", base, article_id),
    body = stats::setNames(list(), character(0)), headers = hdr, timeout = timeout)),
    "doi") %||% NA_character_
  uploaded <- tryCatch(.figshare_upload(base, article_id, write_krt_json(x), hdr, timeout),
                       error = function(e) FALSE)
  x <- append_provenance(x, "deposit", params = list(repository = "figshare",
                                                     doi = doi, sandbox = sandbox))
  if (!is.na(doi)) x$table_id <- doi
  list(article = j, doi = doi, uploaded = isTRUE(uploaded), x = x)
}
